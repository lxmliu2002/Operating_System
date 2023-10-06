
bin/kernel：     文件格式 elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c020e2b7          	lui	t0,0xc020e
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
ffffffffc0200028:	c020e137          	lui	sp,0xc020e

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

int
kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200036:	000be517          	auipc	a0,0xbe
ffffffffc020003a:	de250513          	addi	a0,a0,-542 # ffffffffc02bde18 <edata>
ffffffffc020003e:	000c9617          	auipc	a2,0xc9
ffffffffc0200042:	3a260613          	addi	a2,a2,930 # ffffffffc02c93e0 <end>
kern_init(void) {
ffffffffc0200046:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200048:	8e09                	sub	a2,a2,a0
ffffffffc020004a:	4581                	li	a1,0
kern_init(void) {
ffffffffc020004c:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004e:	0e8090ef          	jal	ra,ffffffffc0209136 <memset>
    cons_init();                // init the console
ffffffffc0200052:	52e000ef          	jal	ra,ffffffffc0200580 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc0200056:	00009597          	auipc	a1,0x9
ffffffffc020005a:	10a58593          	addi	a1,a1,266 # ffffffffc0209160 <etext>
ffffffffc020005e:	00009517          	auipc	a0,0x9
ffffffffc0200062:	12250513          	addi	a0,a0,290 # ffffffffc0209180 <etext+0x20>
ffffffffc0200066:	12c000ef          	jal	ra,ffffffffc0200192 <cprintf>

    print_kerninfo();
ffffffffc020006a:	1b0000ef          	jal	ra,ffffffffc020021a <print_kerninfo>

    // grade_backtrace();

    pmm_init();                 // init physical memory management
ffffffffc020006e:	5b6020ef          	jal	ra,ffffffffc0202624 <pmm_init>

    pic_init();                 // init interrupt controller
ffffffffc0200072:	5e6000ef          	jal	ra,ffffffffc0200658 <pic_init>
    idt_init();                 // init interrupt descriptor table
ffffffffc0200076:	5e4000ef          	jal	ra,ffffffffc020065a <idt_init>

    vmm_init();                 // init virtual memory management
ffffffffc020007a:	3d8040ef          	jal	ra,ffffffffc0204452 <vmm_init>
    sched_init();
ffffffffc020007e:	12d080ef          	jal	ra,ffffffffc02089aa <sched_init>
    proc_init();                // init process table
ffffffffc0200082:	52b050ef          	jal	ra,ffffffffc0205dac <proc_init>
    
    ide_init();                 // init ide devices
ffffffffc0200086:	56e000ef          	jal	ra,ffffffffc02005f4 <ide_init>
    swap_init();                // init swap
ffffffffc020008a:	2f2030ef          	jal	ra,ffffffffc020337c <swap_init>

    clock_init();               // init clock interrupt
ffffffffc020008e:	4a8000ef          	jal	ra,ffffffffc0200536 <clock_init>
    intr_enable();              // enable irq interrupt
ffffffffc0200092:	5ba000ef          	jal	ra,ffffffffc020064c <intr_enable>

    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    //lab1_switch_test();
    
    cpu_idle();                 // run idle process
ffffffffc0200096:	663050ef          	jal	ra,ffffffffc0205ef8 <cpu_idle>

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
ffffffffc02000b2:	00009517          	auipc	a0,0x9
ffffffffc02000b6:	0d650513          	addi	a0,a0,214 # ffffffffc0209188 <etext+0x28>
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
ffffffffc02000c8:	000beb97          	auipc	s7,0xbe
ffffffffc02000cc:	d50b8b93          	addi	s7,s7,-688 # ffffffffc02bde18 <edata>
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
ffffffffc020012a:	000be517          	auipc	a0,0xbe
ffffffffc020012e:	cee50513          	addi	a0,a0,-786 # ffffffffc02bde18 <edata>
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
ffffffffc0200186:	387080ef          	jal	ra,ffffffffc0208d0c <vprintfmt>
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
ffffffffc0200194:	02810313          	addi	t1,sp,40 # ffffffffc020e028 <boot_page_table_sv39+0x28>
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
ffffffffc02001ba:	353080ef          	jal	ra,ffffffffc0208d0c <vprintfmt>
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
ffffffffc020021c:	00009517          	auipc	a0,0x9
ffffffffc0200220:	fa450513          	addi	a0,a0,-92 # ffffffffc02091c0 <etext+0x60>
void print_kerninfo(void) {
ffffffffc0200224:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200226:	f6dff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc020022a:	00000597          	auipc	a1,0x0
ffffffffc020022e:	e0c58593          	addi	a1,a1,-500 # ffffffffc0200036 <kern_init>
ffffffffc0200232:	00009517          	auipc	a0,0x9
ffffffffc0200236:	fae50513          	addi	a0,a0,-82 # ffffffffc02091e0 <etext+0x80>
ffffffffc020023a:	f59ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc020023e:	00009597          	auipc	a1,0x9
ffffffffc0200242:	f2258593          	addi	a1,a1,-222 # ffffffffc0209160 <etext>
ffffffffc0200246:	00009517          	auipc	a0,0x9
ffffffffc020024a:	fba50513          	addi	a0,a0,-70 # ffffffffc0209200 <etext+0xa0>
ffffffffc020024e:	f45ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc0200252:	000be597          	auipc	a1,0xbe
ffffffffc0200256:	bc658593          	addi	a1,a1,-1082 # ffffffffc02bde18 <edata>
ffffffffc020025a:	00009517          	auipc	a0,0x9
ffffffffc020025e:	fc650513          	addi	a0,a0,-58 # ffffffffc0209220 <etext+0xc0>
ffffffffc0200262:	f31ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc0200266:	000c9597          	auipc	a1,0xc9
ffffffffc020026a:	17a58593          	addi	a1,a1,378 # ffffffffc02c93e0 <end>
ffffffffc020026e:	00009517          	auipc	a0,0x9
ffffffffc0200272:	fd250513          	addi	a0,a0,-46 # ffffffffc0209240 <etext+0xe0>
ffffffffc0200276:	f1dff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc020027a:	000c9597          	auipc	a1,0xc9
ffffffffc020027e:	56558593          	addi	a1,a1,1381 # ffffffffc02c97df <end+0x3ff>
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
ffffffffc020029c:	00009517          	auipc	a0,0x9
ffffffffc02002a0:	fc450513          	addi	a0,a0,-60 # ffffffffc0209260 <etext+0x100>
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
    panic("Not Implemented!");
ffffffffc02002ac:	00009617          	auipc	a2,0x9
ffffffffc02002b0:	ee460613          	addi	a2,a2,-284 # ffffffffc0209190 <etext+0x30>
ffffffffc02002b4:	04d00593          	li	a1,77
ffffffffc02002b8:	00009517          	auipc	a0,0x9
ffffffffc02002bc:	ef050513          	addi	a0,a0,-272 # ffffffffc02091a8 <etext+0x48>
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
ffffffffc02002c8:	00009617          	auipc	a2,0x9
ffffffffc02002cc:	0a860613          	addi	a2,a2,168 # ffffffffc0209370 <commands+0xe0>
ffffffffc02002d0:	00009597          	auipc	a1,0x9
ffffffffc02002d4:	0c058593          	addi	a1,a1,192 # ffffffffc0209390 <commands+0x100>
ffffffffc02002d8:	00009517          	auipc	a0,0x9
ffffffffc02002dc:	0c050513          	addi	a0,a0,192 # ffffffffc0209398 <commands+0x108>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002e0:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02002e2:	eb1ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
ffffffffc02002e6:	00009617          	auipc	a2,0x9
ffffffffc02002ea:	0c260613          	addi	a2,a2,194 # ffffffffc02093a8 <commands+0x118>
ffffffffc02002ee:	00009597          	auipc	a1,0x9
ffffffffc02002f2:	0e258593          	addi	a1,a1,226 # ffffffffc02093d0 <commands+0x140>
ffffffffc02002f6:	00009517          	auipc	a0,0x9
ffffffffc02002fa:	0a250513          	addi	a0,a0,162 # ffffffffc0209398 <commands+0x108>
ffffffffc02002fe:	e95ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
ffffffffc0200302:	00009617          	auipc	a2,0x9
ffffffffc0200306:	0de60613          	addi	a2,a2,222 # ffffffffc02093e0 <commands+0x150>
ffffffffc020030a:	00009597          	auipc	a1,0x9
ffffffffc020030e:	0f658593          	addi	a1,a1,246 # ffffffffc0209400 <commands+0x170>
ffffffffc0200312:	00009517          	auipc	a0,0x9
ffffffffc0200316:	08650513          	addi	a0,a0,134 # ffffffffc0209398 <commands+0x108>
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
ffffffffc020034c:	00009517          	auipc	a0,0x9
ffffffffc0200350:	f8c50513          	addi	a0,a0,-116 # ffffffffc02092d8 <commands+0x48>
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
ffffffffc020036e:	00009517          	auipc	a0,0x9
ffffffffc0200372:	f9250513          	addi	a0,a0,-110 # ffffffffc0209300 <commands+0x70>
ffffffffc0200376:	e1dff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    if (tf != NULL) {
ffffffffc020037a:	000c0563          	beqz	s8,ffffffffc0200384 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc020037e:	8562                	mv	a0,s8
ffffffffc0200380:	4c2000ef          	jal	ra,ffffffffc0200842 <print_trapframe>
ffffffffc0200384:	00009c97          	auipc	s9,0x9
ffffffffc0200388:	f0cc8c93          	addi	s9,s9,-244 # ffffffffc0209290 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc020038c:	00009997          	auipc	s3,0x9
ffffffffc0200390:	f9c98993          	addi	s3,s3,-100 # ffffffffc0209328 <commands+0x98>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200394:	00009917          	auipc	s2,0x9
ffffffffc0200398:	f9c90913          	addi	s2,s2,-100 # ffffffffc0209330 <commands+0xa0>
        if (argc == MAXARGS - 1) {
ffffffffc020039c:	4a3d                	li	s4,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc020039e:	00009b17          	auipc	s6,0x9
ffffffffc02003a2:	f9ab0b13          	addi	s6,s6,-102 # ffffffffc0209338 <commands+0xa8>
    if (argc == 0) {
ffffffffc02003a6:	00009a97          	auipc	s5,0x9
ffffffffc02003aa:	feaa8a93          	addi	s5,s5,-22 # ffffffffc0209390 <commands+0x100>
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
ffffffffc02003c4:	555080ef          	jal	ra,ffffffffc0209118 <strchr>
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
ffffffffc02003da:	00009d17          	auipc	s10,0x9
ffffffffc02003de:	eb6d0d13          	addi	s10,s10,-330 # ffffffffc0209290 <commands>
    if (argc == 0) {
ffffffffc02003e2:	8556                	mv	a0,s5
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003e4:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003e6:	0d61                	addi	s10,s10,24
ffffffffc02003e8:	507080ef          	jal	ra,ffffffffc02090ee <strcmp>
ffffffffc02003ec:	c919                	beqz	a0,ffffffffc0200402 <kmonitor+0xbc>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003ee:	2405                	addiw	s0,s0,1
ffffffffc02003f0:	09740463          	beq	s0,s7,ffffffffc0200478 <kmonitor+0x132>
ffffffffc02003f4:	000d3503          	ld	a0,0(s10)
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003f8:	6582                	ld	a1,0(sp)
ffffffffc02003fa:	0d61                	addi	s10,s10,24
ffffffffc02003fc:	4f3080ef          	jal	ra,ffffffffc02090ee <strcmp>
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
ffffffffc0200462:	4b7080ef          	jal	ra,ffffffffc0209118 <strchr>
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
ffffffffc020047a:	00009517          	auipc	a0,0x9
ffffffffc020047e:	ede50513          	addi	a0,a0,-290 # ffffffffc0209358 <commands+0xc8>
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
ffffffffc0200488:	000c9317          	auipc	t1,0xc9
ffffffffc020048c:	dc830313          	addi	t1,t1,-568 # ffffffffc02c9250 <is_panic>
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
ffffffffc02004ac:	000c9717          	auipc	a4,0xc9
ffffffffc02004b0:	daf73223          	sd	a5,-604(a4) # ffffffffc02c9250 <is_panic>

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02004b4:	862e                	mv	a2,a1
    va_start(ap, fmt);
ffffffffc02004b6:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02004b8:	85aa                	mv	a1,a0
ffffffffc02004ba:	00009517          	auipc	a0,0x9
ffffffffc02004be:	f5650513          	addi	a0,a0,-170 # ffffffffc0209410 <commands+0x180>
    va_start(ap, fmt);
ffffffffc02004c2:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02004c4:	ccfff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    vcprintf(fmt, ap);
ffffffffc02004c8:	65a2                	ld	a1,8(sp)
ffffffffc02004ca:	8522                	mv	a0,s0
ffffffffc02004cc:	ca7ff0ef          	jal	ra,ffffffffc0200172 <vcprintf>
    cprintf("\n");
ffffffffc02004d0:	0000a517          	auipc	a0,0xa
ffffffffc02004d4:	ef850513          	addi	a0,a0,-264 # ffffffffc020a3c8 <default_pmm_manager+0x530>
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
ffffffffc0200502:	00009517          	auipc	a0,0x9
ffffffffc0200506:	f2e50513          	addi	a0,a0,-210 # ffffffffc0209430 <commands+0x1a0>
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
ffffffffc0200522:	0000a517          	auipc	a0,0xa
ffffffffc0200526:	ea650513          	addi	a0,a0,-346 # ffffffffc020a3c8 <default_pmm_manager+0x530>
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
ffffffffc0200544:	6a078793          	addi	a5,a5,1696 # 186a0 <_binary_obj___user_matrix_out_size+0xcc38>
ffffffffc0200548:	953e                	add	a0,a0,a5
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc020054a:	4581                	li	a1,0
ffffffffc020054c:	4601                	li	a2,0
ffffffffc020054e:	4881                	li	a7,0
ffffffffc0200550:	00000073          	ecall
    cprintf("++ setup timer interrupts\n");
ffffffffc0200554:	00009517          	auipc	a0,0x9
ffffffffc0200558:	efc50513          	addi	a0,a0,-260 # ffffffffc0209450 <commands+0x1c0>
    ticks = 0;
ffffffffc020055c:	000c9797          	auipc	a5,0xc9
ffffffffc0200560:	d407ba23          	sd	zero,-684(a5) # ffffffffc02c92b0 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc0200564:	c2fff06f          	j	ffffffffc0200192 <cprintf>

ffffffffc0200568 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200568:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020056c:	67e1                	lui	a5,0x18
ffffffffc020056e:	6a078793          	addi	a5,a5,1696 # 186a0 <_binary_obj___user_matrix_out_size+0xcc38>
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
ffffffffc0200602:	000be797          	auipc	a5,0xbe
ffffffffc0200606:	c1678793          	addi	a5,a5,-1002 # ffffffffc02be218 <ide>
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
ffffffffc020061a:	32f080ef          	jal	ra,ffffffffc0209148 <memcpy>
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
ffffffffc020062c:	000be517          	auipc	a0,0xbe
ffffffffc0200630:	bec50513          	addi	a0,a0,-1044 # ffffffffc02be218 <ide>
                   size_t nsecs) {
ffffffffc0200634:	1141                	addi	sp,sp,-16
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200636:	00969613          	slli	a2,a3,0x9
ffffffffc020063a:	85ba                	mv	a1,a4
ffffffffc020063c:	953e                	add	a0,a0,a5
                   size_t nsecs) {
ffffffffc020063e:	e406                	sd	ra,8(sp)
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200640:	309080ef          	jal	ra,ffffffffc0209148 <memcpy>
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
ffffffffc0200662:	67278793          	addi	a5,a5,1650 # ffffffffc0200cd0 <__alltraps>
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
ffffffffc020067c:	00009517          	auipc	a0,0x9
ffffffffc0200680:	11c50513          	addi	a0,a0,284 # ffffffffc0209798 <commands+0x508>
void print_regs(struct pushregs* gpr) {
ffffffffc0200684:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200686:	b0dff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020068a:	640c                	ld	a1,8(s0)
ffffffffc020068c:	00009517          	auipc	a0,0x9
ffffffffc0200690:	12450513          	addi	a0,a0,292 # ffffffffc02097b0 <commands+0x520>
ffffffffc0200694:	affff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc0200698:	680c                	ld	a1,16(s0)
ffffffffc020069a:	00009517          	auipc	a0,0x9
ffffffffc020069e:	12e50513          	addi	a0,a0,302 # ffffffffc02097c8 <commands+0x538>
ffffffffc02006a2:	af1ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02006a6:	6c0c                	ld	a1,24(s0)
ffffffffc02006a8:	00009517          	auipc	a0,0x9
ffffffffc02006ac:	13850513          	addi	a0,a0,312 # ffffffffc02097e0 <commands+0x550>
ffffffffc02006b0:	ae3ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02006b4:	700c                	ld	a1,32(s0)
ffffffffc02006b6:	00009517          	auipc	a0,0x9
ffffffffc02006ba:	14250513          	addi	a0,a0,322 # ffffffffc02097f8 <commands+0x568>
ffffffffc02006be:	ad5ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02006c2:	740c                	ld	a1,40(s0)
ffffffffc02006c4:	00009517          	auipc	a0,0x9
ffffffffc02006c8:	14c50513          	addi	a0,a0,332 # ffffffffc0209810 <commands+0x580>
ffffffffc02006cc:	ac7ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02006d0:	780c                	ld	a1,48(s0)
ffffffffc02006d2:	00009517          	auipc	a0,0x9
ffffffffc02006d6:	15650513          	addi	a0,a0,342 # ffffffffc0209828 <commands+0x598>
ffffffffc02006da:	ab9ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02006de:	7c0c                	ld	a1,56(s0)
ffffffffc02006e0:	00009517          	auipc	a0,0x9
ffffffffc02006e4:	16050513          	addi	a0,a0,352 # ffffffffc0209840 <commands+0x5b0>
ffffffffc02006e8:	aabff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02006ec:	602c                	ld	a1,64(s0)
ffffffffc02006ee:	00009517          	auipc	a0,0x9
ffffffffc02006f2:	16a50513          	addi	a0,a0,362 # ffffffffc0209858 <commands+0x5c8>
ffffffffc02006f6:	a9dff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02006fa:	642c                	ld	a1,72(s0)
ffffffffc02006fc:	00009517          	auipc	a0,0x9
ffffffffc0200700:	17450513          	addi	a0,a0,372 # ffffffffc0209870 <commands+0x5e0>
ffffffffc0200704:	a8fff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200708:	682c                	ld	a1,80(s0)
ffffffffc020070a:	00009517          	auipc	a0,0x9
ffffffffc020070e:	17e50513          	addi	a0,a0,382 # ffffffffc0209888 <commands+0x5f8>
ffffffffc0200712:	a81ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200716:	6c2c                	ld	a1,88(s0)
ffffffffc0200718:	00009517          	auipc	a0,0x9
ffffffffc020071c:	18850513          	addi	a0,a0,392 # ffffffffc02098a0 <commands+0x610>
ffffffffc0200720:	a73ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200724:	702c                	ld	a1,96(s0)
ffffffffc0200726:	00009517          	auipc	a0,0x9
ffffffffc020072a:	19250513          	addi	a0,a0,402 # ffffffffc02098b8 <commands+0x628>
ffffffffc020072e:	a65ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200732:	742c                	ld	a1,104(s0)
ffffffffc0200734:	00009517          	auipc	a0,0x9
ffffffffc0200738:	19c50513          	addi	a0,a0,412 # ffffffffc02098d0 <commands+0x640>
ffffffffc020073c:	a57ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200740:	782c                	ld	a1,112(s0)
ffffffffc0200742:	00009517          	auipc	a0,0x9
ffffffffc0200746:	1a650513          	addi	a0,a0,422 # ffffffffc02098e8 <commands+0x658>
ffffffffc020074a:	a49ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc020074e:	7c2c                	ld	a1,120(s0)
ffffffffc0200750:	00009517          	auipc	a0,0x9
ffffffffc0200754:	1b050513          	addi	a0,a0,432 # ffffffffc0209900 <commands+0x670>
ffffffffc0200758:	a3bff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020075c:	604c                	ld	a1,128(s0)
ffffffffc020075e:	00009517          	auipc	a0,0x9
ffffffffc0200762:	1ba50513          	addi	a0,a0,442 # ffffffffc0209918 <commands+0x688>
ffffffffc0200766:	a2dff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc020076a:	644c                	ld	a1,136(s0)
ffffffffc020076c:	00009517          	auipc	a0,0x9
ffffffffc0200770:	1c450513          	addi	a0,a0,452 # ffffffffc0209930 <commands+0x6a0>
ffffffffc0200774:	a1fff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200778:	684c                	ld	a1,144(s0)
ffffffffc020077a:	00009517          	auipc	a0,0x9
ffffffffc020077e:	1ce50513          	addi	a0,a0,462 # ffffffffc0209948 <commands+0x6b8>
ffffffffc0200782:	a11ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200786:	6c4c                	ld	a1,152(s0)
ffffffffc0200788:	00009517          	auipc	a0,0x9
ffffffffc020078c:	1d850513          	addi	a0,a0,472 # ffffffffc0209960 <commands+0x6d0>
ffffffffc0200790:	a03ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200794:	704c                	ld	a1,160(s0)
ffffffffc0200796:	00009517          	auipc	a0,0x9
ffffffffc020079a:	1e250513          	addi	a0,a0,482 # ffffffffc0209978 <commands+0x6e8>
ffffffffc020079e:	9f5ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02007a2:	744c                	ld	a1,168(s0)
ffffffffc02007a4:	00009517          	auipc	a0,0x9
ffffffffc02007a8:	1ec50513          	addi	a0,a0,492 # ffffffffc0209990 <commands+0x700>
ffffffffc02007ac:	9e7ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02007b0:	784c                	ld	a1,176(s0)
ffffffffc02007b2:	00009517          	auipc	a0,0x9
ffffffffc02007b6:	1f650513          	addi	a0,a0,502 # ffffffffc02099a8 <commands+0x718>
ffffffffc02007ba:	9d9ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02007be:	7c4c                	ld	a1,184(s0)
ffffffffc02007c0:	00009517          	auipc	a0,0x9
ffffffffc02007c4:	20050513          	addi	a0,a0,512 # ffffffffc02099c0 <commands+0x730>
ffffffffc02007c8:	9cbff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02007cc:	606c                	ld	a1,192(s0)
ffffffffc02007ce:	00009517          	auipc	a0,0x9
ffffffffc02007d2:	20a50513          	addi	a0,a0,522 # ffffffffc02099d8 <commands+0x748>
ffffffffc02007d6:	9bdff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02007da:	646c                	ld	a1,200(s0)
ffffffffc02007dc:	00009517          	auipc	a0,0x9
ffffffffc02007e0:	21450513          	addi	a0,a0,532 # ffffffffc02099f0 <commands+0x760>
ffffffffc02007e4:	9afff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02007e8:	686c                	ld	a1,208(s0)
ffffffffc02007ea:	00009517          	auipc	a0,0x9
ffffffffc02007ee:	21e50513          	addi	a0,a0,542 # ffffffffc0209a08 <commands+0x778>
ffffffffc02007f2:	9a1ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02007f6:	6c6c                	ld	a1,216(s0)
ffffffffc02007f8:	00009517          	auipc	a0,0x9
ffffffffc02007fc:	22850513          	addi	a0,a0,552 # ffffffffc0209a20 <commands+0x790>
ffffffffc0200800:	993ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200804:	706c                	ld	a1,224(s0)
ffffffffc0200806:	00009517          	auipc	a0,0x9
ffffffffc020080a:	23250513          	addi	a0,a0,562 # ffffffffc0209a38 <commands+0x7a8>
ffffffffc020080e:	985ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200812:	746c                	ld	a1,232(s0)
ffffffffc0200814:	00009517          	auipc	a0,0x9
ffffffffc0200818:	23c50513          	addi	a0,a0,572 # ffffffffc0209a50 <commands+0x7c0>
ffffffffc020081c:	977ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200820:	786c                	ld	a1,240(s0)
ffffffffc0200822:	00009517          	auipc	a0,0x9
ffffffffc0200826:	24650513          	addi	a0,a0,582 # ffffffffc0209a68 <commands+0x7d8>
ffffffffc020082a:	969ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020082e:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200830:	6402                	ld	s0,0(sp)
ffffffffc0200832:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200834:	00009517          	auipc	a0,0x9
ffffffffc0200838:	24c50513          	addi	a0,a0,588 # ffffffffc0209a80 <commands+0x7f0>
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
ffffffffc020084a:	00009517          	auipc	a0,0x9
ffffffffc020084e:	24e50513          	addi	a0,a0,590 # ffffffffc0209a98 <commands+0x808>
print_trapframe(struct trapframe *tf) {
ffffffffc0200852:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200854:	93fff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200858:	8522                	mv	a0,s0
ffffffffc020085a:	e1bff0ef          	jal	ra,ffffffffc0200674 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc020085e:	10043583          	ld	a1,256(s0)
ffffffffc0200862:	00009517          	auipc	a0,0x9
ffffffffc0200866:	24e50513          	addi	a0,a0,590 # ffffffffc0209ab0 <commands+0x820>
ffffffffc020086a:	929ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020086e:	10843583          	ld	a1,264(s0)
ffffffffc0200872:	00009517          	auipc	a0,0x9
ffffffffc0200876:	25650513          	addi	a0,a0,598 # ffffffffc0209ac8 <commands+0x838>
ffffffffc020087a:	919ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  tval 0x%08x\n", tf->tval);
ffffffffc020087e:	11043583          	ld	a1,272(s0)
ffffffffc0200882:	00009517          	auipc	a0,0x9
ffffffffc0200886:	25e50513          	addi	a0,a0,606 # ffffffffc0209ae0 <commands+0x850>
ffffffffc020088a:	909ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020088e:	11843583          	ld	a1,280(s0)
}
ffffffffc0200892:	6402                	ld	s0,0(sp)
ffffffffc0200894:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200896:	00009517          	auipc	a0,0x9
ffffffffc020089a:	25a50513          	addi	a0,a0,602 # ffffffffc0209af0 <commands+0x860>
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
ffffffffc02008a8:	000c9497          	auipc	s1,0xc9
ffffffffc02008ac:	b2048493          	addi	s1,s1,-1248 # ffffffffc02c93c8 <check_mm_struct>
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
ffffffffc02008de:	00009517          	auipc	a0,0x9
ffffffffc02008e2:	e3a50513          	addi	a0,a0,-454 # ffffffffc0209718 <commands+0x488>
ffffffffc02008e6:	8adff0ef          	jal	ra,ffffffffc0200192 <cprintf>
            print_pgfault(tf);
        }
    struct mm_struct *mm;
    if (check_mm_struct != NULL) {
ffffffffc02008ea:	6088                	ld	a0,0(s1)
ffffffffc02008ec:	c129                	beqz	a0,ffffffffc020092e <pgfault_handler+0x8a>
        assert(current == idleproc);
ffffffffc02008ee:	000c9797          	auipc	a5,0xc9
ffffffffc02008f2:	99278793          	addi	a5,a5,-1646 # ffffffffc02c9280 <current>
ffffffffc02008f6:	6398                	ld	a4,0(a5)
ffffffffc02008f8:	000c9797          	auipc	a5,0xc9
ffffffffc02008fc:	99078793          	addi	a5,a5,-1648 # ffffffffc02c9288 <idleproc>
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
ffffffffc0200916:	0820406f          	j	ffffffffc0204998 <do_pgfault>
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc020091a:	11843703          	ld	a4,280(s0)
ffffffffc020091e:	47bd                	li	a5,15
ffffffffc0200920:	05500613          	li	a2,85
ffffffffc0200924:	05700693          	li	a3,87
ffffffffc0200928:	faf719e3          	bne	a4,a5,ffffffffc02008da <pgfault_handler+0x36>
ffffffffc020092c:	bf4d                	j	ffffffffc02008de <pgfault_handler+0x3a>
        if (current == NULL) {
ffffffffc020092e:	000c9797          	auipc	a5,0xc9
ffffffffc0200932:	95278793          	addi	a5,a5,-1710 # ffffffffc02c9280 <current>
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
ffffffffc020094c:	04c0406f          	j	ffffffffc0204998 <do_pgfault>
        assert(current == idleproc);
ffffffffc0200950:	00009697          	auipc	a3,0x9
ffffffffc0200954:	de868693          	addi	a3,a3,-536 # ffffffffc0209738 <commands+0x4a8>
ffffffffc0200958:	00009617          	auipc	a2,0x9
ffffffffc020095c:	df860613          	addi	a2,a2,-520 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0200960:	06c00593          	li	a1,108
ffffffffc0200964:	00009517          	auipc	a0,0x9
ffffffffc0200968:	e0450513          	addi	a0,a0,-508 # ffffffffc0209768 <commands+0x4d8>
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
ffffffffc020099a:	00009517          	auipc	a0,0x9
ffffffffc020099e:	d7e50513          	addi	a0,a0,-642 # ffffffffc0209718 <commands+0x488>
ffffffffc02009a2:	ff0ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
            panic("unhandled page fault.\n");
ffffffffc02009a6:	00009617          	auipc	a2,0x9
ffffffffc02009aa:	dda60613          	addi	a2,a2,-550 # ffffffffc0209780 <commands+0x4f0>
ffffffffc02009ae:	07300593          	li	a1,115
ffffffffc02009b2:	00009517          	auipc	a0,0x9
ffffffffc02009b6:	db650513          	addi	a0,a0,-586 # ffffffffc0209768 <commands+0x4d8>
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
ffffffffc02009d0:	08f76163          	bltu	a4,a5,ffffffffc0200a52 <interrupt_handler+0x8e>
ffffffffc02009d4:	00009717          	auipc	a4,0x9
ffffffffc02009d8:	a9870713          	addi	a4,a4,-1384 # ffffffffc020946c <commands+0x1dc>
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
ffffffffc02009e6:	00009517          	auipc	a0,0x9
ffffffffc02009ea:	cf250513          	addi	a0,a0,-782 # ffffffffc02096d8 <commands+0x448>
ffffffffc02009ee:	fa4ff06f          	j	ffffffffc0200192 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02009f2:	00009517          	auipc	a0,0x9
ffffffffc02009f6:	cc650513          	addi	a0,a0,-826 # ffffffffc02096b8 <commands+0x428>
ffffffffc02009fa:	f98ff06f          	j	ffffffffc0200192 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02009fe:	00009517          	auipc	a0,0x9
ffffffffc0200a02:	c7a50513          	addi	a0,a0,-902 # ffffffffc0209678 <commands+0x3e8>
ffffffffc0200a06:	f8cff06f          	j	ffffffffc0200192 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc0200a0a:	00009517          	auipc	a0,0x9
ffffffffc0200a0e:	c8e50513          	addi	a0,a0,-882 # ffffffffc0209698 <commands+0x408>
ffffffffc0200a12:	f80ff06f          	j	ffffffffc0200192 <cprintf>
            break;
        case IRQ_U_EXT:
            cprintf("User software interrupt\n");
            break;
        case IRQ_S_EXT:
            cprintf("Supervisor external interrupt\n");
ffffffffc0200a16:	00009517          	auipc	a0,0x9
ffffffffc0200a1a:	ce250513          	addi	a0,a0,-798 # ffffffffc02096f8 <commands+0x468>
ffffffffc0200a1e:	f74ff06f          	j	ffffffffc0200192 <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc0200a22:	1141                	addi	sp,sp,-16
ffffffffc0200a24:	e406                	sd	ra,8(sp)
            clock_set_next_event();
ffffffffc0200a26:	b43ff0ef          	jal	ra,ffffffffc0200568 <clock_set_next_event>
            if (++ticks % TICK_NUM == 0 ) {
ffffffffc0200a2a:	000c9797          	auipc	a5,0xc9
ffffffffc0200a2e:	88678793          	addi	a5,a5,-1914 # ffffffffc02c92b0 <ticks>
ffffffffc0200a32:	639c                	ld	a5,0(a5)
            if (current){
ffffffffc0200a34:	000c9717          	auipc	a4,0xc9
ffffffffc0200a38:	84c70713          	addi	a4,a4,-1972 # ffffffffc02c9280 <current>
ffffffffc0200a3c:	6308                	ld	a0,0(a4)
            if (++ticks % TICK_NUM == 0 ) {
ffffffffc0200a3e:	0785                	addi	a5,a5,1
ffffffffc0200a40:	000c9717          	auipc	a4,0xc9
ffffffffc0200a44:	86f73823          	sd	a5,-1936(a4) # ffffffffc02c92b0 <ticks>
            if (current){
ffffffffc0200a48:	c519                	beqz	a0,ffffffffc0200a56 <interrupt_handler+0x92>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200a4a:	60a2                	ld	ra,8(sp)
ffffffffc0200a4c:	0141                	addi	sp,sp,16
                sched_class_proc_tick(current); 
ffffffffc0200a4e:	72d0706f          	j	ffffffffc020897a <sched_class_proc_tick>
            print_trapframe(tf);
ffffffffc0200a52:	df1ff06f          	j	ffffffffc0200842 <print_trapframe>
}
ffffffffc0200a56:	60a2                	ld	ra,8(sp)
ffffffffc0200a58:	0141                	addi	sp,sp,16
ffffffffc0200a5a:	8082                	ret

ffffffffc0200a5c <exception_handler>:
void kernel_execve_ret(struct trapframe *tf,uintptr_t kstacktop);
void exception_handler(struct trapframe *tf) {
    int ret;
    switch (tf->cause) {
ffffffffc0200a5c:	11853783          	ld	a5,280(a0)
ffffffffc0200a60:	473d                	li	a4,15
ffffffffc0200a62:	1af76e63          	bltu	a4,a5,ffffffffc0200c1e <exception_handler+0x1c2>
ffffffffc0200a66:	00009717          	auipc	a4,0x9
ffffffffc0200a6a:	a3670713          	addi	a4,a4,-1482 # ffffffffc020949c <commands+0x20c>
ffffffffc0200a6e:	078a                	slli	a5,a5,0x2
ffffffffc0200a70:	97ba                	add	a5,a5,a4
ffffffffc0200a72:	439c                	lw	a5,0(a5)
void exception_handler(struct trapframe *tf) {
ffffffffc0200a74:	1101                	addi	sp,sp,-32
ffffffffc0200a76:	e822                	sd	s0,16(sp)
ffffffffc0200a78:	ec06                	sd	ra,24(sp)
ffffffffc0200a7a:	e426                	sd	s1,8(sp)
    switch (tf->cause) {
ffffffffc0200a7c:	97ba                	add	a5,a5,a4
ffffffffc0200a7e:	842a                	mv	s0,a0
ffffffffc0200a80:	8782                	jr	a5
            //cprintf("Environment call from U-mode\n");
            tf->epc += 4;
            syscall();
            break;
        case CAUSE_SUPERVISOR_ECALL:
            cprintf("Environment call from S-mode\n");
ffffffffc0200a82:	00009517          	auipc	a0,0x9
ffffffffc0200a86:	b4e50513          	addi	a0,a0,-1202 # ffffffffc02095d0 <commands+0x340>
ffffffffc0200a8a:	f08ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
            tf->epc += 4;
ffffffffc0200a8e:	10843783          	ld	a5,264(s0)
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200a92:	60e2                	ld	ra,24(sp)
ffffffffc0200a94:	64a2                	ld	s1,8(sp)
            tf->epc += 4;
ffffffffc0200a96:	0791                	addi	a5,a5,4
ffffffffc0200a98:	10f43423          	sd	a5,264(s0)
}
ffffffffc0200a9c:	6442                	ld	s0,16(sp)
ffffffffc0200a9e:	6105                	addi	sp,sp,32
            syscall();
ffffffffc0200aa0:	1660806f          	j	ffffffffc0208c06 <syscall>
            cprintf("Environment call from H-mode\n");
ffffffffc0200aa4:	00009517          	auipc	a0,0x9
ffffffffc0200aa8:	b4c50513          	addi	a0,a0,-1204 # ffffffffc02095f0 <commands+0x360>
}
ffffffffc0200aac:	6442                	ld	s0,16(sp)
ffffffffc0200aae:	60e2                	ld	ra,24(sp)
ffffffffc0200ab0:	64a2                	ld	s1,8(sp)
ffffffffc0200ab2:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc0200ab4:	edeff06f          	j	ffffffffc0200192 <cprintf>
            cprintf("Environment call from M-mode\n");
ffffffffc0200ab8:	00009517          	auipc	a0,0x9
ffffffffc0200abc:	b5850513          	addi	a0,a0,-1192 # ffffffffc0209610 <commands+0x380>
ffffffffc0200ac0:	b7f5                	j	ffffffffc0200aac <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc0200ac2:	00009517          	auipc	a0,0x9
ffffffffc0200ac6:	b6e50513          	addi	a0,a0,-1170 # ffffffffc0209630 <commands+0x3a0>
ffffffffc0200aca:	b7cd                	j	ffffffffc0200aac <exception_handler+0x50>
            cprintf("Load page fault\n");
ffffffffc0200acc:	00009517          	auipc	a0,0x9
ffffffffc0200ad0:	b7c50513          	addi	a0,a0,-1156 # ffffffffc0209648 <commands+0x3b8>
ffffffffc0200ad4:	ebeff0ef          	jal	ra,ffffffffc0200192 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200ad8:	8522                	mv	a0,s0
ffffffffc0200ada:	dcbff0ef          	jal	ra,ffffffffc02008a4 <pgfault_handler>
ffffffffc0200ade:	84aa                	mv	s1,a0
ffffffffc0200ae0:	14051163          	bnez	a0,ffffffffc0200c22 <exception_handler+0x1c6>
}
ffffffffc0200ae4:	60e2                	ld	ra,24(sp)
ffffffffc0200ae6:	6442                	ld	s0,16(sp)
ffffffffc0200ae8:	64a2                	ld	s1,8(sp)
ffffffffc0200aea:	6105                	addi	sp,sp,32
ffffffffc0200aec:	8082                	ret
            cprintf("Store/AMO page fault\n");
ffffffffc0200aee:	00009517          	auipc	a0,0x9
ffffffffc0200af2:	b7250513          	addi	a0,a0,-1166 # ffffffffc0209660 <commands+0x3d0>
ffffffffc0200af6:	e9cff0ef          	jal	ra,ffffffffc0200192 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200afa:	8522                	mv	a0,s0
ffffffffc0200afc:	da9ff0ef          	jal	ra,ffffffffc02008a4 <pgfault_handler>
ffffffffc0200b00:	84aa                	mv	s1,a0
ffffffffc0200b02:	d16d                	beqz	a0,ffffffffc0200ae4 <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200b04:	8522                	mv	a0,s0
ffffffffc0200b06:	d3dff0ef          	jal	ra,ffffffffc0200842 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200b0a:	86a6                	mv	a3,s1
ffffffffc0200b0c:	00009617          	auipc	a2,0x9
ffffffffc0200b10:	a7460613          	addi	a2,a2,-1420 # ffffffffc0209580 <commands+0x2f0>
ffffffffc0200b14:	0fb00593          	li	a1,251
ffffffffc0200b18:	00009517          	auipc	a0,0x9
ffffffffc0200b1c:	c5050513          	addi	a0,a0,-944 # ffffffffc0209768 <commands+0x4d8>
ffffffffc0200b20:	969ff0ef          	jal	ra,ffffffffc0200488 <__panic>
            cprintf("Instruction address misaligned\n");
ffffffffc0200b24:	00009517          	auipc	a0,0x9
ffffffffc0200b28:	9bc50513          	addi	a0,a0,-1604 # ffffffffc02094e0 <commands+0x250>
ffffffffc0200b2c:	b741                	j	ffffffffc0200aac <exception_handler+0x50>
            cprintf("Instruction access fault\n");
ffffffffc0200b2e:	00009517          	auipc	a0,0x9
ffffffffc0200b32:	9d250513          	addi	a0,a0,-1582 # ffffffffc0209500 <commands+0x270>
ffffffffc0200b36:	bf9d                	j	ffffffffc0200aac <exception_handler+0x50>
            cprintf("Illegal instruction\n");
ffffffffc0200b38:	00009517          	auipc	a0,0x9
ffffffffc0200b3c:	9e850513          	addi	a0,a0,-1560 # ffffffffc0209520 <commands+0x290>
ffffffffc0200b40:	b7b5                	j	ffffffffc0200aac <exception_handler+0x50>
            cprintf("Breakpoint\n");
ffffffffc0200b42:	00009517          	auipc	a0,0x9
ffffffffc0200b46:	9f650513          	addi	a0,a0,-1546 # ffffffffc0209538 <commands+0x2a8>
ffffffffc0200b4a:	e48ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
            if(tf->gpr.a7 == 10){
ffffffffc0200b4e:	6458                	ld	a4,136(s0)
ffffffffc0200b50:	47a9                	li	a5,10
ffffffffc0200b52:	f8f719e3          	bne	a4,a5,ffffffffc0200ae4 <exception_handler+0x88>
                tf->epc += 4;
ffffffffc0200b56:	10843783          	ld	a5,264(s0)
ffffffffc0200b5a:	0791                	addi	a5,a5,4
ffffffffc0200b5c:	10f43423          	sd	a5,264(s0)
                syscall();
ffffffffc0200b60:	0a6080ef          	jal	ra,ffffffffc0208c06 <syscall>
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b64:	000c8797          	auipc	a5,0xc8
ffffffffc0200b68:	71c78793          	addi	a5,a5,1820 # ffffffffc02c9280 <current>
ffffffffc0200b6c:	639c                	ld	a5,0(a5)
ffffffffc0200b6e:	8522                	mv	a0,s0
}
ffffffffc0200b70:	6442                	ld	s0,16(sp)
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b72:	6b9c                	ld	a5,16(a5)
}
ffffffffc0200b74:	60e2                	ld	ra,24(sp)
ffffffffc0200b76:	64a2                	ld	s1,8(sp)
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b78:	6589                	lui	a1,0x2
ffffffffc0200b7a:	95be                	add	a1,a1,a5
}
ffffffffc0200b7c:	6105                	addi	sp,sp,32
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b7e:	2200006f          	j	ffffffffc0200d9e <kernel_execve_ret>
            cprintf("Load address misaligned\n");
ffffffffc0200b82:	00009517          	auipc	a0,0x9
ffffffffc0200b86:	9c650513          	addi	a0,a0,-1594 # ffffffffc0209548 <commands+0x2b8>
ffffffffc0200b8a:	b70d                	j	ffffffffc0200aac <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc0200b8c:	00009517          	auipc	a0,0x9
ffffffffc0200b90:	9dc50513          	addi	a0,a0,-1572 # ffffffffc0209568 <commands+0x2d8>
ffffffffc0200b94:	dfeff0ef          	jal	ra,ffffffffc0200192 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200b98:	8522                	mv	a0,s0
ffffffffc0200b9a:	d0bff0ef          	jal	ra,ffffffffc02008a4 <pgfault_handler>
ffffffffc0200b9e:	84aa                	mv	s1,a0
ffffffffc0200ba0:	d131                	beqz	a0,ffffffffc0200ae4 <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200ba2:	8522                	mv	a0,s0
ffffffffc0200ba4:	c9fff0ef          	jal	ra,ffffffffc0200842 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200ba8:	86a6                	mv	a3,s1
ffffffffc0200baa:	00009617          	auipc	a2,0x9
ffffffffc0200bae:	9d660613          	addi	a2,a2,-1578 # ffffffffc0209580 <commands+0x2f0>
ffffffffc0200bb2:	0d000593          	li	a1,208
ffffffffc0200bb6:	00009517          	auipc	a0,0x9
ffffffffc0200bba:	bb250513          	addi	a0,a0,-1102 # ffffffffc0209768 <commands+0x4d8>
ffffffffc0200bbe:	8cbff0ef          	jal	ra,ffffffffc0200488 <__panic>
            cprintf("Store/AMO access fault\n");
ffffffffc0200bc2:	00009517          	auipc	a0,0x9
ffffffffc0200bc6:	9f650513          	addi	a0,a0,-1546 # ffffffffc02095b8 <commands+0x328>
ffffffffc0200bca:	dc8ff0ef          	jal	ra,ffffffffc0200192 <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200bce:	8522                	mv	a0,s0
ffffffffc0200bd0:	cd5ff0ef          	jal	ra,ffffffffc02008a4 <pgfault_handler>
ffffffffc0200bd4:	84aa                	mv	s1,a0
ffffffffc0200bd6:	f00507e3          	beqz	a0,ffffffffc0200ae4 <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200bda:	8522                	mv	a0,s0
ffffffffc0200bdc:	c67ff0ef          	jal	ra,ffffffffc0200842 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200be0:	86a6                	mv	a3,s1
ffffffffc0200be2:	00009617          	auipc	a2,0x9
ffffffffc0200be6:	99e60613          	addi	a2,a2,-1634 # ffffffffc0209580 <commands+0x2f0>
ffffffffc0200bea:	0da00593          	li	a1,218
ffffffffc0200bee:	00009517          	auipc	a0,0x9
ffffffffc0200bf2:	b7a50513          	addi	a0,a0,-1158 # ffffffffc0209768 <commands+0x4d8>
ffffffffc0200bf6:	893ff0ef          	jal	ra,ffffffffc0200488 <__panic>
}
ffffffffc0200bfa:	6442                	ld	s0,16(sp)
ffffffffc0200bfc:	60e2                	ld	ra,24(sp)
ffffffffc0200bfe:	64a2                	ld	s1,8(sp)
ffffffffc0200c00:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc0200c02:	c41ff06f          	j	ffffffffc0200842 <print_trapframe>
            panic("AMO address misaligned\n");
ffffffffc0200c06:	00009617          	auipc	a2,0x9
ffffffffc0200c0a:	99a60613          	addi	a2,a2,-1638 # ffffffffc02095a0 <commands+0x310>
ffffffffc0200c0e:	0d400593          	li	a1,212
ffffffffc0200c12:	00009517          	auipc	a0,0x9
ffffffffc0200c16:	b5650513          	addi	a0,a0,-1194 # ffffffffc0209768 <commands+0x4d8>
ffffffffc0200c1a:	86fff0ef          	jal	ra,ffffffffc0200488 <__panic>
            print_trapframe(tf);
ffffffffc0200c1e:	c25ff06f          	j	ffffffffc0200842 <print_trapframe>
                print_trapframe(tf);
ffffffffc0200c22:	8522                	mv	a0,s0
ffffffffc0200c24:	c1fff0ef          	jal	ra,ffffffffc0200842 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200c28:	86a6                	mv	a3,s1
ffffffffc0200c2a:	00009617          	auipc	a2,0x9
ffffffffc0200c2e:	95660613          	addi	a2,a2,-1706 # ffffffffc0209580 <commands+0x2f0>
ffffffffc0200c32:	0f400593          	li	a1,244
ffffffffc0200c36:	00009517          	auipc	a0,0x9
ffffffffc0200c3a:	b3250513          	addi	a0,a0,-1230 # ffffffffc0209768 <commands+0x4d8>
ffffffffc0200c3e:	84bff0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0200c42 <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
ffffffffc0200c42:	1101                	addi	sp,sp,-32
ffffffffc0200c44:	e822                	sd	s0,16(sp)
    // dispatch based on what type of trap occurred
//    cputs("some trap");
    if (current == NULL) {
ffffffffc0200c46:	000c8417          	auipc	s0,0xc8
ffffffffc0200c4a:	63a40413          	addi	s0,s0,1594 # ffffffffc02c9280 <current>
ffffffffc0200c4e:	6018                	ld	a4,0(s0)
trap(struct trapframe *tf) {
ffffffffc0200c50:	ec06                	sd	ra,24(sp)
ffffffffc0200c52:	e426                	sd	s1,8(sp)
ffffffffc0200c54:	e04a                	sd	s2,0(sp)
ffffffffc0200c56:	11853683          	ld	a3,280(a0)
    if (current == NULL) {
ffffffffc0200c5a:	cf1d                	beqz	a4,ffffffffc0200c98 <trap+0x56>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200c5c:	10053483          	ld	s1,256(a0)
        trap_dispatch(tf);
    } else {
        struct trapframe *otf = current->tf;
ffffffffc0200c60:	0a073903          	ld	s2,160(a4)
        current->tf = tf;
ffffffffc0200c64:	f348                	sd	a0,160(a4)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200c66:	1004f493          	andi	s1,s1,256
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200c6a:	0206c463          	bltz	a3,ffffffffc0200c92 <trap+0x50>
        exception_handler(tf);
ffffffffc0200c6e:	defff0ef          	jal	ra,ffffffffc0200a5c <exception_handler>

        bool in_kernel = trap_in_kernel(tf);

        trap_dispatch(tf);

        current->tf = otf;
ffffffffc0200c72:	601c                	ld	a5,0(s0)
ffffffffc0200c74:	0b27b023          	sd	s2,160(a5)
        if (!in_kernel) {
ffffffffc0200c78:	e499                	bnez	s1,ffffffffc0200c86 <trap+0x44>
            if (current->flags & PF_EXITING) {
ffffffffc0200c7a:	0b07a703          	lw	a4,176(a5)
ffffffffc0200c7e:	8b05                	andi	a4,a4,1
ffffffffc0200c80:	e339                	bnez	a4,ffffffffc0200cc6 <trap+0x84>
                do_exit(-E_KILLED);
            }
            if (current->need_resched) {
ffffffffc0200c82:	6f9c                	ld	a5,24(a5)
ffffffffc0200c84:	eb95                	bnez	a5,ffffffffc0200cb8 <trap+0x76>
                schedule();
            }
        }
    }
}
ffffffffc0200c86:	60e2                	ld	ra,24(sp)
ffffffffc0200c88:	6442                	ld	s0,16(sp)
ffffffffc0200c8a:	64a2                	ld	s1,8(sp)
ffffffffc0200c8c:	6902                	ld	s2,0(sp)
ffffffffc0200c8e:	6105                	addi	sp,sp,32
ffffffffc0200c90:	8082                	ret
        interrupt_handler(tf);
ffffffffc0200c92:	d33ff0ef          	jal	ra,ffffffffc02009c4 <interrupt_handler>
ffffffffc0200c96:	bff1                	j	ffffffffc0200c72 <trap+0x30>
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200c98:	0006c963          	bltz	a3,ffffffffc0200caa <trap+0x68>
}
ffffffffc0200c9c:	6442                	ld	s0,16(sp)
ffffffffc0200c9e:	60e2                	ld	ra,24(sp)
ffffffffc0200ca0:	64a2                	ld	s1,8(sp)
ffffffffc0200ca2:	6902                	ld	s2,0(sp)
ffffffffc0200ca4:	6105                	addi	sp,sp,32
        exception_handler(tf);
ffffffffc0200ca6:	db7ff06f          	j	ffffffffc0200a5c <exception_handler>
}
ffffffffc0200caa:	6442                	ld	s0,16(sp)
ffffffffc0200cac:	60e2                	ld	ra,24(sp)
ffffffffc0200cae:	64a2                	ld	s1,8(sp)
ffffffffc0200cb0:	6902                	ld	s2,0(sp)
ffffffffc0200cb2:	6105                	addi	sp,sp,32
        interrupt_handler(tf);
ffffffffc0200cb4:	d11ff06f          	j	ffffffffc02009c4 <interrupt_handler>
}
ffffffffc0200cb8:	6442                	ld	s0,16(sp)
ffffffffc0200cba:	60e2                	ld	ra,24(sp)
ffffffffc0200cbc:	64a2                	ld	s1,8(sp)
ffffffffc0200cbe:	6902                	ld	s2,0(sp)
ffffffffc0200cc0:	6105                	addi	sp,sp,32
                schedule();
ffffffffc0200cc2:	5f70706f          	j	ffffffffc0208ab8 <schedule>
                do_exit(-E_KILLED);
ffffffffc0200cc6:	555d                	li	a0,-9
ffffffffc0200cc8:	72e040ef          	jal	ra,ffffffffc02053f6 <do_exit>
ffffffffc0200ccc:	601c                	ld	a5,0(s0)
ffffffffc0200cce:	bf55                	j	ffffffffc0200c82 <trap+0x40>

ffffffffc0200cd0 <__alltraps>:
    LOAD x2, 2*REGBYTES(sp)
    .endm

    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0200cd0:	14011173          	csrrw	sp,sscratch,sp
ffffffffc0200cd4:	00011463          	bnez	sp,ffffffffc0200cdc <__alltraps+0xc>
ffffffffc0200cd8:	14002173          	csrr	sp,sscratch
ffffffffc0200cdc:	712d                	addi	sp,sp,-288
ffffffffc0200cde:	e002                	sd	zero,0(sp)
ffffffffc0200ce0:	e406                	sd	ra,8(sp)
ffffffffc0200ce2:	ec0e                	sd	gp,24(sp)
ffffffffc0200ce4:	f012                	sd	tp,32(sp)
ffffffffc0200ce6:	f416                	sd	t0,40(sp)
ffffffffc0200ce8:	f81a                	sd	t1,48(sp)
ffffffffc0200cea:	fc1e                	sd	t2,56(sp)
ffffffffc0200cec:	e0a2                	sd	s0,64(sp)
ffffffffc0200cee:	e4a6                	sd	s1,72(sp)
ffffffffc0200cf0:	e8aa                	sd	a0,80(sp)
ffffffffc0200cf2:	ecae                	sd	a1,88(sp)
ffffffffc0200cf4:	f0b2                	sd	a2,96(sp)
ffffffffc0200cf6:	f4b6                	sd	a3,104(sp)
ffffffffc0200cf8:	f8ba                	sd	a4,112(sp)
ffffffffc0200cfa:	fcbe                	sd	a5,120(sp)
ffffffffc0200cfc:	e142                	sd	a6,128(sp)
ffffffffc0200cfe:	e546                	sd	a7,136(sp)
ffffffffc0200d00:	e94a                	sd	s2,144(sp)
ffffffffc0200d02:	ed4e                	sd	s3,152(sp)
ffffffffc0200d04:	f152                	sd	s4,160(sp)
ffffffffc0200d06:	f556                	sd	s5,168(sp)
ffffffffc0200d08:	f95a                	sd	s6,176(sp)
ffffffffc0200d0a:	fd5e                	sd	s7,184(sp)
ffffffffc0200d0c:	e1e2                	sd	s8,192(sp)
ffffffffc0200d0e:	e5e6                	sd	s9,200(sp)
ffffffffc0200d10:	e9ea                	sd	s10,208(sp)
ffffffffc0200d12:	edee                	sd	s11,216(sp)
ffffffffc0200d14:	f1f2                	sd	t3,224(sp)
ffffffffc0200d16:	f5f6                	sd	t4,232(sp)
ffffffffc0200d18:	f9fa                	sd	t5,240(sp)
ffffffffc0200d1a:	fdfe                	sd	t6,248(sp)
ffffffffc0200d1c:	14001473          	csrrw	s0,sscratch,zero
ffffffffc0200d20:	100024f3          	csrr	s1,sstatus
ffffffffc0200d24:	14102973          	csrr	s2,sepc
ffffffffc0200d28:	143029f3          	csrr	s3,stval
ffffffffc0200d2c:	14202a73          	csrr	s4,scause
ffffffffc0200d30:	e822                	sd	s0,16(sp)
ffffffffc0200d32:	e226                	sd	s1,256(sp)
ffffffffc0200d34:	e64a                	sd	s2,264(sp)
ffffffffc0200d36:	ea4e                	sd	s3,272(sp)
ffffffffc0200d38:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200d3a:	850a                	mv	a0,sp
    jal trap
ffffffffc0200d3c:	f07ff0ef          	jal	ra,ffffffffc0200c42 <trap>

ffffffffc0200d40 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200d40:	6492                	ld	s1,256(sp)
ffffffffc0200d42:	6932                	ld	s2,264(sp)
ffffffffc0200d44:	1004f413          	andi	s0,s1,256
ffffffffc0200d48:	e401                	bnez	s0,ffffffffc0200d50 <__trapret+0x10>
ffffffffc0200d4a:	1200                	addi	s0,sp,288
ffffffffc0200d4c:	14041073          	csrw	sscratch,s0
ffffffffc0200d50:	10049073          	csrw	sstatus,s1
ffffffffc0200d54:	14191073          	csrw	sepc,s2
ffffffffc0200d58:	60a2                	ld	ra,8(sp)
ffffffffc0200d5a:	61e2                	ld	gp,24(sp)
ffffffffc0200d5c:	7202                	ld	tp,32(sp)
ffffffffc0200d5e:	72a2                	ld	t0,40(sp)
ffffffffc0200d60:	7342                	ld	t1,48(sp)
ffffffffc0200d62:	73e2                	ld	t2,56(sp)
ffffffffc0200d64:	6406                	ld	s0,64(sp)
ffffffffc0200d66:	64a6                	ld	s1,72(sp)
ffffffffc0200d68:	6546                	ld	a0,80(sp)
ffffffffc0200d6a:	65e6                	ld	a1,88(sp)
ffffffffc0200d6c:	7606                	ld	a2,96(sp)
ffffffffc0200d6e:	76a6                	ld	a3,104(sp)
ffffffffc0200d70:	7746                	ld	a4,112(sp)
ffffffffc0200d72:	77e6                	ld	a5,120(sp)
ffffffffc0200d74:	680a                	ld	a6,128(sp)
ffffffffc0200d76:	68aa                	ld	a7,136(sp)
ffffffffc0200d78:	694a                	ld	s2,144(sp)
ffffffffc0200d7a:	69ea                	ld	s3,152(sp)
ffffffffc0200d7c:	7a0a                	ld	s4,160(sp)
ffffffffc0200d7e:	7aaa                	ld	s5,168(sp)
ffffffffc0200d80:	7b4a                	ld	s6,176(sp)
ffffffffc0200d82:	7bea                	ld	s7,184(sp)
ffffffffc0200d84:	6c0e                	ld	s8,192(sp)
ffffffffc0200d86:	6cae                	ld	s9,200(sp)
ffffffffc0200d88:	6d4e                	ld	s10,208(sp)
ffffffffc0200d8a:	6dee                	ld	s11,216(sp)
ffffffffc0200d8c:	7e0e                	ld	t3,224(sp)
ffffffffc0200d8e:	7eae                	ld	t4,232(sp)
ffffffffc0200d90:	7f4e                	ld	t5,240(sp)
ffffffffc0200d92:	7fee                	ld	t6,248(sp)
ffffffffc0200d94:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc0200d96:	10200073          	sret

ffffffffc0200d9a <forkrets>:
 
    .globl forkrets
forkrets:
    # set stack to this new process's trapframe
    move sp, a0
ffffffffc0200d9a:	812a                	mv	sp,a0
    j __trapret
ffffffffc0200d9c:	b755                	j	ffffffffc0200d40 <__trapret>

ffffffffc0200d9e <kernel_execve_ret>:

    .global kernel_execve_ret
kernel_execve_ret:
    // adjust sp to beneath kstacktop of current process
    addi a1, a1, -36*REGBYTES
ffffffffc0200d9e:	ee058593          	addi	a1,a1,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x7a20>

    // copy from previous trapframe to new trapframe
    LOAD s1, 35*REGBYTES(a0)
ffffffffc0200da2:	11853483          	ld	s1,280(a0)
    STORE s1, 35*REGBYTES(a1)
ffffffffc0200da6:	1095bc23          	sd	s1,280(a1)
    LOAD s1, 34*REGBYTES(a0)
ffffffffc0200daa:	11053483          	ld	s1,272(a0)
    STORE s1, 34*REGBYTES(a1)
ffffffffc0200dae:	1095b823          	sd	s1,272(a1)
    LOAD s1, 33*REGBYTES(a0)
ffffffffc0200db2:	10853483          	ld	s1,264(a0)
    STORE s1, 33*REGBYTES(a1)
ffffffffc0200db6:	1095b423          	sd	s1,264(a1)
    LOAD s1, 32*REGBYTES(a0)
ffffffffc0200dba:	10053483          	ld	s1,256(a0)
    STORE s1, 32*REGBYTES(a1)
ffffffffc0200dbe:	1095b023          	sd	s1,256(a1)
    LOAD s1, 31*REGBYTES(a0)
ffffffffc0200dc2:	7d64                	ld	s1,248(a0)
    STORE s1, 31*REGBYTES(a1)
ffffffffc0200dc4:	fde4                	sd	s1,248(a1)
    LOAD s1, 30*REGBYTES(a0)
ffffffffc0200dc6:	7964                	ld	s1,240(a0)
    STORE s1, 30*REGBYTES(a1)
ffffffffc0200dc8:	f9e4                	sd	s1,240(a1)
    LOAD s1, 29*REGBYTES(a0)
ffffffffc0200dca:	7564                	ld	s1,232(a0)
    STORE s1, 29*REGBYTES(a1)
ffffffffc0200dcc:	f5e4                	sd	s1,232(a1)
    LOAD s1, 28*REGBYTES(a0)
ffffffffc0200dce:	7164                	ld	s1,224(a0)
    STORE s1, 28*REGBYTES(a1)
ffffffffc0200dd0:	f1e4                	sd	s1,224(a1)
    LOAD s1, 27*REGBYTES(a0)
ffffffffc0200dd2:	6d64                	ld	s1,216(a0)
    STORE s1, 27*REGBYTES(a1)
ffffffffc0200dd4:	ede4                	sd	s1,216(a1)
    LOAD s1, 26*REGBYTES(a0)
ffffffffc0200dd6:	6964                	ld	s1,208(a0)
    STORE s1, 26*REGBYTES(a1)
ffffffffc0200dd8:	e9e4                	sd	s1,208(a1)
    LOAD s1, 25*REGBYTES(a0)
ffffffffc0200dda:	6564                	ld	s1,200(a0)
    STORE s1, 25*REGBYTES(a1)
ffffffffc0200ddc:	e5e4                	sd	s1,200(a1)
    LOAD s1, 24*REGBYTES(a0)
ffffffffc0200dde:	6164                	ld	s1,192(a0)
    STORE s1, 24*REGBYTES(a1)
ffffffffc0200de0:	e1e4                	sd	s1,192(a1)
    LOAD s1, 23*REGBYTES(a0)
ffffffffc0200de2:	7d44                	ld	s1,184(a0)
    STORE s1, 23*REGBYTES(a1)
ffffffffc0200de4:	fdc4                	sd	s1,184(a1)
    LOAD s1, 22*REGBYTES(a0)
ffffffffc0200de6:	7944                	ld	s1,176(a0)
    STORE s1, 22*REGBYTES(a1)
ffffffffc0200de8:	f9c4                	sd	s1,176(a1)
    LOAD s1, 21*REGBYTES(a0)
ffffffffc0200dea:	7544                	ld	s1,168(a0)
    STORE s1, 21*REGBYTES(a1)
ffffffffc0200dec:	f5c4                	sd	s1,168(a1)
    LOAD s1, 20*REGBYTES(a0)
ffffffffc0200dee:	7144                	ld	s1,160(a0)
    STORE s1, 20*REGBYTES(a1)
ffffffffc0200df0:	f1c4                	sd	s1,160(a1)
    LOAD s1, 19*REGBYTES(a0)
ffffffffc0200df2:	6d44                	ld	s1,152(a0)
    STORE s1, 19*REGBYTES(a1)
ffffffffc0200df4:	edc4                	sd	s1,152(a1)
    LOAD s1, 18*REGBYTES(a0)
ffffffffc0200df6:	6944                	ld	s1,144(a0)
    STORE s1, 18*REGBYTES(a1)
ffffffffc0200df8:	e9c4                	sd	s1,144(a1)
    LOAD s1, 17*REGBYTES(a0)
ffffffffc0200dfa:	6544                	ld	s1,136(a0)
    STORE s1, 17*REGBYTES(a1)
ffffffffc0200dfc:	e5c4                	sd	s1,136(a1)
    LOAD s1, 16*REGBYTES(a0)
ffffffffc0200dfe:	6144                	ld	s1,128(a0)
    STORE s1, 16*REGBYTES(a1)
ffffffffc0200e00:	e1c4                	sd	s1,128(a1)
    LOAD s1, 15*REGBYTES(a0)
ffffffffc0200e02:	7d24                	ld	s1,120(a0)
    STORE s1, 15*REGBYTES(a1)
ffffffffc0200e04:	fda4                	sd	s1,120(a1)
    LOAD s1, 14*REGBYTES(a0)
ffffffffc0200e06:	7924                	ld	s1,112(a0)
    STORE s1, 14*REGBYTES(a1)
ffffffffc0200e08:	f9a4                	sd	s1,112(a1)
    LOAD s1, 13*REGBYTES(a0)
ffffffffc0200e0a:	7524                	ld	s1,104(a0)
    STORE s1, 13*REGBYTES(a1)
ffffffffc0200e0c:	f5a4                	sd	s1,104(a1)
    LOAD s1, 12*REGBYTES(a0)
ffffffffc0200e0e:	7124                	ld	s1,96(a0)
    STORE s1, 12*REGBYTES(a1)
ffffffffc0200e10:	f1a4                	sd	s1,96(a1)
    LOAD s1, 11*REGBYTES(a0)
ffffffffc0200e12:	6d24                	ld	s1,88(a0)
    STORE s1, 11*REGBYTES(a1)
ffffffffc0200e14:	eda4                	sd	s1,88(a1)
    LOAD s1, 10*REGBYTES(a0)
ffffffffc0200e16:	6924                	ld	s1,80(a0)
    STORE s1, 10*REGBYTES(a1)
ffffffffc0200e18:	e9a4                	sd	s1,80(a1)
    LOAD s1, 9*REGBYTES(a0)
ffffffffc0200e1a:	6524                	ld	s1,72(a0)
    STORE s1, 9*REGBYTES(a1)
ffffffffc0200e1c:	e5a4                	sd	s1,72(a1)
    LOAD s1, 8*REGBYTES(a0)
ffffffffc0200e1e:	6124                	ld	s1,64(a0)
    STORE s1, 8*REGBYTES(a1)
ffffffffc0200e20:	e1a4                	sd	s1,64(a1)
    LOAD s1, 7*REGBYTES(a0)
ffffffffc0200e22:	7d04                	ld	s1,56(a0)
    STORE s1, 7*REGBYTES(a1)
ffffffffc0200e24:	fd84                	sd	s1,56(a1)
    LOAD s1, 6*REGBYTES(a0)
ffffffffc0200e26:	7904                	ld	s1,48(a0)
    STORE s1, 6*REGBYTES(a1)
ffffffffc0200e28:	f984                	sd	s1,48(a1)
    LOAD s1, 5*REGBYTES(a0)
ffffffffc0200e2a:	7504                	ld	s1,40(a0)
    STORE s1, 5*REGBYTES(a1)
ffffffffc0200e2c:	f584                	sd	s1,40(a1)
    LOAD s1, 4*REGBYTES(a0)
ffffffffc0200e2e:	7104                	ld	s1,32(a0)
    STORE s1, 4*REGBYTES(a1)
ffffffffc0200e30:	f184                	sd	s1,32(a1)
    LOAD s1, 3*REGBYTES(a0)
ffffffffc0200e32:	6d04                	ld	s1,24(a0)
    STORE s1, 3*REGBYTES(a1)
ffffffffc0200e34:	ed84                	sd	s1,24(a1)
    LOAD s1, 2*REGBYTES(a0)
ffffffffc0200e36:	6904                	ld	s1,16(a0)
    STORE s1, 2*REGBYTES(a1)
ffffffffc0200e38:	e984                	sd	s1,16(a1)
    LOAD s1, 1*REGBYTES(a0)
ffffffffc0200e3a:	6504                	ld	s1,8(a0)
    STORE s1, 1*REGBYTES(a1)
ffffffffc0200e3c:	e584                	sd	s1,8(a1)
    LOAD s1, 0*REGBYTES(a0)
ffffffffc0200e3e:	6104                	ld	s1,0(a0)
    STORE s1, 0*REGBYTES(a1)
ffffffffc0200e40:	e184                	sd	s1,0(a1)

    // acutually adjust sp
    move sp, a1
ffffffffc0200e42:	812e                	mv	sp,a1
ffffffffc0200e44:	bdf5                	j	ffffffffc0200d40 <__trapret>

ffffffffc0200e46 <default_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200e46:	000c8797          	auipc	a5,0xc8
ffffffffc0200e4a:	47278793          	addi	a5,a5,1138 # ffffffffc02c92b8 <free_area>
ffffffffc0200e4e:	e79c                	sd	a5,8(a5)
ffffffffc0200e50:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0200e52:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200e56:	8082                	ret

ffffffffc0200e58 <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200e58:	000c8517          	auipc	a0,0xc8
ffffffffc0200e5c:	47056503          	lwu	a0,1136(a0) # ffffffffc02c92c8 <free_area+0x10>
ffffffffc0200e60:	8082                	ret

ffffffffc0200e62 <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc0200e62:	715d                	addi	sp,sp,-80
ffffffffc0200e64:	f84a                	sd	s2,48(sp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200e66:	000c8917          	auipc	s2,0xc8
ffffffffc0200e6a:	45290913          	addi	s2,s2,1106 # ffffffffc02c92b8 <free_area>
ffffffffc0200e6e:	00893783          	ld	a5,8(s2)
ffffffffc0200e72:	e486                	sd	ra,72(sp)
ffffffffc0200e74:	e0a2                	sd	s0,64(sp)
ffffffffc0200e76:	fc26                	sd	s1,56(sp)
ffffffffc0200e78:	f44e                	sd	s3,40(sp)
ffffffffc0200e7a:	f052                	sd	s4,32(sp)
ffffffffc0200e7c:	ec56                	sd	s5,24(sp)
ffffffffc0200e7e:	e85a                	sd	s6,16(sp)
ffffffffc0200e80:	e45e                	sd	s7,8(sp)
ffffffffc0200e82:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200e84:	31278463          	beq	a5,s2,ffffffffc020118c <default_check+0x32a>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200e88:	ff07b703          	ld	a4,-16(a5)
ffffffffc0200e8c:	8305                	srli	a4,a4,0x1
ffffffffc0200e8e:	8b05                	andi	a4,a4,1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0200e90:	30070263          	beqz	a4,ffffffffc0201194 <default_check+0x332>
    int count = 0, total = 0;
ffffffffc0200e94:	4401                	li	s0,0
ffffffffc0200e96:	4481                	li	s1,0
ffffffffc0200e98:	a031                	j	ffffffffc0200ea4 <default_check+0x42>
ffffffffc0200e9a:	ff07b703          	ld	a4,-16(a5)
        assert(PageProperty(p));
ffffffffc0200e9e:	8b09                	andi	a4,a4,2
ffffffffc0200ea0:	2e070a63          	beqz	a4,ffffffffc0201194 <default_check+0x332>
        count ++, total += p->property;
ffffffffc0200ea4:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200ea8:	679c                	ld	a5,8(a5)
ffffffffc0200eaa:	2485                	addiw	s1,s1,1
ffffffffc0200eac:	9c39                	addw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200eae:	ff2796e3          	bne	a5,s2,ffffffffc0200e9a <default_check+0x38>
ffffffffc0200eb2:	89a2                	mv	s3,s0
    }
    assert(total == nr_free_pages());
ffffffffc0200eb4:	05c010ef          	jal	ra,ffffffffc0201f10 <nr_free_pages>
ffffffffc0200eb8:	73351e63          	bne	a0,s3,ffffffffc02015f4 <default_check+0x792>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200ebc:	4505                	li	a0,1
ffffffffc0200ebe:	785000ef          	jal	ra,ffffffffc0201e42 <alloc_pages>
ffffffffc0200ec2:	8a2a                	mv	s4,a0
ffffffffc0200ec4:	46050863          	beqz	a0,ffffffffc0201334 <default_check+0x4d2>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200ec8:	4505                	li	a0,1
ffffffffc0200eca:	779000ef          	jal	ra,ffffffffc0201e42 <alloc_pages>
ffffffffc0200ece:	89aa                	mv	s3,a0
ffffffffc0200ed0:	74050263          	beqz	a0,ffffffffc0201614 <default_check+0x7b2>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200ed4:	4505                	li	a0,1
ffffffffc0200ed6:	76d000ef          	jal	ra,ffffffffc0201e42 <alloc_pages>
ffffffffc0200eda:	8aaa                	mv	s5,a0
ffffffffc0200edc:	4c050c63          	beqz	a0,ffffffffc02013b4 <default_check+0x552>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200ee0:	2d3a0a63          	beq	s4,s3,ffffffffc02011b4 <default_check+0x352>
ffffffffc0200ee4:	2caa0863          	beq	s4,a0,ffffffffc02011b4 <default_check+0x352>
ffffffffc0200ee8:	2ca98663          	beq	s3,a0,ffffffffc02011b4 <default_check+0x352>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200eec:	000a2783          	lw	a5,0(s4)
ffffffffc0200ef0:	2e079263          	bnez	a5,ffffffffc02011d4 <default_check+0x372>
ffffffffc0200ef4:	0009a783          	lw	a5,0(s3)
ffffffffc0200ef8:	2c079e63          	bnez	a5,ffffffffc02011d4 <default_check+0x372>
ffffffffc0200efc:	411c                	lw	a5,0(a0)
ffffffffc0200efe:	2c079b63          	bnez	a5,ffffffffc02011d4 <default_check+0x372>
extern size_t npage;
extern uint_t va_pa_offset;

static inline ppn_t
page2ppn(struct Page *page) {
    return page - pages + nbase;
ffffffffc0200f02:	000c8797          	auipc	a5,0xc8
ffffffffc0200f06:	3e678793          	addi	a5,a5,998 # ffffffffc02c92e8 <pages>
ffffffffc0200f0a:	639c                	ld	a5,0(a5)
ffffffffc0200f0c:	0000b717          	auipc	a4,0xb
ffffffffc0200f10:	09470713          	addi	a4,a4,148 # ffffffffc020bfa0 <nbase>
ffffffffc0200f14:	6310                	ld	a2,0(a4)
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200f16:	000c8717          	auipc	a4,0xc8
ffffffffc0200f1a:	35270713          	addi	a4,a4,850 # ffffffffc02c9268 <npage>
ffffffffc0200f1e:	6314                	ld	a3,0(a4)
ffffffffc0200f20:	40fa0733          	sub	a4,s4,a5
ffffffffc0200f24:	8719                	srai	a4,a4,0x6
ffffffffc0200f26:	9732                	add	a4,a4,a2
ffffffffc0200f28:	06b2                	slli	a3,a3,0xc
}

static inline uintptr_t
page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
ffffffffc0200f2a:	0732                	slli	a4,a4,0xc
ffffffffc0200f2c:	2cd77463          	bleu	a3,a4,ffffffffc02011f4 <default_check+0x392>
    return page - pages + nbase;
ffffffffc0200f30:	40f98733          	sub	a4,s3,a5
ffffffffc0200f34:	8719                	srai	a4,a4,0x6
ffffffffc0200f36:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200f38:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200f3a:	4ed77d63          	bleu	a3,a4,ffffffffc0201434 <default_check+0x5d2>
    return page - pages + nbase;
ffffffffc0200f3e:	40f507b3          	sub	a5,a0,a5
ffffffffc0200f42:	8799                	srai	a5,a5,0x6
ffffffffc0200f44:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200f46:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200f48:	34d7f663          	bleu	a3,a5,ffffffffc0201294 <default_check+0x432>
    assert(alloc_page() == NULL);
ffffffffc0200f4c:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200f4e:	00093c03          	ld	s8,0(s2)
ffffffffc0200f52:	00893b83          	ld	s7,8(s2)
    unsigned int nr_free_store = nr_free;
ffffffffc0200f56:	01092b03          	lw	s6,16(s2)
    elm->prev = elm->next = elm;
ffffffffc0200f5a:	000c8797          	auipc	a5,0xc8
ffffffffc0200f5e:	3727b323          	sd	s2,870(a5) # ffffffffc02c92c0 <free_area+0x8>
ffffffffc0200f62:	000c8797          	auipc	a5,0xc8
ffffffffc0200f66:	3527bb23          	sd	s2,854(a5) # ffffffffc02c92b8 <free_area>
    nr_free = 0;
ffffffffc0200f6a:	000c8797          	auipc	a5,0xc8
ffffffffc0200f6e:	3407af23          	sw	zero,862(a5) # ffffffffc02c92c8 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0200f72:	6d1000ef          	jal	ra,ffffffffc0201e42 <alloc_pages>
ffffffffc0200f76:	2e051f63          	bnez	a0,ffffffffc0201274 <default_check+0x412>
    free_page(p0);
ffffffffc0200f7a:	4585                	li	a1,1
ffffffffc0200f7c:	8552                	mv	a0,s4
ffffffffc0200f7e:	74d000ef          	jal	ra,ffffffffc0201eca <free_pages>
    free_page(p1);
ffffffffc0200f82:	4585                	li	a1,1
ffffffffc0200f84:	854e                	mv	a0,s3
ffffffffc0200f86:	745000ef          	jal	ra,ffffffffc0201eca <free_pages>
    free_page(p2);
ffffffffc0200f8a:	4585                	li	a1,1
ffffffffc0200f8c:	8556                	mv	a0,s5
ffffffffc0200f8e:	73d000ef          	jal	ra,ffffffffc0201eca <free_pages>
    assert(nr_free == 3);
ffffffffc0200f92:	01092703          	lw	a4,16(s2)
ffffffffc0200f96:	478d                	li	a5,3
ffffffffc0200f98:	2af71e63          	bne	a4,a5,ffffffffc0201254 <default_check+0x3f2>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200f9c:	4505                	li	a0,1
ffffffffc0200f9e:	6a5000ef          	jal	ra,ffffffffc0201e42 <alloc_pages>
ffffffffc0200fa2:	89aa                	mv	s3,a0
ffffffffc0200fa4:	28050863          	beqz	a0,ffffffffc0201234 <default_check+0x3d2>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200fa8:	4505                	li	a0,1
ffffffffc0200faa:	699000ef          	jal	ra,ffffffffc0201e42 <alloc_pages>
ffffffffc0200fae:	8aaa                	mv	s5,a0
ffffffffc0200fb0:	3e050263          	beqz	a0,ffffffffc0201394 <default_check+0x532>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200fb4:	4505                	li	a0,1
ffffffffc0200fb6:	68d000ef          	jal	ra,ffffffffc0201e42 <alloc_pages>
ffffffffc0200fba:	8a2a                	mv	s4,a0
ffffffffc0200fbc:	3a050c63          	beqz	a0,ffffffffc0201374 <default_check+0x512>
    assert(alloc_page() == NULL);
ffffffffc0200fc0:	4505                	li	a0,1
ffffffffc0200fc2:	681000ef          	jal	ra,ffffffffc0201e42 <alloc_pages>
ffffffffc0200fc6:	38051763          	bnez	a0,ffffffffc0201354 <default_check+0x4f2>
    free_page(p0);
ffffffffc0200fca:	4585                	li	a1,1
ffffffffc0200fcc:	854e                	mv	a0,s3
ffffffffc0200fce:	6fd000ef          	jal	ra,ffffffffc0201eca <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0200fd2:	00893783          	ld	a5,8(s2)
ffffffffc0200fd6:	23278f63          	beq	a5,s2,ffffffffc0201214 <default_check+0x3b2>
    assert((p = alloc_page()) == p0);
ffffffffc0200fda:	4505                	li	a0,1
ffffffffc0200fdc:	667000ef          	jal	ra,ffffffffc0201e42 <alloc_pages>
ffffffffc0200fe0:	32a99a63          	bne	s3,a0,ffffffffc0201314 <default_check+0x4b2>
    assert(alloc_page() == NULL);
ffffffffc0200fe4:	4505                	li	a0,1
ffffffffc0200fe6:	65d000ef          	jal	ra,ffffffffc0201e42 <alloc_pages>
ffffffffc0200fea:	30051563          	bnez	a0,ffffffffc02012f4 <default_check+0x492>
    assert(nr_free == 0);
ffffffffc0200fee:	01092783          	lw	a5,16(s2)
ffffffffc0200ff2:	2e079163          	bnez	a5,ffffffffc02012d4 <default_check+0x472>
    free_page(p);
ffffffffc0200ff6:	854e                	mv	a0,s3
ffffffffc0200ff8:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0200ffa:	000c8797          	auipc	a5,0xc8
ffffffffc0200ffe:	2b87bf23          	sd	s8,702(a5) # ffffffffc02c92b8 <free_area>
ffffffffc0201002:	000c8797          	auipc	a5,0xc8
ffffffffc0201006:	2b77bf23          	sd	s7,702(a5) # ffffffffc02c92c0 <free_area+0x8>
    nr_free = nr_free_store;
ffffffffc020100a:	000c8797          	auipc	a5,0xc8
ffffffffc020100e:	2b67af23          	sw	s6,702(a5) # ffffffffc02c92c8 <free_area+0x10>
    free_page(p);
ffffffffc0201012:	6b9000ef          	jal	ra,ffffffffc0201eca <free_pages>
    free_page(p1);
ffffffffc0201016:	4585                	li	a1,1
ffffffffc0201018:	8556                	mv	a0,s5
ffffffffc020101a:	6b1000ef          	jal	ra,ffffffffc0201eca <free_pages>
    free_page(p2);
ffffffffc020101e:	4585                	li	a1,1
ffffffffc0201020:	8552                	mv	a0,s4
ffffffffc0201022:	6a9000ef          	jal	ra,ffffffffc0201eca <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0201026:	4515                	li	a0,5
ffffffffc0201028:	61b000ef          	jal	ra,ffffffffc0201e42 <alloc_pages>
ffffffffc020102c:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc020102e:	28050363          	beqz	a0,ffffffffc02012b4 <default_check+0x452>
ffffffffc0201032:	651c                	ld	a5,8(a0)
ffffffffc0201034:	8385                	srli	a5,a5,0x1
ffffffffc0201036:	8b85                	andi	a5,a5,1
    assert(!PageProperty(p0));
ffffffffc0201038:	54079e63          	bnez	a5,ffffffffc0201594 <default_check+0x732>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc020103c:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc020103e:	00093b03          	ld	s6,0(s2)
ffffffffc0201042:	00893a83          	ld	s5,8(s2)
ffffffffc0201046:	000c8797          	auipc	a5,0xc8
ffffffffc020104a:	2727b923          	sd	s2,626(a5) # ffffffffc02c92b8 <free_area>
ffffffffc020104e:	000c8797          	auipc	a5,0xc8
ffffffffc0201052:	2727b923          	sd	s2,626(a5) # ffffffffc02c92c0 <free_area+0x8>
    assert(alloc_page() == NULL);
ffffffffc0201056:	5ed000ef          	jal	ra,ffffffffc0201e42 <alloc_pages>
ffffffffc020105a:	50051d63          	bnez	a0,ffffffffc0201574 <default_check+0x712>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc020105e:	08098a13          	addi	s4,s3,128
ffffffffc0201062:	8552                	mv	a0,s4
ffffffffc0201064:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc0201066:	01092b83          	lw	s7,16(s2)
    nr_free = 0;
ffffffffc020106a:	000c8797          	auipc	a5,0xc8
ffffffffc020106e:	2407af23          	sw	zero,606(a5) # ffffffffc02c92c8 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc0201072:	659000ef          	jal	ra,ffffffffc0201eca <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0201076:	4511                	li	a0,4
ffffffffc0201078:	5cb000ef          	jal	ra,ffffffffc0201e42 <alloc_pages>
ffffffffc020107c:	4c051c63          	bnez	a0,ffffffffc0201554 <default_check+0x6f2>
ffffffffc0201080:	0889b783          	ld	a5,136(s3)
ffffffffc0201084:	8385                	srli	a5,a5,0x1
ffffffffc0201086:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0201088:	4a078663          	beqz	a5,ffffffffc0201534 <default_check+0x6d2>
ffffffffc020108c:	0909a703          	lw	a4,144(s3)
ffffffffc0201090:	478d                	li	a5,3
ffffffffc0201092:	4af71163          	bne	a4,a5,ffffffffc0201534 <default_check+0x6d2>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0201096:	450d                	li	a0,3
ffffffffc0201098:	5ab000ef          	jal	ra,ffffffffc0201e42 <alloc_pages>
ffffffffc020109c:	8c2a                	mv	s8,a0
ffffffffc020109e:	46050b63          	beqz	a0,ffffffffc0201514 <default_check+0x6b2>
    assert(alloc_page() == NULL);
ffffffffc02010a2:	4505                	li	a0,1
ffffffffc02010a4:	59f000ef          	jal	ra,ffffffffc0201e42 <alloc_pages>
ffffffffc02010a8:	44051663          	bnez	a0,ffffffffc02014f4 <default_check+0x692>
    assert(p0 + 2 == p1);
ffffffffc02010ac:	438a1463          	bne	s4,s8,ffffffffc02014d4 <default_check+0x672>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc02010b0:	4585                	li	a1,1
ffffffffc02010b2:	854e                	mv	a0,s3
ffffffffc02010b4:	617000ef          	jal	ra,ffffffffc0201eca <free_pages>
    free_pages(p1, 3);
ffffffffc02010b8:	458d                	li	a1,3
ffffffffc02010ba:	8552                	mv	a0,s4
ffffffffc02010bc:	60f000ef          	jal	ra,ffffffffc0201eca <free_pages>
ffffffffc02010c0:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc02010c4:	04098c13          	addi	s8,s3,64
ffffffffc02010c8:	8385                	srli	a5,a5,0x1
ffffffffc02010ca:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc02010cc:	3e078463          	beqz	a5,ffffffffc02014b4 <default_check+0x652>
ffffffffc02010d0:	0109a703          	lw	a4,16(s3)
ffffffffc02010d4:	4785                	li	a5,1
ffffffffc02010d6:	3cf71f63          	bne	a4,a5,ffffffffc02014b4 <default_check+0x652>
ffffffffc02010da:	008a3783          	ld	a5,8(s4)
ffffffffc02010de:	8385                	srli	a5,a5,0x1
ffffffffc02010e0:	8b85                	andi	a5,a5,1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc02010e2:	3a078963          	beqz	a5,ffffffffc0201494 <default_check+0x632>
ffffffffc02010e6:	010a2703          	lw	a4,16(s4)
ffffffffc02010ea:	478d                	li	a5,3
ffffffffc02010ec:	3af71463          	bne	a4,a5,ffffffffc0201494 <default_check+0x632>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc02010f0:	4505                	li	a0,1
ffffffffc02010f2:	551000ef          	jal	ra,ffffffffc0201e42 <alloc_pages>
ffffffffc02010f6:	36a99f63          	bne	s3,a0,ffffffffc0201474 <default_check+0x612>
    free_page(p0);
ffffffffc02010fa:	4585                	li	a1,1
ffffffffc02010fc:	5cf000ef          	jal	ra,ffffffffc0201eca <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0201100:	4509                	li	a0,2
ffffffffc0201102:	541000ef          	jal	ra,ffffffffc0201e42 <alloc_pages>
ffffffffc0201106:	34aa1763          	bne	s4,a0,ffffffffc0201454 <default_check+0x5f2>

    free_pages(p0, 2);
ffffffffc020110a:	4589                	li	a1,2
ffffffffc020110c:	5bf000ef          	jal	ra,ffffffffc0201eca <free_pages>
    free_page(p2);
ffffffffc0201110:	4585                	li	a1,1
ffffffffc0201112:	8562                	mv	a0,s8
ffffffffc0201114:	5b7000ef          	jal	ra,ffffffffc0201eca <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0201118:	4515                	li	a0,5
ffffffffc020111a:	529000ef          	jal	ra,ffffffffc0201e42 <alloc_pages>
ffffffffc020111e:	89aa                	mv	s3,a0
ffffffffc0201120:	48050a63          	beqz	a0,ffffffffc02015b4 <default_check+0x752>
    assert(alloc_page() == NULL);
ffffffffc0201124:	4505                	li	a0,1
ffffffffc0201126:	51d000ef          	jal	ra,ffffffffc0201e42 <alloc_pages>
ffffffffc020112a:	2e051563          	bnez	a0,ffffffffc0201414 <default_check+0x5b2>

    assert(nr_free == 0);
ffffffffc020112e:	01092783          	lw	a5,16(s2)
ffffffffc0201132:	2c079163          	bnez	a5,ffffffffc02013f4 <default_check+0x592>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0201136:	4595                	li	a1,5
ffffffffc0201138:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc020113a:	000c8797          	auipc	a5,0xc8
ffffffffc020113e:	1977a723          	sw	s7,398(a5) # ffffffffc02c92c8 <free_area+0x10>
    free_list = free_list_store;
ffffffffc0201142:	000c8797          	auipc	a5,0xc8
ffffffffc0201146:	1767bb23          	sd	s6,374(a5) # ffffffffc02c92b8 <free_area>
ffffffffc020114a:	000c8797          	auipc	a5,0xc8
ffffffffc020114e:	1757bb23          	sd	s5,374(a5) # ffffffffc02c92c0 <free_area+0x8>
    free_pages(p0, 5);
ffffffffc0201152:	579000ef          	jal	ra,ffffffffc0201eca <free_pages>
    return listelm->next;
ffffffffc0201156:	00893783          	ld	a5,8(s2)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc020115a:	01278963          	beq	a5,s2,ffffffffc020116c <default_check+0x30a>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc020115e:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201162:	679c                	ld	a5,8(a5)
ffffffffc0201164:	34fd                	addiw	s1,s1,-1
ffffffffc0201166:	9c19                	subw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201168:	ff279be3          	bne	a5,s2,ffffffffc020115e <default_check+0x2fc>
    }
    assert(count == 0);
ffffffffc020116c:	26049463          	bnez	s1,ffffffffc02013d4 <default_check+0x572>
    assert(total == 0);
ffffffffc0201170:	46041263          	bnez	s0,ffffffffc02015d4 <default_check+0x772>
}
ffffffffc0201174:	60a6                	ld	ra,72(sp)
ffffffffc0201176:	6406                	ld	s0,64(sp)
ffffffffc0201178:	74e2                	ld	s1,56(sp)
ffffffffc020117a:	7942                	ld	s2,48(sp)
ffffffffc020117c:	79a2                	ld	s3,40(sp)
ffffffffc020117e:	7a02                	ld	s4,32(sp)
ffffffffc0201180:	6ae2                	ld	s5,24(sp)
ffffffffc0201182:	6b42                	ld	s6,16(sp)
ffffffffc0201184:	6ba2                	ld	s7,8(sp)
ffffffffc0201186:	6c02                	ld	s8,0(sp)
ffffffffc0201188:	6161                	addi	sp,sp,80
ffffffffc020118a:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc020118c:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc020118e:	4401                	li	s0,0
ffffffffc0201190:	4481                	li	s1,0
ffffffffc0201192:	b30d                	j	ffffffffc0200eb4 <default_check+0x52>
        assert(PageProperty(p));
ffffffffc0201194:	00009697          	auipc	a3,0x9
ffffffffc0201198:	97468693          	addi	a3,a3,-1676 # ffffffffc0209b08 <commands+0x878>
ffffffffc020119c:	00008617          	auipc	a2,0x8
ffffffffc02011a0:	5b460613          	addi	a2,a2,1460 # ffffffffc0209750 <commands+0x4c0>
ffffffffc02011a4:	0ef00593          	li	a1,239
ffffffffc02011a8:	00009517          	auipc	a0,0x9
ffffffffc02011ac:	97050513          	addi	a0,a0,-1680 # ffffffffc0209b18 <commands+0x888>
ffffffffc02011b0:	ad8ff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc02011b4:	00009697          	auipc	a3,0x9
ffffffffc02011b8:	9fc68693          	addi	a3,a3,-1540 # ffffffffc0209bb0 <commands+0x920>
ffffffffc02011bc:	00008617          	auipc	a2,0x8
ffffffffc02011c0:	59460613          	addi	a2,a2,1428 # ffffffffc0209750 <commands+0x4c0>
ffffffffc02011c4:	0bc00593          	li	a1,188
ffffffffc02011c8:	00009517          	auipc	a0,0x9
ffffffffc02011cc:	95050513          	addi	a0,a0,-1712 # ffffffffc0209b18 <commands+0x888>
ffffffffc02011d0:	ab8ff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc02011d4:	00009697          	auipc	a3,0x9
ffffffffc02011d8:	a0468693          	addi	a3,a3,-1532 # ffffffffc0209bd8 <commands+0x948>
ffffffffc02011dc:	00008617          	auipc	a2,0x8
ffffffffc02011e0:	57460613          	addi	a2,a2,1396 # ffffffffc0209750 <commands+0x4c0>
ffffffffc02011e4:	0bd00593          	li	a1,189
ffffffffc02011e8:	00009517          	auipc	a0,0x9
ffffffffc02011ec:	93050513          	addi	a0,a0,-1744 # ffffffffc0209b18 <commands+0x888>
ffffffffc02011f0:	a98ff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc02011f4:	00009697          	auipc	a3,0x9
ffffffffc02011f8:	a2468693          	addi	a3,a3,-1500 # ffffffffc0209c18 <commands+0x988>
ffffffffc02011fc:	00008617          	auipc	a2,0x8
ffffffffc0201200:	55460613          	addi	a2,a2,1364 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0201204:	0bf00593          	li	a1,191
ffffffffc0201208:	00009517          	auipc	a0,0x9
ffffffffc020120c:	91050513          	addi	a0,a0,-1776 # ffffffffc0209b18 <commands+0x888>
ffffffffc0201210:	a78ff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(!list_empty(&free_list));
ffffffffc0201214:	00009697          	auipc	a3,0x9
ffffffffc0201218:	a8c68693          	addi	a3,a3,-1396 # ffffffffc0209ca0 <commands+0xa10>
ffffffffc020121c:	00008617          	auipc	a2,0x8
ffffffffc0201220:	53460613          	addi	a2,a2,1332 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0201224:	0d800593          	li	a1,216
ffffffffc0201228:	00009517          	auipc	a0,0x9
ffffffffc020122c:	8f050513          	addi	a0,a0,-1808 # ffffffffc0209b18 <commands+0x888>
ffffffffc0201230:	a58ff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201234:	00009697          	auipc	a3,0x9
ffffffffc0201238:	91c68693          	addi	a3,a3,-1764 # ffffffffc0209b50 <commands+0x8c0>
ffffffffc020123c:	00008617          	auipc	a2,0x8
ffffffffc0201240:	51460613          	addi	a2,a2,1300 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0201244:	0d100593          	li	a1,209
ffffffffc0201248:	00009517          	auipc	a0,0x9
ffffffffc020124c:	8d050513          	addi	a0,a0,-1840 # ffffffffc0209b18 <commands+0x888>
ffffffffc0201250:	a38ff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(nr_free == 3);
ffffffffc0201254:	00009697          	auipc	a3,0x9
ffffffffc0201258:	a3c68693          	addi	a3,a3,-1476 # ffffffffc0209c90 <commands+0xa00>
ffffffffc020125c:	00008617          	auipc	a2,0x8
ffffffffc0201260:	4f460613          	addi	a2,a2,1268 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0201264:	0cf00593          	li	a1,207
ffffffffc0201268:	00009517          	auipc	a0,0x9
ffffffffc020126c:	8b050513          	addi	a0,a0,-1872 # ffffffffc0209b18 <commands+0x888>
ffffffffc0201270:	a18ff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201274:	00009697          	auipc	a3,0x9
ffffffffc0201278:	a0468693          	addi	a3,a3,-1532 # ffffffffc0209c78 <commands+0x9e8>
ffffffffc020127c:	00008617          	auipc	a2,0x8
ffffffffc0201280:	4d460613          	addi	a2,a2,1236 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0201284:	0ca00593          	li	a1,202
ffffffffc0201288:	00009517          	auipc	a0,0x9
ffffffffc020128c:	89050513          	addi	a0,a0,-1904 # ffffffffc0209b18 <commands+0x888>
ffffffffc0201290:	9f8ff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0201294:	00009697          	auipc	a3,0x9
ffffffffc0201298:	9c468693          	addi	a3,a3,-1596 # ffffffffc0209c58 <commands+0x9c8>
ffffffffc020129c:	00008617          	auipc	a2,0x8
ffffffffc02012a0:	4b460613          	addi	a2,a2,1204 # ffffffffc0209750 <commands+0x4c0>
ffffffffc02012a4:	0c100593          	li	a1,193
ffffffffc02012a8:	00009517          	auipc	a0,0x9
ffffffffc02012ac:	87050513          	addi	a0,a0,-1936 # ffffffffc0209b18 <commands+0x888>
ffffffffc02012b0:	9d8ff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(p0 != NULL);
ffffffffc02012b4:	00009697          	auipc	a3,0x9
ffffffffc02012b8:	a3468693          	addi	a3,a3,-1484 # ffffffffc0209ce8 <commands+0xa58>
ffffffffc02012bc:	00008617          	auipc	a2,0x8
ffffffffc02012c0:	49460613          	addi	a2,a2,1172 # ffffffffc0209750 <commands+0x4c0>
ffffffffc02012c4:	0f700593          	li	a1,247
ffffffffc02012c8:	00009517          	auipc	a0,0x9
ffffffffc02012cc:	85050513          	addi	a0,a0,-1968 # ffffffffc0209b18 <commands+0x888>
ffffffffc02012d0:	9b8ff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(nr_free == 0);
ffffffffc02012d4:	00009697          	auipc	a3,0x9
ffffffffc02012d8:	a0468693          	addi	a3,a3,-1532 # ffffffffc0209cd8 <commands+0xa48>
ffffffffc02012dc:	00008617          	auipc	a2,0x8
ffffffffc02012e0:	47460613          	addi	a2,a2,1140 # ffffffffc0209750 <commands+0x4c0>
ffffffffc02012e4:	0de00593          	li	a1,222
ffffffffc02012e8:	00009517          	auipc	a0,0x9
ffffffffc02012ec:	83050513          	addi	a0,a0,-2000 # ffffffffc0209b18 <commands+0x888>
ffffffffc02012f0:	998ff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02012f4:	00009697          	auipc	a3,0x9
ffffffffc02012f8:	98468693          	addi	a3,a3,-1660 # ffffffffc0209c78 <commands+0x9e8>
ffffffffc02012fc:	00008617          	auipc	a2,0x8
ffffffffc0201300:	45460613          	addi	a2,a2,1108 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0201304:	0dc00593          	li	a1,220
ffffffffc0201308:	00009517          	auipc	a0,0x9
ffffffffc020130c:	81050513          	addi	a0,a0,-2032 # ffffffffc0209b18 <commands+0x888>
ffffffffc0201310:	978ff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0201314:	00009697          	auipc	a3,0x9
ffffffffc0201318:	9a468693          	addi	a3,a3,-1628 # ffffffffc0209cb8 <commands+0xa28>
ffffffffc020131c:	00008617          	auipc	a2,0x8
ffffffffc0201320:	43460613          	addi	a2,a2,1076 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0201324:	0db00593          	li	a1,219
ffffffffc0201328:	00008517          	auipc	a0,0x8
ffffffffc020132c:	7f050513          	addi	a0,a0,2032 # ffffffffc0209b18 <commands+0x888>
ffffffffc0201330:	958ff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201334:	00009697          	auipc	a3,0x9
ffffffffc0201338:	81c68693          	addi	a3,a3,-2020 # ffffffffc0209b50 <commands+0x8c0>
ffffffffc020133c:	00008617          	auipc	a2,0x8
ffffffffc0201340:	41460613          	addi	a2,a2,1044 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0201344:	0b800593          	li	a1,184
ffffffffc0201348:	00008517          	auipc	a0,0x8
ffffffffc020134c:	7d050513          	addi	a0,a0,2000 # ffffffffc0209b18 <commands+0x888>
ffffffffc0201350:	938ff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201354:	00009697          	auipc	a3,0x9
ffffffffc0201358:	92468693          	addi	a3,a3,-1756 # ffffffffc0209c78 <commands+0x9e8>
ffffffffc020135c:	00008617          	auipc	a2,0x8
ffffffffc0201360:	3f460613          	addi	a2,a2,1012 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0201364:	0d500593          	li	a1,213
ffffffffc0201368:	00008517          	auipc	a0,0x8
ffffffffc020136c:	7b050513          	addi	a0,a0,1968 # ffffffffc0209b18 <commands+0x888>
ffffffffc0201370:	918ff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201374:	00009697          	auipc	a3,0x9
ffffffffc0201378:	81c68693          	addi	a3,a3,-2020 # ffffffffc0209b90 <commands+0x900>
ffffffffc020137c:	00008617          	auipc	a2,0x8
ffffffffc0201380:	3d460613          	addi	a2,a2,980 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0201384:	0d300593          	li	a1,211
ffffffffc0201388:	00008517          	auipc	a0,0x8
ffffffffc020138c:	79050513          	addi	a0,a0,1936 # ffffffffc0209b18 <commands+0x888>
ffffffffc0201390:	8f8ff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201394:	00008697          	auipc	a3,0x8
ffffffffc0201398:	7dc68693          	addi	a3,a3,2012 # ffffffffc0209b70 <commands+0x8e0>
ffffffffc020139c:	00008617          	auipc	a2,0x8
ffffffffc02013a0:	3b460613          	addi	a2,a2,948 # ffffffffc0209750 <commands+0x4c0>
ffffffffc02013a4:	0d200593          	li	a1,210
ffffffffc02013a8:	00008517          	auipc	a0,0x8
ffffffffc02013ac:	77050513          	addi	a0,a0,1904 # ffffffffc0209b18 <commands+0x888>
ffffffffc02013b0:	8d8ff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02013b4:	00008697          	auipc	a3,0x8
ffffffffc02013b8:	7dc68693          	addi	a3,a3,2012 # ffffffffc0209b90 <commands+0x900>
ffffffffc02013bc:	00008617          	auipc	a2,0x8
ffffffffc02013c0:	39460613          	addi	a2,a2,916 # ffffffffc0209750 <commands+0x4c0>
ffffffffc02013c4:	0ba00593          	li	a1,186
ffffffffc02013c8:	00008517          	auipc	a0,0x8
ffffffffc02013cc:	75050513          	addi	a0,a0,1872 # ffffffffc0209b18 <commands+0x888>
ffffffffc02013d0:	8b8ff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(count == 0);
ffffffffc02013d4:	00009697          	auipc	a3,0x9
ffffffffc02013d8:	a6468693          	addi	a3,a3,-1436 # ffffffffc0209e38 <commands+0xba8>
ffffffffc02013dc:	00008617          	auipc	a2,0x8
ffffffffc02013e0:	37460613          	addi	a2,a2,884 # ffffffffc0209750 <commands+0x4c0>
ffffffffc02013e4:	12400593          	li	a1,292
ffffffffc02013e8:	00008517          	auipc	a0,0x8
ffffffffc02013ec:	73050513          	addi	a0,a0,1840 # ffffffffc0209b18 <commands+0x888>
ffffffffc02013f0:	898ff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(nr_free == 0);
ffffffffc02013f4:	00009697          	auipc	a3,0x9
ffffffffc02013f8:	8e468693          	addi	a3,a3,-1820 # ffffffffc0209cd8 <commands+0xa48>
ffffffffc02013fc:	00008617          	auipc	a2,0x8
ffffffffc0201400:	35460613          	addi	a2,a2,852 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0201404:	11900593          	li	a1,281
ffffffffc0201408:	00008517          	auipc	a0,0x8
ffffffffc020140c:	71050513          	addi	a0,a0,1808 # ffffffffc0209b18 <commands+0x888>
ffffffffc0201410:	878ff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201414:	00009697          	auipc	a3,0x9
ffffffffc0201418:	86468693          	addi	a3,a3,-1948 # ffffffffc0209c78 <commands+0x9e8>
ffffffffc020141c:	00008617          	auipc	a2,0x8
ffffffffc0201420:	33460613          	addi	a2,a2,820 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0201424:	11700593          	li	a1,279
ffffffffc0201428:	00008517          	auipc	a0,0x8
ffffffffc020142c:	6f050513          	addi	a0,a0,1776 # ffffffffc0209b18 <commands+0x888>
ffffffffc0201430:	858ff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0201434:	00009697          	auipc	a3,0x9
ffffffffc0201438:	80468693          	addi	a3,a3,-2044 # ffffffffc0209c38 <commands+0x9a8>
ffffffffc020143c:	00008617          	auipc	a2,0x8
ffffffffc0201440:	31460613          	addi	a2,a2,788 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0201444:	0c000593          	li	a1,192
ffffffffc0201448:	00008517          	auipc	a0,0x8
ffffffffc020144c:	6d050513          	addi	a0,a0,1744 # ffffffffc0209b18 <commands+0x888>
ffffffffc0201450:	838ff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0201454:	00009697          	auipc	a3,0x9
ffffffffc0201458:	9a468693          	addi	a3,a3,-1628 # ffffffffc0209df8 <commands+0xb68>
ffffffffc020145c:	00008617          	auipc	a2,0x8
ffffffffc0201460:	2f460613          	addi	a2,a2,756 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0201464:	11100593          	li	a1,273
ffffffffc0201468:	00008517          	auipc	a0,0x8
ffffffffc020146c:	6b050513          	addi	a0,a0,1712 # ffffffffc0209b18 <commands+0x888>
ffffffffc0201470:	818ff0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0201474:	00009697          	auipc	a3,0x9
ffffffffc0201478:	96468693          	addi	a3,a3,-1692 # ffffffffc0209dd8 <commands+0xb48>
ffffffffc020147c:	00008617          	auipc	a2,0x8
ffffffffc0201480:	2d460613          	addi	a2,a2,724 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0201484:	10f00593          	li	a1,271
ffffffffc0201488:	00008517          	auipc	a0,0x8
ffffffffc020148c:	69050513          	addi	a0,a0,1680 # ffffffffc0209b18 <commands+0x888>
ffffffffc0201490:	ff9fe0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0201494:	00009697          	auipc	a3,0x9
ffffffffc0201498:	91c68693          	addi	a3,a3,-1764 # ffffffffc0209db0 <commands+0xb20>
ffffffffc020149c:	00008617          	auipc	a2,0x8
ffffffffc02014a0:	2b460613          	addi	a2,a2,692 # ffffffffc0209750 <commands+0x4c0>
ffffffffc02014a4:	10d00593          	li	a1,269
ffffffffc02014a8:	00008517          	auipc	a0,0x8
ffffffffc02014ac:	67050513          	addi	a0,a0,1648 # ffffffffc0209b18 <commands+0x888>
ffffffffc02014b0:	fd9fe0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc02014b4:	00009697          	auipc	a3,0x9
ffffffffc02014b8:	8d468693          	addi	a3,a3,-1836 # ffffffffc0209d88 <commands+0xaf8>
ffffffffc02014bc:	00008617          	auipc	a2,0x8
ffffffffc02014c0:	29460613          	addi	a2,a2,660 # ffffffffc0209750 <commands+0x4c0>
ffffffffc02014c4:	10c00593          	li	a1,268
ffffffffc02014c8:	00008517          	auipc	a0,0x8
ffffffffc02014cc:	65050513          	addi	a0,a0,1616 # ffffffffc0209b18 <commands+0x888>
ffffffffc02014d0:	fb9fe0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(p0 + 2 == p1);
ffffffffc02014d4:	00009697          	auipc	a3,0x9
ffffffffc02014d8:	8a468693          	addi	a3,a3,-1884 # ffffffffc0209d78 <commands+0xae8>
ffffffffc02014dc:	00008617          	auipc	a2,0x8
ffffffffc02014e0:	27460613          	addi	a2,a2,628 # ffffffffc0209750 <commands+0x4c0>
ffffffffc02014e4:	10700593          	li	a1,263
ffffffffc02014e8:	00008517          	auipc	a0,0x8
ffffffffc02014ec:	63050513          	addi	a0,a0,1584 # ffffffffc0209b18 <commands+0x888>
ffffffffc02014f0:	f99fe0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02014f4:	00008697          	auipc	a3,0x8
ffffffffc02014f8:	78468693          	addi	a3,a3,1924 # ffffffffc0209c78 <commands+0x9e8>
ffffffffc02014fc:	00008617          	auipc	a2,0x8
ffffffffc0201500:	25460613          	addi	a2,a2,596 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0201504:	10600593          	li	a1,262
ffffffffc0201508:	00008517          	auipc	a0,0x8
ffffffffc020150c:	61050513          	addi	a0,a0,1552 # ffffffffc0209b18 <commands+0x888>
ffffffffc0201510:	f79fe0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0201514:	00009697          	auipc	a3,0x9
ffffffffc0201518:	84468693          	addi	a3,a3,-1980 # ffffffffc0209d58 <commands+0xac8>
ffffffffc020151c:	00008617          	auipc	a2,0x8
ffffffffc0201520:	23460613          	addi	a2,a2,564 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0201524:	10500593          	li	a1,261
ffffffffc0201528:	00008517          	auipc	a0,0x8
ffffffffc020152c:	5f050513          	addi	a0,a0,1520 # ffffffffc0209b18 <commands+0x888>
ffffffffc0201530:	f59fe0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0201534:	00008697          	auipc	a3,0x8
ffffffffc0201538:	7f468693          	addi	a3,a3,2036 # ffffffffc0209d28 <commands+0xa98>
ffffffffc020153c:	00008617          	auipc	a2,0x8
ffffffffc0201540:	21460613          	addi	a2,a2,532 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0201544:	10400593          	li	a1,260
ffffffffc0201548:	00008517          	auipc	a0,0x8
ffffffffc020154c:	5d050513          	addi	a0,a0,1488 # ffffffffc0209b18 <commands+0x888>
ffffffffc0201550:	f39fe0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0201554:	00008697          	auipc	a3,0x8
ffffffffc0201558:	7bc68693          	addi	a3,a3,1980 # ffffffffc0209d10 <commands+0xa80>
ffffffffc020155c:	00008617          	auipc	a2,0x8
ffffffffc0201560:	1f460613          	addi	a2,a2,500 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0201564:	10300593          	li	a1,259
ffffffffc0201568:	00008517          	auipc	a0,0x8
ffffffffc020156c:	5b050513          	addi	a0,a0,1456 # ffffffffc0209b18 <commands+0x888>
ffffffffc0201570:	f19fe0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201574:	00008697          	auipc	a3,0x8
ffffffffc0201578:	70468693          	addi	a3,a3,1796 # ffffffffc0209c78 <commands+0x9e8>
ffffffffc020157c:	00008617          	auipc	a2,0x8
ffffffffc0201580:	1d460613          	addi	a2,a2,468 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0201584:	0fd00593          	li	a1,253
ffffffffc0201588:	00008517          	auipc	a0,0x8
ffffffffc020158c:	59050513          	addi	a0,a0,1424 # ffffffffc0209b18 <commands+0x888>
ffffffffc0201590:	ef9fe0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(!PageProperty(p0));
ffffffffc0201594:	00008697          	auipc	a3,0x8
ffffffffc0201598:	76468693          	addi	a3,a3,1892 # ffffffffc0209cf8 <commands+0xa68>
ffffffffc020159c:	00008617          	auipc	a2,0x8
ffffffffc02015a0:	1b460613          	addi	a2,a2,436 # ffffffffc0209750 <commands+0x4c0>
ffffffffc02015a4:	0f800593          	li	a1,248
ffffffffc02015a8:	00008517          	auipc	a0,0x8
ffffffffc02015ac:	57050513          	addi	a0,a0,1392 # ffffffffc0209b18 <commands+0x888>
ffffffffc02015b0:	ed9fe0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc02015b4:	00009697          	auipc	a3,0x9
ffffffffc02015b8:	86468693          	addi	a3,a3,-1948 # ffffffffc0209e18 <commands+0xb88>
ffffffffc02015bc:	00008617          	auipc	a2,0x8
ffffffffc02015c0:	19460613          	addi	a2,a2,404 # ffffffffc0209750 <commands+0x4c0>
ffffffffc02015c4:	11600593          	li	a1,278
ffffffffc02015c8:	00008517          	auipc	a0,0x8
ffffffffc02015cc:	55050513          	addi	a0,a0,1360 # ffffffffc0209b18 <commands+0x888>
ffffffffc02015d0:	eb9fe0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(total == 0);
ffffffffc02015d4:	00009697          	auipc	a3,0x9
ffffffffc02015d8:	87468693          	addi	a3,a3,-1932 # ffffffffc0209e48 <commands+0xbb8>
ffffffffc02015dc:	00008617          	auipc	a2,0x8
ffffffffc02015e0:	17460613          	addi	a2,a2,372 # ffffffffc0209750 <commands+0x4c0>
ffffffffc02015e4:	12500593          	li	a1,293
ffffffffc02015e8:	00008517          	auipc	a0,0x8
ffffffffc02015ec:	53050513          	addi	a0,a0,1328 # ffffffffc0209b18 <commands+0x888>
ffffffffc02015f0:	e99fe0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(total == nr_free_pages());
ffffffffc02015f4:	00008697          	auipc	a3,0x8
ffffffffc02015f8:	53c68693          	addi	a3,a3,1340 # ffffffffc0209b30 <commands+0x8a0>
ffffffffc02015fc:	00008617          	auipc	a2,0x8
ffffffffc0201600:	15460613          	addi	a2,a2,340 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0201604:	0f200593          	li	a1,242
ffffffffc0201608:	00008517          	auipc	a0,0x8
ffffffffc020160c:	51050513          	addi	a0,a0,1296 # ffffffffc0209b18 <commands+0x888>
ffffffffc0201610:	e79fe0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201614:	00008697          	auipc	a3,0x8
ffffffffc0201618:	55c68693          	addi	a3,a3,1372 # ffffffffc0209b70 <commands+0x8e0>
ffffffffc020161c:	00008617          	auipc	a2,0x8
ffffffffc0201620:	13460613          	addi	a2,a2,308 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0201624:	0b900593          	li	a1,185
ffffffffc0201628:	00008517          	auipc	a0,0x8
ffffffffc020162c:	4f050513          	addi	a0,a0,1264 # ffffffffc0209b18 <commands+0x888>
ffffffffc0201630:	e59fe0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0201634 <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc0201634:	1141                	addi	sp,sp,-16
ffffffffc0201636:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201638:	16058e63          	beqz	a1,ffffffffc02017b4 <default_free_pages+0x180>
    for (; p != base + n; p ++) {
ffffffffc020163c:	00659693          	slli	a3,a1,0x6
ffffffffc0201640:	96aa                	add	a3,a3,a0
ffffffffc0201642:	02d50d63          	beq	a0,a3,ffffffffc020167c <default_free_pages+0x48>
ffffffffc0201646:	651c                	ld	a5,8(a0)
ffffffffc0201648:	8b85                	andi	a5,a5,1
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc020164a:	14079563          	bnez	a5,ffffffffc0201794 <default_free_pages+0x160>
ffffffffc020164e:	651c                	ld	a5,8(a0)
ffffffffc0201650:	8385                	srli	a5,a5,0x1
ffffffffc0201652:	8b85                	andi	a5,a5,1
ffffffffc0201654:	14079063          	bnez	a5,ffffffffc0201794 <default_free_pages+0x160>
ffffffffc0201658:	87aa                	mv	a5,a0
ffffffffc020165a:	a809                	j	ffffffffc020166c <default_free_pages+0x38>
ffffffffc020165c:	6798                	ld	a4,8(a5)
ffffffffc020165e:	8b05                	andi	a4,a4,1
ffffffffc0201660:	12071a63          	bnez	a4,ffffffffc0201794 <default_free_pages+0x160>
ffffffffc0201664:	6798                	ld	a4,8(a5)
ffffffffc0201666:	8b09                	andi	a4,a4,2
ffffffffc0201668:	12071663          	bnez	a4,ffffffffc0201794 <default_free_pages+0x160>
        p->flags = 0;
ffffffffc020166c:	0007b423          	sd	zero,8(a5)
    return page->ref;
}

static inline void
set_page_ref(struct Page *page, int val) {
    page->ref = val;
ffffffffc0201670:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0201674:	04078793          	addi	a5,a5,64
ffffffffc0201678:	fed792e3          	bne	a5,a3,ffffffffc020165c <default_free_pages+0x28>
    base->property = n;
ffffffffc020167c:	2581                	sext.w	a1,a1
ffffffffc020167e:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc0201680:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201684:	4789                	li	a5,2
ffffffffc0201686:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc020168a:	000c8697          	auipc	a3,0xc8
ffffffffc020168e:	c2e68693          	addi	a3,a3,-978 # ffffffffc02c92b8 <free_area>
ffffffffc0201692:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0201694:	669c                	ld	a5,8(a3)
ffffffffc0201696:	9db9                	addw	a1,a1,a4
ffffffffc0201698:	000c8717          	auipc	a4,0xc8
ffffffffc020169c:	c2b72823          	sw	a1,-976(a4) # ffffffffc02c92c8 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc02016a0:	0cd78163          	beq	a5,a3,ffffffffc0201762 <default_free_pages+0x12e>
            struct Page* page = le2page(le, page_link);
ffffffffc02016a4:	fe878713          	addi	a4,a5,-24
ffffffffc02016a8:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc02016aa:	4801                	li	a6,0
ffffffffc02016ac:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc02016b0:	00e56a63          	bltu	a0,a4,ffffffffc02016c4 <default_free_pages+0x90>
    return listelm->next;
ffffffffc02016b4:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc02016b6:	04d70f63          	beq	a4,a3,ffffffffc0201714 <default_free_pages+0xe0>
        while ((le = list_next(le)) != &free_list) {
ffffffffc02016ba:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc02016bc:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc02016c0:	fee57ae3          	bleu	a4,a0,ffffffffc02016b4 <default_free_pages+0x80>
ffffffffc02016c4:	00080663          	beqz	a6,ffffffffc02016d0 <default_free_pages+0x9c>
ffffffffc02016c8:	000c8817          	auipc	a6,0xc8
ffffffffc02016cc:	beb83823          	sd	a1,-1040(a6) # ffffffffc02c92b8 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc02016d0:	638c                	ld	a1,0(a5)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc02016d2:	e390                	sd	a2,0(a5)
ffffffffc02016d4:	e590                	sd	a2,8(a1)
    elm->next = next;
ffffffffc02016d6:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02016d8:	ed0c                	sd	a1,24(a0)
    if (le != &free_list) {
ffffffffc02016da:	06d58a63          	beq	a1,a3,ffffffffc020174e <default_free_pages+0x11a>
        if (p + p->property == base) {
ffffffffc02016de:	ff85a603          	lw	a2,-8(a1)
        p = le2page(le, page_link);
ffffffffc02016e2:	fe858713          	addi	a4,a1,-24
        if (p + p->property == base) {
ffffffffc02016e6:	02061793          	slli	a5,a2,0x20
ffffffffc02016ea:	83e9                	srli	a5,a5,0x1a
ffffffffc02016ec:	97ba                	add	a5,a5,a4
ffffffffc02016ee:	04f51b63          	bne	a0,a5,ffffffffc0201744 <default_free_pages+0x110>
            p->property += base->property;
ffffffffc02016f2:	491c                	lw	a5,16(a0)
ffffffffc02016f4:	9e3d                	addw	a2,a2,a5
ffffffffc02016f6:	fec5ac23          	sw	a2,-8(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02016fa:	57f5                	li	a5,-3
ffffffffc02016fc:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201700:	01853803          	ld	a6,24(a0)
ffffffffc0201704:	7110                	ld	a2,32(a0)
            base = p;
ffffffffc0201706:	853a                	mv	a0,a4
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0201708:	00c83423          	sd	a2,8(a6)
    next->prev = prev;
ffffffffc020170c:	659c                	ld	a5,8(a1)
ffffffffc020170e:	01063023          	sd	a6,0(a2)
ffffffffc0201712:	a815                	j	ffffffffc0201746 <default_free_pages+0x112>
    prev->next = next->prev = elm;
ffffffffc0201714:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201716:	f114                	sd	a3,32(a0)
ffffffffc0201718:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc020171a:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc020171c:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc020171e:	00d70563          	beq	a4,a3,ffffffffc0201728 <default_free_pages+0xf4>
ffffffffc0201722:	4805                	li	a6,1
ffffffffc0201724:	87ba                	mv	a5,a4
ffffffffc0201726:	bf59                	j	ffffffffc02016bc <default_free_pages+0x88>
ffffffffc0201728:	e290                	sd	a2,0(a3)
    return listelm->prev;
ffffffffc020172a:	85be                	mv	a1,a5
    if (le != &free_list) {
ffffffffc020172c:	00d78d63          	beq	a5,a3,ffffffffc0201746 <default_free_pages+0x112>
        if (p + p->property == base) {
ffffffffc0201730:	ff85a603          	lw	a2,-8(a1)
        p = le2page(le, page_link);
ffffffffc0201734:	fe858713          	addi	a4,a1,-24
        if (p + p->property == base) {
ffffffffc0201738:	02061793          	slli	a5,a2,0x20
ffffffffc020173c:	83e9                	srli	a5,a5,0x1a
ffffffffc020173e:	97ba                	add	a5,a5,a4
ffffffffc0201740:	faf509e3          	beq	a0,a5,ffffffffc02016f2 <default_free_pages+0xbe>
ffffffffc0201744:	711c                	ld	a5,32(a0)
    if (le != &free_list) {
ffffffffc0201746:	fe878713          	addi	a4,a5,-24
ffffffffc020174a:	00d78963          	beq	a5,a3,ffffffffc020175c <default_free_pages+0x128>
        if (base + base->property == p) {
ffffffffc020174e:	4910                	lw	a2,16(a0)
ffffffffc0201750:	02061693          	slli	a3,a2,0x20
ffffffffc0201754:	82e9                	srli	a3,a3,0x1a
ffffffffc0201756:	96aa                	add	a3,a3,a0
ffffffffc0201758:	00d70e63          	beq	a4,a3,ffffffffc0201774 <default_free_pages+0x140>
}
ffffffffc020175c:	60a2                	ld	ra,8(sp)
ffffffffc020175e:	0141                	addi	sp,sp,16
ffffffffc0201760:	8082                	ret
ffffffffc0201762:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc0201764:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc0201768:	e398                	sd	a4,0(a5)
ffffffffc020176a:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc020176c:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020176e:	ed1c                	sd	a5,24(a0)
}
ffffffffc0201770:	0141                	addi	sp,sp,16
ffffffffc0201772:	8082                	ret
            base->property += p->property;
ffffffffc0201774:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201778:	ff078693          	addi	a3,a5,-16
ffffffffc020177c:	9e39                	addw	a2,a2,a4
ffffffffc020177e:	c910                	sw	a2,16(a0)
ffffffffc0201780:	5775                	li	a4,-3
ffffffffc0201782:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201786:	6398                	ld	a4,0(a5)
ffffffffc0201788:	679c                	ld	a5,8(a5)
}
ffffffffc020178a:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc020178c:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc020178e:	e398                	sd	a4,0(a5)
ffffffffc0201790:	0141                	addi	sp,sp,16
ffffffffc0201792:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0201794:	00008697          	auipc	a3,0x8
ffffffffc0201798:	6c468693          	addi	a3,a3,1732 # ffffffffc0209e58 <commands+0xbc8>
ffffffffc020179c:	00008617          	auipc	a2,0x8
ffffffffc02017a0:	fb460613          	addi	a2,a2,-76 # ffffffffc0209750 <commands+0x4c0>
ffffffffc02017a4:	08200593          	li	a1,130
ffffffffc02017a8:	00008517          	auipc	a0,0x8
ffffffffc02017ac:	37050513          	addi	a0,a0,880 # ffffffffc0209b18 <commands+0x888>
ffffffffc02017b0:	cd9fe0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(n > 0);
ffffffffc02017b4:	00008697          	auipc	a3,0x8
ffffffffc02017b8:	6cc68693          	addi	a3,a3,1740 # ffffffffc0209e80 <commands+0xbf0>
ffffffffc02017bc:	00008617          	auipc	a2,0x8
ffffffffc02017c0:	f9460613          	addi	a2,a2,-108 # ffffffffc0209750 <commands+0x4c0>
ffffffffc02017c4:	07f00593          	li	a1,127
ffffffffc02017c8:	00008517          	auipc	a0,0x8
ffffffffc02017cc:	35050513          	addi	a0,a0,848 # ffffffffc0209b18 <commands+0x888>
ffffffffc02017d0:	cb9fe0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc02017d4 <default_alloc_pages>:
    assert(n > 0);
ffffffffc02017d4:	c959                	beqz	a0,ffffffffc020186a <default_alloc_pages+0x96>
    if (n > nr_free) {
ffffffffc02017d6:	000c8597          	auipc	a1,0xc8
ffffffffc02017da:	ae258593          	addi	a1,a1,-1310 # ffffffffc02c92b8 <free_area>
ffffffffc02017de:	0105a803          	lw	a6,16(a1)
ffffffffc02017e2:	862a                	mv	a2,a0
ffffffffc02017e4:	02081793          	slli	a5,a6,0x20
ffffffffc02017e8:	9381                	srli	a5,a5,0x20
ffffffffc02017ea:	00a7ee63          	bltu	a5,a0,ffffffffc0201806 <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc02017ee:	87ae                	mv	a5,a1
ffffffffc02017f0:	a801                	j	ffffffffc0201800 <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc02017f2:	ff87a703          	lw	a4,-8(a5)
ffffffffc02017f6:	02071693          	slli	a3,a4,0x20
ffffffffc02017fa:	9281                	srli	a3,a3,0x20
ffffffffc02017fc:	00c6f763          	bleu	a2,a3,ffffffffc020180a <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc0201800:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201802:	feb798e3          	bne	a5,a1,ffffffffc02017f2 <default_alloc_pages+0x1e>
        return NULL;
ffffffffc0201806:	4501                	li	a0,0
}
ffffffffc0201808:	8082                	ret
        struct Page *p = le2page(le, page_link);
ffffffffc020180a:	fe878513          	addi	a0,a5,-24
    if (page != NULL) {
ffffffffc020180e:	dd6d                	beqz	a0,ffffffffc0201808 <default_alloc_pages+0x34>
    return listelm->prev;
ffffffffc0201810:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201814:	0087b303          	ld	t1,8(a5)
    prev->next = next;
ffffffffc0201818:	00060e1b          	sext.w	t3,a2
ffffffffc020181c:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc0201820:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc0201824:	02d67863          	bleu	a3,a2,ffffffffc0201854 <default_alloc_pages+0x80>
            struct Page *p = page + n;
ffffffffc0201828:	061a                	slli	a2,a2,0x6
ffffffffc020182a:	962a                	add	a2,a2,a0
            p->property = page->property - n;
ffffffffc020182c:	41c7073b          	subw	a4,a4,t3
ffffffffc0201830:	ca18                	sw	a4,16(a2)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201832:	00860693          	addi	a3,a2,8
ffffffffc0201836:	4709                	li	a4,2
ffffffffc0201838:	40e6b02f          	amoor.d	zero,a4,(a3)
    __list_add(elm, listelm, listelm->next);
ffffffffc020183c:	0088b703          	ld	a4,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc0201840:	01860693          	addi	a3,a2,24
    prev->next = next->prev = elm;
ffffffffc0201844:	0105a803          	lw	a6,16(a1)
ffffffffc0201848:	e314                	sd	a3,0(a4)
ffffffffc020184a:	00d8b423          	sd	a3,8(a7)
    elm->next = next;
ffffffffc020184e:	f218                	sd	a4,32(a2)
    elm->prev = prev;
ffffffffc0201850:	01163c23          	sd	a7,24(a2)
        nr_free -= n;
ffffffffc0201854:	41c8083b          	subw	a6,a6,t3
ffffffffc0201858:	000c8717          	auipc	a4,0xc8
ffffffffc020185c:	a7072823          	sw	a6,-1424(a4) # ffffffffc02c92c8 <free_area+0x10>
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0201860:	5775                	li	a4,-3
ffffffffc0201862:	17c1                	addi	a5,a5,-16
ffffffffc0201864:	60e7b02f          	amoand.d	zero,a4,(a5)
ffffffffc0201868:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc020186a:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc020186c:	00008697          	auipc	a3,0x8
ffffffffc0201870:	61468693          	addi	a3,a3,1556 # ffffffffc0209e80 <commands+0xbf0>
ffffffffc0201874:	00008617          	auipc	a2,0x8
ffffffffc0201878:	edc60613          	addi	a2,a2,-292 # ffffffffc0209750 <commands+0x4c0>
ffffffffc020187c:	06100593          	li	a1,97
ffffffffc0201880:	00008517          	auipc	a0,0x8
ffffffffc0201884:	29850513          	addi	a0,a0,664 # ffffffffc0209b18 <commands+0x888>
default_alloc_pages(size_t n) {
ffffffffc0201888:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc020188a:	bfffe0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc020188e <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc020188e:	1141                	addi	sp,sp,-16
ffffffffc0201890:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201892:	c1ed                	beqz	a1,ffffffffc0201974 <default_init_memmap+0xe6>
    for (; p != base + n; p ++) {
ffffffffc0201894:	00659693          	slli	a3,a1,0x6
ffffffffc0201898:	96aa                	add	a3,a3,a0
ffffffffc020189a:	02d50463          	beq	a0,a3,ffffffffc02018c2 <default_init_memmap+0x34>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc020189e:	6518                	ld	a4,8(a0)
        assert(PageReserved(p));
ffffffffc02018a0:	87aa                	mv	a5,a0
ffffffffc02018a2:	8b05                	andi	a4,a4,1
ffffffffc02018a4:	e709                	bnez	a4,ffffffffc02018ae <default_init_memmap+0x20>
ffffffffc02018a6:	a07d                	j	ffffffffc0201954 <default_init_memmap+0xc6>
ffffffffc02018a8:	6798                	ld	a4,8(a5)
ffffffffc02018aa:	8b05                	andi	a4,a4,1
ffffffffc02018ac:	c745                	beqz	a4,ffffffffc0201954 <default_init_memmap+0xc6>
        p->flags = p->property = 0;
ffffffffc02018ae:	0007a823          	sw	zero,16(a5)
ffffffffc02018b2:	0007b423          	sd	zero,8(a5)
ffffffffc02018b6:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02018ba:	04078793          	addi	a5,a5,64
ffffffffc02018be:	fed795e3          	bne	a5,a3,ffffffffc02018a8 <default_init_memmap+0x1a>
    base->property = n;
ffffffffc02018c2:	2581                	sext.w	a1,a1
ffffffffc02018c4:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02018c6:	4789                	li	a5,2
ffffffffc02018c8:	00850713          	addi	a4,a0,8
ffffffffc02018cc:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc02018d0:	000c8697          	auipc	a3,0xc8
ffffffffc02018d4:	9e868693          	addi	a3,a3,-1560 # ffffffffc02c92b8 <free_area>
ffffffffc02018d8:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02018da:	669c                	ld	a5,8(a3)
ffffffffc02018dc:	9db9                	addw	a1,a1,a4
ffffffffc02018de:	000c8717          	auipc	a4,0xc8
ffffffffc02018e2:	9eb72523          	sw	a1,-1558(a4) # ffffffffc02c92c8 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc02018e6:	04d78a63          	beq	a5,a3,ffffffffc020193a <default_init_memmap+0xac>
            struct Page* page = le2page(le, page_link);
ffffffffc02018ea:	fe878713          	addi	a4,a5,-24
ffffffffc02018ee:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc02018f0:	4801                	li	a6,0
ffffffffc02018f2:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc02018f6:	00e56a63          	bltu	a0,a4,ffffffffc020190a <default_init_memmap+0x7c>
    return listelm->next;
ffffffffc02018fa:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc02018fc:	02d70563          	beq	a4,a3,ffffffffc0201926 <default_init_memmap+0x98>
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201900:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201902:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0201906:	fee57ae3          	bleu	a4,a0,ffffffffc02018fa <default_init_memmap+0x6c>
ffffffffc020190a:	00080663          	beqz	a6,ffffffffc0201916 <default_init_memmap+0x88>
ffffffffc020190e:	000c8717          	auipc	a4,0xc8
ffffffffc0201912:	9ab73523          	sd	a1,-1622(a4) # ffffffffc02c92b8 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201916:	6398                	ld	a4,0(a5)
}
ffffffffc0201918:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc020191a:	e390                	sd	a2,0(a5)
ffffffffc020191c:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc020191e:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201920:	ed18                	sd	a4,24(a0)
ffffffffc0201922:	0141                	addi	sp,sp,16
ffffffffc0201924:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0201926:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201928:	f114                	sd	a3,32(a0)
ffffffffc020192a:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc020192c:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc020192e:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201930:	00d70e63          	beq	a4,a3,ffffffffc020194c <default_init_memmap+0xbe>
ffffffffc0201934:	4805                	li	a6,1
ffffffffc0201936:	87ba                	mv	a5,a4
ffffffffc0201938:	b7e9                	j	ffffffffc0201902 <default_init_memmap+0x74>
}
ffffffffc020193a:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc020193c:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc0201940:	e398                	sd	a4,0(a5)
ffffffffc0201942:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc0201944:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201946:	ed1c                	sd	a5,24(a0)
}
ffffffffc0201948:	0141                	addi	sp,sp,16
ffffffffc020194a:	8082                	ret
ffffffffc020194c:	60a2                	ld	ra,8(sp)
ffffffffc020194e:	e290                	sd	a2,0(a3)
ffffffffc0201950:	0141                	addi	sp,sp,16
ffffffffc0201952:	8082                	ret
        assert(PageReserved(p));
ffffffffc0201954:	00008697          	auipc	a3,0x8
ffffffffc0201958:	53468693          	addi	a3,a3,1332 # ffffffffc0209e88 <commands+0xbf8>
ffffffffc020195c:	00008617          	auipc	a2,0x8
ffffffffc0201960:	df460613          	addi	a2,a2,-524 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0201964:	04800593          	li	a1,72
ffffffffc0201968:	00008517          	auipc	a0,0x8
ffffffffc020196c:	1b050513          	addi	a0,a0,432 # ffffffffc0209b18 <commands+0x888>
ffffffffc0201970:	b19fe0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(n > 0);
ffffffffc0201974:	00008697          	auipc	a3,0x8
ffffffffc0201978:	50c68693          	addi	a3,a3,1292 # ffffffffc0209e80 <commands+0xbf0>
ffffffffc020197c:	00008617          	auipc	a2,0x8
ffffffffc0201980:	dd460613          	addi	a2,a2,-556 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0201984:	04500593          	li	a1,69
ffffffffc0201988:	00008517          	auipc	a0,0x8
ffffffffc020198c:	19050513          	addi	a0,a0,400 # ffffffffc0209b18 <commands+0x888>
ffffffffc0201990:	af9fe0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0201994 <slob_free>:
static void slob_free(void *block, int size)
{
	slob_t *cur, *b = (slob_t *)block;
	unsigned long flags;

	if (!block)
ffffffffc0201994:	c125                	beqz	a0,ffffffffc02019f4 <slob_free+0x60>
		return;

	if (size)
ffffffffc0201996:	e1a5                	bnez	a1,ffffffffc02019f6 <slob_free+0x62>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201998:	100027f3          	csrr	a5,sstatus
ffffffffc020199c:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020199e:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02019a0:	e3bd                	bnez	a5,ffffffffc0201a06 <slob_free+0x72>
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02019a2:	000bc797          	auipc	a5,0xbc
ffffffffc02019a6:	46678793          	addi	a5,a5,1126 # ffffffffc02bde08 <slobfree>
ffffffffc02019aa:	639c                	ld	a5,0(a5)
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02019ac:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02019ae:	00a7fa63          	bleu	a0,a5,ffffffffc02019c2 <slob_free+0x2e>
ffffffffc02019b2:	00e56c63          	bltu	a0,a4,ffffffffc02019ca <slob_free+0x36>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02019b6:	00e7fa63          	bleu	a4,a5,ffffffffc02019ca <slob_free+0x36>
    return 0;
ffffffffc02019ba:	87ba                	mv	a5,a4
ffffffffc02019bc:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02019be:	fea7eae3          	bltu	a5,a0,ffffffffc02019b2 <slob_free+0x1e>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02019c2:	fee7ece3          	bltu	a5,a4,ffffffffc02019ba <slob_free+0x26>
ffffffffc02019c6:	fee57ae3          	bleu	a4,a0,ffffffffc02019ba <slob_free+0x26>
			break;

	if (b + b->units == cur->next) {
ffffffffc02019ca:	4110                	lw	a2,0(a0)
ffffffffc02019cc:	00461693          	slli	a3,a2,0x4
ffffffffc02019d0:	96aa                	add	a3,a3,a0
ffffffffc02019d2:	08d70b63          	beq	a4,a3,ffffffffc0201a68 <slob_free+0xd4>
		b->units += cur->next->units;
		b->next = cur->next->next;
	} else
		b->next = cur->next;

	if (cur + cur->units == b) {
ffffffffc02019d6:	4394                	lw	a3,0(a5)
		b->next = cur->next;
ffffffffc02019d8:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc02019da:	00469713          	slli	a4,a3,0x4
ffffffffc02019de:	973e                	add	a4,a4,a5
ffffffffc02019e0:	08e50f63          	beq	a0,a4,ffffffffc0201a7e <slob_free+0xea>
		cur->units += b->units;
		cur->next = b->next;
	} else
		cur->next = b;
ffffffffc02019e4:	e788                	sd	a0,8(a5)

	slobfree = cur;
ffffffffc02019e6:	000bc717          	auipc	a4,0xbc
ffffffffc02019ea:	42f73123          	sd	a5,1058(a4) # ffffffffc02bde08 <slobfree>
    if (flag) {
ffffffffc02019ee:	c199                	beqz	a1,ffffffffc02019f4 <slob_free+0x60>
        intr_enable();
ffffffffc02019f0:	c5dfe06f          	j	ffffffffc020064c <intr_enable>
ffffffffc02019f4:	8082                	ret
		b->units = SLOB_UNITS(size);
ffffffffc02019f6:	05bd                	addi	a1,a1,15
ffffffffc02019f8:	8191                	srli	a1,a1,0x4
ffffffffc02019fa:	c10c                	sw	a1,0(a0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02019fc:	100027f3          	csrr	a5,sstatus
ffffffffc0201a00:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0201a02:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201a04:	dfd9                	beqz	a5,ffffffffc02019a2 <slob_free+0xe>
{
ffffffffc0201a06:	1101                	addi	sp,sp,-32
ffffffffc0201a08:	e42a                	sd	a0,8(sp)
ffffffffc0201a0a:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc0201a0c:	c47fe0ef          	jal	ra,ffffffffc0200652 <intr_disable>
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201a10:	000bc797          	auipc	a5,0xbc
ffffffffc0201a14:	3f878793          	addi	a5,a5,1016 # ffffffffc02bde08 <slobfree>
ffffffffc0201a18:	639c                	ld	a5,0(a5)
        return 1;
ffffffffc0201a1a:	6522                	ld	a0,8(sp)
ffffffffc0201a1c:	4585                	li	a1,1
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201a1e:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201a20:	00a7fa63          	bleu	a0,a5,ffffffffc0201a34 <slob_free+0xa0>
ffffffffc0201a24:	00e56c63          	bltu	a0,a4,ffffffffc0201a3c <slob_free+0xa8>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201a28:	00e7fa63          	bleu	a4,a5,ffffffffc0201a3c <slob_free+0xa8>
    return 0;
ffffffffc0201a2c:	87ba                	mv	a5,a4
ffffffffc0201a2e:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201a30:	fea7eae3          	bltu	a5,a0,ffffffffc0201a24 <slob_free+0x90>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201a34:	fee7ece3          	bltu	a5,a4,ffffffffc0201a2c <slob_free+0x98>
ffffffffc0201a38:	fee57ae3          	bleu	a4,a0,ffffffffc0201a2c <slob_free+0x98>
	if (b + b->units == cur->next) {
ffffffffc0201a3c:	4110                	lw	a2,0(a0)
ffffffffc0201a3e:	00461693          	slli	a3,a2,0x4
ffffffffc0201a42:	96aa                	add	a3,a3,a0
ffffffffc0201a44:	04d70763          	beq	a4,a3,ffffffffc0201a92 <slob_free+0xfe>
		b->next = cur->next;
ffffffffc0201a48:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc0201a4a:	4394                	lw	a3,0(a5)
ffffffffc0201a4c:	00469713          	slli	a4,a3,0x4
ffffffffc0201a50:	973e                	add	a4,a4,a5
ffffffffc0201a52:	04e50663          	beq	a0,a4,ffffffffc0201a9e <slob_free+0x10a>
		cur->next = b;
ffffffffc0201a56:	e788                	sd	a0,8(a5)
	slobfree = cur;
ffffffffc0201a58:	000bc717          	auipc	a4,0xbc
ffffffffc0201a5c:	3af73823          	sd	a5,944(a4) # ffffffffc02bde08 <slobfree>
    if (flag) {
ffffffffc0201a60:	e58d                	bnez	a1,ffffffffc0201a8a <slob_free+0xf6>

	spin_unlock_irqrestore(&slob_lock, flags);
}
ffffffffc0201a62:	60e2                	ld	ra,24(sp)
ffffffffc0201a64:	6105                	addi	sp,sp,32
ffffffffc0201a66:	8082                	ret
		b->units += cur->next->units;
ffffffffc0201a68:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc0201a6a:	6718                	ld	a4,8(a4)
		b->units += cur->next->units;
ffffffffc0201a6c:	9e35                	addw	a2,a2,a3
ffffffffc0201a6e:	c110                	sw	a2,0(a0)
	if (cur + cur->units == b) {
ffffffffc0201a70:	4394                	lw	a3,0(a5)
		b->next = cur->next->next;
ffffffffc0201a72:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc0201a74:	00469713          	slli	a4,a3,0x4
ffffffffc0201a78:	973e                	add	a4,a4,a5
ffffffffc0201a7a:	f6e515e3          	bne	a0,a4,ffffffffc02019e4 <slob_free+0x50>
		cur->units += b->units;
ffffffffc0201a7e:	4118                	lw	a4,0(a0)
		cur->next = b->next;
ffffffffc0201a80:	6510                	ld	a2,8(a0)
		cur->units += b->units;
ffffffffc0201a82:	9eb9                	addw	a3,a3,a4
ffffffffc0201a84:	c394                	sw	a3,0(a5)
		cur->next = b->next;
ffffffffc0201a86:	e790                	sd	a2,8(a5)
ffffffffc0201a88:	bfb9                	j	ffffffffc02019e6 <slob_free+0x52>
}
ffffffffc0201a8a:	60e2                	ld	ra,24(sp)
ffffffffc0201a8c:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201a8e:	bbffe06f          	j	ffffffffc020064c <intr_enable>
		b->units += cur->next->units;
ffffffffc0201a92:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc0201a94:	6718                	ld	a4,8(a4)
		b->units += cur->next->units;
ffffffffc0201a96:	9e35                	addw	a2,a2,a3
ffffffffc0201a98:	c110                	sw	a2,0(a0)
		b->next = cur->next->next;
ffffffffc0201a9a:	e518                	sd	a4,8(a0)
ffffffffc0201a9c:	b77d                	j	ffffffffc0201a4a <slob_free+0xb6>
		cur->units += b->units;
ffffffffc0201a9e:	4118                	lw	a4,0(a0)
		cur->next = b->next;
ffffffffc0201aa0:	6510                	ld	a2,8(a0)
		cur->units += b->units;
ffffffffc0201aa2:	9eb9                	addw	a3,a3,a4
ffffffffc0201aa4:	c394                	sw	a3,0(a5)
		cur->next = b->next;
ffffffffc0201aa6:	e790                	sd	a2,8(a5)
ffffffffc0201aa8:	bf45                	j	ffffffffc0201a58 <slob_free+0xc4>

ffffffffc0201aaa <__slob_get_free_pages.isra.0>:
  struct Page * page = alloc_pages(1 << order);
ffffffffc0201aaa:	4785                	li	a5,1
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0201aac:	1141                	addi	sp,sp,-16
  struct Page * page = alloc_pages(1 << order);
ffffffffc0201aae:	00a7953b          	sllw	a0,a5,a0
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0201ab2:	e406                	sd	ra,8(sp)
  struct Page * page = alloc_pages(1 << order);
ffffffffc0201ab4:	38e000ef          	jal	ra,ffffffffc0201e42 <alloc_pages>
  if(!page)
ffffffffc0201ab8:	c139                	beqz	a0,ffffffffc0201afe <__slob_get_free_pages.isra.0+0x54>
    return page - pages + nbase;
ffffffffc0201aba:	000c8797          	auipc	a5,0xc8
ffffffffc0201abe:	82e78793          	addi	a5,a5,-2002 # ffffffffc02c92e8 <pages>
ffffffffc0201ac2:	6394                	ld	a3,0(a5)
ffffffffc0201ac4:	0000a797          	auipc	a5,0xa
ffffffffc0201ac8:	4dc78793          	addi	a5,a5,1244 # ffffffffc020bfa0 <nbase>
    return KADDR(page2pa(page));
ffffffffc0201acc:	000c7717          	auipc	a4,0xc7
ffffffffc0201ad0:	79c70713          	addi	a4,a4,1948 # ffffffffc02c9268 <npage>
    return page - pages + nbase;
ffffffffc0201ad4:	40d506b3          	sub	a3,a0,a3
ffffffffc0201ad8:	6388                	ld	a0,0(a5)
ffffffffc0201ada:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0201adc:	57fd                	li	a5,-1
ffffffffc0201ade:	6318                	ld	a4,0(a4)
    return page - pages + nbase;
ffffffffc0201ae0:	96aa                	add	a3,a3,a0
    return KADDR(page2pa(page));
ffffffffc0201ae2:	83b1                	srli	a5,a5,0xc
ffffffffc0201ae4:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0201ae6:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0201ae8:	00e7ff63          	bleu	a4,a5,ffffffffc0201b06 <__slob_get_free_pages.isra.0+0x5c>
ffffffffc0201aec:	000c7797          	auipc	a5,0xc7
ffffffffc0201af0:	7ec78793          	addi	a5,a5,2028 # ffffffffc02c92d8 <va_pa_offset>
ffffffffc0201af4:	6388                	ld	a0,0(a5)
}
ffffffffc0201af6:	60a2                	ld	ra,8(sp)
ffffffffc0201af8:	9536                	add	a0,a0,a3
ffffffffc0201afa:	0141                	addi	sp,sp,16
ffffffffc0201afc:	8082                	ret
ffffffffc0201afe:	60a2                	ld	ra,8(sp)
    return NULL;
ffffffffc0201b00:	4501                	li	a0,0
}
ffffffffc0201b02:	0141                	addi	sp,sp,16
ffffffffc0201b04:	8082                	ret
ffffffffc0201b06:	00008617          	auipc	a2,0x8
ffffffffc0201b0a:	3e260613          	addi	a2,a2,994 # ffffffffc0209ee8 <default_pmm_manager+0x50>
ffffffffc0201b0e:	06900593          	li	a1,105
ffffffffc0201b12:	00008517          	auipc	a0,0x8
ffffffffc0201b16:	3fe50513          	addi	a0,a0,1022 # ffffffffc0209f10 <default_pmm_manager+0x78>
ffffffffc0201b1a:	96ffe0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0201b1e <slob_alloc.isra.1.constprop.3>:
static void *slob_alloc(size_t size, gfp_t gfp, int align)
ffffffffc0201b1e:	7179                	addi	sp,sp,-48
ffffffffc0201b20:	f406                	sd	ra,40(sp)
ffffffffc0201b22:	f022                	sd	s0,32(sp)
ffffffffc0201b24:	ec26                	sd	s1,24(sp)
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc0201b26:	01050713          	addi	a4,a0,16
ffffffffc0201b2a:	6785                	lui	a5,0x1
ffffffffc0201b2c:	0cf77b63          	bleu	a5,a4,ffffffffc0201c02 <slob_alloc.isra.1.constprop.3+0xe4>
	int delta = 0, units = SLOB_UNITS(size);
ffffffffc0201b30:	00f50413          	addi	s0,a0,15
ffffffffc0201b34:	8011                	srli	s0,s0,0x4
ffffffffc0201b36:	2401                	sext.w	s0,s0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201b38:	10002673          	csrr	a2,sstatus
ffffffffc0201b3c:	8a09                	andi	a2,a2,2
ffffffffc0201b3e:	ea5d                	bnez	a2,ffffffffc0201bf4 <slob_alloc.isra.1.constprop.3+0xd6>
	prev = slobfree;
ffffffffc0201b40:	000bc497          	auipc	s1,0xbc
ffffffffc0201b44:	2c848493          	addi	s1,s1,712 # ffffffffc02bde08 <slobfree>
ffffffffc0201b48:	6094                	ld	a3,0(s1)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0201b4a:	669c                	ld	a5,8(a3)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201b4c:	4398                	lw	a4,0(a5)
ffffffffc0201b4e:	0a875763          	ble	s0,a4,ffffffffc0201bfc <slob_alloc.isra.1.constprop.3+0xde>
		if (cur == slobfree) {
ffffffffc0201b52:	00f68a63          	beq	a3,a5,ffffffffc0201b66 <slob_alloc.isra.1.constprop.3+0x48>
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0201b56:	6788                	ld	a0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201b58:	4118                	lw	a4,0(a0)
ffffffffc0201b5a:	02875763          	ble	s0,a4,ffffffffc0201b88 <slob_alloc.isra.1.constprop.3+0x6a>
ffffffffc0201b5e:	6094                	ld	a3,0(s1)
ffffffffc0201b60:	87aa                	mv	a5,a0
		if (cur == slobfree) {
ffffffffc0201b62:	fef69ae3          	bne	a3,a5,ffffffffc0201b56 <slob_alloc.isra.1.constprop.3+0x38>
    if (flag) {
ffffffffc0201b66:	ea39                	bnez	a2,ffffffffc0201bbc <slob_alloc.isra.1.constprop.3+0x9e>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc0201b68:	4501                	li	a0,0
ffffffffc0201b6a:	f41ff0ef          	jal	ra,ffffffffc0201aaa <__slob_get_free_pages.isra.0>
			if (!cur)
ffffffffc0201b6e:	cd29                	beqz	a0,ffffffffc0201bc8 <slob_alloc.isra.1.constprop.3+0xaa>
			slob_free(cur, PAGE_SIZE);
ffffffffc0201b70:	6585                	lui	a1,0x1
ffffffffc0201b72:	e23ff0ef          	jal	ra,ffffffffc0201994 <slob_free>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201b76:	10002673          	csrr	a2,sstatus
ffffffffc0201b7a:	8a09                	andi	a2,a2,2
ffffffffc0201b7c:	ea1d                	bnez	a2,ffffffffc0201bb2 <slob_alloc.isra.1.constprop.3+0x94>
			cur = slobfree;
ffffffffc0201b7e:	609c                	ld	a5,0(s1)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0201b80:	6788                	ld	a0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201b82:	4118                	lw	a4,0(a0)
ffffffffc0201b84:	fc874de3          	blt	a4,s0,ffffffffc0201b5e <slob_alloc.isra.1.constprop.3+0x40>
			if (cur->units == units) /* exact fit? */
ffffffffc0201b88:	04e40663          	beq	s0,a4,ffffffffc0201bd4 <slob_alloc.isra.1.constprop.3+0xb6>
				prev->next = cur + units;
ffffffffc0201b8c:	00441693          	slli	a3,s0,0x4
ffffffffc0201b90:	96aa                	add	a3,a3,a0
ffffffffc0201b92:	e794                	sd	a3,8(a5)
				prev->next->next = cur->next;
ffffffffc0201b94:	650c                	ld	a1,8(a0)
				prev->next->units = cur->units - units;
ffffffffc0201b96:	9f01                	subw	a4,a4,s0
ffffffffc0201b98:	c298                	sw	a4,0(a3)
				prev->next->next = cur->next;
ffffffffc0201b9a:	e68c                	sd	a1,8(a3)
				cur->units = units;
ffffffffc0201b9c:	c100                	sw	s0,0(a0)
			slobfree = prev;
ffffffffc0201b9e:	000bc717          	auipc	a4,0xbc
ffffffffc0201ba2:	26f73523          	sd	a5,618(a4) # ffffffffc02bde08 <slobfree>
    if (flag) {
ffffffffc0201ba6:	ee15                	bnez	a2,ffffffffc0201be2 <slob_alloc.isra.1.constprop.3+0xc4>
}
ffffffffc0201ba8:	70a2                	ld	ra,40(sp)
ffffffffc0201baa:	7402                	ld	s0,32(sp)
ffffffffc0201bac:	64e2                	ld	s1,24(sp)
ffffffffc0201bae:	6145                	addi	sp,sp,48
ffffffffc0201bb0:	8082                	ret
        intr_disable();
ffffffffc0201bb2:	aa1fe0ef          	jal	ra,ffffffffc0200652 <intr_disable>
ffffffffc0201bb6:	4605                	li	a2,1
			cur = slobfree;
ffffffffc0201bb8:	609c                	ld	a5,0(s1)
ffffffffc0201bba:	b7d9                	j	ffffffffc0201b80 <slob_alloc.isra.1.constprop.3+0x62>
        intr_enable();
ffffffffc0201bbc:	a91fe0ef          	jal	ra,ffffffffc020064c <intr_enable>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc0201bc0:	4501                	li	a0,0
ffffffffc0201bc2:	ee9ff0ef          	jal	ra,ffffffffc0201aaa <__slob_get_free_pages.isra.0>
			if (!cur)
ffffffffc0201bc6:	f54d                	bnez	a0,ffffffffc0201b70 <slob_alloc.isra.1.constprop.3+0x52>
}
ffffffffc0201bc8:	70a2                	ld	ra,40(sp)
ffffffffc0201bca:	7402                	ld	s0,32(sp)
ffffffffc0201bcc:	64e2                	ld	s1,24(sp)
				return 0;
ffffffffc0201bce:	4501                	li	a0,0
}
ffffffffc0201bd0:	6145                	addi	sp,sp,48
ffffffffc0201bd2:	8082                	ret
				prev->next = cur->next; /* unlink */
ffffffffc0201bd4:	6518                	ld	a4,8(a0)
ffffffffc0201bd6:	e798                	sd	a4,8(a5)
			slobfree = prev;
ffffffffc0201bd8:	000bc717          	auipc	a4,0xbc
ffffffffc0201bdc:	22f73823          	sd	a5,560(a4) # ffffffffc02bde08 <slobfree>
    if (flag) {
ffffffffc0201be0:	d661                	beqz	a2,ffffffffc0201ba8 <slob_alloc.isra.1.constprop.3+0x8a>
ffffffffc0201be2:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0201be4:	a69fe0ef          	jal	ra,ffffffffc020064c <intr_enable>
}
ffffffffc0201be8:	70a2                	ld	ra,40(sp)
ffffffffc0201bea:	7402                	ld	s0,32(sp)
ffffffffc0201bec:	6522                	ld	a0,8(sp)
ffffffffc0201bee:	64e2                	ld	s1,24(sp)
ffffffffc0201bf0:	6145                	addi	sp,sp,48
ffffffffc0201bf2:	8082                	ret
        intr_disable();
ffffffffc0201bf4:	a5ffe0ef          	jal	ra,ffffffffc0200652 <intr_disable>
ffffffffc0201bf8:	4605                	li	a2,1
ffffffffc0201bfa:	b799                	j	ffffffffc0201b40 <slob_alloc.isra.1.constprop.3+0x22>
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201bfc:	853e                	mv	a0,a5
ffffffffc0201bfe:	87b6                	mv	a5,a3
ffffffffc0201c00:	b761                	j	ffffffffc0201b88 <slob_alloc.isra.1.constprop.3+0x6a>
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc0201c02:	00008697          	auipc	a3,0x8
ffffffffc0201c06:	38668693          	addi	a3,a3,902 # ffffffffc0209f88 <default_pmm_manager+0xf0>
ffffffffc0201c0a:	00008617          	auipc	a2,0x8
ffffffffc0201c0e:	b4660613          	addi	a2,a2,-1210 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0201c12:	06400593          	li	a1,100
ffffffffc0201c16:	00008517          	auipc	a0,0x8
ffffffffc0201c1a:	39250513          	addi	a0,a0,914 # ffffffffc0209fa8 <default_pmm_manager+0x110>
ffffffffc0201c1e:	86bfe0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0201c22 <kmalloc_init>:
slob_init(void) {
  cprintf("use SLOB allocator\n");
}

inline void 
kmalloc_init(void) {
ffffffffc0201c22:	1141                	addi	sp,sp,-16
  cprintf("use SLOB allocator\n");
ffffffffc0201c24:	00008517          	auipc	a0,0x8
ffffffffc0201c28:	39c50513          	addi	a0,a0,924 # ffffffffc0209fc0 <default_pmm_manager+0x128>
kmalloc_init(void) {
ffffffffc0201c2c:	e406                	sd	ra,8(sp)
  cprintf("use SLOB allocator\n");
ffffffffc0201c2e:	d64fe0ef          	jal	ra,ffffffffc0200192 <cprintf>
    slob_init();
    cprintf("kmalloc_init() succeeded!\n");
}
ffffffffc0201c32:	60a2                	ld	ra,8(sp)
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201c34:	00008517          	auipc	a0,0x8
ffffffffc0201c38:	33450513          	addi	a0,a0,820 # ffffffffc0209f68 <default_pmm_manager+0xd0>
}
ffffffffc0201c3c:	0141                	addi	sp,sp,16
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201c3e:	d54fe06f          	j	ffffffffc0200192 <cprintf>

ffffffffc0201c42 <kallocated>:
}

size_t
kallocated(void) {
   return slob_allocated();
}
ffffffffc0201c42:	4501                	li	a0,0
ffffffffc0201c44:	8082                	ret

ffffffffc0201c46 <kmalloc>:
	return 0;
}

void *
kmalloc(size_t size)
{
ffffffffc0201c46:	1101                	addi	sp,sp,-32
ffffffffc0201c48:	e04a                	sd	s2,0(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201c4a:	6905                	lui	s2,0x1
{
ffffffffc0201c4c:	e822                	sd	s0,16(sp)
ffffffffc0201c4e:	ec06                	sd	ra,24(sp)
ffffffffc0201c50:	e426                	sd	s1,8(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201c52:	fef90793          	addi	a5,s2,-17 # fef <_binary_obj___user_faultread_out_size-0x8911>
{
ffffffffc0201c56:	842a                	mv	s0,a0
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201c58:	04a7fc63          	bleu	a0,a5,ffffffffc0201cb0 <kmalloc+0x6a>
	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
ffffffffc0201c5c:	4561                	li	a0,24
ffffffffc0201c5e:	ec1ff0ef          	jal	ra,ffffffffc0201b1e <slob_alloc.isra.1.constprop.3>
ffffffffc0201c62:	84aa                	mv	s1,a0
	if (!bb)
ffffffffc0201c64:	cd21                	beqz	a0,ffffffffc0201cbc <kmalloc+0x76>
	bb->order = find_order(size);
ffffffffc0201c66:	0004079b          	sext.w	a5,s0
	int order = 0;
ffffffffc0201c6a:	4501                	li	a0,0
	for ( ; size > 4096 ; size >>=1)
ffffffffc0201c6c:	00f95763          	ble	a5,s2,ffffffffc0201c7a <kmalloc+0x34>
ffffffffc0201c70:	6705                	lui	a4,0x1
ffffffffc0201c72:	8785                	srai	a5,a5,0x1
		order++;
ffffffffc0201c74:	2505                	addiw	a0,a0,1
	for ( ; size > 4096 ; size >>=1)
ffffffffc0201c76:	fef74ee3          	blt	a4,a5,ffffffffc0201c72 <kmalloc+0x2c>
	bb->order = find_order(size);
ffffffffc0201c7a:	c088                	sw	a0,0(s1)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
ffffffffc0201c7c:	e2fff0ef          	jal	ra,ffffffffc0201aaa <__slob_get_free_pages.isra.0>
ffffffffc0201c80:	e488                	sd	a0,8(s1)
ffffffffc0201c82:	842a                	mv	s0,a0
	if (bb->pages) {
ffffffffc0201c84:	c935                	beqz	a0,ffffffffc0201cf8 <kmalloc+0xb2>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201c86:	100027f3          	csrr	a5,sstatus
ffffffffc0201c8a:	8b89                	andi	a5,a5,2
ffffffffc0201c8c:	e3a1                	bnez	a5,ffffffffc0201ccc <kmalloc+0x86>
		bb->next = bigblocks;
ffffffffc0201c8e:	000c7797          	auipc	a5,0xc7
ffffffffc0201c92:	5ca78793          	addi	a5,a5,1482 # ffffffffc02c9258 <bigblocks>
ffffffffc0201c96:	639c                	ld	a5,0(a5)
		bigblocks = bb;
ffffffffc0201c98:	000c7717          	auipc	a4,0xc7
ffffffffc0201c9c:	5c973023          	sd	s1,1472(a4) # ffffffffc02c9258 <bigblocks>
		bb->next = bigblocks;
ffffffffc0201ca0:	e89c                	sd	a5,16(s1)
  return __kmalloc(size, 0);
}
ffffffffc0201ca2:	8522                	mv	a0,s0
ffffffffc0201ca4:	60e2                	ld	ra,24(sp)
ffffffffc0201ca6:	6442                	ld	s0,16(sp)
ffffffffc0201ca8:	64a2                	ld	s1,8(sp)
ffffffffc0201caa:	6902                	ld	s2,0(sp)
ffffffffc0201cac:	6105                	addi	sp,sp,32
ffffffffc0201cae:	8082                	ret
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
ffffffffc0201cb0:	0541                	addi	a0,a0,16
ffffffffc0201cb2:	e6dff0ef          	jal	ra,ffffffffc0201b1e <slob_alloc.isra.1.constprop.3>
		return m ? (void *)(m + 1) : 0;
ffffffffc0201cb6:	01050413          	addi	s0,a0,16
ffffffffc0201cba:	f565                	bnez	a0,ffffffffc0201ca2 <kmalloc+0x5c>
ffffffffc0201cbc:	4401                	li	s0,0
}
ffffffffc0201cbe:	8522                	mv	a0,s0
ffffffffc0201cc0:	60e2                	ld	ra,24(sp)
ffffffffc0201cc2:	6442                	ld	s0,16(sp)
ffffffffc0201cc4:	64a2                	ld	s1,8(sp)
ffffffffc0201cc6:	6902                	ld	s2,0(sp)
ffffffffc0201cc8:	6105                	addi	sp,sp,32
ffffffffc0201cca:	8082                	ret
        intr_disable();
ffffffffc0201ccc:	987fe0ef          	jal	ra,ffffffffc0200652 <intr_disable>
		bb->next = bigblocks;
ffffffffc0201cd0:	000c7797          	auipc	a5,0xc7
ffffffffc0201cd4:	58878793          	addi	a5,a5,1416 # ffffffffc02c9258 <bigblocks>
ffffffffc0201cd8:	639c                	ld	a5,0(a5)
		bigblocks = bb;
ffffffffc0201cda:	000c7717          	auipc	a4,0xc7
ffffffffc0201cde:	56973f23          	sd	s1,1406(a4) # ffffffffc02c9258 <bigblocks>
		bb->next = bigblocks;
ffffffffc0201ce2:	e89c                	sd	a5,16(s1)
        intr_enable();
ffffffffc0201ce4:	969fe0ef          	jal	ra,ffffffffc020064c <intr_enable>
ffffffffc0201ce8:	6480                	ld	s0,8(s1)
}
ffffffffc0201cea:	60e2                	ld	ra,24(sp)
ffffffffc0201cec:	64a2                	ld	s1,8(sp)
ffffffffc0201cee:	8522                	mv	a0,s0
ffffffffc0201cf0:	6442                	ld	s0,16(sp)
ffffffffc0201cf2:	6902                	ld	s2,0(sp)
ffffffffc0201cf4:	6105                	addi	sp,sp,32
ffffffffc0201cf6:	8082                	ret
	slob_free(bb, sizeof(bigblock_t));
ffffffffc0201cf8:	45e1                	li	a1,24
ffffffffc0201cfa:	8526                	mv	a0,s1
ffffffffc0201cfc:	c99ff0ef          	jal	ra,ffffffffc0201994 <slob_free>
  return __kmalloc(size, 0);
ffffffffc0201d00:	b74d                	j	ffffffffc0201ca2 <kmalloc+0x5c>

ffffffffc0201d02 <kfree>:
void kfree(void *block)
{
	bigblock_t *bb, **last = &bigblocks;
	unsigned long flags;

	if (!block)
ffffffffc0201d02:	c175                	beqz	a0,ffffffffc0201de6 <kfree+0xe4>
{
ffffffffc0201d04:	1101                	addi	sp,sp,-32
ffffffffc0201d06:	e426                	sd	s1,8(sp)
ffffffffc0201d08:	ec06                	sd	ra,24(sp)
ffffffffc0201d0a:	e822                	sd	s0,16(sp)
		return;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
ffffffffc0201d0c:	03451793          	slli	a5,a0,0x34
ffffffffc0201d10:	84aa                	mv	s1,a0
ffffffffc0201d12:	eb8d                	bnez	a5,ffffffffc0201d44 <kfree+0x42>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201d14:	100027f3          	csrr	a5,sstatus
ffffffffc0201d18:	8b89                	andi	a5,a5,2
ffffffffc0201d1a:	efc9                	bnez	a5,ffffffffc0201db4 <kfree+0xb2>
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201d1c:	000c7797          	auipc	a5,0xc7
ffffffffc0201d20:	53c78793          	addi	a5,a5,1340 # ffffffffc02c9258 <bigblocks>
ffffffffc0201d24:	6394                	ld	a3,0(a5)
ffffffffc0201d26:	ce99                	beqz	a3,ffffffffc0201d44 <kfree+0x42>
			if (bb->pages == block) {
ffffffffc0201d28:	669c                	ld	a5,8(a3)
ffffffffc0201d2a:	6a80                	ld	s0,16(a3)
ffffffffc0201d2c:	0af50e63          	beq	a0,a5,ffffffffc0201de8 <kfree+0xe6>
    return 0;
ffffffffc0201d30:	4601                	li	a2,0
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201d32:	c801                	beqz	s0,ffffffffc0201d42 <kfree+0x40>
			if (bb->pages == block) {
ffffffffc0201d34:	6418                	ld	a4,8(s0)
ffffffffc0201d36:	681c                	ld	a5,16(s0)
ffffffffc0201d38:	00970f63          	beq	a4,s1,ffffffffc0201d56 <kfree+0x54>
ffffffffc0201d3c:	86a2                	mv	a3,s0
ffffffffc0201d3e:	843e                	mv	s0,a5
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201d40:	f875                	bnez	s0,ffffffffc0201d34 <kfree+0x32>
    if (flag) {
ffffffffc0201d42:	e659                	bnez	a2,ffffffffc0201dd0 <kfree+0xce>
		spin_unlock_irqrestore(&block_lock, flags);
	}

	slob_free((slob_t *)block - 1, 0);
	return;
}
ffffffffc0201d44:	6442                	ld	s0,16(sp)
ffffffffc0201d46:	60e2                	ld	ra,24(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201d48:	ff048513          	addi	a0,s1,-16
}
ffffffffc0201d4c:	64a2                	ld	s1,8(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201d4e:	4581                	li	a1,0
}
ffffffffc0201d50:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201d52:	c43ff06f          	j	ffffffffc0201994 <slob_free>
				*last = bb->next;
ffffffffc0201d56:	ea9c                	sd	a5,16(a3)
ffffffffc0201d58:	e641                	bnez	a2,ffffffffc0201de0 <kfree+0xde>
    return pa2page(PADDR(kva));
ffffffffc0201d5a:	c02007b7          	lui	a5,0xc0200
				__slob_free_pages((unsigned long)block, bb->order);
ffffffffc0201d5e:	4018                	lw	a4,0(s0)
ffffffffc0201d60:	08f4ea63          	bltu	s1,a5,ffffffffc0201df4 <kfree+0xf2>
ffffffffc0201d64:	000c7797          	auipc	a5,0xc7
ffffffffc0201d68:	57478793          	addi	a5,a5,1396 # ffffffffc02c92d8 <va_pa_offset>
ffffffffc0201d6c:	6394                	ld	a3,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0201d6e:	000c7797          	auipc	a5,0xc7
ffffffffc0201d72:	4fa78793          	addi	a5,a5,1274 # ffffffffc02c9268 <npage>
ffffffffc0201d76:	639c                	ld	a5,0(a5)
    return pa2page(PADDR(kva));
ffffffffc0201d78:	8c95                	sub	s1,s1,a3
    if (PPN(pa) >= npage) {
ffffffffc0201d7a:	80b1                	srli	s1,s1,0xc
ffffffffc0201d7c:	08f4f963          	bleu	a5,s1,ffffffffc0201e0e <kfree+0x10c>
    return &pages[PPN(pa) - nbase];
ffffffffc0201d80:	0000a797          	auipc	a5,0xa
ffffffffc0201d84:	22078793          	addi	a5,a5,544 # ffffffffc020bfa0 <nbase>
ffffffffc0201d88:	639c                	ld	a5,0(a5)
ffffffffc0201d8a:	000c7697          	auipc	a3,0xc7
ffffffffc0201d8e:	55e68693          	addi	a3,a3,1374 # ffffffffc02c92e8 <pages>
ffffffffc0201d92:	6288                	ld	a0,0(a3)
ffffffffc0201d94:	8c9d                	sub	s1,s1,a5
ffffffffc0201d96:	049a                	slli	s1,s1,0x6
  free_pages(kva2page(kva), 1 << order);
ffffffffc0201d98:	4585                	li	a1,1
ffffffffc0201d9a:	9526                	add	a0,a0,s1
ffffffffc0201d9c:	00e595bb          	sllw	a1,a1,a4
ffffffffc0201da0:	12a000ef          	jal	ra,ffffffffc0201eca <free_pages>
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201da4:	8522                	mv	a0,s0
}
ffffffffc0201da6:	6442                	ld	s0,16(sp)
ffffffffc0201da8:	60e2                	ld	ra,24(sp)
ffffffffc0201daa:	64a2                	ld	s1,8(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201dac:	45e1                	li	a1,24
}
ffffffffc0201dae:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201db0:	be5ff06f          	j	ffffffffc0201994 <slob_free>
        intr_disable();
ffffffffc0201db4:	89ffe0ef          	jal	ra,ffffffffc0200652 <intr_disable>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201db8:	000c7797          	auipc	a5,0xc7
ffffffffc0201dbc:	4a078793          	addi	a5,a5,1184 # ffffffffc02c9258 <bigblocks>
ffffffffc0201dc0:	6394                	ld	a3,0(a5)
ffffffffc0201dc2:	c699                	beqz	a3,ffffffffc0201dd0 <kfree+0xce>
			if (bb->pages == block) {
ffffffffc0201dc4:	669c                	ld	a5,8(a3)
ffffffffc0201dc6:	6a80                	ld	s0,16(a3)
ffffffffc0201dc8:	00f48763          	beq	s1,a5,ffffffffc0201dd6 <kfree+0xd4>
        return 1;
ffffffffc0201dcc:	4605                	li	a2,1
ffffffffc0201dce:	b795                	j	ffffffffc0201d32 <kfree+0x30>
        intr_enable();
ffffffffc0201dd0:	87dfe0ef          	jal	ra,ffffffffc020064c <intr_enable>
ffffffffc0201dd4:	bf85                	j	ffffffffc0201d44 <kfree+0x42>
				*last = bb->next;
ffffffffc0201dd6:	000c7797          	auipc	a5,0xc7
ffffffffc0201dda:	4887b123          	sd	s0,1154(a5) # ffffffffc02c9258 <bigblocks>
ffffffffc0201dde:	8436                	mv	s0,a3
ffffffffc0201de0:	86dfe0ef          	jal	ra,ffffffffc020064c <intr_enable>
ffffffffc0201de4:	bf9d                	j	ffffffffc0201d5a <kfree+0x58>
ffffffffc0201de6:	8082                	ret
ffffffffc0201de8:	000c7797          	auipc	a5,0xc7
ffffffffc0201dec:	4687b823          	sd	s0,1136(a5) # ffffffffc02c9258 <bigblocks>
ffffffffc0201df0:	8436                	mv	s0,a3
ffffffffc0201df2:	b7a5                	j	ffffffffc0201d5a <kfree+0x58>
    return pa2page(PADDR(kva));
ffffffffc0201df4:	86a6                	mv	a3,s1
ffffffffc0201df6:	00008617          	auipc	a2,0x8
ffffffffc0201dfa:	12a60613          	addi	a2,a2,298 # ffffffffc0209f20 <default_pmm_manager+0x88>
ffffffffc0201dfe:	06e00593          	li	a1,110
ffffffffc0201e02:	00008517          	auipc	a0,0x8
ffffffffc0201e06:	10e50513          	addi	a0,a0,270 # ffffffffc0209f10 <default_pmm_manager+0x78>
ffffffffc0201e0a:	e7efe0ef          	jal	ra,ffffffffc0200488 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0201e0e:	00008617          	auipc	a2,0x8
ffffffffc0201e12:	13a60613          	addi	a2,a2,314 # ffffffffc0209f48 <default_pmm_manager+0xb0>
ffffffffc0201e16:	06200593          	li	a1,98
ffffffffc0201e1a:	00008517          	auipc	a0,0x8
ffffffffc0201e1e:	0f650513          	addi	a0,a0,246 # ffffffffc0209f10 <default_pmm_manager+0x78>
ffffffffc0201e22:	e66fe0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0201e26 <pa2page.part.4>:
pa2page(uintptr_t pa) {
ffffffffc0201e26:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc0201e28:	00008617          	auipc	a2,0x8
ffffffffc0201e2c:	12060613          	addi	a2,a2,288 # ffffffffc0209f48 <default_pmm_manager+0xb0>
ffffffffc0201e30:	06200593          	li	a1,98
ffffffffc0201e34:	00008517          	auipc	a0,0x8
ffffffffc0201e38:	0dc50513          	addi	a0,a0,220 # ffffffffc0209f10 <default_pmm_manager+0x78>
pa2page(uintptr_t pa) {
ffffffffc0201e3c:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0201e3e:	e4afe0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0201e42 <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
ffffffffc0201e42:	715d                	addi	sp,sp,-80
ffffffffc0201e44:	e0a2                	sd	s0,64(sp)
ffffffffc0201e46:	fc26                	sd	s1,56(sp)
ffffffffc0201e48:	f84a                	sd	s2,48(sp)
ffffffffc0201e4a:	f44e                	sd	s3,40(sp)
ffffffffc0201e4c:	f052                	sd	s4,32(sp)
ffffffffc0201e4e:	ec56                	sd	s5,24(sp)
ffffffffc0201e50:	e486                	sd	ra,72(sp)
ffffffffc0201e52:	842a                	mv	s0,a0
ffffffffc0201e54:	000c7497          	auipc	s1,0xc7
ffffffffc0201e58:	47c48493          	addi	s1,s1,1148 # ffffffffc02c92d0 <pmm_manager>
        {
            page = pmm_manager->alloc_pages(n);
        }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201e5c:	4985                	li	s3,1
ffffffffc0201e5e:	000c7a17          	auipc	s4,0xc7
ffffffffc0201e62:	41aa0a13          	addi	s4,s4,1050 # ffffffffc02c9278 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc0201e66:	0005091b          	sext.w	s2,a0
ffffffffc0201e6a:	000c7a97          	auipc	s5,0xc7
ffffffffc0201e6e:	55ea8a93          	addi	s5,s5,1374 # ffffffffc02c93c8 <check_mm_struct>
ffffffffc0201e72:	a00d                	j	ffffffffc0201e94 <alloc_pages+0x52>
            page = pmm_manager->alloc_pages(n);
ffffffffc0201e74:	609c                	ld	a5,0(s1)
ffffffffc0201e76:	6f9c                	ld	a5,24(a5)
ffffffffc0201e78:	9782                	jalr	a5
        swap_out(check_mm_struct, n, 0);
ffffffffc0201e7a:	4601                	li	a2,0
ffffffffc0201e7c:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201e7e:	ed0d                	bnez	a0,ffffffffc0201eb8 <alloc_pages+0x76>
ffffffffc0201e80:	0289ec63          	bltu	s3,s0,ffffffffc0201eb8 <alloc_pages+0x76>
ffffffffc0201e84:	000a2783          	lw	a5,0(s4)
ffffffffc0201e88:	2781                	sext.w	a5,a5
ffffffffc0201e8a:	c79d                	beqz	a5,ffffffffc0201eb8 <alloc_pages+0x76>
        swap_out(check_mm_struct, n, 0);
ffffffffc0201e8c:	000ab503          	ld	a0,0(s5)
ffffffffc0201e90:	48d010ef          	jal	ra,ffffffffc0203b1c <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201e94:	100027f3          	csrr	a5,sstatus
ffffffffc0201e98:	8b89                	andi	a5,a5,2
            page = pmm_manager->alloc_pages(n);
ffffffffc0201e9a:	8522                	mv	a0,s0
ffffffffc0201e9c:	dfe1                	beqz	a5,ffffffffc0201e74 <alloc_pages+0x32>
        intr_disable();
ffffffffc0201e9e:	fb4fe0ef          	jal	ra,ffffffffc0200652 <intr_disable>
ffffffffc0201ea2:	609c                	ld	a5,0(s1)
ffffffffc0201ea4:	8522                	mv	a0,s0
ffffffffc0201ea6:	6f9c                	ld	a5,24(a5)
ffffffffc0201ea8:	9782                	jalr	a5
ffffffffc0201eaa:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0201eac:	fa0fe0ef          	jal	ra,ffffffffc020064c <intr_enable>
ffffffffc0201eb0:	6522                	ld	a0,8(sp)
        swap_out(check_mm_struct, n, 0);
ffffffffc0201eb2:	4601                	li	a2,0
ffffffffc0201eb4:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201eb6:	d569                	beqz	a0,ffffffffc0201e80 <alloc_pages+0x3e>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc0201eb8:	60a6                	ld	ra,72(sp)
ffffffffc0201eba:	6406                	ld	s0,64(sp)
ffffffffc0201ebc:	74e2                	ld	s1,56(sp)
ffffffffc0201ebe:	7942                	ld	s2,48(sp)
ffffffffc0201ec0:	79a2                	ld	s3,40(sp)
ffffffffc0201ec2:	7a02                	ld	s4,32(sp)
ffffffffc0201ec4:	6ae2                	ld	s5,24(sp)
ffffffffc0201ec6:	6161                	addi	sp,sp,80
ffffffffc0201ec8:	8082                	ret

ffffffffc0201eca <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201eca:	100027f3          	csrr	a5,sstatus
ffffffffc0201ece:	8b89                	andi	a5,a5,2
ffffffffc0201ed0:	eb89                	bnez	a5,ffffffffc0201ee2 <free_pages+0x18>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0201ed2:	000c7797          	auipc	a5,0xc7
ffffffffc0201ed6:	3fe78793          	addi	a5,a5,1022 # ffffffffc02c92d0 <pmm_manager>
ffffffffc0201eda:	639c                	ld	a5,0(a5)
ffffffffc0201edc:	0207b303          	ld	t1,32(a5)
ffffffffc0201ee0:	8302                	jr	t1
void free_pages(struct Page *base, size_t n) {
ffffffffc0201ee2:	1101                	addi	sp,sp,-32
ffffffffc0201ee4:	ec06                	sd	ra,24(sp)
ffffffffc0201ee6:	e822                	sd	s0,16(sp)
ffffffffc0201ee8:	e426                	sd	s1,8(sp)
ffffffffc0201eea:	842a                	mv	s0,a0
ffffffffc0201eec:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0201eee:	f64fe0ef          	jal	ra,ffffffffc0200652 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0201ef2:	000c7797          	auipc	a5,0xc7
ffffffffc0201ef6:	3de78793          	addi	a5,a5,990 # ffffffffc02c92d0 <pmm_manager>
ffffffffc0201efa:	639c                	ld	a5,0(a5)
ffffffffc0201efc:	85a6                	mv	a1,s1
ffffffffc0201efe:	8522                	mv	a0,s0
ffffffffc0201f00:	739c                	ld	a5,32(a5)
ffffffffc0201f02:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0201f04:	6442                	ld	s0,16(sp)
ffffffffc0201f06:	60e2                	ld	ra,24(sp)
ffffffffc0201f08:	64a2                	ld	s1,8(sp)
ffffffffc0201f0a:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201f0c:	f40fe06f          	j	ffffffffc020064c <intr_enable>

ffffffffc0201f10 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201f10:	100027f3          	csrr	a5,sstatus
ffffffffc0201f14:	8b89                	andi	a5,a5,2
ffffffffc0201f16:	eb89                	bnez	a5,ffffffffc0201f28 <nr_free_pages+0x18>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc0201f18:	000c7797          	auipc	a5,0xc7
ffffffffc0201f1c:	3b878793          	addi	a5,a5,952 # ffffffffc02c92d0 <pmm_manager>
ffffffffc0201f20:	639c                	ld	a5,0(a5)
ffffffffc0201f22:	0287b303          	ld	t1,40(a5)
ffffffffc0201f26:	8302                	jr	t1
size_t nr_free_pages(void) {
ffffffffc0201f28:	1141                	addi	sp,sp,-16
ffffffffc0201f2a:	e406                	sd	ra,8(sp)
ffffffffc0201f2c:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0201f2e:	f24fe0ef          	jal	ra,ffffffffc0200652 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0201f32:	000c7797          	auipc	a5,0xc7
ffffffffc0201f36:	39e78793          	addi	a5,a5,926 # ffffffffc02c92d0 <pmm_manager>
ffffffffc0201f3a:	639c                	ld	a5,0(a5)
ffffffffc0201f3c:	779c                	ld	a5,40(a5)
ffffffffc0201f3e:	9782                	jalr	a5
ffffffffc0201f40:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0201f42:	f0afe0ef          	jal	ra,ffffffffc020064c <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0201f46:	8522                	mv	a0,s0
ffffffffc0201f48:	60a2                	ld	ra,8(sp)
ffffffffc0201f4a:	6402                	ld	s0,0(sp)
ffffffffc0201f4c:	0141                	addi	sp,sp,16
ffffffffc0201f4e:	8082                	ret

ffffffffc0201f50 <get_pte>:
// parameter:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201f50:	7139                	addi	sp,sp,-64
ffffffffc0201f52:	f426                	sd	s1,40(sp)
     *   PTE_W           0x002                   // page table/directory entry
     * flags bit : Writeable
     *   PTE_U           0x004                   // page table/directory entry
     * flags bit : User can access
     */
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0201f54:	01e5d493          	srli	s1,a1,0x1e
ffffffffc0201f58:	1ff4f493          	andi	s1,s1,511
ffffffffc0201f5c:	048e                	slli	s1,s1,0x3
ffffffffc0201f5e:	94aa                	add	s1,s1,a0
    if (!(*pdep1 & PTE_V)) {
ffffffffc0201f60:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201f62:	f04a                	sd	s2,32(sp)
ffffffffc0201f64:	ec4e                	sd	s3,24(sp)
ffffffffc0201f66:	e852                	sd	s4,16(sp)
ffffffffc0201f68:	fc06                	sd	ra,56(sp)
ffffffffc0201f6a:	f822                	sd	s0,48(sp)
ffffffffc0201f6c:	e456                	sd	s5,8(sp)
ffffffffc0201f6e:	e05a                	sd	s6,0(sp)
    if (!(*pdep1 & PTE_V)) {
ffffffffc0201f70:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201f74:	892e                	mv	s2,a1
ffffffffc0201f76:	8a32                	mv	s4,a2
ffffffffc0201f78:	000c7997          	auipc	s3,0xc7
ffffffffc0201f7c:	2f098993          	addi	s3,s3,752 # ffffffffc02c9268 <npage>
    if (!(*pdep1 & PTE_V)) {
ffffffffc0201f80:	e7bd                	bnez	a5,ffffffffc0201fee <get_pte+0x9e>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0201f82:	12060c63          	beqz	a2,ffffffffc02020ba <get_pte+0x16a>
ffffffffc0201f86:	4505                	li	a0,1
ffffffffc0201f88:	ebbff0ef          	jal	ra,ffffffffc0201e42 <alloc_pages>
ffffffffc0201f8c:	842a                	mv	s0,a0
ffffffffc0201f8e:	12050663          	beqz	a0,ffffffffc02020ba <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc0201f92:	000c7b17          	auipc	s6,0xc7
ffffffffc0201f96:	356b0b13          	addi	s6,s6,854 # ffffffffc02c92e8 <pages>
ffffffffc0201f9a:	000b3503          	ld	a0,0(s6)
    page->ref = val;
ffffffffc0201f9e:	4785                	li	a5,1
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201fa0:	000c7997          	auipc	s3,0xc7
ffffffffc0201fa4:	2c898993          	addi	s3,s3,712 # ffffffffc02c9268 <npage>
    return page - pages + nbase;
ffffffffc0201fa8:	40a40533          	sub	a0,s0,a0
ffffffffc0201fac:	00080ab7          	lui	s5,0x80
ffffffffc0201fb0:	8519                	srai	a0,a0,0x6
ffffffffc0201fb2:	0009b703          	ld	a4,0(s3)
    page->ref = val;
ffffffffc0201fb6:	c01c                	sw	a5,0(s0)
ffffffffc0201fb8:	57fd                	li	a5,-1
    return page - pages + nbase;
ffffffffc0201fba:	9556                	add	a0,a0,s5
ffffffffc0201fbc:	83b1                	srli	a5,a5,0xc
ffffffffc0201fbe:	8fe9                	and	a5,a5,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc0201fc0:	0532                	slli	a0,a0,0xc
ffffffffc0201fc2:	14e7f363          	bleu	a4,a5,ffffffffc0202108 <get_pte+0x1b8>
ffffffffc0201fc6:	000c7797          	auipc	a5,0xc7
ffffffffc0201fca:	31278793          	addi	a5,a5,786 # ffffffffc02c92d8 <va_pa_offset>
ffffffffc0201fce:	639c                	ld	a5,0(a5)
ffffffffc0201fd0:	6605                	lui	a2,0x1
ffffffffc0201fd2:	4581                	li	a1,0
ffffffffc0201fd4:	953e                	add	a0,a0,a5
ffffffffc0201fd6:	160070ef          	jal	ra,ffffffffc0209136 <memset>
    return page - pages + nbase;
ffffffffc0201fda:	000b3683          	ld	a3,0(s6)
ffffffffc0201fde:	40d406b3          	sub	a3,s0,a3
ffffffffc0201fe2:	8699                	srai	a3,a3,0x6
ffffffffc0201fe4:	96d6                	add	a3,a3,s5
  asm volatile("sfence.vma");
}

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201fe6:	06aa                	slli	a3,a3,0xa
ffffffffc0201fe8:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0201fec:	e094                	sd	a3,0(s1)
    }

    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0201fee:	77fd                	lui	a5,0xfffff
ffffffffc0201ff0:	068a                	slli	a3,a3,0x2
ffffffffc0201ff2:	0009b703          	ld	a4,0(s3)
ffffffffc0201ff6:	8efd                	and	a3,a3,a5
ffffffffc0201ff8:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201ffc:	0ce7f163          	bleu	a4,a5,ffffffffc02020be <get_pte+0x16e>
ffffffffc0202000:	000c7a97          	auipc	s5,0xc7
ffffffffc0202004:	2d8a8a93          	addi	s5,s5,728 # ffffffffc02c92d8 <va_pa_offset>
ffffffffc0202008:	000ab403          	ld	s0,0(s5)
ffffffffc020200c:	01595793          	srli	a5,s2,0x15
ffffffffc0202010:	1ff7f793          	andi	a5,a5,511
ffffffffc0202014:	96a2                	add	a3,a3,s0
ffffffffc0202016:	00379413          	slli	s0,a5,0x3
ffffffffc020201a:	9436                	add	s0,s0,a3
    if (!(*pdep0 & PTE_V)) {
ffffffffc020201c:	6014                	ld	a3,0(s0)
ffffffffc020201e:	0016f793          	andi	a5,a3,1
ffffffffc0202022:	e3ad                	bnez	a5,ffffffffc0202084 <get_pte+0x134>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0202024:	080a0b63          	beqz	s4,ffffffffc02020ba <get_pte+0x16a>
ffffffffc0202028:	4505                	li	a0,1
ffffffffc020202a:	e19ff0ef          	jal	ra,ffffffffc0201e42 <alloc_pages>
ffffffffc020202e:	84aa                	mv	s1,a0
ffffffffc0202030:	c549                	beqz	a0,ffffffffc02020ba <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc0202032:	000c7b17          	auipc	s6,0xc7
ffffffffc0202036:	2b6b0b13          	addi	s6,s6,694 # ffffffffc02c92e8 <pages>
ffffffffc020203a:	000b3503          	ld	a0,0(s6)
    page->ref = val;
ffffffffc020203e:	4785                	li	a5,1
    return page - pages + nbase;
ffffffffc0202040:	00080a37          	lui	s4,0x80
ffffffffc0202044:	40a48533          	sub	a0,s1,a0
ffffffffc0202048:	8519                	srai	a0,a0,0x6
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc020204a:	0009b703          	ld	a4,0(s3)
    page->ref = val;
ffffffffc020204e:	c09c                	sw	a5,0(s1)
ffffffffc0202050:	57fd                	li	a5,-1
    return page - pages + nbase;
ffffffffc0202052:	9552                	add	a0,a0,s4
ffffffffc0202054:	83b1                	srli	a5,a5,0xc
ffffffffc0202056:	8fe9                	and	a5,a5,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc0202058:	0532                	slli	a0,a0,0xc
ffffffffc020205a:	08e7fa63          	bleu	a4,a5,ffffffffc02020ee <get_pte+0x19e>
ffffffffc020205e:	000ab783          	ld	a5,0(s5)
ffffffffc0202062:	6605                	lui	a2,0x1
ffffffffc0202064:	4581                	li	a1,0
ffffffffc0202066:	953e                	add	a0,a0,a5
ffffffffc0202068:	0ce070ef          	jal	ra,ffffffffc0209136 <memset>
    return page - pages + nbase;
ffffffffc020206c:	000b3683          	ld	a3,0(s6)
ffffffffc0202070:	40d486b3          	sub	a3,s1,a3
ffffffffc0202074:	8699                	srai	a3,a3,0x6
ffffffffc0202076:	96d2                	add	a3,a3,s4
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0202078:	06aa                	slli	a3,a3,0xa
ffffffffc020207a:	0116e693          	ori	a3,a3,17
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc020207e:	e014                	sd	a3,0(s0)
ffffffffc0202080:	0009b703          	ld	a4,0(s3)
        }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0202084:	068a                	slli	a3,a3,0x2
ffffffffc0202086:	757d                	lui	a0,0xfffff
ffffffffc0202088:	8ee9                	and	a3,a3,a0
ffffffffc020208a:	00c6d793          	srli	a5,a3,0xc
ffffffffc020208e:	04e7f463          	bleu	a4,a5,ffffffffc02020d6 <get_pte+0x186>
ffffffffc0202092:	000ab503          	ld	a0,0(s5)
ffffffffc0202096:	00c95793          	srli	a5,s2,0xc
ffffffffc020209a:	1ff7f793          	andi	a5,a5,511
ffffffffc020209e:	96aa                	add	a3,a3,a0
ffffffffc02020a0:	00379513          	slli	a0,a5,0x3
ffffffffc02020a4:	9536                	add	a0,a0,a3
}
ffffffffc02020a6:	70e2                	ld	ra,56(sp)
ffffffffc02020a8:	7442                	ld	s0,48(sp)
ffffffffc02020aa:	74a2                	ld	s1,40(sp)
ffffffffc02020ac:	7902                	ld	s2,32(sp)
ffffffffc02020ae:	69e2                	ld	s3,24(sp)
ffffffffc02020b0:	6a42                	ld	s4,16(sp)
ffffffffc02020b2:	6aa2                	ld	s5,8(sp)
ffffffffc02020b4:	6b02                	ld	s6,0(sp)
ffffffffc02020b6:	6121                	addi	sp,sp,64
ffffffffc02020b8:	8082                	ret
            return NULL;
ffffffffc02020ba:	4501                	li	a0,0
ffffffffc02020bc:	b7ed                	j	ffffffffc02020a6 <get_pte+0x156>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc02020be:	00008617          	auipc	a2,0x8
ffffffffc02020c2:	e2a60613          	addi	a2,a2,-470 # ffffffffc0209ee8 <default_pmm_manager+0x50>
ffffffffc02020c6:	0fd00593          	li	a1,253
ffffffffc02020ca:	00008517          	auipc	a0,0x8
ffffffffc02020ce:	f3e50513          	addi	a0,a0,-194 # ffffffffc020a008 <default_pmm_manager+0x170>
ffffffffc02020d2:	bb6fe0ef          	jal	ra,ffffffffc0200488 <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc02020d6:	00008617          	auipc	a2,0x8
ffffffffc02020da:	e1260613          	addi	a2,a2,-494 # ffffffffc0209ee8 <default_pmm_manager+0x50>
ffffffffc02020de:	10800593          	li	a1,264
ffffffffc02020e2:	00008517          	auipc	a0,0x8
ffffffffc02020e6:	f2650513          	addi	a0,a0,-218 # ffffffffc020a008 <default_pmm_manager+0x170>
ffffffffc02020ea:	b9efe0ef          	jal	ra,ffffffffc0200488 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc02020ee:	86aa                	mv	a3,a0
ffffffffc02020f0:	00008617          	auipc	a2,0x8
ffffffffc02020f4:	df860613          	addi	a2,a2,-520 # ffffffffc0209ee8 <default_pmm_manager+0x50>
ffffffffc02020f8:	10500593          	li	a1,261
ffffffffc02020fc:	00008517          	auipc	a0,0x8
ffffffffc0202100:	f0c50513          	addi	a0,a0,-244 # ffffffffc020a008 <default_pmm_manager+0x170>
ffffffffc0202104:	b84fe0ef          	jal	ra,ffffffffc0200488 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202108:	86aa                	mv	a3,a0
ffffffffc020210a:	00008617          	auipc	a2,0x8
ffffffffc020210e:	dde60613          	addi	a2,a2,-546 # ffffffffc0209ee8 <default_pmm_manager+0x50>
ffffffffc0202112:	0f900593          	li	a1,249
ffffffffc0202116:	00008517          	auipc	a0,0x8
ffffffffc020211a:	ef250513          	addi	a0,a0,-270 # ffffffffc020a008 <default_pmm_manager+0x170>
ffffffffc020211e:	b6afe0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0202122 <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0202122:	1141                	addi	sp,sp,-16
ffffffffc0202124:	e022                	sd	s0,0(sp)
ffffffffc0202126:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202128:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc020212a:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc020212c:	e25ff0ef          	jal	ra,ffffffffc0201f50 <get_pte>
    if (ptep_store != NULL) {
ffffffffc0202130:	c011                	beqz	s0,ffffffffc0202134 <get_page+0x12>
        *ptep_store = ptep;
ffffffffc0202132:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0202134:	c129                	beqz	a0,ffffffffc0202176 <get_page+0x54>
ffffffffc0202136:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc0202138:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc020213a:	0017f713          	andi	a4,a5,1
ffffffffc020213e:	e709                	bnez	a4,ffffffffc0202148 <get_page+0x26>
}
ffffffffc0202140:	60a2                	ld	ra,8(sp)
ffffffffc0202142:	6402                	ld	s0,0(sp)
ffffffffc0202144:	0141                	addi	sp,sp,16
ffffffffc0202146:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0202148:	000c7717          	auipc	a4,0xc7
ffffffffc020214c:	12070713          	addi	a4,a4,288 # ffffffffc02c9268 <npage>
ffffffffc0202150:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202152:	078a                	slli	a5,a5,0x2
ffffffffc0202154:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202156:	02e7f563          	bleu	a4,a5,ffffffffc0202180 <get_page+0x5e>
    return &pages[PPN(pa) - nbase];
ffffffffc020215a:	000c7717          	auipc	a4,0xc7
ffffffffc020215e:	18e70713          	addi	a4,a4,398 # ffffffffc02c92e8 <pages>
ffffffffc0202162:	6308                	ld	a0,0(a4)
ffffffffc0202164:	60a2                	ld	ra,8(sp)
ffffffffc0202166:	6402                	ld	s0,0(sp)
ffffffffc0202168:	fff80737          	lui	a4,0xfff80
ffffffffc020216c:	97ba                	add	a5,a5,a4
ffffffffc020216e:	079a                	slli	a5,a5,0x6
ffffffffc0202170:	953e                	add	a0,a0,a5
ffffffffc0202172:	0141                	addi	sp,sp,16
ffffffffc0202174:	8082                	ret
ffffffffc0202176:	60a2                	ld	ra,8(sp)
ffffffffc0202178:	6402                	ld	s0,0(sp)
    return NULL;
ffffffffc020217a:	4501                	li	a0,0
}
ffffffffc020217c:	0141                	addi	sp,sp,16
ffffffffc020217e:	8082                	ret
ffffffffc0202180:	ca7ff0ef          	jal	ra,ffffffffc0201e26 <pa2page.part.4>

ffffffffc0202184 <unmap_range>:
        *ptep = 0;                  //(5) clear second page table entry
        tlb_invalidate(pgdir, la);  //(6) flush tlb
    }
}

void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc0202184:	711d                	addi	sp,sp,-96
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202186:	00c5e7b3          	or	a5,a1,a2
void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc020218a:	ec86                	sd	ra,88(sp)
ffffffffc020218c:	e8a2                	sd	s0,80(sp)
ffffffffc020218e:	e4a6                	sd	s1,72(sp)
ffffffffc0202190:	e0ca                	sd	s2,64(sp)
ffffffffc0202192:	fc4e                	sd	s3,56(sp)
ffffffffc0202194:	f852                	sd	s4,48(sp)
ffffffffc0202196:	f456                	sd	s5,40(sp)
ffffffffc0202198:	f05a                	sd	s6,32(sp)
ffffffffc020219a:	ec5e                	sd	s7,24(sp)
ffffffffc020219c:	e862                	sd	s8,16(sp)
ffffffffc020219e:	e466                	sd	s9,8(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02021a0:	03479713          	slli	a4,a5,0x34
ffffffffc02021a4:	eb71                	bnez	a4,ffffffffc0202278 <unmap_range+0xf4>
    assert(USER_ACCESS(start, end));
ffffffffc02021a6:	002007b7          	lui	a5,0x200
ffffffffc02021aa:	842e                	mv	s0,a1
ffffffffc02021ac:	0af5e663          	bltu	a1,a5,ffffffffc0202258 <unmap_range+0xd4>
ffffffffc02021b0:	8932                	mv	s2,a2
ffffffffc02021b2:	0ac5f363          	bleu	a2,a1,ffffffffc0202258 <unmap_range+0xd4>
ffffffffc02021b6:	4785                	li	a5,1
ffffffffc02021b8:	07fe                	slli	a5,a5,0x1f
ffffffffc02021ba:	08c7ef63          	bltu	a5,a2,ffffffffc0202258 <unmap_range+0xd4>
ffffffffc02021be:	89aa                	mv	s3,a0
            continue;
        }
        if (*ptep != 0) {
            page_remove_pte(pgdir, start, ptep);
        }
        start += PGSIZE;
ffffffffc02021c0:	6a05                	lui	s4,0x1
    if (PPN(pa) >= npage) {
ffffffffc02021c2:	000c7c97          	auipc	s9,0xc7
ffffffffc02021c6:	0a6c8c93          	addi	s9,s9,166 # ffffffffc02c9268 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc02021ca:	000c7c17          	auipc	s8,0xc7
ffffffffc02021ce:	11ec0c13          	addi	s8,s8,286 # ffffffffc02c92e8 <pages>
ffffffffc02021d2:	fff80bb7          	lui	s7,0xfff80
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc02021d6:	00200b37          	lui	s6,0x200
ffffffffc02021da:	ffe00ab7          	lui	s5,0xffe00
        pte_t *ptep = get_pte(pgdir, start, 0);
ffffffffc02021de:	4601                	li	a2,0
ffffffffc02021e0:	85a2                	mv	a1,s0
ffffffffc02021e2:	854e                	mv	a0,s3
ffffffffc02021e4:	d6dff0ef          	jal	ra,ffffffffc0201f50 <get_pte>
ffffffffc02021e8:	84aa                	mv	s1,a0
        if (ptep == NULL) {
ffffffffc02021ea:	cd21                	beqz	a0,ffffffffc0202242 <unmap_range+0xbe>
        if (*ptep != 0) {
ffffffffc02021ec:	611c                	ld	a5,0(a0)
ffffffffc02021ee:	e38d                	bnez	a5,ffffffffc0202210 <unmap_range+0x8c>
        start += PGSIZE;
ffffffffc02021f0:	9452                	add	s0,s0,s4
    } while (start != 0 && start < end);
ffffffffc02021f2:	ff2466e3          	bltu	s0,s2,ffffffffc02021de <unmap_range+0x5a>
}
ffffffffc02021f6:	60e6                	ld	ra,88(sp)
ffffffffc02021f8:	6446                	ld	s0,80(sp)
ffffffffc02021fa:	64a6                	ld	s1,72(sp)
ffffffffc02021fc:	6906                	ld	s2,64(sp)
ffffffffc02021fe:	79e2                	ld	s3,56(sp)
ffffffffc0202200:	7a42                	ld	s4,48(sp)
ffffffffc0202202:	7aa2                	ld	s5,40(sp)
ffffffffc0202204:	7b02                	ld	s6,32(sp)
ffffffffc0202206:	6be2                	ld	s7,24(sp)
ffffffffc0202208:	6c42                	ld	s8,16(sp)
ffffffffc020220a:	6ca2                	ld	s9,8(sp)
ffffffffc020220c:	6125                	addi	sp,sp,96
ffffffffc020220e:	8082                	ret
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc0202210:	0017f713          	andi	a4,a5,1
ffffffffc0202214:	df71                	beqz	a4,ffffffffc02021f0 <unmap_range+0x6c>
    if (PPN(pa) >= npage) {
ffffffffc0202216:	000cb703          	ld	a4,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc020221a:	078a                	slli	a5,a5,0x2
ffffffffc020221c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020221e:	06e7fd63          	bleu	a4,a5,ffffffffc0202298 <unmap_range+0x114>
    return &pages[PPN(pa) - nbase];
ffffffffc0202222:	000c3503          	ld	a0,0(s8)
ffffffffc0202226:	97de                	add	a5,a5,s7
ffffffffc0202228:	079a                	slli	a5,a5,0x6
ffffffffc020222a:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc020222c:	411c                	lw	a5,0(a0)
ffffffffc020222e:	fff7871b          	addiw	a4,a5,-1
ffffffffc0202232:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0202234:	cf11                	beqz	a4,ffffffffc0202250 <unmap_range+0xcc>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0202236:	0004b023          	sd	zero,0(s1)
}

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void tlb_invalidate(pde_t *pgdir, uintptr_t la) {
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc020223a:	12040073          	sfence.vma	s0
        start += PGSIZE;
ffffffffc020223e:	9452                	add	s0,s0,s4
ffffffffc0202240:	bf4d                	j	ffffffffc02021f2 <unmap_range+0x6e>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc0202242:	945a                	add	s0,s0,s6
ffffffffc0202244:	01547433          	and	s0,s0,s5
    } while (start != 0 && start < end);
ffffffffc0202248:	d45d                	beqz	s0,ffffffffc02021f6 <unmap_range+0x72>
ffffffffc020224a:	f9246ae3          	bltu	s0,s2,ffffffffc02021de <unmap_range+0x5a>
ffffffffc020224e:	b765                	j	ffffffffc02021f6 <unmap_range+0x72>
            free_page(page);
ffffffffc0202250:	4585                	li	a1,1
ffffffffc0202252:	c79ff0ef          	jal	ra,ffffffffc0201eca <free_pages>
ffffffffc0202256:	b7c5                	j	ffffffffc0202236 <unmap_range+0xb2>
    assert(USER_ACCESS(start, end));
ffffffffc0202258:	00008697          	auipc	a3,0x8
ffffffffc020225c:	35868693          	addi	a3,a3,856 # ffffffffc020a5b0 <default_pmm_manager+0x718>
ffffffffc0202260:	00007617          	auipc	a2,0x7
ffffffffc0202264:	4f060613          	addi	a2,a2,1264 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0202268:	14000593          	li	a1,320
ffffffffc020226c:	00008517          	auipc	a0,0x8
ffffffffc0202270:	d9c50513          	addi	a0,a0,-612 # ffffffffc020a008 <default_pmm_manager+0x170>
ffffffffc0202274:	a14fe0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202278:	00008697          	auipc	a3,0x8
ffffffffc020227c:	30868693          	addi	a3,a3,776 # ffffffffc020a580 <default_pmm_manager+0x6e8>
ffffffffc0202280:	00007617          	auipc	a2,0x7
ffffffffc0202284:	4d060613          	addi	a2,a2,1232 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0202288:	13f00593          	li	a1,319
ffffffffc020228c:	00008517          	auipc	a0,0x8
ffffffffc0202290:	d7c50513          	addi	a0,a0,-644 # ffffffffc020a008 <default_pmm_manager+0x170>
ffffffffc0202294:	9f4fe0ef          	jal	ra,ffffffffc0200488 <__panic>
ffffffffc0202298:	b8fff0ef          	jal	ra,ffffffffc0201e26 <pa2page.part.4>

ffffffffc020229c <exit_range>:
void exit_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc020229c:	7119                	addi	sp,sp,-128
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020229e:	00c5e7b3          	or	a5,a1,a2
void exit_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc02022a2:	fc86                	sd	ra,120(sp)
ffffffffc02022a4:	f8a2                	sd	s0,112(sp)
ffffffffc02022a6:	f4a6                	sd	s1,104(sp)
ffffffffc02022a8:	f0ca                	sd	s2,96(sp)
ffffffffc02022aa:	ecce                	sd	s3,88(sp)
ffffffffc02022ac:	e8d2                	sd	s4,80(sp)
ffffffffc02022ae:	e4d6                	sd	s5,72(sp)
ffffffffc02022b0:	e0da                	sd	s6,64(sp)
ffffffffc02022b2:	fc5e                	sd	s7,56(sp)
ffffffffc02022b4:	f862                	sd	s8,48(sp)
ffffffffc02022b6:	f466                	sd	s9,40(sp)
ffffffffc02022b8:	f06a                	sd	s10,32(sp)
ffffffffc02022ba:	ec6e                	sd	s11,24(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02022bc:	03479713          	slli	a4,a5,0x34
ffffffffc02022c0:	1c071163          	bnez	a4,ffffffffc0202482 <exit_range+0x1e6>
    assert(USER_ACCESS(start, end));
ffffffffc02022c4:	002007b7          	lui	a5,0x200
ffffffffc02022c8:	20f5e563          	bltu	a1,a5,ffffffffc02024d2 <exit_range+0x236>
ffffffffc02022cc:	8b32                	mv	s6,a2
ffffffffc02022ce:	20c5f263          	bleu	a2,a1,ffffffffc02024d2 <exit_range+0x236>
ffffffffc02022d2:	4785                	li	a5,1
ffffffffc02022d4:	07fe                	slli	a5,a5,0x1f
ffffffffc02022d6:	1ec7ee63          	bltu	a5,a2,ffffffffc02024d2 <exit_range+0x236>
    d1start = ROUNDDOWN(start, PDSIZE);
ffffffffc02022da:	c00009b7          	lui	s3,0xc0000
ffffffffc02022de:	400007b7          	lui	a5,0x40000
ffffffffc02022e2:	0135f9b3          	and	s3,a1,s3
ffffffffc02022e6:	99be                	add	s3,s3,a5
        pde1 = pgdir[PDX1(d1start)];
ffffffffc02022e8:	c0000337          	lui	t1,0xc0000
ffffffffc02022ec:	00698933          	add	s2,s3,t1
ffffffffc02022f0:	01e95913          	srli	s2,s2,0x1e
ffffffffc02022f4:	1ff97913          	andi	s2,s2,511
ffffffffc02022f8:	8e2a                	mv	t3,a0
ffffffffc02022fa:	090e                	slli	s2,s2,0x3
ffffffffc02022fc:	9972                	add	s2,s2,t3
ffffffffc02022fe:	00093b83          	ld	s7,0(s2)
    d0start = ROUNDDOWN(start, PTSIZE);
ffffffffc0202302:	ffe004b7          	lui	s1,0xffe00
    return KADDR(page2pa(page));
ffffffffc0202306:	5dfd                	li	s11,-1
        if (pde1&PTE_V){
ffffffffc0202308:	001bf793          	andi	a5,s7,1
    d0start = ROUNDDOWN(start, PTSIZE);
ffffffffc020230c:	8ced                	and	s1,s1,a1
    if (PPN(pa) >= npage) {
ffffffffc020230e:	000c7d17          	auipc	s10,0xc7
ffffffffc0202312:	f5ad0d13          	addi	s10,s10,-166 # ffffffffc02c9268 <npage>
    return KADDR(page2pa(page));
ffffffffc0202316:	00cddd93          	srli	s11,s11,0xc
ffffffffc020231a:	000c7717          	auipc	a4,0xc7
ffffffffc020231e:	fbe70713          	addi	a4,a4,-66 # ffffffffc02c92d8 <va_pa_offset>
    return &pages[PPN(pa) - nbase];
ffffffffc0202322:	000c7e97          	auipc	t4,0xc7
ffffffffc0202326:	fc6e8e93          	addi	t4,t4,-58 # ffffffffc02c92e8 <pages>
        if (pde1&PTE_V){
ffffffffc020232a:	e79d                	bnez	a5,ffffffffc0202358 <exit_range+0xbc>
    } while (d1start != 0 && d1start < end);
ffffffffc020232c:	12098963          	beqz	s3,ffffffffc020245e <exit_range+0x1c2>
ffffffffc0202330:	400007b7          	lui	a5,0x40000
ffffffffc0202334:	84ce                	mv	s1,s3
ffffffffc0202336:	97ce                	add	a5,a5,s3
ffffffffc0202338:	1369f363          	bleu	s6,s3,ffffffffc020245e <exit_range+0x1c2>
ffffffffc020233c:	89be                	mv	s3,a5
        pde1 = pgdir[PDX1(d1start)];
ffffffffc020233e:	00698933          	add	s2,s3,t1
ffffffffc0202342:	01e95913          	srli	s2,s2,0x1e
ffffffffc0202346:	1ff97913          	andi	s2,s2,511
ffffffffc020234a:	090e                	slli	s2,s2,0x3
ffffffffc020234c:	9972                	add	s2,s2,t3
ffffffffc020234e:	00093b83          	ld	s7,0(s2)
        if (pde1&PTE_V){
ffffffffc0202352:	001bf793          	andi	a5,s7,1
ffffffffc0202356:	dbf9                	beqz	a5,ffffffffc020232c <exit_range+0x90>
    if (PPN(pa) >= npage) {
ffffffffc0202358:	000d3783          	ld	a5,0(s10)
    return pa2page(PDE_ADDR(pde));
ffffffffc020235c:	0b8a                	slli	s7,s7,0x2
ffffffffc020235e:	00cbdb93          	srli	s7,s7,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202362:	14fbfc63          	bleu	a5,s7,ffffffffc02024ba <exit_range+0x21e>
    return &pages[PPN(pa) - nbase];
ffffffffc0202366:	fff80ab7          	lui	s5,0xfff80
ffffffffc020236a:	9ade                	add	s5,s5,s7
    return page - pages + nbase;
ffffffffc020236c:	000806b7          	lui	a3,0x80
ffffffffc0202370:	96d6                	add	a3,a3,s5
ffffffffc0202372:	006a9593          	slli	a1,s5,0x6
    return KADDR(page2pa(page));
ffffffffc0202376:	01b6f633          	and	a2,a3,s11
    return page - pages + nbase;
ffffffffc020237a:	e42e                	sd	a1,8(sp)
    return page2ppn(page) << PGSHIFT;
ffffffffc020237c:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020237e:	12f67263          	bleu	a5,a2,ffffffffc02024a2 <exit_range+0x206>
ffffffffc0202382:	00073a03          	ld	s4,0(a4)
            free_pd0 = 1;
ffffffffc0202386:	4c85                	li	s9,1
    return &pages[PPN(pa) - nbase];
ffffffffc0202388:	fff808b7          	lui	a7,0xfff80
    return KADDR(page2pa(page));
ffffffffc020238c:	9a36                	add	s4,s4,a3
    return page - pages + nbase;
ffffffffc020238e:	00080837          	lui	a6,0x80
ffffffffc0202392:	6a85                	lui	s5,0x1
                d0start += PTSIZE;
ffffffffc0202394:	00200c37          	lui	s8,0x200
ffffffffc0202398:	a801                	j	ffffffffc02023a8 <exit_range+0x10c>
                    free_pd0 = 0;
ffffffffc020239a:	4c81                	li	s9,0
                d0start += PTSIZE;
ffffffffc020239c:	94e2                	add	s1,s1,s8
            } while (d0start != 0 && d0start < d1start+PDSIZE && d0start < end);
ffffffffc020239e:	c0d9                	beqz	s1,ffffffffc0202424 <exit_range+0x188>
ffffffffc02023a0:	0934f263          	bleu	s3,s1,ffffffffc0202424 <exit_range+0x188>
ffffffffc02023a4:	0d64fc63          	bleu	s6,s1,ffffffffc020247c <exit_range+0x1e0>
                pde0 = pd0[PDX0(d0start)];
ffffffffc02023a8:	0154d413          	srli	s0,s1,0x15
ffffffffc02023ac:	1ff47413          	andi	s0,s0,511
ffffffffc02023b0:	040e                	slli	s0,s0,0x3
ffffffffc02023b2:	9452                	add	s0,s0,s4
ffffffffc02023b4:	601c                	ld	a5,0(s0)
                if (pde0&PTE_V) {
ffffffffc02023b6:	0017f693          	andi	a3,a5,1
ffffffffc02023ba:	d2e5                	beqz	a3,ffffffffc020239a <exit_range+0xfe>
    if (PPN(pa) >= npage) {
ffffffffc02023bc:	000d3583          	ld	a1,0(s10)
    return pa2page(PDE_ADDR(pde));
ffffffffc02023c0:	00279513          	slli	a0,a5,0x2
ffffffffc02023c4:	8131                	srli	a0,a0,0xc
    if (PPN(pa) >= npage) {
ffffffffc02023c6:	0eb57a63          	bleu	a1,a0,ffffffffc02024ba <exit_range+0x21e>
    return &pages[PPN(pa) - nbase];
ffffffffc02023ca:	9546                	add	a0,a0,a7
    return page - pages + nbase;
ffffffffc02023cc:	010506b3          	add	a3,a0,a6
    return KADDR(page2pa(page));
ffffffffc02023d0:	01b6f7b3          	and	a5,a3,s11
    return page - pages + nbase;
ffffffffc02023d4:	051a                	slli	a0,a0,0x6
    return page2ppn(page) << PGSHIFT;
ffffffffc02023d6:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02023d8:	0cb7f563          	bleu	a1,a5,ffffffffc02024a2 <exit_range+0x206>
ffffffffc02023dc:	631c                	ld	a5,0(a4)
ffffffffc02023de:	96be                	add	a3,a3,a5
                    for (int i = 0;i <NPTEENTRY;i++)
ffffffffc02023e0:	015685b3          	add	a1,a3,s5
                        if (pt[i]&PTE_V){
ffffffffc02023e4:	629c                	ld	a5,0(a3)
ffffffffc02023e6:	8b85                	andi	a5,a5,1
ffffffffc02023e8:	fbd5                	bnez	a5,ffffffffc020239c <exit_range+0x100>
ffffffffc02023ea:	06a1                	addi	a3,a3,8
                    for (int i = 0;i <NPTEENTRY;i++)
ffffffffc02023ec:	fed59ce3          	bne	a1,a3,ffffffffc02023e4 <exit_range+0x148>
    return &pages[PPN(pa) - nbase];
ffffffffc02023f0:	000eb783          	ld	a5,0(t4)
                        free_page(pde2page(pde0));
ffffffffc02023f4:	4585                	li	a1,1
ffffffffc02023f6:	e072                	sd	t3,0(sp)
ffffffffc02023f8:	953e                	add	a0,a0,a5
ffffffffc02023fa:	ad1ff0ef          	jal	ra,ffffffffc0201eca <free_pages>
                d0start += PTSIZE;
ffffffffc02023fe:	94e2                	add	s1,s1,s8
                        pd0[PDX0(d0start)] = 0;
ffffffffc0202400:	00043023          	sd	zero,0(s0)
ffffffffc0202404:	000c7e97          	auipc	t4,0xc7
ffffffffc0202408:	ee4e8e93          	addi	t4,t4,-284 # ffffffffc02c92e8 <pages>
ffffffffc020240c:	6e02                	ld	t3,0(sp)
ffffffffc020240e:	c0000337          	lui	t1,0xc0000
ffffffffc0202412:	fff808b7          	lui	a7,0xfff80
ffffffffc0202416:	00080837          	lui	a6,0x80
ffffffffc020241a:	000c7717          	auipc	a4,0xc7
ffffffffc020241e:	ebe70713          	addi	a4,a4,-322 # ffffffffc02c92d8 <va_pa_offset>
            } while (d0start != 0 && d0start < d1start+PDSIZE && d0start < end);
ffffffffc0202422:	fcbd                	bnez	s1,ffffffffc02023a0 <exit_range+0x104>
            if (free_pd0) {
ffffffffc0202424:	f00c84e3          	beqz	s9,ffffffffc020232c <exit_range+0x90>
    if (PPN(pa) >= npage) {
ffffffffc0202428:	000d3783          	ld	a5,0(s10)
ffffffffc020242c:	e072                	sd	t3,0(sp)
ffffffffc020242e:	08fbf663          	bleu	a5,s7,ffffffffc02024ba <exit_range+0x21e>
    return &pages[PPN(pa) - nbase];
ffffffffc0202432:	000eb503          	ld	a0,0(t4)
                free_page(pde2page(pde1));
ffffffffc0202436:	67a2                	ld	a5,8(sp)
ffffffffc0202438:	4585                	li	a1,1
ffffffffc020243a:	953e                	add	a0,a0,a5
ffffffffc020243c:	a8fff0ef          	jal	ra,ffffffffc0201eca <free_pages>
                pgdir[PDX1(d1start)] = 0;
ffffffffc0202440:	00093023          	sd	zero,0(s2)
ffffffffc0202444:	000c7717          	auipc	a4,0xc7
ffffffffc0202448:	e9470713          	addi	a4,a4,-364 # ffffffffc02c92d8 <va_pa_offset>
ffffffffc020244c:	c0000337          	lui	t1,0xc0000
ffffffffc0202450:	6e02                	ld	t3,0(sp)
ffffffffc0202452:	000c7e97          	auipc	t4,0xc7
ffffffffc0202456:	e96e8e93          	addi	t4,t4,-362 # ffffffffc02c92e8 <pages>
    } while (d1start != 0 && d1start < end);
ffffffffc020245a:	ec099be3          	bnez	s3,ffffffffc0202330 <exit_range+0x94>
}
ffffffffc020245e:	70e6                	ld	ra,120(sp)
ffffffffc0202460:	7446                	ld	s0,112(sp)
ffffffffc0202462:	74a6                	ld	s1,104(sp)
ffffffffc0202464:	7906                	ld	s2,96(sp)
ffffffffc0202466:	69e6                	ld	s3,88(sp)
ffffffffc0202468:	6a46                	ld	s4,80(sp)
ffffffffc020246a:	6aa6                	ld	s5,72(sp)
ffffffffc020246c:	6b06                	ld	s6,64(sp)
ffffffffc020246e:	7be2                	ld	s7,56(sp)
ffffffffc0202470:	7c42                	ld	s8,48(sp)
ffffffffc0202472:	7ca2                	ld	s9,40(sp)
ffffffffc0202474:	7d02                	ld	s10,32(sp)
ffffffffc0202476:	6de2                	ld	s11,24(sp)
ffffffffc0202478:	6109                	addi	sp,sp,128
ffffffffc020247a:	8082                	ret
            if (free_pd0) {
ffffffffc020247c:	ea0c8ae3          	beqz	s9,ffffffffc0202330 <exit_range+0x94>
ffffffffc0202480:	b765                	j	ffffffffc0202428 <exit_range+0x18c>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202482:	00008697          	auipc	a3,0x8
ffffffffc0202486:	0fe68693          	addi	a3,a3,254 # ffffffffc020a580 <default_pmm_manager+0x6e8>
ffffffffc020248a:	00007617          	auipc	a2,0x7
ffffffffc020248e:	2c660613          	addi	a2,a2,710 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0202492:	15000593          	li	a1,336
ffffffffc0202496:	00008517          	auipc	a0,0x8
ffffffffc020249a:	b7250513          	addi	a0,a0,-1166 # ffffffffc020a008 <default_pmm_manager+0x170>
ffffffffc020249e:	febfd0ef          	jal	ra,ffffffffc0200488 <__panic>
    return KADDR(page2pa(page));
ffffffffc02024a2:	00008617          	auipc	a2,0x8
ffffffffc02024a6:	a4660613          	addi	a2,a2,-1466 # ffffffffc0209ee8 <default_pmm_manager+0x50>
ffffffffc02024aa:	06900593          	li	a1,105
ffffffffc02024ae:	00008517          	auipc	a0,0x8
ffffffffc02024b2:	a6250513          	addi	a0,a0,-1438 # ffffffffc0209f10 <default_pmm_manager+0x78>
ffffffffc02024b6:	fd3fd0ef          	jal	ra,ffffffffc0200488 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02024ba:	00008617          	auipc	a2,0x8
ffffffffc02024be:	a8e60613          	addi	a2,a2,-1394 # ffffffffc0209f48 <default_pmm_manager+0xb0>
ffffffffc02024c2:	06200593          	li	a1,98
ffffffffc02024c6:	00008517          	auipc	a0,0x8
ffffffffc02024ca:	a4a50513          	addi	a0,a0,-1462 # ffffffffc0209f10 <default_pmm_manager+0x78>
ffffffffc02024ce:	fbbfd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc02024d2:	00008697          	auipc	a3,0x8
ffffffffc02024d6:	0de68693          	addi	a3,a3,222 # ffffffffc020a5b0 <default_pmm_manager+0x718>
ffffffffc02024da:	00007617          	auipc	a2,0x7
ffffffffc02024de:	27660613          	addi	a2,a2,630 # ffffffffc0209750 <commands+0x4c0>
ffffffffc02024e2:	15100593          	li	a1,337
ffffffffc02024e6:	00008517          	auipc	a0,0x8
ffffffffc02024ea:	b2250513          	addi	a0,a0,-1246 # ffffffffc020a008 <default_pmm_manager+0x170>
ffffffffc02024ee:	f9bfd0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc02024f2 <page_remove>:
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc02024f2:	1101                	addi	sp,sp,-32
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02024f4:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc02024f6:	e426                	sd	s1,8(sp)
ffffffffc02024f8:	ec06                	sd	ra,24(sp)
ffffffffc02024fa:	e822                	sd	s0,16(sp)
ffffffffc02024fc:	84ae                	mv	s1,a1
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02024fe:	a53ff0ef          	jal	ra,ffffffffc0201f50 <get_pte>
    if (ptep != NULL) {
ffffffffc0202502:	c511                	beqz	a0,ffffffffc020250e <page_remove+0x1c>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc0202504:	611c                	ld	a5,0(a0)
ffffffffc0202506:	842a                	mv	s0,a0
ffffffffc0202508:	0017f713          	andi	a4,a5,1
ffffffffc020250c:	e711                	bnez	a4,ffffffffc0202518 <page_remove+0x26>
}
ffffffffc020250e:	60e2                	ld	ra,24(sp)
ffffffffc0202510:	6442                	ld	s0,16(sp)
ffffffffc0202512:	64a2                	ld	s1,8(sp)
ffffffffc0202514:	6105                	addi	sp,sp,32
ffffffffc0202516:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0202518:	000c7717          	auipc	a4,0xc7
ffffffffc020251c:	d5070713          	addi	a4,a4,-688 # ffffffffc02c9268 <npage>
ffffffffc0202520:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202522:	078a                	slli	a5,a5,0x2
ffffffffc0202524:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202526:	02e7fe63          	bleu	a4,a5,ffffffffc0202562 <page_remove+0x70>
    return &pages[PPN(pa) - nbase];
ffffffffc020252a:	000c7717          	auipc	a4,0xc7
ffffffffc020252e:	dbe70713          	addi	a4,a4,-578 # ffffffffc02c92e8 <pages>
ffffffffc0202532:	6308                	ld	a0,0(a4)
ffffffffc0202534:	fff80737          	lui	a4,0xfff80
ffffffffc0202538:	97ba                	add	a5,a5,a4
ffffffffc020253a:	079a                	slli	a5,a5,0x6
ffffffffc020253c:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc020253e:	411c                	lw	a5,0(a0)
ffffffffc0202540:	fff7871b          	addiw	a4,a5,-1
ffffffffc0202544:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0202546:	cb11                	beqz	a4,ffffffffc020255a <page_remove+0x68>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0202548:	00043023          	sd	zero,0(s0)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc020254c:	12048073          	sfence.vma	s1
}
ffffffffc0202550:	60e2                	ld	ra,24(sp)
ffffffffc0202552:	6442                	ld	s0,16(sp)
ffffffffc0202554:	64a2                	ld	s1,8(sp)
ffffffffc0202556:	6105                	addi	sp,sp,32
ffffffffc0202558:	8082                	ret
            free_page(page);
ffffffffc020255a:	4585                	li	a1,1
ffffffffc020255c:	96fff0ef          	jal	ra,ffffffffc0201eca <free_pages>
ffffffffc0202560:	b7e5                	j	ffffffffc0202548 <page_remove+0x56>
ffffffffc0202562:	8c5ff0ef          	jal	ra,ffffffffc0201e26 <pa2page.part.4>

ffffffffc0202566 <page_insert>:
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0202566:	7179                	addi	sp,sp,-48
ffffffffc0202568:	e44e                	sd	s3,8(sp)
ffffffffc020256a:	89b2                	mv	s3,a2
ffffffffc020256c:	f022                	sd	s0,32(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc020256e:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0202570:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0202572:	85ce                	mv	a1,s3
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0202574:	ec26                	sd	s1,24(sp)
ffffffffc0202576:	f406                	sd	ra,40(sp)
ffffffffc0202578:	e84a                	sd	s2,16(sp)
ffffffffc020257a:	e052                	sd	s4,0(sp)
ffffffffc020257c:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc020257e:	9d3ff0ef          	jal	ra,ffffffffc0201f50 <get_pte>
    if (ptep == NULL) {
ffffffffc0202582:	cd49                	beqz	a0,ffffffffc020261c <page_insert+0xb6>
    page->ref += 1;
ffffffffc0202584:	4014                	lw	a3,0(s0)
    if (*ptep & PTE_V) {
ffffffffc0202586:	611c                	ld	a5,0(a0)
ffffffffc0202588:	892a                	mv	s2,a0
ffffffffc020258a:	0016871b          	addiw	a4,a3,1
ffffffffc020258e:	c018                	sw	a4,0(s0)
ffffffffc0202590:	0017f713          	andi	a4,a5,1
ffffffffc0202594:	ef05                	bnez	a4,ffffffffc02025cc <page_insert+0x66>
ffffffffc0202596:	000c7797          	auipc	a5,0xc7
ffffffffc020259a:	d5278793          	addi	a5,a5,-686 # ffffffffc02c92e8 <pages>
ffffffffc020259e:	6398                	ld	a4,0(a5)
    return page - pages + nbase;
ffffffffc02025a0:	8c19                	sub	s0,s0,a4
ffffffffc02025a2:	000806b7          	lui	a3,0x80
ffffffffc02025a6:	8419                	srai	s0,s0,0x6
ffffffffc02025a8:	9436                	add	s0,s0,a3
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc02025aa:	042a                	slli	s0,s0,0xa
ffffffffc02025ac:	8c45                	or	s0,s0,s1
ffffffffc02025ae:	00146413          	ori	s0,s0,1
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc02025b2:	00893023          	sd	s0,0(s2)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02025b6:	12098073          	sfence.vma	s3
    return 0;
ffffffffc02025ba:	4501                	li	a0,0
}
ffffffffc02025bc:	70a2                	ld	ra,40(sp)
ffffffffc02025be:	7402                	ld	s0,32(sp)
ffffffffc02025c0:	64e2                	ld	s1,24(sp)
ffffffffc02025c2:	6942                	ld	s2,16(sp)
ffffffffc02025c4:	69a2                	ld	s3,8(sp)
ffffffffc02025c6:	6a02                	ld	s4,0(sp)
ffffffffc02025c8:	6145                	addi	sp,sp,48
ffffffffc02025ca:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc02025cc:	000c7717          	auipc	a4,0xc7
ffffffffc02025d0:	c9c70713          	addi	a4,a4,-868 # ffffffffc02c9268 <npage>
ffffffffc02025d4:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc02025d6:	078a                	slli	a5,a5,0x2
ffffffffc02025d8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02025da:	04e7f363          	bleu	a4,a5,ffffffffc0202620 <page_insert+0xba>
    return &pages[PPN(pa) - nbase];
ffffffffc02025de:	000c7a17          	auipc	s4,0xc7
ffffffffc02025e2:	d0aa0a13          	addi	s4,s4,-758 # ffffffffc02c92e8 <pages>
ffffffffc02025e6:	000a3703          	ld	a4,0(s4)
ffffffffc02025ea:	fff80537          	lui	a0,0xfff80
ffffffffc02025ee:	953e                	add	a0,a0,a5
ffffffffc02025f0:	051a                	slli	a0,a0,0x6
ffffffffc02025f2:	953a                	add	a0,a0,a4
        if (p == page) {
ffffffffc02025f4:	00a40a63          	beq	s0,a0,ffffffffc0202608 <page_insert+0xa2>
    page->ref -= 1;
ffffffffc02025f8:	411c                	lw	a5,0(a0)
ffffffffc02025fa:	fff7869b          	addiw	a3,a5,-1
ffffffffc02025fe:	c114                	sw	a3,0(a0)
        if (page_ref(page) ==
ffffffffc0202600:	c691                	beqz	a3,ffffffffc020260c <page_insert+0xa6>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202602:	12098073          	sfence.vma	s3
ffffffffc0202606:	bf69                	j	ffffffffc02025a0 <page_insert+0x3a>
ffffffffc0202608:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc020260a:	bf59                	j	ffffffffc02025a0 <page_insert+0x3a>
            free_page(page);
ffffffffc020260c:	4585                	li	a1,1
ffffffffc020260e:	8bdff0ef          	jal	ra,ffffffffc0201eca <free_pages>
ffffffffc0202612:	000a3703          	ld	a4,0(s4)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202616:	12098073          	sfence.vma	s3
ffffffffc020261a:	b759                	j	ffffffffc02025a0 <page_insert+0x3a>
        return -E_NO_MEM;
ffffffffc020261c:	5571                	li	a0,-4
ffffffffc020261e:	bf79                	j	ffffffffc02025bc <page_insert+0x56>
ffffffffc0202620:	807ff0ef          	jal	ra,ffffffffc0201e26 <pa2page.part.4>

ffffffffc0202624 <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc0202624:	00008797          	auipc	a5,0x8
ffffffffc0202628:	87478793          	addi	a5,a5,-1932 # ffffffffc0209e98 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020262c:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc020262e:	715d                	addi	sp,sp,-80
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0202630:	00008517          	auipc	a0,0x8
ffffffffc0202634:	a0050513          	addi	a0,a0,-1536 # ffffffffc020a030 <default_pmm_manager+0x198>
void pmm_init(void) {
ffffffffc0202638:	e486                	sd	ra,72(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc020263a:	000c7717          	auipc	a4,0xc7
ffffffffc020263e:	c8f73b23          	sd	a5,-874(a4) # ffffffffc02c92d0 <pmm_manager>
void pmm_init(void) {
ffffffffc0202642:	e0a2                	sd	s0,64(sp)
ffffffffc0202644:	fc26                	sd	s1,56(sp)
ffffffffc0202646:	f84a                	sd	s2,48(sp)
ffffffffc0202648:	f44e                	sd	s3,40(sp)
ffffffffc020264a:	f052                	sd	s4,32(sp)
ffffffffc020264c:	ec56                	sd	s5,24(sp)
ffffffffc020264e:	e85a                	sd	s6,16(sp)
ffffffffc0202650:	e45e                	sd	s7,8(sp)
ffffffffc0202652:	e062                	sd	s8,0(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0202654:	000c7417          	auipc	s0,0xc7
ffffffffc0202658:	c7c40413          	addi	s0,s0,-900 # ffffffffc02c92d0 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020265c:	b37fd0ef          	jal	ra,ffffffffc0200192 <cprintf>
    pmm_manager->init();
ffffffffc0202660:	601c                	ld	a5,0(s0)
ffffffffc0202662:	000c7497          	auipc	s1,0xc7
ffffffffc0202666:	c0648493          	addi	s1,s1,-1018 # ffffffffc02c9268 <npage>
ffffffffc020266a:	000c7917          	auipc	s2,0xc7
ffffffffc020266e:	c7e90913          	addi	s2,s2,-898 # ffffffffc02c92e8 <pages>
ffffffffc0202672:	679c                	ld	a5,8(a5)
ffffffffc0202674:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0202676:	57f5                	li	a5,-3
ffffffffc0202678:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc020267a:	00008517          	auipc	a0,0x8
ffffffffc020267e:	9ce50513          	addi	a0,a0,-1586 # ffffffffc020a048 <default_pmm_manager+0x1b0>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0202682:	000c7717          	auipc	a4,0xc7
ffffffffc0202686:	c4f73b23          	sd	a5,-938(a4) # ffffffffc02c92d8 <va_pa_offset>
    cprintf("physcial memory map:\n");
ffffffffc020268a:	b09fd0ef          	jal	ra,ffffffffc0200192 <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc020268e:	46c5                	li	a3,17
ffffffffc0202690:	06ee                	slli	a3,a3,0x1b
ffffffffc0202692:	40100613          	li	a2,1025
ffffffffc0202696:	16fd                	addi	a3,a3,-1
ffffffffc0202698:	0656                	slli	a2,a2,0x15
ffffffffc020269a:	07e005b7          	lui	a1,0x7e00
ffffffffc020269e:	00008517          	auipc	a0,0x8
ffffffffc02026a2:	9c250513          	addi	a0,a0,-1598 # ffffffffc020a060 <default_pmm_manager+0x1c8>
ffffffffc02026a6:	aedfd0ef          	jal	ra,ffffffffc0200192 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02026aa:	777d                	lui	a4,0xfffff
ffffffffc02026ac:	000c8797          	auipc	a5,0xc8
ffffffffc02026b0:	d3378793          	addi	a5,a5,-717 # ffffffffc02ca3df <end+0xfff>
ffffffffc02026b4:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc02026b6:	00088737          	lui	a4,0x88
ffffffffc02026ba:	000c7697          	auipc	a3,0xc7
ffffffffc02026be:	bae6b723          	sd	a4,-1106(a3) # ffffffffc02c9268 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02026c2:	000c7717          	auipc	a4,0xc7
ffffffffc02026c6:	c2f73323          	sd	a5,-986(a4) # ffffffffc02c92e8 <pages>
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02026ca:	4701                	li	a4,0
ffffffffc02026cc:	4685                	li	a3,1
ffffffffc02026ce:	fff80837          	lui	a6,0xfff80
ffffffffc02026d2:	a019                	j	ffffffffc02026d8 <pmm_init+0xb4>
ffffffffc02026d4:	00093783          	ld	a5,0(s2)
        SetPageReserved(pages + i);
ffffffffc02026d8:	00671613          	slli	a2,a4,0x6
ffffffffc02026dc:	97b2                	add	a5,a5,a2
ffffffffc02026de:	07a1                	addi	a5,a5,8
ffffffffc02026e0:	40d7b02f          	amoor.d	zero,a3,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02026e4:	6090                	ld	a2,0(s1)
ffffffffc02026e6:	0705                	addi	a4,a4,1
ffffffffc02026e8:	010607b3          	add	a5,a2,a6
ffffffffc02026ec:	fef764e3          	bltu	a4,a5,ffffffffc02026d4 <pmm_init+0xb0>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02026f0:	00093503          	ld	a0,0(s2)
ffffffffc02026f4:	fe0007b7          	lui	a5,0xfe000
ffffffffc02026f8:	00661693          	slli	a3,a2,0x6
ffffffffc02026fc:	97aa                	add	a5,a5,a0
ffffffffc02026fe:	96be                	add	a3,a3,a5
ffffffffc0202700:	c02007b7          	lui	a5,0xc0200
ffffffffc0202704:	7af6ed63          	bltu	a3,a5,ffffffffc0202ebe <pmm_init+0x89a>
ffffffffc0202708:	000c7997          	auipc	s3,0xc7
ffffffffc020270c:	bd098993          	addi	s3,s3,-1072 # ffffffffc02c92d8 <va_pa_offset>
ffffffffc0202710:	0009b583          	ld	a1,0(s3)
    if (freemem < mem_end) {
ffffffffc0202714:	47c5                	li	a5,17
ffffffffc0202716:	07ee                	slli	a5,a5,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0202718:	8e8d                	sub	a3,a3,a1
    if (freemem < mem_end) {
ffffffffc020271a:	02f6f763          	bleu	a5,a3,ffffffffc0202748 <pmm_init+0x124>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc020271e:	6585                	lui	a1,0x1
ffffffffc0202720:	15fd                	addi	a1,a1,-1
ffffffffc0202722:	96ae                	add	a3,a3,a1
    if (PPN(pa) >= npage) {
ffffffffc0202724:	00c6d713          	srli	a4,a3,0xc
ffffffffc0202728:	48c77a63          	bleu	a2,a4,ffffffffc0202bbc <pmm_init+0x598>
    pmm_manager->init_memmap(base, n);
ffffffffc020272c:	6010                	ld	a2,0(s0)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc020272e:	75fd                	lui	a1,0xfffff
ffffffffc0202730:	8eed                	and	a3,a3,a1
    return &pages[PPN(pa) - nbase];
ffffffffc0202732:	9742                	add	a4,a4,a6
    pmm_manager->init_memmap(base, n);
ffffffffc0202734:	6a10                	ld	a2,16(a2)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0202736:	40d786b3          	sub	a3,a5,a3
ffffffffc020273a:	071a                	slli	a4,a4,0x6
    pmm_manager->init_memmap(base, n);
ffffffffc020273c:	00c6d593          	srli	a1,a3,0xc
ffffffffc0202740:	953a                	add	a0,a0,a4
ffffffffc0202742:	9602                	jalr	a2
ffffffffc0202744:	0009b583          	ld	a1,0(s3)
    cprintf("vapaofset is %llu\n",va_pa_offset);
ffffffffc0202748:	00008517          	auipc	a0,0x8
ffffffffc020274c:	94050513          	addi	a0,a0,-1728 # ffffffffc020a088 <default_pmm_manager+0x1f0>
ffffffffc0202750:	a43fd0ef          	jal	ra,ffffffffc0200192 <cprintf>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0202754:	601c                	ld	a5,0(s0)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0202756:	000c7417          	auipc	s0,0xc7
ffffffffc020275a:	b0a40413          	addi	s0,s0,-1270 # ffffffffc02c9260 <boot_pgdir>
    pmm_manager->check();
ffffffffc020275e:	7b9c                	ld	a5,48(a5)
ffffffffc0202760:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0202762:	00008517          	auipc	a0,0x8
ffffffffc0202766:	93e50513          	addi	a0,a0,-1730 # ffffffffc020a0a0 <default_pmm_manager+0x208>
ffffffffc020276a:	a29fd0ef          	jal	ra,ffffffffc0200192 <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc020276e:	0000c697          	auipc	a3,0xc
ffffffffc0202772:	89268693          	addi	a3,a3,-1902 # ffffffffc020e000 <boot_page_table_sv39>
ffffffffc0202776:	000c7797          	auipc	a5,0xc7
ffffffffc020277a:	aed7b523          	sd	a3,-1302(a5) # ffffffffc02c9260 <boot_pgdir>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc020277e:	c02007b7          	lui	a5,0xc0200
ffffffffc0202782:	10f6eae3          	bltu	a3,a5,ffffffffc0203096 <pmm_init+0xa72>
ffffffffc0202786:	0009b783          	ld	a5,0(s3)
ffffffffc020278a:	8e9d                	sub	a3,a3,a5
ffffffffc020278c:	000c7797          	auipc	a5,0xc7
ffffffffc0202790:	b4d7ba23          	sd	a3,-1196(a5) # ffffffffc02c92e0 <boot_cr3>
    // assert(npage <= KMEMSIZE / PGSIZE);
    // The memory starts at 2GB in RISC-V
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();
ffffffffc0202794:	f7cff0ef          	jal	ra,ffffffffc0201f10 <nr_free_pages>

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0202798:	6098                	ld	a4,0(s1)
ffffffffc020279a:	c80007b7          	lui	a5,0xc8000
ffffffffc020279e:	83b1                	srli	a5,a5,0xc
    nr_free_store=nr_free_pages();
ffffffffc02027a0:	8a2a                	mv	s4,a0
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc02027a2:	0ce7eae3          	bltu	a5,a4,ffffffffc0203076 <pmm_init+0xa52>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc02027a6:	6008                	ld	a0,0(s0)
ffffffffc02027a8:	44050463          	beqz	a0,ffffffffc0202bf0 <pmm_init+0x5cc>
ffffffffc02027ac:	6785                	lui	a5,0x1
ffffffffc02027ae:	17fd                	addi	a5,a5,-1
ffffffffc02027b0:	8fe9                	and	a5,a5,a0
ffffffffc02027b2:	2781                	sext.w	a5,a5
ffffffffc02027b4:	42079e63          	bnez	a5,ffffffffc0202bf0 <pmm_init+0x5cc>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc02027b8:	4601                	li	a2,0
ffffffffc02027ba:	4581                	li	a1,0
ffffffffc02027bc:	967ff0ef          	jal	ra,ffffffffc0202122 <get_page>
ffffffffc02027c0:	78051b63          	bnez	a0,ffffffffc0202f56 <pmm_init+0x932>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc02027c4:	4505                	li	a0,1
ffffffffc02027c6:	e7cff0ef          	jal	ra,ffffffffc0201e42 <alloc_pages>
ffffffffc02027ca:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc02027cc:	6008                	ld	a0,0(s0)
ffffffffc02027ce:	4681                	li	a3,0
ffffffffc02027d0:	4601                	li	a2,0
ffffffffc02027d2:	85d6                	mv	a1,s5
ffffffffc02027d4:	d93ff0ef          	jal	ra,ffffffffc0202566 <page_insert>
ffffffffc02027d8:	7a051f63          	bnez	a0,ffffffffc0202f96 <pmm_init+0x972>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc02027dc:	6008                	ld	a0,0(s0)
ffffffffc02027de:	4601                	li	a2,0
ffffffffc02027e0:	4581                	li	a1,0
ffffffffc02027e2:	f6eff0ef          	jal	ra,ffffffffc0201f50 <get_pte>
ffffffffc02027e6:	78050863          	beqz	a0,ffffffffc0202f76 <pmm_init+0x952>
    assert(pte2page(*ptep) == p1);
ffffffffc02027ea:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc02027ec:	0017f713          	andi	a4,a5,1
ffffffffc02027f0:	3e070463          	beqz	a4,ffffffffc0202bd8 <pmm_init+0x5b4>
    if (PPN(pa) >= npage) {
ffffffffc02027f4:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc02027f6:	078a                	slli	a5,a5,0x2
ffffffffc02027f8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02027fa:	3ce7f163          	bleu	a4,a5,ffffffffc0202bbc <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc02027fe:	00093683          	ld	a3,0(s2)
ffffffffc0202802:	fff80637          	lui	a2,0xfff80
ffffffffc0202806:	97b2                	add	a5,a5,a2
ffffffffc0202808:	079a                	slli	a5,a5,0x6
ffffffffc020280a:	97b6                	add	a5,a5,a3
ffffffffc020280c:	72fa9563          	bne	s5,a5,ffffffffc0202f36 <pmm_init+0x912>
    assert(page_ref(p1) == 1);
ffffffffc0202810:	000aab83          	lw	s7,0(s5) # 1000 <_binary_obj___user_faultread_out_size-0x8900>
ffffffffc0202814:	4785                	li	a5,1
ffffffffc0202816:	70fb9063          	bne	s7,a5,ffffffffc0202f16 <pmm_init+0x8f2>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc020281a:	6008                	ld	a0,0(s0)
ffffffffc020281c:	76fd                	lui	a3,0xfffff
ffffffffc020281e:	611c                	ld	a5,0(a0)
ffffffffc0202820:	078a                	slli	a5,a5,0x2
ffffffffc0202822:	8ff5                	and	a5,a5,a3
ffffffffc0202824:	00c7d613          	srli	a2,a5,0xc
ffffffffc0202828:	66e67e63          	bleu	a4,a2,ffffffffc0202ea4 <pmm_init+0x880>
ffffffffc020282c:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202830:	97e2                	add	a5,a5,s8
ffffffffc0202832:	0007bb03          	ld	s6,0(a5) # 1000 <_binary_obj___user_faultread_out_size-0x8900>
ffffffffc0202836:	0b0a                	slli	s6,s6,0x2
ffffffffc0202838:	00db7b33          	and	s6,s6,a3
ffffffffc020283c:	00cb5793          	srli	a5,s6,0xc
ffffffffc0202840:	56e7f863          	bleu	a4,a5,ffffffffc0202db0 <pmm_init+0x78c>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0202844:	4601                	li	a2,0
ffffffffc0202846:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202848:	9b62                	add	s6,s6,s8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc020284a:	f06ff0ef          	jal	ra,ffffffffc0201f50 <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc020284e:	0b21                	addi	s6,s6,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0202850:	55651063          	bne	a0,s6,ffffffffc0202d90 <pmm_init+0x76c>

    p2 = alloc_page();
ffffffffc0202854:	4505                	li	a0,1
ffffffffc0202856:	decff0ef          	jal	ra,ffffffffc0201e42 <alloc_pages>
ffffffffc020285a:	8b2a                	mv	s6,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc020285c:	6008                	ld	a0,0(s0)
ffffffffc020285e:	46d1                	li	a3,20
ffffffffc0202860:	6605                	lui	a2,0x1
ffffffffc0202862:	85da                	mv	a1,s6
ffffffffc0202864:	d03ff0ef          	jal	ra,ffffffffc0202566 <page_insert>
ffffffffc0202868:	50051463          	bnez	a0,ffffffffc0202d70 <pmm_init+0x74c>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc020286c:	6008                	ld	a0,0(s0)
ffffffffc020286e:	4601                	li	a2,0
ffffffffc0202870:	6585                	lui	a1,0x1
ffffffffc0202872:	edeff0ef          	jal	ra,ffffffffc0201f50 <get_pte>
ffffffffc0202876:	4c050d63          	beqz	a0,ffffffffc0202d50 <pmm_init+0x72c>
    assert(*ptep & PTE_U);
ffffffffc020287a:	611c                	ld	a5,0(a0)
ffffffffc020287c:	0107f713          	andi	a4,a5,16
ffffffffc0202880:	4a070863          	beqz	a4,ffffffffc0202d30 <pmm_init+0x70c>
    assert(*ptep & PTE_W);
ffffffffc0202884:	8b91                	andi	a5,a5,4
ffffffffc0202886:	48078563          	beqz	a5,ffffffffc0202d10 <pmm_init+0x6ec>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc020288a:	6008                	ld	a0,0(s0)
ffffffffc020288c:	611c                	ld	a5,0(a0)
ffffffffc020288e:	8bc1                	andi	a5,a5,16
ffffffffc0202890:	46078063          	beqz	a5,ffffffffc0202cf0 <pmm_init+0x6cc>
    assert(page_ref(p2) == 1);
ffffffffc0202894:	000b2783          	lw	a5,0(s6) # 200000 <_binary_obj___user_matrix_out_size+0x1f4598>
ffffffffc0202898:	43779c63          	bne	a5,s7,ffffffffc0202cd0 <pmm_init+0x6ac>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc020289c:	4681                	li	a3,0
ffffffffc020289e:	6605                	lui	a2,0x1
ffffffffc02028a0:	85d6                	mv	a1,s5
ffffffffc02028a2:	cc5ff0ef          	jal	ra,ffffffffc0202566 <page_insert>
ffffffffc02028a6:	40051563          	bnez	a0,ffffffffc0202cb0 <pmm_init+0x68c>
    assert(page_ref(p1) == 2);
ffffffffc02028aa:	000aa703          	lw	a4,0(s5)
ffffffffc02028ae:	4789                	li	a5,2
ffffffffc02028b0:	3ef71063          	bne	a4,a5,ffffffffc0202c90 <pmm_init+0x66c>
    assert(page_ref(p2) == 0);
ffffffffc02028b4:	000b2783          	lw	a5,0(s6)
ffffffffc02028b8:	3a079c63          	bnez	a5,ffffffffc0202c70 <pmm_init+0x64c>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc02028bc:	6008                	ld	a0,0(s0)
ffffffffc02028be:	4601                	li	a2,0
ffffffffc02028c0:	6585                	lui	a1,0x1
ffffffffc02028c2:	e8eff0ef          	jal	ra,ffffffffc0201f50 <get_pte>
ffffffffc02028c6:	38050563          	beqz	a0,ffffffffc0202c50 <pmm_init+0x62c>
    assert(pte2page(*ptep) == p1);
ffffffffc02028ca:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc02028cc:	00177793          	andi	a5,a4,1
ffffffffc02028d0:	30078463          	beqz	a5,ffffffffc0202bd8 <pmm_init+0x5b4>
    if (PPN(pa) >= npage) {
ffffffffc02028d4:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc02028d6:	00271793          	slli	a5,a4,0x2
ffffffffc02028da:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02028dc:	2ed7f063          	bleu	a3,a5,ffffffffc0202bbc <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc02028e0:	00093683          	ld	a3,0(s2)
ffffffffc02028e4:	fff80637          	lui	a2,0xfff80
ffffffffc02028e8:	97b2                	add	a5,a5,a2
ffffffffc02028ea:	079a                	slli	a5,a5,0x6
ffffffffc02028ec:	97b6                	add	a5,a5,a3
ffffffffc02028ee:	32fa9163          	bne	s5,a5,ffffffffc0202c10 <pmm_init+0x5ec>
    assert((*ptep & PTE_U) == 0);
ffffffffc02028f2:	8b41                	andi	a4,a4,16
ffffffffc02028f4:	70071163          	bnez	a4,ffffffffc0202ff6 <pmm_init+0x9d2>

    page_remove(boot_pgdir, 0x0);
ffffffffc02028f8:	6008                	ld	a0,0(s0)
ffffffffc02028fa:	4581                	li	a1,0
ffffffffc02028fc:	bf7ff0ef          	jal	ra,ffffffffc02024f2 <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc0202900:	000aa703          	lw	a4,0(s5)
ffffffffc0202904:	4785                	li	a5,1
ffffffffc0202906:	6cf71863          	bne	a4,a5,ffffffffc0202fd6 <pmm_init+0x9b2>
    assert(page_ref(p2) == 0);
ffffffffc020290a:	000b2783          	lw	a5,0(s6)
ffffffffc020290e:	6a079463          	bnez	a5,ffffffffc0202fb6 <pmm_init+0x992>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc0202912:	6008                	ld	a0,0(s0)
ffffffffc0202914:	6585                	lui	a1,0x1
ffffffffc0202916:	bddff0ef          	jal	ra,ffffffffc02024f2 <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc020291a:	000aa783          	lw	a5,0(s5)
ffffffffc020291e:	50079363          	bnez	a5,ffffffffc0202e24 <pmm_init+0x800>
    assert(page_ref(p2) == 0);
ffffffffc0202922:	000b2783          	lw	a5,0(s6)
ffffffffc0202926:	4c079f63          	bnez	a5,ffffffffc0202e04 <pmm_init+0x7e0>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc020292a:	00043a83          	ld	s5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc020292e:	6090                	ld	a2,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202930:	000ab783          	ld	a5,0(s5)
ffffffffc0202934:	078a                	slli	a5,a5,0x2
ffffffffc0202936:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202938:	28c7f263          	bleu	a2,a5,ffffffffc0202bbc <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc020293c:	fff80737          	lui	a4,0xfff80
ffffffffc0202940:	00093503          	ld	a0,0(s2)
ffffffffc0202944:	97ba                	add	a5,a5,a4
ffffffffc0202946:	079a                	slli	a5,a5,0x6
ffffffffc0202948:	00f50733          	add	a4,a0,a5
ffffffffc020294c:	4314                	lw	a3,0(a4)
ffffffffc020294e:	4705                	li	a4,1
ffffffffc0202950:	48e69a63          	bne	a3,a4,ffffffffc0202de4 <pmm_init+0x7c0>
    return page - pages + nbase;
ffffffffc0202954:	8799                	srai	a5,a5,0x6
ffffffffc0202956:	00080b37          	lui	s6,0x80
    return KADDR(page2pa(page));
ffffffffc020295a:	577d                	li	a4,-1
    return page - pages + nbase;
ffffffffc020295c:	97da                	add	a5,a5,s6
    return KADDR(page2pa(page));
ffffffffc020295e:	8331                	srli	a4,a4,0xc
ffffffffc0202960:	8f7d                	and	a4,a4,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0202962:	07b2                	slli	a5,a5,0xc
    return KADDR(page2pa(page));
ffffffffc0202964:	46c77363          	bleu	a2,a4,ffffffffc0202dca <pmm_init+0x7a6>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc0202968:	0009b683          	ld	a3,0(s3)
ffffffffc020296c:	97b6                	add	a5,a5,a3
    return pa2page(PDE_ADDR(pde));
ffffffffc020296e:	639c                	ld	a5,0(a5)
ffffffffc0202970:	078a                	slli	a5,a5,0x2
ffffffffc0202972:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202974:	24c7f463          	bleu	a2,a5,ffffffffc0202bbc <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc0202978:	416787b3          	sub	a5,a5,s6
ffffffffc020297c:	079a                	slli	a5,a5,0x6
ffffffffc020297e:	953e                	add	a0,a0,a5
ffffffffc0202980:	4585                	li	a1,1
ffffffffc0202982:	d48ff0ef          	jal	ra,ffffffffc0201eca <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0202986:	000ab783          	ld	a5,0(s5)
    if (PPN(pa) >= npage) {
ffffffffc020298a:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc020298c:	078a                	slli	a5,a5,0x2
ffffffffc020298e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202990:	22e7f663          	bleu	a4,a5,ffffffffc0202bbc <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc0202994:	00093503          	ld	a0,0(s2)
ffffffffc0202998:	416787b3          	sub	a5,a5,s6
ffffffffc020299c:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc020299e:	953e                	add	a0,a0,a5
ffffffffc02029a0:	4585                	li	a1,1
ffffffffc02029a2:	d28ff0ef          	jal	ra,ffffffffc0201eca <free_pages>
    boot_pgdir[0] = 0;
ffffffffc02029a6:	601c                	ld	a5,0(s0)
ffffffffc02029a8:	0007b023          	sd	zero,0(a5)
  asm volatile("sfence.vma");
ffffffffc02029ac:	12000073          	sfence.vma
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc02029b0:	d60ff0ef          	jal	ra,ffffffffc0201f10 <nr_free_pages>
ffffffffc02029b4:	68aa1163          	bne	s4,a0,ffffffffc0203036 <pmm_init+0xa12>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc02029b8:	00008517          	auipc	a0,0x8
ffffffffc02029bc:	9f850513          	addi	a0,a0,-1544 # ffffffffc020a3b0 <default_pmm_manager+0x518>
ffffffffc02029c0:	fd2fd0ef          	jal	ra,ffffffffc0200192 <cprintf>
static void check_boot_pgdir(void) {
    size_t nr_free_store;
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();
ffffffffc02029c4:	d4cff0ef          	jal	ra,ffffffffc0201f10 <nr_free_pages>

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02029c8:	6098                	ld	a4,0(s1)
ffffffffc02029ca:	c02007b7          	lui	a5,0xc0200
    nr_free_store=nr_free_pages();
ffffffffc02029ce:	8a2a                	mv	s4,a0
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02029d0:	00c71693          	slli	a3,a4,0xc
ffffffffc02029d4:	18d7f563          	bleu	a3,a5,ffffffffc0202b5e <pmm_init+0x53a>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02029d8:	83b1                	srli	a5,a5,0xc
ffffffffc02029da:	6008                	ld	a0,0(s0)
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02029dc:	c0200ab7          	lui	s5,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02029e0:	1ae7f163          	bleu	a4,a5,ffffffffc0202b82 <pmm_init+0x55e>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc02029e4:	7bfd                	lui	s7,0xfffff
ffffffffc02029e6:	6b05                	lui	s6,0x1
ffffffffc02029e8:	a029                	j	ffffffffc02029f2 <pmm_init+0x3ce>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02029ea:	00cad713          	srli	a4,s5,0xc
ffffffffc02029ee:	18f77a63          	bleu	a5,a4,ffffffffc0202b82 <pmm_init+0x55e>
ffffffffc02029f2:	0009b583          	ld	a1,0(s3)
ffffffffc02029f6:	4601                	li	a2,0
ffffffffc02029f8:	95d6                	add	a1,a1,s5
ffffffffc02029fa:	d56ff0ef          	jal	ra,ffffffffc0201f50 <get_pte>
ffffffffc02029fe:	16050263          	beqz	a0,ffffffffc0202b62 <pmm_init+0x53e>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202a02:	611c                	ld	a5,0(a0)
ffffffffc0202a04:	078a                	slli	a5,a5,0x2
ffffffffc0202a06:	0177f7b3          	and	a5,a5,s7
ffffffffc0202a0a:	19579963          	bne	a5,s5,ffffffffc0202b9c <pmm_init+0x578>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0202a0e:	609c                	ld	a5,0(s1)
ffffffffc0202a10:	9ada                	add	s5,s5,s6
ffffffffc0202a12:	6008                	ld	a0,0(s0)
ffffffffc0202a14:	00c79713          	slli	a4,a5,0xc
ffffffffc0202a18:	fceae9e3          	bltu	s5,a4,ffffffffc02029ea <pmm_init+0x3c6>
    }


    assert(boot_pgdir[0] == 0);
ffffffffc0202a1c:	611c                	ld	a5,0(a0)
ffffffffc0202a1e:	62079c63          	bnez	a5,ffffffffc0203056 <pmm_init+0xa32>

    struct Page *p;
    p = alloc_page();
ffffffffc0202a22:	4505                	li	a0,1
ffffffffc0202a24:	c1eff0ef          	jal	ra,ffffffffc0201e42 <alloc_pages>
ffffffffc0202a28:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0202a2a:	6008                	ld	a0,0(s0)
ffffffffc0202a2c:	4699                	li	a3,6
ffffffffc0202a2e:	10000613          	li	a2,256
ffffffffc0202a32:	85d6                	mv	a1,s5
ffffffffc0202a34:	b33ff0ef          	jal	ra,ffffffffc0202566 <page_insert>
ffffffffc0202a38:	1e051c63          	bnez	a0,ffffffffc0202c30 <pmm_init+0x60c>
    assert(page_ref(p) == 1);
ffffffffc0202a3c:	000aa703          	lw	a4,0(s5) # ffffffffc0200000 <kern_entry>
ffffffffc0202a40:	4785                	li	a5,1
ffffffffc0202a42:	44f71163          	bne	a4,a5,ffffffffc0202e84 <pmm_init+0x860>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0202a46:	6008                	ld	a0,0(s0)
ffffffffc0202a48:	6b05                	lui	s6,0x1
ffffffffc0202a4a:	4699                	li	a3,6
ffffffffc0202a4c:	100b0613          	addi	a2,s6,256 # 1100 <_binary_obj___user_faultread_out_size-0x8800>
ffffffffc0202a50:	85d6                	mv	a1,s5
ffffffffc0202a52:	b15ff0ef          	jal	ra,ffffffffc0202566 <page_insert>
ffffffffc0202a56:	40051763          	bnez	a0,ffffffffc0202e64 <pmm_init+0x840>
    assert(page_ref(p) == 2);
ffffffffc0202a5a:	000aa703          	lw	a4,0(s5)
ffffffffc0202a5e:	4789                	li	a5,2
ffffffffc0202a60:	3ef71263          	bne	a4,a5,ffffffffc0202e44 <pmm_init+0x820>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc0202a64:	00008597          	auipc	a1,0x8
ffffffffc0202a68:	a8458593          	addi	a1,a1,-1404 # ffffffffc020a4e8 <default_pmm_manager+0x650>
ffffffffc0202a6c:	10000513          	li	a0,256
ffffffffc0202a70:	66c060ef          	jal	ra,ffffffffc02090dc <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0202a74:	100b0593          	addi	a1,s6,256
ffffffffc0202a78:	10000513          	li	a0,256
ffffffffc0202a7c:	672060ef          	jal	ra,ffffffffc02090ee <strcmp>
ffffffffc0202a80:	44051b63          	bnez	a0,ffffffffc0202ed6 <pmm_init+0x8b2>
    return page - pages + nbase;
ffffffffc0202a84:	00093683          	ld	a3,0(s2)
ffffffffc0202a88:	00080737          	lui	a4,0x80
    return KADDR(page2pa(page));
ffffffffc0202a8c:	5b7d                	li	s6,-1
    return page - pages + nbase;
ffffffffc0202a8e:	40da86b3          	sub	a3,s5,a3
ffffffffc0202a92:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0202a94:	609c                	ld	a5,0(s1)
    return page - pages + nbase;
ffffffffc0202a96:	96ba                	add	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc0202a98:	00cb5b13          	srli	s6,s6,0xc
ffffffffc0202a9c:	0166f733          	and	a4,a3,s6
    return page2ppn(page) << PGSHIFT;
ffffffffc0202aa0:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202aa2:	10f77f63          	bleu	a5,a4,ffffffffc0202bc0 <pmm_init+0x59c>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0202aa6:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202aaa:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0202aae:	96be                	add	a3,a3,a5
ffffffffc0202ab0:	10068023          	sb	zero,256(a3) # fffffffffffff100 <end+0x3fd35d20>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202ab4:	5e4060ef          	jal	ra,ffffffffc0209098 <strlen>
ffffffffc0202ab8:	54051f63          	bnez	a0,ffffffffc0203016 <pmm_init+0x9f2>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0202abc:	00043b83          	ld	s7,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0202ac0:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202ac2:	000bb683          	ld	a3,0(s7) # fffffffffffff000 <end+0x3fd35c20>
ffffffffc0202ac6:	068a                	slli	a3,a3,0x2
ffffffffc0202ac8:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202aca:	0ef6f963          	bleu	a5,a3,ffffffffc0202bbc <pmm_init+0x598>
    return KADDR(page2pa(page));
ffffffffc0202ace:	0166fb33          	and	s6,a3,s6
    return page2ppn(page) << PGSHIFT;
ffffffffc0202ad2:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202ad4:	0efb7663          	bleu	a5,s6,ffffffffc0202bc0 <pmm_init+0x59c>
ffffffffc0202ad8:	0009b983          	ld	s3,0(s3)
    free_page(p);
ffffffffc0202adc:	4585                	li	a1,1
ffffffffc0202ade:	8556                	mv	a0,s5
ffffffffc0202ae0:	99b6                	add	s3,s3,a3
ffffffffc0202ae2:	be8ff0ef          	jal	ra,ffffffffc0201eca <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0202ae6:	0009b783          	ld	a5,0(s3)
    if (PPN(pa) >= npage) {
ffffffffc0202aea:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202aec:	078a                	slli	a5,a5,0x2
ffffffffc0202aee:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202af0:	0ce7f663          	bleu	a4,a5,ffffffffc0202bbc <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc0202af4:	00093503          	ld	a0,0(s2)
ffffffffc0202af8:	fff809b7          	lui	s3,0xfff80
ffffffffc0202afc:	97ce                	add	a5,a5,s3
ffffffffc0202afe:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd0[0]));
ffffffffc0202b00:	953e                	add	a0,a0,a5
ffffffffc0202b02:	4585                	li	a1,1
ffffffffc0202b04:	bc6ff0ef          	jal	ra,ffffffffc0201eca <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0202b08:	000bb783          	ld	a5,0(s7)
    if (PPN(pa) >= npage) {
ffffffffc0202b0c:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202b0e:	078a                	slli	a5,a5,0x2
ffffffffc0202b10:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202b12:	0ae7f563          	bleu	a4,a5,ffffffffc0202bbc <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc0202b16:	00093503          	ld	a0,0(s2)
ffffffffc0202b1a:	97ce                	add	a5,a5,s3
ffffffffc0202b1c:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc0202b1e:	953e                	add	a0,a0,a5
ffffffffc0202b20:	4585                	li	a1,1
ffffffffc0202b22:	ba8ff0ef          	jal	ra,ffffffffc0201eca <free_pages>
    boot_pgdir[0] = 0;
ffffffffc0202b26:	601c                	ld	a5,0(s0)
ffffffffc0202b28:	0007b023          	sd	zero,0(a5) # ffffffffc0200000 <kern_entry>
  asm volatile("sfence.vma");
ffffffffc0202b2c:	12000073          	sfence.vma
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc0202b30:	be0ff0ef          	jal	ra,ffffffffc0201f10 <nr_free_pages>
ffffffffc0202b34:	3caa1163          	bne	s4,a0,ffffffffc0202ef6 <pmm_init+0x8d2>

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc0202b38:	00008517          	auipc	a0,0x8
ffffffffc0202b3c:	a2850513          	addi	a0,a0,-1496 # ffffffffc020a560 <default_pmm_manager+0x6c8>
ffffffffc0202b40:	e52fd0ef          	jal	ra,ffffffffc0200192 <cprintf>
}
ffffffffc0202b44:	6406                	ld	s0,64(sp)
ffffffffc0202b46:	60a6                	ld	ra,72(sp)
ffffffffc0202b48:	74e2                	ld	s1,56(sp)
ffffffffc0202b4a:	7942                	ld	s2,48(sp)
ffffffffc0202b4c:	79a2                	ld	s3,40(sp)
ffffffffc0202b4e:	7a02                	ld	s4,32(sp)
ffffffffc0202b50:	6ae2                	ld	s5,24(sp)
ffffffffc0202b52:	6b42                	ld	s6,16(sp)
ffffffffc0202b54:	6ba2                	ld	s7,8(sp)
ffffffffc0202b56:	6c02                	ld	s8,0(sp)
ffffffffc0202b58:	6161                	addi	sp,sp,80
    kmalloc_init();
ffffffffc0202b5a:	8c8ff06f          	j	ffffffffc0201c22 <kmalloc_init>
ffffffffc0202b5e:	6008                	ld	a0,0(s0)
ffffffffc0202b60:	bd75                	j	ffffffffc0202a1c <pmm_init+0x3f8>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202b62:	00008697          	auipc	a3,0x8
ffffffffc0202b66:	86e68693          	addi	a3,a3,-1938 # ffffffffc020a3d0 <default_pmm_manager+0x538>
ffffffffc0202b6a:	00007617          	auipc	a2,0x7
ffffffffc0202b6e:	be660613          	addi	a2,a2,-1050 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0202b72:	25700593          	li	a1,599
ffffffffc0202b76:	00007517          	auipc	a0,0x7
ffffffffc0202b7a:	49250513          	addi	a0,a0,1170 # ffffffffc020a008 <default_pmm_manager+0x170>
ffffffffc0202b7e:	90bfd0ef          	jal	ra,ffffffffc0200488 <__panic>
ffffffffc0202b82:	86d6                	mv	a3,s5
ffffffffc0202b84:	00007617          	auipc	a2,0x7
ffffffffc0202b88:	36460613          	addi	a2,a2,868 # ffffffffc0209ee8 <default_pmm_manager+0x50>
ffffffffc0202b8c:	25700593          	li	a1,599
ffffffffc0202b90:	00007517          	auipc	a0,0x7
ffffffffc0202b94:	47850513          	addi	a0,a0,1144 # ffffffffc020a008 <default_pmm_manager+0x170>
ffffffffc0202b98:	8f1fd0ef          	jal	ra,ffffffffc0200488 <__panic>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202b9c:	00008697          	auipc	a3,0x8
ffffffffc0202ba0:	87468693          	addi	a3,a3,-1932 # ffffffffc020a410 <default_pmm_manager+0x578>
ffffffffc0202ba4:	00007617          	auipc	a2,0x7
ffffffffc0202ba8:	bac60613          	addi	a2,a2,-1108 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0202bac:	25800593          	li	a1,600
ffffffffc0202bb0:	00007517          	auipc	a0,0x7
ffffffffc0202bb4:	45850513          	addi	a0,a0,1112 # ffffffffc020a008 <default_pmm_manager+0x170>
ffffffffc0202bb8:	8d1fd0ef          	jal	ra,ffffffffc0200488 <__panic>
ffffffffc0202bbc:	a6aff0ef          	jal	ra,ffffffffc0201e26 <pa2page.part.4>
    return KADDR(page2pa(page));
ffffffffc0202bc0:	00007617          	auipc	a2,0x7
ffffffffc0202bc4:	32860613          	addi	a2,a2,808 # ffffffffc0209ee8 <default_pmm_manager+0x50>
ffffffffc0202bc8:	06900593          	li	a1,105
ffffffffc0202bcc:	00007517          	auipc	a0,0x7
ffffffffc0202bd0:	34450513          	addi	a0,a0,836 # ffffffffc0209f10 <default_pmm_manager+0x78>
ffffffffc0202bd4:	8b5fd0ef          	jal	ra,ffffffffc0200488 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0202bd8:	00007617          	auipc	a2,0x7
ffffffffc0202bdc:	5c860613          	addi	a2,a2,1480 # ffffffffc020a1a0 <default_pmm_manager+0x308>
ffffffffc0202be0:	07400593          	li	a1,116
ffffffffc0202be4:	00007517          	auipc	a0,0x7
ffffffffc0202be8:	32c50513          	addi	a0,a0,812 # ffffffffc0209f10 <default_pmm_manager+0x78>
ffffffffc0202bec:	89dfd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0202bf0:	00007697          	auipc	a3,0x7
ffffffffc0202bf4:	4f068693          	addi	a3,a3,1264 # ffffffffc020a0e0 <default_pmm_manager+0x248>
ffffffffc0202bf8:	00007617          	auipc	a2,0x7
ffffffffc0202bfc:	b5860613          	addi	a2,a2,-1192 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0202c00:	21b00593          	li	a1,539
ffffffffc0202c04:	00007517          	auipc	a0,0x7
ffffffffc0202c08:	40450513          	addi	a0,a0,1028 # ffffffffc020a008 <default_pmm_manager+0x170>
ffffffffc0202c0c:	87dfd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0202c10:	00007697          	auipc	a3,0x7
ffffffffc0202c14:	5b868693          	addi	a3,a3,1464 # ffffffffc020a1c8 <default_pmm_manager+0x330>
ffffffffc0202c18:	00007617          	auipc	a2,0x7
ffffffffc0202c1c:	b3860613          	addi	a2,a2,-1224 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0202c20:	23700593          	li	a1,567
ffffffffc0202c24:	00007517          	auipc	a0,0x7
ffffffffc0202c28:	3e450513          	addi	a0,a0,996 # ffffffffc020a008 <default_pmm_manager+0x170>
ffffffffc0202c2c:	85dfd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0202c30:	00008697          	auipc	a3,0x8
ffffffffc0202c34:	81068693          	addi	a3,a3,-2032 # ffffffffc020a440 <default_pmm_manager+0x5a8>
ffffffffc0202c38:	00007617          	auipc	a2,0x7
ffffffffc0202c3c:	b1860613          	addi	a2,a2,-1256 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0202c40:	26000593          	li	a1,608
ffffffffc0202c44:	00007517          	auipc	a0,0x7
ffffffffc0202c48:	3c450513          	addi	a0,a0,964 # ffffffffc020a008 <default_pmm_manager+0x170>
ffffffffc0202c4c:	83dfd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0202c50:	00007697          	auipc	a3,0x7
ffffffffc0202c54:	60868693          	addi	a3,a3,1544 # ffffffffc020a258 <default_pmm_manager+0x3c0>
ffffffffc0202c58:	00007617          	auipc	a2,0x7
ffffffffc0202c5c:	af860613          	addi	a2,a2,-1288 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0202c60:	23600593          	li	a1,566
ffffffffc0202c64:	00007517          	auipc	a0,0x7
ffffffffc0202c68:	3a450513          	addi	a0,a0,932 # ffffffffc020a008 <default_pmm_manager+0x170>
ffffffffc0202c6c:	81dfd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202c70:	00007697          	auipc	a3,0x7
ffffffffc0202c74:	6b068693          	addi	a3,a3,1712 # ffffffffc020a320 <default_pmm_manager+0x488>
ffffffffc0202c78:	00007617          	auipc	a2,0x7
ffffffffc0202c7c:	ad860613          	addi	a2,a2,-1320 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0202c80:	23500593          	li	a1,565
ffffffffc0202c84:	00007517          	auipc	a0,0x7
ffffffffc0202c88:	38450513          	addi	a0,a0,900 # ffffffffc020a008 <default_pmm_manager+0x170>
ffffffffc0202c8c:	ffcfd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc0202c90:	00007697          	auipc	a3,0x7
ffffffffc0202c94:	67868693          	addi	a3,a3,1656 # ffffffffc020a308 <default_pmm_manager+0x470>
ffffffffc0202c98:	00007617          	auipc	a2,0x7
ffffffffc0202c9c:	ab860613          	addi	a2,a2,-1352 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0202ca0:	23400593          	li	a1,564
ffffffffc0202ca4:	00007517          	auipc	a0,0x7
ffffffffc0202ca8:	36450513          	addi	a0,a0,868 # ffffffffc020a008 <default_pmm_manager+0x170>
ffffffffc0202cac:	fdcfd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0202cb0:	00007697          	auipc	a3,0x7
ffffffffc0202cb4:	62868693          	addi	a3,a3,1576 # ffffffffc020a2d8 <default_pmm_manager+0x440>
ffffffffc0202cb8:	00007617          	auipc	a2,0x7
ffffffffc0202cbc:	a9860613          	addi	a2,a2,-1384 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0202cc0:	23300593          	li	a1,563
ffffffffc0202cc4:	00007517          	auipc	a0,0x7
ffffffffc0202cc8:	34450513          	addi	a0,a0,836 # ffffffffc020a008 <default_pmm_manager+0x170>
ffffffffc0202ccc:	fbcfd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc0202cd0:	00007697          	auipc	a3,0x7
ffffffffc0202cd4:	5f068693          	addi	a3,a3,1520 # ffffffffc020a2c0 <default_pmm_manager+0x428>
ffffffffc0202cd8:	00007617          	auipc	a2,0x7
ffffffffc0202cdc:	a7860613          	addi	a2,a2,-1416 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0202ce0:	23100593          	li	a1,561
ffffffffc0202ce4:	00007517          	auipc	a0,0x7
ffffffffc0202ce8:	32450513          	addi	a0,a0,804 # ffffffffc020a008 <default_pmm_manager+0x170>
ffffffffc0202cec:	f9cfd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0202cf0:	00007697          	auipc	a3,0x7
ffffffffc0202cf4:	5b868693          	addi	a3,a3,1464 # ffffffffc020a2a8 <default_pmm_manager+0x410>
ffffffffc0202cf8:	00007617          	auipc	a2,0x7
ffffffffc0202cfc:	a5860613          	addi	a2,a2,-1448 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0202d00:	23000593          	li	a1,560
ffffffffc0202d04:	00007517          	auipc	a0,0x7
ffffffffc0202d08:	30450513          	addi	a0,a0,772 # ffffffffc020a008 <default_pmm_manager+0x170>
ffffffffc0202d0c:	f7cfd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(*ptep & PTE_W);
ffffffffc0202d10:	00007697          	auipc	a3,0x7
ffffffffc0202d14:	58868693          	addi	a3,a3,1416 # ffffffffc020a298 <default_pmm_manager+0x400>
ffffffffc0202d18:	00007617          	auipc	a2,0x7
ffffffffc0202d1c:	a3860613          	addi	a2,a2,-1480 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0202d20:	22f00593          	li	a1,559
ffffffffc0202d24:	00007517          	auipc	a0,0x7
ffffffffc0202d28:	2e450513          	addi	a0,a0,740 # ffffffffc020a008 <default_pmm_manager+0x170>
ffffffffc0202d2c:	f5cfd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(*ptep & PTE_U);
ffffffffc0202d30:	00007697          	auipc	a3,0x7
ffffffffc0202d34:	55868693          	addi	a3,a3,1368 # ffffffffc020a288 <default_pmm_manager+0x3f0>
ffffffffc0202d38:	00007617          	auipc	a2,0x7
ffffffffc0202d3c:	a1860613          	addi	a2,a2,-1512 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0202d40:	22e00593          	li	a1,558
ffffffffc0202d44:	00007517          	auipc	a0,0x7
ffffffffc0202d48:	2c450513          	addi	a0,a0,708 # ffffffffc020a008 <default_pmm_manager+0x170>
ffffffffc0202d4c:	f3cfd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0202d50:	00007697          	auipc	a3,0x7
ffffffffc0202d54:	50868693          	addi	a3,a3,1288 # ffffffffc020a258 <default_pmm_manager+0x3c0>
ffffffffc0202d58:	00007617          	auipc	a2,0x7
ffffffffc0202d5c:	9f860613          	addi	a2,a2,-1544 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0202d60:	22d00593          	li	a1,557
ffffffffc0202d64:	00007517          	auipc	a0,0x7
ffffffffc0202d68:	2a450513          	addi	a0,a0,676 # ffffffffc020a008 <default_pmm_manager+0x170>
ffffffffc0202d6c:	f1cfd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0202d70:	00007697          	auipc	a3,0x7
ffffffffc0202d74:	4b068693          	addi	a3,a3,1200 # ffffffffc020a220 <default_pmm_manager+0x388>
ffffffffc0202d78:	00007617          	auipc	a2,0x7
ffffffffc0202d7c:	9d860613          	addi	a2,a2,-1576 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0202d80:	22c00593          	li	a1,556
ffffffffc0202d84:	00007517          	auipc	a0,0x7
ffffffffc0202d88:	28450513          	addi	a0,a0,644 # ffffffffc020a008 <default_pmm_manager+0x170>
ffffffffc0202d8c:	efcfd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0202d90:	00007697          	auipc	a3,0x7
ffffffffc0202d94:	46868693          	addi	a3,a3,1128 # ffffffffc020a1f8 <default_pmm_manager+0x360>
ffffffffc0202d98:	00007617          	auipc	a2,0x7
ffffffffc0202d9c:	9b860613          	addi	a2,a2,-1608 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0202da0:	22900593          	li	a1,553
ffffffffc0202da4:	00007517          	auipc	a0,0x7
ffffffffc0202da8:	26450513          	addi	a0,a0,612 # ffffffffc020a008 <default_pmm_manager+0x170>
ffffffffc0202dac:	edcfd0ef          	jal	ra,ffffffffc0200488 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202db0:	86da                	mv	a3,s6
ffffffffc0202db2:	00007617          	auipc	a2,0x7
ffffffffc0202db6:	13660613          	addi	a2,a2,310 # ffffffffc0209ee8 <default_pmm_manager+0x50>
ffffffffc0202dba:	22800593          	li	a1,552
ffffffffc0202dbe:	00007517          	auipc	a0,0x7
ffffffffc0202dc2:	24a50513          	addi	a0,a0,586 # ffffffffc020a008 <default_pmm_manager+0x170>
ffffffffc0202dc6:	ec2fd0ef          	jal	ra,ffffffffc0200488 <__panic>
    return KADDR(page2pa(page));
ffffffffc0202dca:	86be                	mv	a3,a5
ffffffffc0202dcc:	00007617          	auipc	a2,0x7
ffffffffc0202dd0:	11c60613          	addi	a2,a2,284 # ffffffffc0209ee8 <default_pmm_manager+0x50>
ffffffffc0202dd4:	06900593          	li	a1,105
ffffffffc0202dd8:	00007517          	auipc	a0,0x7
ffffffffc0202ddc:	13850513          	addi	a0,a0,312 # ffffffffc0209f10 <default_pmm_manager+0x78>
ffffffffc0202de0:	ea8fd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0202de4:	00007697          	auipc	a3,0x7
ffffffffc0202de8:	58468693          	addi	a3,a3,1412 # ffffffffc020a368 <default_pmm_manager+0x4d0>
ffffffffc0202dec:	00007617          	auipc	a2,0x7
ffffffffc0202df0:	96460613          	addi	a2,a2,-1692 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0202df4:	24200593          	li	a1,578
ffffffffc0202df8:	00007517          	auipc	a0,0x7
ffffffffc0202dfc:	21050513          	addi	a0,a0,528 # ffffffffc020a008 <default_pmm_manager+0x170>
ffffffffc0202e00:	e88fd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202e04:	00007697          	auipc	a3,0x7
ffffffffc0202e08:	51c68693          	addi	a3,a3,1308 # ffffffffc020a320 <default_pmm_manager+0x488>
ffffffffc0202e0c:	00007617          	auipc	a2,0x7
ffffffffc0202e10:	94460613          	addi	a2,a2,-1724 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0202e14:	24000593          	li	a1,576
ffffffffc0202e18:	00007517          	auipc	a0,0x7
ffffffffc0202e1c:	1f050513          	addi	a0,a0,496 # ffffffffc020a008 <default_pmm_manager+0x170>
ffffffffc0202e20:	e68fd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc0202e24:	00007697          	auipc	a3,0x7
ffffffffc0202e28:	52c68693          	addi	a3,a3,1324 # ffffffffc020a350 <default_pmm_manager+0x4b8>
ffffffffc0202e2c:	00007617          	auipc	a2,0x7
ffffffffc0202e30:	92460613          	addi	a2,a2,-1756 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0202e34:	23f00593          	li	a1,575
ffffffffc0202e38:	00007517          	auipc	a0,0x7
ffffffffc0202e3c:	1d050513          	addi	a0,a0,464 # ffffffffc020a008 <default_pmm_manager+0x170>
ffffffffc0202e40:	e48fd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(page_ref(p) == 2);
ffffffffc0202e44:	00007697          	auipc	a3,0x7
ffffffffc0202e48:	68c68693          	addi	a3,a3,1676 # ffffffffc020a4d0 <default_pmm_manager+0x638>
ffffffffc0202e4c:	00007617          	auipc	a2,0x7
ffffffffc0202e50:	90460613          	addi	a2,a2,-1788 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0202e54:	26300593          	li	a1,611
ffffffffc0202e58:	00007517          	auipc	a0,0x7
ffffffffc0202e5c:	1b050513          	addi	a0,a0,432 # ffffffffc020a008 <default_pmm_manager+0x170>
ffffffffc0202e60:	e28fd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0202e64:	00007697          	auipc	a3,0x7
ffffffffc0202e68:	62c68693          	addi	a3,a3,1580 # ffffffffc020a490 <default_pmm_manager+0x5f8>
ffffffffc0202e6c:	00007617          	auipc	a2,0x7
ffffffffc0202e70:	8e460613          	addi	a2,a2,-1820 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0202e74:	26200593          	li	a1,610
ffffffffc0202e78:	00007517          	auipc	a0,0x7
ffffffffc0202e7c:	19050513          	addi	a0,a0,400 # ffffffffc020a008 <default_pmm_manager+0x170>
ffffffffc0202e80:	e08fd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(page_ref(p) == 1);
ffffffffc0202e84:	00007697          	auipc	a3,0x7
ffffffffc0202e88:	5f468693          	addi	a3,a3,1524 # ffffffffc020a478 <default_pmm_manager+0x5e0>
ffffffffc0202e8c:	00007617          	auipc	a2,0x7
ffffffffc0202e90:	8c460613          	addi	a2,a2,-1852 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0202e94:	26100593          	li	a1,609
ffffffffc0202e98:	00007517          	auipc	a0,0x7
ffffffffc0202e9c:	17050513          	addi	a0,a0,368 # ffffffffc020a008 <default_pmm_manager+0x170>
ffffffffc0202ea0:	de8fd0ef          	jal	ra,ffffffffc0200488 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0202ea4:	86be                	mv	a3,a5
ffffffffc0202ea6:	00007617          	auipc	a2,0x7
ffffffffc0202eaa:	04260613          	addi	a2,a2,66 # ffffffffc0209ee8 <default_pmm_manager+0x50>
ffffffffc0202eae:	22700593          	li	a1,551
ffffffffc0202eb2:	00007517          	auipc	a0,0x7
ffffffffc0202eb6:	15650513          	addi	a0,a0,342 # ffffffffc020a008 <default_pmm_manager+0x170>
ffffffffc0202eba:	dcefd0ef          	jal	ra,ffffffffc0200488 <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0202ebe:	00007617          	auipc	a2,0x7
ffffffffc0202ec2:	06260613          	addi	a2,a2,98 # ffffffffc0209f20 <default_pmm_manager+0x88>
ffffffffc0202ec6:	07f00593          	li	a1,127
ffffffffc0202eca:	00007517          	auipc	a0,0x7
ffffffffc0202ece:	13e50513          	addi	a0,a0,318 # ffffffffc020a008 <default_pmm_manager+0x170>
ffffffffc0202ed2:	db6fd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0202ed6:	00007697          	auipc	a3,0x7
ffffffffc0202eda:	62a68693          	addi	a3,a3,1578 # ffffffffc020a500 <default_pmm_manager+0x668>
ffffffffc0202ede:	00007617          	auipc	a2,0x7
ffffffffc0202ee2:	87260613          	addi	a2,a2,-1934 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0202ee6:	26700593          	li	a1,615
ffffffffc0202eea:	00007517          	auipc	a0,0x7
ffffffffc0202eee:	11e50513          	addi	a0,a0,286 # ffffffffc020a008 <default_pmm_manager+0x170>
ffffffffc0202ef2:	d96fd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0202ef6:	00007697          	auipc	a3,0x7
ffffffffc0202efa:	49a68693          	addi	a3,a3,1178 # ffffffffc020a390 <default_pmm_manager+0x4f8>
ffffffffc0202efe:	00007617          	auipc	a2,0x7
ffffffffc0202f02:	85260613          	addi	a2,a2,-1966 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0202f06:	27300593          	li	a1,627
ffffffffc0202f0a:	00007517          	auipc	a0,0x7
ffffffffc0202f0e:	0fe50513          	addi	a0,a0,254 # ffffffffc020a008 <default_pmm_manager+0x170>
ffffffffc0202f12:	d76fd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0202f16:	00007697          	auipc	a3,0x7
ffffffffc0202f1a:	2ca68693          	addi	a3,a3,714 # ffffffffc020a1e0 <default_pmm_manager+0x348>
ffffffffc0202f1e:	00007617          	auipc	a2,0x7
ffffffffc0202f22:	83260613          	addi	a2,a2,-1998 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0202f26:	22500593          	li	a1,549
ffffffffc0202f2a:	00007517          	auipc	a0,0x7
ffffffffc0202f2e:	0de50513          	addi	a0,a0,222 # ffffffffc020a008 <default_pmm_manager+0x170>
ffffffffc0202f32:	d56fd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0202f36:	00007697          	auipc	a3,0x7
ffffffffc0202f3a:	29268693          	addi	a3,a3,658 # ffffffffc020a1c8 <default_pmm_manager+0x330>
ffffffffc0202f3e:	00007617          	auipc	a2,0x7
ffffffffc0202f42:	81260613          	addi	a2,a2,-2030 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0202f46:	22400593          	li	a1,548
ffffffffc0202f4a:	00007517          	auipc	a0,0x7
ffffffffc0202f4e:	0be50513          	addi	a0,a0,190 # ffffffffc020a008 <default_pmm_manager+0x170>
ffffffffc0202f52:	d36fd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0202f56:	00007697          	auipc	a3,0x7
ffffffffc0202f5a:	1c268693          	addi	a3,a3,450 # ffffffffc020a118 <default_pmm_manager+0x280>
ffffffffc0202f5e:	00006617          	auipc	a2,0x6
ffffffffc0202f62:	7f260613          	addi	a2,a2,2034 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0202f66:	21c00593          	li	a1,540
ffffffffc0202f6a:	00007517          	auipc	a0,0x7
ffffffffc0202f6e:	09e50513          	addi	a0,a0,158 # ffffffffc020a008 <default_pmm_manager+0x170>
ffffffffc0202f72:	d16fd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0202f76:	00007697          	auipc	a3,0x7
ffffffffc0202f7a:	1fa68693          	addi	a3,a3,506 # ffffffffc020a170 <default_pmm_manager+0x2d8>
ffffffffc0202f7e:	00006617          	auipc	a2,0x6
ffffffffc0202f82:	7d260613          	addi	a2,a2,2002 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0202f86:	22300593          	li	a1,547
ffffffffc0202f8a:	00007517          	auipc	a0,0x7
ffffffffc0202f8e:	07e50513          	addi	a0,a0,126 # ffffffffc020a008 <default_pmm_manager+0x170>
ffffffffc0202f92:	cf6fd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0202f96:	00007697          	auipc	a3,0x7
ffffffffc0202f9a:	1aa68693          	addi	a3,a3,426 # ffffffffc020a140 <default_pmm_manager+0x2a8>
ffffffffc0202f9e:	00006617          	auipc	a2,0x6
ffffffffc0202fa2:	7b260613          	addi	a2,a2,1970 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0202fa6:	22000593          	li	a1,544
ffffffffc0202faa:	00007517          	auipc	a0,0x7
ffffffffc0202fae:	05e50513          	addi	a0,a0,94 # ffffffffc020a008 <default_pmm_manager+0x170>
ffffffffc0202fb2:	cd6fd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202fb6:	00007697          	auipc	a3,0x7
ffffffffc0202fba:	36a68693          	addi	a3,a3,874 # ffffffffc020a320 <default_pmm_manager+0x488>
ffffffffc0202fbe:	00006617          	auipc	a2,0x6
ffffffffc0202fc2:	79260613          	addi	a2,a2,1938 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0202fc6:	23c00593          	li	a1,572
ffffffffc0202fca:	00007517          	auipc	a0,0x7
ffffffffc0202fce:	03e50513          	addi	a0,a0,62 # ffffffffc020a008 <default_pmm_manager+0x170>
ffffffffc0202fd2:	cb6fd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0202fd6:	00007697          	auipc	a3,0x7
ffffffffc0202fda:	20a68693          	addi	a3,a3,522 # ffffffffc020a1e0 <default_pmm_manager+0x348>
ffffffffc0202fde:	00006617          	auipc	a2,0x6
ffffffffc0202fe2:	77260613          	addi	a2,a2,1906 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0202fe6:	23b00593          	li	a1,571
ffffffffc0202fea:	00007517          	auipc	a0,0x7
ffffffffc0202fee:	01e50513          	addi	a0,a0,30 # ffffffffc020a008 <default_pmm_manager+0x170>
ffffffffc0202ff2:	c96fd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc0202ff6:	00007697          	auipc	a3,0x7
ffffffffc0202ffa:	34268693          	addi	a3,a3,834 # ffffffffc020a338 <default_pmm_manager+0x4a0>
ffffffffc0202ffe:	00006617          	auipc	a2,0x6
ffffffffc0203002:	75260613          	addi	a2,a2,1874 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0203006:	23800593          	li	a1,568
ffffffffc020300a:	00007517          	auipc	a0,0x7
ffffffffc020300e:	ffe50513          	addi	a0,a0,-2 # ffffffffc020a008 <default_pmm_manager+0x170>
ffffffffc0203012:	c76fd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0203016:	00007697          	auipc	a3,0x7
ffffffffc020301a:	52268693          	addi	a3,a3,1314 # ffffffffc020a538 <default_pmm_manager+0x6a0>
ffffffffc020301e:	00006617          	auipc	a2,0x6
ffffffffc0203022:	73260613          	addi	a2,a2,1842 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0203026:	26a00593          	li	a1,618
ffffffffc020302a:	00007517          	auipc	a0,0x7
ffffffffc020302e:	fde50513          	addi	a0,a0,-34 # ffffffffc020a008 <default_pmm_manager+0x170>
ffffffffc0203032:	c56fd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0203036:	00007697          	auipc	a3,0x7
ffffffffc020303a:	35a68693          	addi	a3,a3,858 # ffffffffc020a390 <default_pmm_manager+0x4f8>
ffffffffc020303e:	00006617          	auipc	a2,0x6
ffffffffc0203042:	71260613          	addi	a2,a2,1810 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0203046:	24a00593          	li	a1,586
ffffffffc020304a:	00007517          	auipc	a0,0x7
ffffffffc020304e:	fbe50513          	addi	a0,a0,-66 # ffffffffc020a008 <default_pmm_manager+0x170>
ffffffffc0203052:	c36fd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc0203056:	00007697          	auipc	a3,0x7
ffffffffc020305a:	3d268693          	addi	a3,a3,978 # ffffffffc020a428 <default_pmm_manager+0x590>
ffffffffc020305e:	00006617          	auipc	a2,0x6
ffffffffc0203062:	6f260613          	addi	a2,a2,1778 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0203066:	25c00593          	li	a1,604
ffffffffc020306a:	00007517          	auipc	a0,0x7
ffffffffc020306e:	f9e50513          	addi	a0,a0,-98 # ffffffffc020a008 <default_pmm_manager+0x170>
ffffffffc0203072:	c16fd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0203076:	00007697          	auipc	a3,0x7
ffffffffc020307a:	04a68693          	addi	a3,a3,74 # ffffffffc020a0c0 <default_pmm_manager+0x228>
ffffffffc020307e:	00006617          	auipc	a2,0x6
ffffffffc0203082:	6d260613          	addi	a2,a2,1746 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0203086:	21a00593          	li	a1,538
ffffffffc020308a:	00007517          	auipc	a0,0x7
ffffffffc020308e:	f7e50513          	addi	a0,a0,-130 # ffffffffc020a008 <default_pmm_manager+0x170>
ffffffffc0203092:	bf6fd0ef          	jal	ra,ffffffffc0200488 <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0203096:	00007617          	auipc	a2,0x7
ffffffffc020309a:	e8a60613          	addi	a2,a2,-374 # ffffffffc0209f20 <default_pmm_manager+0x88>
ffffffffc020309e:	0c100593          	li	a1,193
ffffffffc02030a2:	00007517          	auipc	a0,0x7
ffffffffc02030a6:	f6650513          	addi	a0,a0,-154 # ffffffffc020a008 <default_pmm_manager+0x170>
ffffffffc02030aa:	bdefd0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc02030ae <copy_range>:
               bool share) {
ffffffffc02030ae:	7159                	addi	sp,sp,-112
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02030b0:	00d667b3          	or	a5,a2,a3
               bool share) {
ffffffffc02030b4:	f486                	sd	ra,104(sp)
ffffffffc02030b6:	f0a2                	sd	s0,96(sp)
ffffffffc02030b8:	eca6                	sd	s1,88(sp)
ffffffffc02030ba:	e8ca                	sd	s2,80(sp)
ffffffffc02030bc:	e4ce                	sd	s3,72(sp)
ffffffffc02030be:	e0d2                	sd	s4,64(sp)
ffffffffc02030c0:	fc56                	sd	s5,56(sp)
ffffffffc02030c2:	f85a                	sd	s6,48(sp)
ffffffffc02030c4:	f45e                	sd	s7,40(sp)
ffffffffc02030c6:	f062                	sd	s8,32(sp)
ffffffffc02030c8:	ec66                	sd	s9,24(sp)
ffffffffc02030ca:	e86a                	sd	s10,16(sp)
ffffffffc02030cc:	e46e                	sd	s11,8(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02030ce:	03479713          	slli	a4,a5,0x34
ffffffffc02030d2:	1e071863          	bnez	a4,ffffffffc02032c2 <copy_range+0x214>
    assert(USER_ACCESS(start, end));
ffffffffc02030d6:	002007b7          	lui	a5,0x200
ffffffffc02030da:	8432                	mv	s0,a2
ffffffffc02030dc:	16f66b63          	bltu	a2,a5,ffffffffc0203252 <copy_range+0x1a4>
ffffffffc02030e0:	84b6                	mv	s1,a3
ffffffffc02030e2:	16d67863          	bleu	a3,a2,ffffffffc0203252 <copy_range+0x1a4>
ffffffffc02030e6:	4785                	li	a5,1
ffffffffc02030e8:	07fe                	slli	a5,a5,0x1f
ffffffffc02030ea:	16d7e463          	bltu	a5,a3,ffffffffc0203252 <copy_range+0x1a4>
ffffffffc02030ee:	5a7d                	li	s4,-1
ffffffffc02030f0:	8aaa                	mv	s5,a0
ffffffffc02030f2:	892e                	mv	s2,a1
        start += PGSIZE;
ffffffffc02030f4:	6985                	lui	s3,0x1
    if (PPN(pa) >= npage) {
ffffffffc02030f6:	000c6c17          	auipc	s8,0xc6
ffffffffc02030fa:	172c0c13          	addi	s8,s8,370 # ffffffffc02c9268 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc02030fe:	000c6b97          	auipc	s7,0xc6
ffffffffc0203102:	1eab8b93          	addi	s7,s7,490 # ffffffffc02c92e8 <pages>
    return page - pages + nbase;
ffffffffc0203106:	00080b37          	lui	s6,0x80
    return KADDR(page2pa(page));
ffffffffc020310a:	00ca5a13          	srli	s4,s4,0xc
        pte_t *ptep = get_pte(from, start, 0), *nptep;
ffffffffc020310e:	4601                	li	a2,0
ffffffffc0203110:	85a2                	mv	a1,s0
ffffffffc0203112:	854a                	mv	a0,s2
ffffffffc0203114:	e3dfe0ef          	jal	ra,ffffffffc0201f50 <get_pte>
ffffffffc0203118:	8caa                	mv	s9,a0
        if (ptep == NULL) {
ffffffffc020311a:	c17d                	beqz	a0,ffffffffc0203200 <copy_range+0x152>
        if (*ptep & PTE_V) {
ffffffffc020311c:	611c                	ld	a5,0(a0)
ffffffffc020311e:	8b85                	andi	a5,a5,1
ffffffffc0203120:	e785                	bnez	a5,ffffffffc0203148 <copy_range+0x9a>
        start += PGSIZE;
ffffffffc0203122:	944e                	add	s0,s0,s3
    } while (start != 0 && start < end);
ffffffffc0203124:	fe9465e3          	bltu	s0,s1,ffffffffc020310e <copy_range+0x60>
    return 0;
ffffffffc0203128:	4501                	li	a0,0
}
ffffffffc020312a:	70a6                	ld	ra,104(sp)
ffffffffc020312c:	7406                	ld	s0,96(sp)
ffffffffc020312e:	64e6                	ld	s1,88(sp)
ffffffffc0203130:	6946                	ld	s2,80(sp)
ffffffffc0203132:	69a6                	ld	s3,72(sp)
ffffffffc0203134:	6a06                	ld	s4,64(sp)
ffffffffc0203136:	7ae2                	ld	s5,56(sp)
ffffffffc0203138:	7b42                	ld	s6,48(sp)
ffffffffc020313a:	7ba2                	ld	s7,40(sp)
ffffffffc020313c:	7c02                	ld	s8,32(sp)
ffffffffc020313e:	6ce2                	ld	s9,24(sp)
ffffffffc0203140:	6d42                	ld	s10,16(sp)
ffffffffc0203142:	6da2                	ld	s11,8(sp)
ffffffffc0203144:	6165                	addi	sp,sp,112
ffffffffc0203146:	8082                	ret
            if ((nptep = get_pte(to, start, 1)) == NULL) {
ffffffffc0203148:	4605                	li	a2,1
ffffffffc020314a:	85a2                	mv	a1,s0
ffffffffc020314c:	8556                	mv	a0,s5
ffffffffc020314e:	e03fe0ef          	jal	ra,ffffffffc0201f50 <get_pte>
ffffffffc0203152:	c169                	beqz	a0,ffffffffc0203214 <copy_range+0x166>
            uint32_t perm = (*ptep & PTE_USER);
ffffffffc0203154:	000cb783          	ld	a5,0(s9)
    if (!(pte & PTE_V)) {
ffffffffc0203158:	0017f713          	andi	a4,a5,1
ffffffffc020315c:	01f7fc93          	andi	s9,a5,31
ffffffffc0203160:	14070563          	beqz	a4,ffffffffc02032aa <copy_range+0x1fc>
    if (PPN(pa) >= npage) {
ffffffffc0203164:	000c3683          	ld	a3,0(s8)
    return pa2page(PTE_ADDR(pte));
ffffffffc0203168:	078a                	slli	a5,a5,0x2
ffffffffc020316a:	00c7d713          	srli	a4,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020316e:	12d77263          	bleu	a3,a4,ffffffffc0203292 <copy_range+0x1e4>
    return &pages[PPN(pa) - nbase];
ffffffffc0203172:	000bb783          	ld	a5,0(s7)
ffffffffc0203176:	fff806b7          	lui	a3,0xfff80
ffffffffc020317a:	9736                	add	a4,a4,a3
ffffffffc020317c:	071a                	slli	a4,a4,0x6
            struct Page *npage = alloc_page();
ffffffffc020317e:	4505                	li	a0,1
ffffffffc0203180:	00e78db3          	add	s11,a5,a4
ffffffffc0203184:	cbffe0ef          	jal	ra,ffffffffc0201e42 <alloc_pages>
ffffffffc0203188:	8d2a                	mv	s10,a0
            assert(page != NULL);
ffffffffc020318a:	0a0d8463          	beqz	s11,ffffffffc0203232 <copy_range+0x184>
            assert(npage != NULL);
ffffffffc020318e:	c175                	beqz	a0,ffffffffc0203272 <copy_range+0x1c4>
    return page - pages + nbase;
ffffffffc0203190:	000bb703          	ld	a4,0(s7)
    return KADDR(page2pa(page));
ffffffffc0203194:	000c3603          	ld	a2,0(s8)
    return page - pages + nbase;
ffffffffc0203198:	40ed86b3          	sub	a3,s11,a4
ffffffffc020319c:	8699                	srai	a3,a3,0x6
ffffffffc020319e:	96da                	add	a3,a3,s6
    return KADDR(page2pa(page));
ffffffffc02031a0:	0146f7b3          	and	a5,a3,s4
    return page2ppn(page) << PGSHIFT;
ffffffffc02031a4:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02031a6:	06c7fa63          	bleu	a2,a5,ffffffffc020321a <copy_range+0x16c>
    return page - pages + nbase;
ffffffffc02031aa:	40e507b3          	sub	a5,a0,a4
    return KADDR(page2pa(page));
ffffffffc02031ae:	000c6717          	auipc	a4,0xc6
ffffffffc02031b2:	12a70713          	addi	a4,a4,298 # ffffffffc02c92d8 <va_pa_offset>
ffffffffc02031b6:	6308                	ld	a0,0(a4)
    return page - pages + nbase;
ffffffffc02031b8:	8799                	srai	a5,a5,0x6
ffffffffc02031ba:	97da                	add	a5,a5,s6
    return KADDR(page2pa(page));
ffffffffc02031bc:	0147f733          	and	a4,a5,s4
ffffffffc02031c0:	00a685b3          	add	a1,a3,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc02031c4:	07b2                	slli	a5,a5,0xc
    return KADDR(page2pa(page));
ffffffffc02031c6:	04c77963          	bleu	a2,a4,ffffffffc0203218 <copy_range+0x16a>
            memcpy(dst, src, PGSIZE);
ffffffffc02031ca:	6605                	lui	a2,0x1
ffffffffc02031cc:	953e                	add	a0,a0,a5
ffffffffc02031ce:	77b050ef          	jal	ra,ffffffffc0209148 <memcpy>
            ret = page_insert(to, npage, start, perm);
ffffffffc02031d2:	86e6                	mv	a3,s9
ffffffffc02031d4:	8622                	mv	a2,s0
ffffffffc02031d6:	85ea                	mv	a1,s10
ffffffffc02031d8:	8556                	mv	a0,s5
ffffffffc02031da:	b8cff0ef          	jal	ra,ffffffffc0202566 <page_insert>
            assert(ret == 0);
ffffffffc02031de:	d131                	beqz	a0,ffffffffc0203122 <copy_range+0x74>
ffffffffc02031e0:	00007697          	auipc	a3,0x7
ffffffffc02031e4:	e1868693          	addi	a3,a3,-488 # ffffffffc0209ff8 <default_pmm_manager+0x160>
ffffffffc02031e8:	00006617          	auipc	a2,0x6
ffffffffc02031ec:	56860613          	addi	a2,a2,1384 # ffffffffc0209750 <commands+0x4c0>
ffffffffc02031f0:	1bc00593          	li	a1,444
ffffffffc02031f4:	00007517          	auipc	a0,0x7
ffffffffc02031f8:	e1450513          	addi	a0,a0,-492 # ffffffffc020a008 <default_pmm_manager+0x170>
ffffffffc02031fc:	a8cfd0ef          	jal	ra,ffffffffc0200488 <__panic>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc0203200:	002007b7          	lui	a5,0x200
ffffffffc0203204:	943e                	add	s0,s0,a5
ffffffffc0203206:	ffe007b7          	lui	a5,0xffe00
ffffffffc020320a:	8c7d                	and	s0,s0,a5
    } while (start != 0 && start < end);
ffffffffc020320c:	dc11                	beqz	s0,ffffffffc0203128 <copy_range+0x7a>
ffffffffc020320e:	f09460e3          	bltu	s0,s1,ffffffffc020310e <copy_range+0x60>
ffffffffc0203212:	bf19                	j	ffffffffc0203128 <copy_range+0x7a>
                return -E_NO_MEM;
ffffffffc0203214:	5571                	li	a0,-4
ffffffffc0203216:	bf11                	j	ffffffffc020312a <copy_range+0x7c>
ffffffffc0203218:	86be                	mv	a3,a5
ffffffffc020321a:	00007617          	auipc	a2,0x7
ffffffffc020321e:	cce60613          	addi	a2,a2,-818 # ffffffffc0209ee8 <default_pmm_manager+0x50>
ffffffffc0203222:	06900593          	li	a1,105
ffffffffc0203226:	00007517          	auipc	a0,0x7
ffffffffc020322a:	cea50513          	addi	a0,a0,-790 # ffffffffc0209f10 <default_pmm_manager+0x78>
ffffffffc020322e:	a5afd0ef          	jal	ra,ffffffffc0200488 <__panic>
            assert(page != NULL);
ffffffffc0203232:	00007697          	auipc	a3,0x7
ffffffffc0203236:	da668693          	addi	a3,a3,-602 # ffffffffc0209fd8 <default_pmm_manager+0x140>
ffffffffc020323a:	00006617          	auipc	a2,0x6
ffffffffc020323e:	51660613          	addi	a2,a2,1302 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0203242:	1a200593          	li	a1,418
ffffffffc0203246:	00007517          	auipc	a0,0x7
ffffffffc020324a:	dc250513          	addi	a0,a0,-574 # ffffffffc020a008 <default_pmm_manager+0x170>
ffffffffc020324e:	a3afd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc0203252:	00007697          	auipc	a3,0x7
ffffffffc0203256:	35e68693          	addi	a3,a3,862 # ffffffffc020a5b0 <default_pmm_manager+0x718>
ffffffffc020325a:	00006617          	auipc	a2,0x6
ffffffffc020325e:	4f660613          	addi	a2,a2,1270 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0203262:	18e00593          	li	a1,398
ffffffffc0203266:	00007517          	auipc	a0,0x7
ffffffffc020326a:	da250513          	addi	a0,a0,-606 # ffffffffc020a008 <default_pmm_manager+0x170>
ffffffffc020326e:	a1afd0ef          	jal	ra,ffffffffc0200488 <__panic>
            assert(npage != NULL);
ffffffffc0203272:	00007697          	auipc	a3,0x7
ffffffffc0203276:	d7668693          	addi	a3,a3,-650 # ffffffffc0209fe8 <default_pmm_manager+0x150>
ffffffffc020327a:	00006617          	auipc	a2,0x6
ffffffffc020327e:	4d660613          	addi	a2,a2,1238 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0203282:	1a300593          	li	a1,419
ffffffffc0203286:	00007517          	auipc	a0,0x7
ffffffffc020328a:	d8250513          	addi	a0,a0,-638 # ffffffffc020a008 <default_pmm_manager+0x170>
ffffffffc020328e:	9fafd0ef          	jal	ra,ffffffffc0200488 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0203292:	00007617          	auipc	a2,0x7
ffffffffc0203296:	cb660613          	addi	a2,a2,-842 # ffffffffc0209f48 <default_pmm_manager+0xb0>
ffffffffc020329a:	06200593          	li	a1,98
ffffffffc020329e:	00007517          	auipc	a0,0x7
ffffffffc02032a2:	c7250513          	addi	a0,a0,-910 # ffffffffc0209f10 <default_pmm_manager+0x78>
ffffffffc02032a6:	9e2fd0ef          	jal	ra,ffffffffc0200488 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc02032aa:	00007617          	auipc	a2,0x7
ffffffffc02032ae:	ef660613          	addi	a2,a2,-266 # ffffffffc020a1a0 <default_pmm_manager+0x308>
ffffffffc02032b2:	07400593          	li	a1,116
ffffffffc02032b6:	00007517          	auipc	a0,0x7
ffffffffc02032ba:	c5a50513          	addi	a0,a0,-934 # ffffffffc0209f10 <default_pmm_manager+0x78>
ffffffffc02032be:	9cafd0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02032c2:	00007697          	auipc	a3,0x7
ffffffffc02032c6:	2be68693          	addi	a3,a3,702 # ffffffffc020a580 <default_pmm_manager+0x6e8>
ffffffffc02032ca:	00006617          	auipc	a2,0x6
ffffffffc02032ce:	48660613          	addi	a2,a2,1158 # ffffffffc0209750 <commands+0x4c0>
ffffffffc02032d2:	18d00593          	li	a1,397
ffffffffc02032d6:	00007517          	auipc	a0,0x7
ffffffffc02032da:	d3250513          	addi	a0,a0,-718 # ffffffffc020a008 <default_pmm_manager+0x170>
ffffffffc02032de:	9aafd0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc02032e2 <tlb_invalidate>:
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02032e2:	12058073          	sfence.vma	a1
}
ffffffffc02032e6:	8082                	ret

ffffffffc02032e8 <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc02032e8:	7179                	addi	sp,sp,-48
ffffffffc02032ea:	e84a                	sd	s2,16(sp)
ffffffffc02032ec:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc02032ee:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc02032f0:	f022                	sd	s0,32(sp)
ffffffffc02032f2:	ec26                	sd	s1,24(sp)
ffffffffc02032f4:	e44e                	sd	s3,8(sp)
ffffffffc02032f6:	f406                	sd	ra,40(sp)
ffffffffc02032f8:	84ae                	mv	s1,a1
ffffffffc02032fa:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc02032fc:	b47fe0ef          	jal	ra,ffffffffc0201e42 <alloc_pages>
ffffffffc0203300:	842a                	mv	s0,a0
    if (page != NULL) {
ffffffffc0203302:	cd1d                	beqz	a0,ffffffffc0203340 <pgdir_alloc_page+0x58>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc0203304:	85aa                	mv	a1,a0
ffffffffc0203306:	86ce                	mv	a3,s3
ffffffffc0203308:	8626                	mv	a2,s1
ffffffffc020330a:	854a                	mv	a0,s2
ffffffffc020330c:	a5aff0ef          	jal	ra,ffffffffc0202566 <page_insert>
ffffffffc0203310:	e121                	bnez	a0,ffffffffc0203350 <pgdir_alloc_page+0x68>
        if (swap_init_ok) {
ffffffffc0203312:	000c6797          	auipc	a5,0xc6
ffffffffc0203316:	f6678793          	addi	a5,a5,-154 # ffffffffc02c9278 <swap_init_ok>
ffffffffc020331a:	439c                	lw	a5,0(a5)
ffffffffc020331c:	2781                	sext.w	a5,a5
ffffffffc020331e:	c38d                	beqz	a5,ffffffffc0203340 <pgdir_alloc_page+0x58>
            if (check_mm_struct != NULL) {
ffffffffc0203320:	000c6797          	auipc	a5,0xc6
ffffffffc0203324:	0a878793          	addi	a5,a5,168 # ffffffffc02c93c8 <check_mm_struct>
ffffffffc0203328:	6388                	ld	a0,0(a5)
ffffffffc020332a:	c919                	beqz	a0,ffffffffc0203340 <pgdir_alloc_page+0x58>
                swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc020332c:	4681                	li	a3,0
ffffffffc020332e:	8622                	mv	a2,s0
ffffffffc0203330:	85a6                	mv	a1,s1
ffffffffc0203332:	7da000ef          	jal	ra,ffffffffc0203b0c <swap_map_swappable>
                assert(page_ref(page) == 1);
ffffffffc0203336:	4018                	lw	a4,0(s0)
                page->pra_vaddr = la;
ffffffffc0203338:	fc04                	sd	s1,56(s0)
                assert(page_ref(page) == 1);
ffffffffc020333a:	4785                	li	a5,1
ffffffffc020333c:	02f71063          	bne	a4,a5,ffffffffc020335c <pgdir_alloc_page+0x74>
}
ffffffffc0203340:	8522                	mv	a0,s0
ffffffffc0203342:	70a2                	ld	ra,40(sp)
ffffffffc0203344:	7402                	ld	s0,32(sp)
ffffffffc0203346:	64e2                	ld	s1,24(sp)
ffffffffc0203348:	6942                	ld	s2,16(sp)
ffffffffc020334a:	69a2                	ld	s3,8(sp)
ffffffffc020334c:	6145                	addi	sp,sp,48
ffffffffc020334e:	8082                	ret
            free_page(page);
ffffffffc0203350:	8522                	mv	a0,s0
ffffffffc0203352:	4585                	li	a1,1
ffffffffc0203354:	b77fe0ef          	jal	ra,ffffffffc0201eca <free_pages>
            return NULL;
ffffffffc0203358:	4401                	li	s0,0
ffffffffc020335a:	b7dd                	j	ffffffffc0203340 <pgdir_alloc_page+0x58>
                assert(page_ref(page) == 1);
ffffffffc020335c:	00007697          	auipc	a3,0x7
ffffffffc0203360:	cbc68693          	addi	a3,a3,-836 # ffffffffc020a018 <default_pmm_manager+0x180>
ffffffffc0203364:	00006617          	auipc	a2,0x6
ffffffffc0203368:	3ec60613          	addi	a2,a2,1004 # ffffffffc0209750 <commands+0x4c0>
ffffffffc020336c:	1fb00593          	li	a1,507
ffffffffc0203370:	00007517          	auipc	a0,0x7
ffffffffc0203374:	c9850513          	addi	a0,a0,-872 # ffffffffc020a008 <default_pmm_manager+0x170>
ffffffffc0203378:	910fd0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc020337c <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
ffffffffc020337c:	7135                	addi	sp,sp,-160
ffffffffc020337e:	ed06                	sd	ra,152(sp)
ffffffffc0203380:	e922                	sd	s0,144(sp)
ffffffffc0203382:	e526                	sd	s1,136(sp)
ffffffffc0203384:	e14a                	sd	s2,128(sp)
ffffffffc0203386:	fcce                	sd	s3,120(sp)
ffffffffc0203388:	f8d2                	sd	s4,112(sp)
ffffffffc020338a:	f4d6                	sd	s5,104(sp)
ffffffffc020338c:	f0da                	sd	s6,96(sp)
ffffffffc020338e:	ecde                	sd	s7,88(sp)
ffffffffc0203390:	e8e2                	sd	s8,80(sp)
ffffffffc0203392:	e4e6                	sd	s9,72(sp)
ffffffffc0203394:	e0ea                	sd	s10,64(sp)
ffffffffc0203396:	fc6e                	sd	s11,56(sp)
     swapfs_init();
ffffffffc0203398:	79c010ef          	jal	ra,ffffffffc0204b34 <swapfs_init>

     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc020339c:	000c6797          	auipc	a5,0xc6
ffffffffc02033a0:	fdc78793          	addi	a5,a5,-36 # ffffffffc02c9378 <max_swap_offset>
ffffffffc02033a4:	6394                	ld	a3,0(a5)
ffffffffc02033a6:	010007b7          	lui	a5,0x1000
ffffffffc02033aa:	17e1                	addi	a5,a5,-8
ffffffffc02033ac:	ff968713          	addi	a4,a3,-7
ffffffffc02033b0:	4ae7ee63          	bltu	a5,a4,ffffffffc020386c <swap_init+0x4f0>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }
     

     sm = &swap_manager_fifo;
ffffffffc02033b4:	000bb797          	auipc	a5,0xbb
ffffffffc02033b8:	9e478793          	addi	a5,a5,-1564 # ffffffffc02bdd98 <swap_manager_fifo>
     int r = sm->init();
ffffffffc02033bc:	6798                	ld	a4,8(a5)
     sm = &swap_manager_fifo;
ffffffffc02033be:	000c6697          	auipc	a3,0xc6
ffffffffc02033c2:	eaf6b923          	sd	a5,-334(a3) # ffffffffc02c9270 <sm>
     int r = sm->init();
ffffffffc02033c6:	9702                	jalr	a4
ffffffffc02033c8:	8aaa                	mv	s5,a0
     
     if (r == 0)
ffffffffc02033ca:	c10d                	beqz	a0,ffffffffc02033ec <swap_init+0x70>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc02033cc:	60ea                	ld	ra,152(sp)
ffffffffc02033ce:	644a                	ld	s0,144(sp)
ffffffffc02033d0:	8556                	mv	a0,s5
ffffffffc02033d2:	64aa                	ld	s1,136(sp)
ffffffffc02033d4:	690a                	ld	s2,128(sp)
ffffffffc02033d6:	79e6                	ld	s3,120(sp)
ffffffffc02033d8:	7a46                	ld	s4,112(sp)
ffffffffc02033da:	7aa6                	ld	s5,104(sp)
ffffffffc02033dc:	7b06                	ld	s6,96(sp)
ffffffffc02033de:	6be6                	ld	s7,88(sp)
ffffffffc02033e0:	6c46                	ld	s8,80(sp)
ffffffffc02033e2:	6ca6                	ld	s9,72(sp)
ffffffffc02033e4:	6d06                	ld	s10,64(sp)
ffffffffc02033e6:	7de2                	ld	s11,56(sp)
ffffffffc02033e8:	610d                	addi	sp,sp,160
ffffffffc02033ea:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc02033ec:	000c6797          	auipc	a5,0xc6
ffffffffc02033f0:	e8478793          	addi	a5,a5,-380 # ffffffffc02c9270 <sm>
ffffffffc02033f4:	639c                	ld	a5,0(a5)
ffffffffc02033f6:	00007517          	auipc	a0,0x7
ffffffffc02033fa:	25250513          	addi	a0,a0,594 # ffffffffc020a648 <default_pmm_manager+0x7b0>
    return listelm->next;
ffffffffc02033fe:	000c6417          	auipc	s0,0xc6
ffffffffc0203402:	eba40413          	addi	s0,s0,-326 # ffffffffc02c92b8 <free_area>
ffffffffc0203406:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc0203408:	4785                	li	a5,1
ffffffffc020340a:	000c6717          	auipc	a4,0xc6
ffffffffc020340e:	e6f72723          	sw	a5,-402(a4) # ffffffffc02c9278 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0203412:	d81fc0ef          	jal	ra,ffffffffc0200192 <cprintf>
ffffffffc0203416:	641c                	ld	a5,8(s0)
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0203418:	36878e63          	beq	a5,s0,ffffffffc0203794 <swap_init+0x418>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc020341c:	ff07b703          	ld	a4,-16(a5)
ffffffffc0203420:	8305                	srli	a4,a4,0x1
ffffffffc0203422:	8b05                	andi	a4,a4,1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0203424:	36070c63          	beqz	a4,ffffffffc020379c <swap_init+0x420>
     int ret, count = 0, total = 0, i;
ffffffffc0203428:	4481                	li	s1,0
ffffffffc020342a:	4901                	li	s2,0
ffffffffc020342c:	a031                	j	ffffffffc0203438 <swap_init+0xbc>
ffffffffc020342e:	ff07b703          	ld	a4,-16(a5)
        assert(PageProperty(p));
ffffffffc0203432:	8b09                	andi	a4,a4,2
ffffffffc0203434:	36070463          	beqz	a4,ffffffffc020379c <swap_init+0x420>
        count ++, total += p->property;
ffffffffc0203438:	ff87a703          	lw	a4,-8(a5)
ffffffffc020343c:	679c                	ld	a5,8(a5)
ffffffffc020343e:	2905                	addiw	s2,s2,1
ffffffffc0203440:	9cb9                	addw	s1,s1,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc0203442:	fe8796e3          	bne	a5,s0,ffffffffc020342e <swap_init+0xb2>
ffffffffc0203446:	89a6                	mv	s3,s1
     }
     assert(total == nr_free_pages());
ffffffffc0203448:	ac9fe0ef          	jal	ra,ffffffffc0201f10 <nr_free_pages>
ffffffffc020344c:	69351863          	bne	a0,s3,ffffffffc0203adc <swap_init+0x760>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc0203450:	8626                	mv	a2,s1
ffffffffc0203452:	85ca                	mv	a1,s2
ffffffffc0203454:	00007517          	auipc	a0,0x7
ffffffffc0203458:	20c50513          	addi	a0,a0,524 # ffffffffc020a660 <default_pmm_manager+0x7c8>
ffffffffc020345c:	d37fc0ef          	jal	ra,ffffffffc0200192 <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc0203460:	457000ef          	jal	ra,ffffffffc02040b6 <mm_create>
ffffffffc0203464:	8baa                	mv	s7,a0
     assert(mm != NULL);
ffffffffc0203466:	60050b63          	beqz	a0,ffffffffc0203a7c <swap_init+0x700>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc020346a:	000c6797          	auipc	a5,0xc6
ffffffffc020346e:	f5e78793          	addi	a5,a5,-162 # ffffffffc02c93c8 <check_mm_struct>
ffffffffc0203472:	639c                	ld	a5,0(a5)
ffffffffc0203474:	62079463          	bnez	a5,ffffffffc0203a9c <swap_init+0x720>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0203478:	000c6797          	auipc	a5,0xc6
ffffffffc020347c:	de878793          	addi	a5,a5,-536 # ffffffffc02c9260 <boot_pgdir>
ffffffffc0203480:	0007bb03          	ld	s6,0(a5)
     check_mm_struct = mm;
ffffffffc0203484:	000c6797          	auipc	a5,0xc6
ffffffffc0203488:	f4a7b223          	sd	a0,-188(a5) # ffffffffc02c93c8 <check_mm_struct>
     assert(pgdir[0] == 0);
ffffffffc020348c:	000b3783          	ld	a5,0(s6) # 80000 <_binary_obj___user_matrix_out_size+0x74598>
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0203490:	01653c23          	sd	s6,24(a0)
     assert(pgdir[0] == 0);
ffffffffc0203494:	4e079863          	bnez	a5,ffffffffc0203984 <swap_init+0x608>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc0203498:	6599                	lui	a1,0x6
ffffffffc020349a:	460d                	li	a2,3
ffffffffc020349c:	6505                	lui	a0,0x1
ffffffffc020349e:	465000ef          	jal	ra,ffffffffc0204102 <vma_create>
ffffffffc02034a2:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc02034a4:	50050063          	beqz	a0,ffffffffc02039a4 <swap_init+0x628>

     insert_vma_struct(mm, vma);
ffffffffc02034a8:	855e                	mv	a0,s7
ffffffffc02034aa:	4c5000ef          	jal	ra,ffffffffc020416e <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc02034ae:	00007517          	auipc	a0,0x7
ffffffffc02034b2:	22250513          	addi	a0,a0,546 # ffffffffc020a6d0 <default_pmm_manager+0x838>
ffffffffc02034b6:	cddfc0ef          	jal	ra,ffffffffc0200192 <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc02034ba:	018bb503          	ld	a0,24(s7)
ffffffffc02034be:	4605                	li	a2,1
ffffffffc02034c0:	6585                	lui	a1,0x1
ffffffffc02034c2:	a8ffe0ef          	jal	ra,ffffffffc0201f50 <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc02034c6:	4e050f63          	beqz	a0,ffffffffc02039c4 <swap_init+0x648>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc02034ca:	00007517          	auipc	a0,0x7
ffffffffc02034ce:	25650513          	addi	a0,a0,598 # ffffffffc020a720 <default_pmm_manager+0x888>
ffffffffc02034d2:	000c6997          	auipc	s3,0xc6
ffffffffc02034d6:	e1e98993          	addi	s3,s3,-482 # ffffffffc02c92f0 <check_rp>
ffffffffc02034da:	cb9fc0ef          	jal	ra,ffffffffc0200192 <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02034de:	000c6a17          	auipc	s4,0xc6
ffffffffc02034e2:	e32a0a13          	addi	s4,s4,-462 # ffffffffc02c9310 <swap_in_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc02034e6:	8c4e                	mv	s8,s3
          check_rp[i] = alloc_page();
ffffffffc02034e8:	4505                	li	a0,1
ffffffffc02034ea:	959fe0ef          	jal	ra,ffffffffc0201e42 <alloc_pages>
ffffffffc02034ee:	00ac3023          	sd	a0,0(s8)
          assert(check_rp[i] != NULL );
ffffffffc02034f2:	32050d63          	beqz	a0,ffffffffc020382c <swap_init+0x4b0>
ffffffffc02034f6:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc02034f8:	8b89                	andi	a5,a5,2
ffffffffc02034fa:	30079963          	bnez	a5,ffffffffc020380c <swap_init+0x490>
ffffffffc02034fe:	0c21                	addi	s8,s8,8
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0203500:	ff4c14e3          	bne	s8,s4,ffffffffc02034e8 <swap_init+0x16c>
     }
     list_entry_t free_list_store = free_list;
ffffffffc0203504:	601c                	ld	a5,0(s0)
     assert(list_empty(&free_list));
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
     nr_free = 0;
ffffffffc0203506:	000c6c17          	auipc	s8,0xc6
ffffffffc020350a:	deac0c13          	addi	s8,s8,-534 # ffffffffc02c92f0 <check_rp>
     list_entry_t free_list_store = free_list;
ffffffffc020350e:	ec3e                	sd	a5,24(sp)
ffffffffc0203510:	641c                	ld	a5,8(s0)
ffffffffc0203512:	f03e                	sd	a5,32(sp)
     unsigned int nr_free_store = nr_free;
ffffffffc0203514:	481c                	lw	a5,16(s0)
ffffffffc0203516:	f43e                	sd	a5,40(sp)
    elm->prev = elm->next = elm;
ffffffffc0203518:	000c6797          	auipc	a5,0xc6
ffffffffc020351c:	da87b423          	sd	s0,-600(a5) # ffffffffc02c92c0 <free_area+0x8>
ffffffffc0203520:	000c6797          	auipc	a5,0xc6
ffffffffc0203524:	d887bc23          	sd	s0,-616(a5) # ffffffffc02c92b8 <free_area>
     nr_free = 0;
ffffffffc0203528:	000c6797          	auipc	a5,0xc6
ffffffffc020352c:	da07a023          	sw	zero,-608(a5) # ffffffffc02c92c8 <free_area+0x10>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
        free_pages(check_rp[i],1);
ffffffffc0203530:	000c3503          	ld	a0,0(s8)
ffffffffc0203534:	4585                	li	a1,1
ffffffffc0203536:	0c21                	addi	s8,s8,8
ffffffffc0203538:	993fe0ef          	jal	ra,ffffffffc0201eca <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020353c:	ff4c1ae3          	bne	s8,s4,ffffffffc0203530 <swap_init+0x1b4>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0203540:	01042c03          	lw	s8,16(s0)
ffffffffc0203544:	4791                	li	a5,4
ffffffffc0203546:	50fc1b63          	bne	s8,a5,ffffffffc0203a5c <swap_init+0x6e0>
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc020354a:	00007517          	auipc	a0,0x7
ffffffffc020354e:	25e50513          	addi	a0,a0,606 # ffffffffc020a7a8 <default_pmm_manager+0x910>
ffffffffc0203552:	c41fc0ef          	jal	ra,ffffffffc0200192 <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203556:	6685                	lui	a3,0x1
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc0203558:	000c6797          	auipc	a5,0xc6
ffffffffc020355c:	d207a223          	sw	zero,-732(a5) # ffffffffc02c927c <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203560:	4629                	li	a2,10
     pgfault_num=0;
ffffffffc0203562:	000c6797          	auipc	a5,0xc6
ffffffffc0203566:	d1a78793          	addi	a5,a5,-742 # ffffffffc02c927c <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc020356a:	00c68023          	sb	a2,0(a3) # 1000 <_binary_obj___user_faultread_out_size-0x8900>
     assert(pgfault_num==1);
ffffffffc020356e:	4398                	lw	a4,0(a5)
ffffffffc0203570:	4585                	li	a1,1
ffffffffc0203572:	2701                	sext.w	a4,a4
ffffffffc0203574:	38b71863          	bne	a4,a1,ffffffffc0203904 <swap_init+0x588>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc0203578:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==1);
ffffffffc020357c:	4394                	lw	a3,0(a5)
ffffffffc020357e:	2681                	sext.w	a3,a3
ffffffffc0203580:	3ae69263          	bne	a3,a4,ffffffffc0203924 <swap_init+0x5a8>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203584:	6689                	lui	a3,0x2
ffffffffc0203586:	462d                	li	a2,11
ffffffffc0203588:	00c68023          	sb	a2,0(a3) # 2000 <_binary_obj___user_faultread_out_size-0x7900>
     assert(pgfault_num==2);
ffffffffc020358c:	4398                	lw	a4,0(a5)
ffffffffc020358e:	4589                	li	a1,2
ffffffffc0203590:	2701                	sext.w	a4,a4
ffffffffc0203592:	2eb71963          	bne	a4,a1,ffffffffc0203884 <swap_init+0x508>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc0203596:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==2);
ffffffffc020359a:	4394                	lw	a3,0(a5)
ffffffffc020359c:	2681                	sext.w	a3,a3
ffffffffc020359e:	30e69363          	bne	a3,a4,ffffffffc02038a4 <swap_init+0x528>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc02035a2:	668d                	lui	a3,0x3
ffffffffc02035a4:	4631                	li	a2,12
ffffffffc02035a6:	00c68023          	sb	a2,0(a3) # 3000 <_binary_obj___user_faultread_out_size-0x6900>
     assert(pgfault_num==3);
ffffffffc02035aa:	4398                	lw	a4,0(a5)
ffffffffc02035ac:	458d                	li	a1,3
ffffffffc02035ae:	2701                	sext.w	a4,a4
ffffffffc02035b0:	30b71a63          	bne	a4,a1,ffffffffc02038c4 <swap_init+0x548>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc02035b4:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==3);
ffffffffc02035b8:	4394                	lw	a3,0(a5)
ffffffffc02035ba:	2681                	sext.w	a3,a3
ffffffffc02035bc:	32e69463          	bne	a3,a4,ffffffffc02038e4 <swap_init+0x568>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc02035c0:	6691                	lui	a3,0x4
ffffffffc02035c2:	4635                	li	a2,13
ffffffffc02035c4:	00c68023          	sb	a2,0(a3) # 4000 <_binary_obj___user_faultread_out_size-0x5900>
     assert(pgfault_num==4);
ffffffffc02035c8:	4398                	lw	a4,0(a5)
ffffffffc02035ca:	2701                	sext.w	a4,a4
ffffffffc02035cc:	37871c63          	bne	a4,s8,ffffffffc0203944 <swap_init+0x5c8>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc02035d0:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==4);
ffffffffc02035d4:	439c                	lw	a5,0(a5)
ffffffffc02035d6:	2781                	sext.w	a5,a5
ffffffffc02035d8:	38e79663          	bne	a5,a4,ffffffffc0203964 <swap_init+0x5e8>
     
     check_content_set();
     assert( nr_free == 0);         
ffffffffc02035dc:	481c                	lw	a5,16(s0)
ffffffffc02035de:	40079363          	bnez	a5,ffffffffc02039e4 <swap_init+0x668>
ffffffffc02035e2:	000c6797          	auipc	a5,0xc6
ffffffffc02035e6:	d2e78793          	addi	a5,a5,-722 # ffffffffc02c9310 <swap_in_seq_no>
ffffffffc02035ea:	000c6717          	auipc	a4,0xc6
ffffffffc02035ee:	d4e70713          	addi	a4,a4,-690 # ffffffffc02c9338 <swap_out_seq_no>
ffffffffc02035f2:	000c6617          	auipc	a2,0xc6
ffffffffc02035f6:	d4660613          	addi	a2,a2,-698 # ffffffffc02c9338 <swap_out_seq_no>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc02035fa:	56fd                	li	a3,-1
ffffffffc02035fc:	c394                	sw	a3,0(a5)
ffffffffc02035fe:	c314                	sw	a3,0(a4)
ffffffffc0203600:	0791                	addi	a5,a5,4
ffffffffc0203602:	0711                	addi	a4,a4,4
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc0203604:	fef61ce3          	bne	a2,a5,ffffffffc02035fc <swap_init+0x280>
ffffffffc0203608:	000c6697          	auipc	a3,0xc6
ffffffffc020360c:	d9068693          	addi	a3,a3,-624 # ffffffffc02c9398 <check_ptep>
ffffffffc0203610:	000c6817          	auipc	a6,0xc6
ffffffffc0203614:	ce080813          	addi	a6,a6,-800 # ffffffffc02c92f0 <check_rp>
ffffffffc0203618:	6d05                	lui	s10,0x1
    if (PPN(pa) >= npage) {
ffffffffc020361a:	000c6c97          	auipc	s9,0xc6
ffffffffc020361e:	c4ec8c93          	addi	s9,s9,-946 # ffffffffc02c9268 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0203622:	00009d97          	auipc	s11,0x9
ffffffffc0203626:	97ed8d93          	addi	s11,s11,-1666 # ffffffffc020bfa0 <nbase>
ffffffffc020362a:	000c6c17          	auipc	s8,0xc6
ffffffffc020362e:	cbec0c13          	addi	s8,s8,-834 # ffffffffc02c92e8 <pages>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         check_ptep[i]=0;
ffffffffc0203632:	0006b023          	sd	zero,0(a3)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0203636:	4601                	li	a2,0
ffffffffc0203638:	85ea                	mv	a1,s10
ffffffffc020363a:	855a                	mv	a0,s6
ffffffffc020363c:	e842                	sd	a6,16(sp)
         check_ptep[i]=0;
ffffffffc020363e:	e436                	sd	a3,8(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0203640:	911fe0ef          	jal	ra,ffffffffc0201f50 <get_pte>
ffffffffc0203644:	66a2                	ld	a3,8(sp)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
ffffffffc0203646:	6842                	ld	a6,16(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0203648:	e288                	sd	a0,0(a3)
         assert(check_ptep[i] != NULL);
ffffffffc020364a:	20050163          	beqz	a0,ffffffffc020384c <swap_init+0x4d0>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc020364e:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0203650:	0017f613          	andi	a2,a5,1
ffffffffc0203654:	1a060063          	beqz	a2,ffffffffc02037f4 <swap_init+0x478>
    if (PPN(pa) >= npage) {
ffffffffc0203658:	000cb603          	ld	a2,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc020365c:	078a                	slli	a5,a5,0x2
ffffffffc020365e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203660:	14c7fe63          	bleu	a2,a5,ffffffffc02037bc <swap_init+0x440>
    return &pages[PPN(pa) - nbase];
ffffffffc0203664:	000db703          	ld	a4,0(s11)
ffffffffc0203668:	000c3603          	ld	a2,0(s8)
ffffffffc020366c:	00083583          	ld	a1,0(a6)
ffffffffc0203670:	8f99                	sub	a5,a5,a4
ffffffffc0203672:	079a                	slli	a5,a5,0x6
ffffffffc0203674:	e43a                	sd	a4,8(sp)
ffffffffc0203676:	97b2                	add	a5,a5,a2
ffffffffc0203678:	14f59e63          	bne	a1,a5,ffffffffc02037d4 <swap_init+0x458>
ffffffffc020367c:	6785                	lui	a5,0x1
ffffffffc020367e:	9d3e                	add	s10,s10,a5
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0203680:	6795                	lui	a5,0x5
ffffffffc0203682:	06a1                	addi	a3,a3,8
ffffffffc0203684:	0821                	addi	a6,a6,8
ffffffffc0203686:	fafd16e3          	bne	s10,a5,ffffffffc0203632 <swap_init+0x2b6>
         assert((*check_ptep[i] & PTE_V));          
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc020368a:	00007517          	auipc	a0,0x7
ffffffffc020368e:	1c650513          	addi	a0,a0,454 # ffffffffc020a850 <default_pmm_manager+0x9b8>
ffffffffc0203692:	b01fc0ef          	jal	ra,ffffffffc0200192 <cprintf>
    int ret = sm->check_swap();
ffffffffc0203696:	000c6797          	auipc	a5,0xc6
ffffffffc020369a:	bda78793          	addi	a5,a5,-1062 # ffffffffc02c9270 <sm>
ffffffffc020369e:	639c                	ld	a5,0(a5)
ffffffffc02036a0:	7f9c                	ld	a5,56(a5)
ffffffffc02036a2:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
ffffffffc02036a4:	40051c63          	bnez	a0,ffffffffc0203abc <swap_init+0x740>

     nr_free = nr_free_store;
ffffffffc02036a8:	77a2                	ld	a5,40(sp)
ffffffffc02036aa:	000c6717          	auipc	a4,0xc6
ffffffffc02036ae:	c0f72f23          	sw	a5,-994(a4) # ffffffffc02c92c8 <free_area+0x10>
     free_list = free_list_store;
ffffffffc02036b2:	67e2                	ld	a5,24(sp)
ffffffffc02036b4:	000c6717          	auipc	a4,0xc6
ffffffffc02036b8:	c0f73223          	sd	a5,-1020(a4) # ffffffffc02c92b8 <free_area>
ffffffffc02036bc:	7782                	ld	a5,32(sp)
ffffffffc02036be:	000c6717          	auipc	a4,0xc6
ffffffffc02036c2:	c0f73123          	sd	a5,-1022(a4) # ffffffffc02c92c0 <free_area+0x8>

     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         free_pages(check_rp[i],1);
ffffffffc02036c6:	0009b503          	ld	a0,0(s3)
ffffffffc02036ca:	4585                	li	a1,1
ffffffffc02036cc:	09a1                	addi	s3,s3,8
ffffffffc02036ce:	ffcfe0ef          	jal	ra,ffffffffc0201eca <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02036d2:	ff499ae3          	bne	s3,s4,ffffffffc02036c6 <swap_init+0x34a>
     } 

     //free_page(pte2page(*temp_ptep));

     mm->pgdir = NULL;
ffffffffc02036d6:	000bbc23          	sd	zero,24(s7)
     mm_destroy(mm);
ffffffffc02036da:	855e                	mv	a0,s7
ffffffffc02036dc:	361000ef          	jal	ra,ffffffffc020423c <mm_destroy>
     check_mm_struct = NULL;

     pde_t *pd1=pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc02036e0:	000c6797          	auipc	a5,0xc6
ffffffffc02036e4:	b8078793          	addi	a5,a5,-1152 # ffffffffc02c9260 <boot_pgdir>
ffffffffc02036e8:	639c                	ld	a5,0(a5)
     check_mm_struct = NULL;
ffffffffc02036ea:	000c6697          	auipc	a3,0xc6
ffffffffc02036ee:	cc06bf23          	sd	zero,-802(a3) # ffffffffc02c93c8 <check_mm_struct>
    if (PPN(pa) >= npage) {
ffffffffc02036f2:	000cb703          	ld	a4,0(s9)
    return pa2page(PDE_ADDR(pde));
ffffffffc02036f6:	6394                	ld	a3,0(a5)
ffffffffc02036f8:	068a                	slli	a3,a3,0x2
ffffffffc02036fa:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc02036fc:	0ce6f063          	bleu	a4,a3,ffffffffc02037bc <swap_init+0x440>
    return &pages[PPN(pa) - nbase];
ffffffffc0203700:	67a2                	ld	a5,8(sp)
ffffffffc0203702:	000c3503          	ld	a0,0(s8)
ffffffffc0203706:	8e9d                	sub	a3,a3,a5
ffffffffc0203708:	069a                	slli	a3,a3,0x6
    return page - pages + nbase;
ffffffffc020370a:	8699                	srai	a3,a3,0x6
ffffffffc020370c:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc020370e:	57fd                	li	a5,-1
ffffffffc0203710:	83b1                	srli	a5,a5,0xc
ffffffffc0203712:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0203714:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0203716:	2ee7f763          	bleu	a4,a5,ffffffffc0203a04 <swap_init+0x688>
     free_page(pde2page(pd0[0]));
ffffffffc020371a:	000c6797          	auipc	a5,0xc6
ffffffffc020371e:	bbe78793          	addi	a5,a5,-1090 # ffffffffc02c92d8 <va_pa_offset>
ffffffffc0203722:	639c                	ld	a5,0(a5)
ffffffffc0203724:	96be                	add	a3,a3,a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0203726:	629c                	ld	a5,0(a3)
ffffffffc0203728:	078a                	slli	a5,a5,0x2
ffffffffc020372a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020372c:	08e7f863          	bleu	a4,a5,ffffffffc02037bc <swap_init+0x440>
    return &pages[PPN(pa) - nbase];
ffffffffc0203730:	69a2                	ld	s3,8(sp)
ffffffffc0203732:	4585                	li	a1,1
ffffffffc0203734:	413787b3          	sub	a5,a5,s3
ffffffffc0203738:	079a                	slli	a5,a5,0x6
ffffffffc020373a:	953e                	add	a0,a0,a5
ffffffffc020373c:	f8efe0ef          	jal	ra,ffffffffc0201eca <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0203740:	000b3783          	ld	a5,0(s6)
    if (PPN(pa) >= npage) {
ffffffffc0203744:	000cb703          	ld	a4,0(s9)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203748:	078a                	slli	a5,a5,0x2
ffffffffc020374a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020374c:	06e7f863          	bleu	a4,a5,ffffffffc02037bc <swap_init+0x440>
    return &pages[PPN(pa) - nbase];
ffffffffc0203750:	000c3503          	ld	a0,0(s8)
ffffffffc0203754:	413787b3          	sub	a5,a5,s3
ffffffffc0203758:	079a                	slli	a5,a5,0x6
     free_page(pde2page(pd1[0]));
ffffffffc020375a:	4585                	li	a1,1
ffffffffc020375c:	953e                	add	a0,a0,a5
ffffffffc020375e:	f6cfe0ef          	jal	ra,ffffffffc0201eca <free_pages>
     pgdir[0] = 0;
ffffffffc0203762:	000b3023          	sd	zero,0(s6)
  asm volatile("sfence.vma");
ffffffffc0203766:	12000073          	sfence.vma
    return listelm->next;
ffffffffc020376a:	641c                	ld	a5,8(s0)
     flush_tlb();

     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc020376c:	00878963          	beq	a5,s0,ffffffffc020377e <swap_init+0x402>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
ffffffffc0203770:	ff87a703          	lw	a4,-8(a5)
ffffffffc0203774:	679c                	ld	a5,8(a5)
ffffffffc0203776:	397d                	addiw	s2,s2,-1
ffffffffc0203778:	9c99                	subw	s1,s1,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc020377a:	fe879be3          	bne	a5,s0,ffffffffc0203770 <swap_init+0x3f4>
     }
     assert(count==0);
ffffffffc020377e:	28091f63          	bnez	s2,ffffffffc0203a1c <swap_init+0x6a0>
     assert(total==0);
ffffffffc0203782:	2a049d63          	bnez	s1,ffffffffc0203a3c <swap_init+0x6c0>

     cprintf("check_swap() succeeded!\n");
ffffffffc0203786:	00007517          	auipc	a0,0x7
ffffffffc020378a:	11a50513          	addi	a0,a0,282 # ffffffffc020a8a0 <default_pmm_manager+0xa08>
ffffffffc020378e:	a05fc0ef          	jal	ra,ffffffffc0200192 <cprintf>
ffffffffc0203792:	b92d                	j	ffffffffc02033cc <swap_init+0x50>
     int ret, count = 0, total = 0, i;
ffffffffc0203794:	4481                	li	s1,0
ffffffffc0203796:	4901                	li	s2,0
     while ((le = list_next(le)) != &free_list) {
ffffffffc0203798:	4981                	li	s3,0
ffffffffc020379a:	b17d                	j	ffffffffc0203448 <swap_init+0xcc>
        assert(PageProperty(p));
ffffffffc020379c:	00006697          	auipc	a3,0x6
ffffffffc02037a0:	36c68693          	addi	a3,a3,876 # ffffffffc0209b08 <commands+0x878>
ffffffffc02037a4:	00006617          	auipc	a2,0x6
ffffffffc02037a8:	fac60613          	addi	a2,a2,-84 # ffffffffc0209750 <commands+0x4c0>
ffffffffc02037ac:	0bc00593          	li	a1,188
ffffffffc02037b0:	00007517          	auipc	a0,0x7
ffffffffc02037b4:	e8850513          	addi	a0,a0,-376 # ffffffffc020a638 <default_pmm_manager+0x7a0>
ffffffffc02037b8:	cd1fc0ef          	jal	ra,ffffffffc0200488 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02037bc:	00006617          	auipc	a2,0x6
ffffffffc02037c0:	78c60613          	addi	a2,a2,1932 # ffffffffc0209f48 <default_pmm_manager+0xb0>
ffffffffc02037c4:	06200593          	li	a1,98
ffffffffc02037c8:	00006517          	auipc	a0,0x6
ffffffffc02037cc:	74850513          	addi	a0,a0,1864 # ffffffffc0209f10 <default_pmm_manager+0x78>
ffffffffc02037d0:	cb9fc0ef          	jal	ra,ffffffffc0200488 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc02037d4:	00007697          	auipc	a3,0x7
ffffffffc02037d8:	05468693          	addi	a3,a3,84 # ffffffffc020a828 <default_pmm_manager+0x990>
ffffffffc02037dc:	00006617          	auipc	a2,0x6
ffffffffc02037e0:	f7460613          	addi	a2,a2,-140 # ffffffffc0209750 <commands+0x4c0>
ffffffffc02037e4:	0fc00593          	li	a1,252
ffffffffc02037e8:	00007517          	auipc	a0,0x7
ffffffffc02037ec:	e5050513          	addi	a0,a0,-432 # ffffffffc020a638 <default_pmm_manager+0x7a0>
ffffffffc02037f0:	c99fc0ef          	jal	ra,ffffffffc0200488 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc02037f4:	00007617          	auipc	a2,0x7
ffffffffc02037f8:	9ac60613          	addi	a2,a2,-1620 # ffffffffc020a1a0 <default_pmm_manager+0x308>
ffffffffc02037fc:	07400593          	li	a1,116
ffffffffc0203800:	00006517          	auipc	a0,0x6
ffffffffc0203804:	71050513          	addi	a0,a0,1808 # ffffffffc0209f10 <default_pmm_manager+0x78>
ffffffffc0203808:	c81fc0ef          	jal	ra,ffffffffc0200488 <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc020380c:	00007697          	auipc	a3,0x7
ffffffffc0203810:	f5468693          	addi	a3,a3,-172 # ffffffffc020a760 <default_pmm_manager+0x8c8>
ffffffffc0203814:	00006617          	auipc	a2,0x6
ffffffffc0203818:	f3c60613          	addi	a2,a2,-196 # ffffffffc0209750 <commands+0x4c0>
ffffffffc020381c:	0dd00593          	li	a1,221
ffffffffc0203820:	00007517          	auipc	a0,0x7
ffffffffc0203824:	e1850513          	addi	a0,a0,-488 # ffffffffc020a638 <default_pmm_manager+0x7a0>
ffffffffc0203828:	c61fc0ef          	jal	ra,ffffffffc0200488 <__panic>
          assert(check_rp[i] != NULL );
ffffffffc020382c:	00007697          	auipc	a3,0x7
ffffffffc0203830:	f1c68693          	addi	a3,a3,-228 # ffffffffc020a748 <default_pmm_manager+0x8b0>
ffffffffc0203834:	00006617          	auipc	a2,0x6
ffffffffc0203838:	f1c60613          	addi	a2,a2,-228 # ffffffffc0209750 <commands+0x4c0>
ffffffffc020383c:	0dc00593          	li	a1,220
ffffffffc0203840:	00007517          	auipc	a0,0x7
ffffffffc0203844:	df850513          	addi	a0,a0,-520 # ffffffffc020a638 <default_pmm_manager+0x7a0>
ffffffffc0203848:	c41fc0ef          	jal	ra,ffffffffc0200488 <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc020384c:	00007697          	auipc	a3,0x7
ffffffffc0203850:	fc468693          	addi	a3,a3,-60 # ffffffffc020a810 <default_pmm_manager+0x978>
ffffffffc0203854:	00006617          	auipc	a2,0x6
ffffffffc0203858:	efc60613          	addi	a2,a2,-260 # ffffffffc0209750 <commands+0x4c0>
ffffffffc020385c:	0fb00593          	li	a1,251
ffffffffc0203860:	00007517          	auipc	a0,0x7
ffffffffc0203864:	dd850513          	addi	a0,a0,-552 # ffffffffc020a638 <default_pmm_manager+0x7a0>
ffffffffc0203868:	c21fc0ef          	jal	ra,ffffffffc0200488 <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc020386c:	00007617          	auipc	a2,0x7
ffffffffc0203870:	dac60613          	addi	a2,a2,-596 # ffffffffc020a618 <default_pmm_manager+0x780>
ffffffffc0203874:	02800593          	li	a1,40
ffffffffc0203878:	00007517          	auipc	a0,0x7
ffffffffc020387c:	dc050513          	addi	a0,a0,-576 # ffffffffc020a638 <default_pmm_manager+0x7a0>
ffffffffc0203880:	c09fc0ef          	jal	ra,ffffffffc0200488 <__panic>
     assert(pgfault_num==2);
ffffffffc0203884:	00007697          	auipc	a3,0x7
ffffffffc0203888:	f5c68693          	addi	a3,a3,-164 # ffffffffc020a7e0 <default_pmm_manager+0x948>
ffffffffc020388c:	00006617          	auipc	a2,0x6
ffffffffc0203890:	ec460613          	addi	a2,a2,-316 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0203894:	09700593          	li	a1,151
ffffffffc0203898:	00007517          	auipc	a0,0x7
ffffffffc020389c:	da050513          	addi	a0,a0,-608 # ffffffffc020a638 <default_pmm_manager+0x7a0>
ffffffffc02038a0:	be9fc0ef          	jal	ra,ffffffffc0200488 <__panic>
     assert(pgfault_num==2);
ffffffffc02038a4:	00007697          	auipc	a3,0x7
ffffffffc02038a8:	f3c68693          	addi	a3,a3,-196 # ffffffffc020a7e0 <default_pmm_manager+0x948>
ffffffffc02038ac:	00006617          	auipc	a2,0x6
ffffffffc02038b0:	ea460613          	addi	a2,a2,-348 # ffffffffc0209750 <commands+0x4c0>
ffffffffc02038b4:	09900593          	li	a1,153
ffffffffc02038b8:	00007517          	auipc	a0,0x7
ffffffffc02038bc:	d8050513          	addi	a0,a0,-640 # ffffffffc020a638 <default_pmm_manager+0x7a0>
ffffffffc02038c0:	bc9fc0ef          	jal	ra,ffffffffc0200488 <__panic>
     assert(pgfault_num==3);
ffffffffc02038c4:	00007697          	auipc	a3,0x7
ffffffffc02038c8:	f2c68693          	addi	a3,a3,-212 # ffffffffc020a7f0 <default_pmm_manager+0x958>
ffffffffc02038cc:	00006617          	auipc	a2,0x6
ffffffffc02038d0:	e8460613          	addi	a2,a2,-380 # ffffffffc0209750 <commands+0x4c0>
ffffffffc02038d4:	09b00593          	li	a1,155
ffffffffc02038d8:	00007517          	auipc	a0,0x7
ffffffffc02038dc:	d6050513          	addi	a0,a0,-672 # ffffffffc020a638 <default_pmm_manager+0x7a0>
ffffffffc02038e0:	ba9fc0ef          	jal	ra,ffffffffc0200488 <__panic>
     assert(pgfault_num==3);
ffffffffc02038e4:	00007697          	auipc	a3,0x7
ffffffffc02038e8:	f0c68693          	addi	a3,a3,-244 # ffffffffc020a7f0 <default_pmm_manager+0x958>
ffffffffc02038ec:	00006617          	auipc	a2,0x6
ffffffffc02038f0:	e6460613          	addi	a2,a2,-412 # ffffffffc0209750 <commands+0x4c0>
ffffffffc02038f4:	09d00593          	li	a1,157
ffffffffc02038f8:	00007517          	auipc	a0,0x7
ffffffffc02038fc:	d4050513          	addi	a0,a0,-704 # ffffffffc020a638 <default_pmm_manager+0x7a0>
ffffffffc0203900:	b89fc0ef          	jal	ra,ffffffffc0200488 <__panic>
     assert(pgfault_num==1);
ffffffffc0203904:	00007697          	auipc	a3,0x7
ffffffffc0203908:	ecc68693          	addi	a3,a3,-308 # ffffffffc020a7d0 <default_pmm_manager+0x938>
ffffffffc020390c:	00006617          	auipc	a2,0x6
ffffffffc0203910:	e4460613          	addi	a2,a2,-444 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0203914:	09300593          	li	a1,147
ffffffffc0203918:	00007517          	auipc	a0,0x7
ffffffffc020391c:	d2050513          	addi	a0,a0,-736 # ffffffffc020a638 <default_pmm_manager+0x7a0>
ffffffffc0203920:	b69fc0ef          	jal	ra,ffffffffc0200488 <__panic>
     assert(pgfault_num==1);
ffffffffc0203924:	00007697          	auipc	a3,0x7
ffffffffc0203928:	eac68693          	addi	a3,a3,-340 # ffffffffc020a7d0 <default_pmm_manager+0x938>
ffffffffc020392c:	00006617          	auipc	a2,0x6
ffffffffc0203930:	e2460613          	addi	a2,a2,-476 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0203934:	09500593          	li	a1,149
ffffffffc0203938:	00007517          	auipc	a0,0x7
ffffffffc020393c:	d0050513          	addi	a0,a0,-768 # ffffffffc020a638 <default_pmm_manager+0x7a0>
ffffffffc0203940:	b49fc0ef          	jal	ra,ffffffffc0200488 <__panic>
     assert(pgfault_num==4);
ffffffffc0203944:	00007697          	auipc	a3,0x7
ffffffffc0203948:	ebc68693          	addi	a3,a3,-324 # ffffffffc020a800 <default_pmm_manager+0x968>
ffffffffc020394c:	00006617          	auipc	a2,0x6
ffffffffc0203950:	e0460613          	addi	a2,a2,-508 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0203954:	09f00593          	li	a1,159
ffffffffc0203958:	00007517          	auipc	a0,0x7
ffffffffc020395c:	ce050513          	addi	a0,a0,-800 # ffffffffc020a638 <default_pmm_manager+0x7a0>
ffffffffc0203960:	b29fc0ef          	jal	ra,ffffffffc0200488 <__panic>
     assert(pgfault_num==4);
ffffffffc0203964:	00007697          	auipc	a3,0x7
ffffffffc0203968:	e9c68693          	addi	a3,a3,-356 # ffffffffc020a800 <default_pmm_manager+0x968>
ffffffffc020396c:	00006617          	auipc	a2,0x6
ffffffffc0203970:	de460613          	addi	a2,a2,-540 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0203974:	0a100593          	li	a1,161
ffffffffc0203978:	00007517          	auipc	a0,0x7
ffffffffc020397c:	cc050513          	addi	a0,a0,-832 # ffffffffc020a638 <default_pmm_manager+0x7a0>
ffffffffc0203980:	b09fc0ef          	jal	ra,ffffffffc0200488 <__panic>
     assert(pgdir[0] == 0);
ffffffffc0203984:	00007697          	auipc	a3,0x7
ffffffffc0203988:	d2c68693          	addi	a3,a3,-724 # ffffffffc020a6b0 <default_pmm_manager+0x818>
ffffffffc020398c:	00006617          	auipc	a2,0x6
ffffffffc0203990:	dc460613          	addi	a2,a2,-572 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0203994:	0cc00593          	li	a1,204
ffffffffc0203998:	00007517          	auipc	a0,0x7
ffffffffc020399c:	ca050513          	addi	a0,a0,-864 # ffffffffc020a638 <default_pmm_manager+0x7a0>
ffffffffc02039a0:	ae9fc0ef          	jal	ra,ffffffffc0200488 <__panic>
     assert(vma != NULL);
ffffffffc02039a4:	00007697          	auipc	a3,0x7
ffffffffc02039a8:	d1c68693          	addi	a3,a3,-740 # ffffffffc020a6c0 <default_pmm_manager+0x828>
ffffffffc02039ac:	00006617          	auipc	a2,0x6
ffffffffc02039b0:	da460613          	addi	a2,a2,-604 # ffffffffc0209750 <commands+0x4c0>
ffffffffc02039b4:	0cf00593          	li	a1,207
ffffffffc02039b8:	00007517          	auipc	a0,0x7
ffffffffc02039bc:	c8050513          	addi	a0,a0,-896 # ffffffffc020a638 <default_pmm_manager+0x7a0>
ffffffffc02039c0:	ac9fc0ef          	jal	ra,ffffffffc0200488 <__panic>
     assert(temp_ptep!= NULL);
ffffffffc02039c4:	00007697          	auipc	a3,0x7
ffffffffc02039c8:	d4468693          	addi	a3,a3,-700 # ffffffffc020a708 <default_pmm_manager+0x870>
ffffffffc02039cc:	00006617          	auipc	a2,0x6
ffffffffc02039d0:	d8460613          	addi	a2,a2,-636 # ffffffffc0209750 <commands+0x4c0>
ffffffffc02039d4:	0d700593          	li	a1,215
ffffffffc02039d8:	00007517          	auipc	a0,0x7
ffffffffc02039dc:	c6050513          	addi	a0,a0,-928 # ffffffffc020a638 <default_pmm_manager+0x7a0>
ffffffffc02039e0:	aa9fc0ef          	jal	ra,ffffffffc0200488 <__panic>
     assert( nr_free == 0);         
ffffffffc02039e4:	00006697          	auipc	a3,0x6
ffffffffc02039e8:	2f468693          	addi	a3,a3,756 # ffffffffc0209cd8 <commands+0xa48>
ffffffffc02039ec:	00006617          	auipc	a2,0x6
ffffffffc02039f0:	d6460613          	addi	a2,a2,-668 # ffffffffc0209750 <commands+0x4c0>
ffffffffc02039f4:	0f300593          	li	a1,243
ffffffffc02039f8:	00007517          	auipc	a0,0x7
ffffffffc02039fc:	c4050513          	addi	a0,a0,-960 # ffffffffc020a638 <default_pmm_manager+0x7a0>
ffffffffc0203a00:	a89fc0ef          	jal	ra,ffffffffc0200488 <__panic>
    return KADDR(page2pa(page));
ffffffffc0203a04:	00006617          	auipc	a2,0x6
ffffffffc0203a08:	4e460613          	addi	a2,a2,1252 # ffffffffc0209ee8 <default_pmm_manager+0x50>
ffffffffc0203a0c:	06900593          	li	a1,105
ffffffffc0203a10:	00006517          	auipc	a0,0x6
ffffffffc0203a14:	50050513          	addi	a0,a0,1280 # ffffffffc0209f10 <default_pmm_manager+0x78>
ffffffffc0203a18:	a71fc0ef          	jal	ra,ffffffffc0200488 <__panic>
     assert(count==0);
ffffffffc0203a1c:	00007697          	auipc	a3,0x7
ffffffffc0203a20:	e6468693          	addi	a3,a3,-412 # ffffffffc020a880 <default_pmm_manager+0x9e8>
ffffffffc0203a24:	00006617          	auipc	a2,0x6
ffffffffc0203a28:	d2c60613          	addi	a2,a2,-724 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0203a2c:	11d00593          	li	a1,285
ffffffffc0203a30:	00007517          	auipc	a0,0x7
ffffffffc0203a34:	c0850513          	addi	a0,a0,-1016 # ffffffffc020a638 <default_pmm_manager+0x7a0>
ffffffffc0203a38:	a51fc0ef          	jal	ra,ffffffffc0200488 <__panic>
     assert(total==0);
ffffffffc0203a3c:	00007697          	auipc	a3,0x7
ffffffffc0203a40:	e5468693          	addi	a3,a3,-428 # ffffffffc020a890 <default_pmm_manager+0x9f8>
ffffffffc0203a44:	00006617          	auipc	a2,0x6
ffffffffc0203a48:	d0c60613          	addi	a2,a2,-756 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0203a4c:	11e00593          	li	a1,286
ffffffffc0203a50:	00007517          	auipc	a0,0x7
ffffffffc0203a54:	be850513          	addi	a0,a0,-1048 # ffffffffc020a638 <default_pmm_manager+0x7a0>
ffffffffc0203a58:	a31fc0ef          	jal	ra,ffffffffc0200488 <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0203a5c:	00007697          	auipc	a3,0x7
ffffffffc0203a60:	d2468693          	addi	a3,a3,-732 # ffffffffc020a780 <default_pmm_manager+0x8e8>
ffffffffc0203a64:	00006617          	auipc	a2,0x6
ffffffffc0203a68:	cec60613          	addi	a2,a2,-788 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0203a6c:	0ea00593          	li	a1,234
ffffffffc0203a70:	00007517          	auipc	a0,0x7
ffffffffc0203a74:	bc850513          	addi	a0,a0,-1080 # ffffffffc020a638 <default_pmm_manager+0x7a0>
ffffffffc0203a78:	a11fc0ef          	jal	ra,ffffffffc0200488 <__panic>
     assert(mm != NULL);
ffffffffc0203a7c:	00007697          	auipc	a3,0x7
ffffffffc0203a80:	c0c68693          	addi	a3,a3,-1012 # ffffffffc020a688 <default_pmm_manager+0x7f0>
ffffffffc0203a84:	00006617          	auipc	a2,0x6
ffffffffc0203a88:	ccc60613          	addi	a2,a2,-820 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0203a8c:	0c400593          	li	a1,196
ffffffffc0203a90:	00007517          	auipc	a0,0x7
ffffffffc0203a94:	ba850513          	addi	a0,a0,-1112 # ffffffffc020a638 <default_pmm_manager+0x7a0>
ffffffffc0203a98:	9f1fc0ef          	jal	ra,ffffffffc0200488 <__panic>
     assert(check_mm_struct == NULL);
ffffffffc0203a9c:	00007697          	auipc	a3,0x7
ffffffffc0203aa0:	bfc68693          	addi	a3,a3,-1028 # ffffffffc020a698 <default_pmm_manager+0x800>
ffffffffc0203aa4:	00006617          	auipc	a2,0x6
ffffffffc0203aa8:	cac60613          	addi	a2,a2,-852 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0203aac:	0c700593          	li	a1,199
ffffffffc0203ab0:	00007517          	auipc	a0,0x7
ffffffffc0203ab4:	b8850513          	addi	a0,a0,-1144 # ffffffffc020a638 <default_pmm_manager+0x7a0>
ffffffffc0203ab8:	9d1fc0ef          	jal	ra,ffffffffc0200488 <__panic>
     assert(ret==0);
ffffffffc0203abc:	00007697          	auipc	a3,0x7
ffffffffc0203ac0:	dbc68693          	addi	a3,a3,-580 # ffffffffc020a878 <default_pmm_manager+0x9e0>
ffffffffc0203ac4:	00006617          	auipc	a2,0x6
ffffffffc0203ac8:	c8c60613          	addi	a2,a2,-884 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0203acc:	10200593          	li	a1,258
ffffffffc0203ad0:	00007517          	auipc	a0,0x7
ffffffffc0203ad4:	b6850513          	addi	a0,a0,-1176 # ffffffffc020a638 <default_pmm_manager+0x7a0>
ffffffffc0203ad8:	9b1fc0ef          	jal	ra,ffffffffc0200488 <__panic>
     assert(total == nr_free_pages());
ffffffffc0203adc:	00006697          	auipc	a3,0x6
ffffffffc0203ae0:	05468693          	addi	a3,a3,84 # ffffffffc0209b30 <commands+0x8a0>
ffffffffc0203ae4:	00006617          	auipc	a2,0x6
ffffffffc0203ae8:	c6c60613          	addi	a2,a2,-916 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0203aec:	0bf00593          	li	a1,191
ffffffffc0203af0:	00007517          	auipc	a0,0x7
ffffffffc0203af4:	b4850513          	addi	a0,a0,-1208 # ffffffffc020a638 <default_pmm_manager+0x7a0>
ffffffffc0203af8:	991fc0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0203afc <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc0203afc:	000c5797          	auipc	a5,0xc5
ffffffffc0203b00:	77478793          	addi	a5,a5,1908 # ffffffffc02c9270 <sm>
ffffffffc0203b04:	639c                	ld	a5,0(a5)
ffffffffc0203b06:	0107b303          	ld	t1,16(a5)
ffffffffc0203b0a:	8302                	jr	t1

ffffffffc0203b0c <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc0203b0c:	000c5797          	auipc	a5,0xc5
ffffffffc0203b10:	76478793          	addi	a5,a5,1892 # ffffffffc02c9270 <sm>
ffffffffc0203b14:	639c                	ld	a5,0(a5)
ffffffffc0203b16:	0207b303          	ld	t1,32(a5)
ffffffffc0203b1a:	8302                	jr	t1

ffffffffc0203b1c <swap_out>:
{
ffffffffc0203b1c:	711d                	addi	sp,sp,-96
ffffffffc0203b1e:	ec86                	sd	ra,88(sp)
ffffffffc0203b20:	e8a2                	sd	s0,80(sp)
ffffffffc0203b22:	e4a6                	sd	s1,72(sp)
ffffffffc0203b24:	e0ca                	sd	s2,64(sp)
ffffffffc0203b26:	fc4e                	sd	s3,56(sp)
ffffffffc0203b28:	f852                	sd	s4,48(sp)
ffffffffc0203b2a:	f456                	sd	s5,40(sp)
ffffffffc0203b2c:	f05a                	sd	s6,32(sp)
ffffffffc0203b2e:	ec5e                	sd	s7,24(sp)
ffffffffc0203b30:	e862                	sd	s8,16(sp)
     for (i = 0; i != n; ++ i)
ffffffffc0203b32:	cde9                	beqz	a1,ffffffffc0203c0c <swap_out+0xf0>
ffffffffc0203b34:	8ab2                	mv	s5,a2
ffffffffc0203b36:	892a                	mv	s2,a0
ffffffffc0203b38:	8a2e                	mv	s4,a1
ffffffffc0203b3a:	4401                	li	s0,0
ffffffffc0203b3c:	000c5997          	auipc	s3,0xc5
ffffffffc0203b40:	73498993          	addi	s3,s3,1844 # ffffffffc02c9270 <sm>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203b44:	00007b17          	auipc	s6,0x7
ffffffffc0203b48:	ddcb0b13          	addi	s6,s6,-548 # ffffffffc020a920 <default_pmm_manager+0xa88>
                    cprintf("SWAP: failed to save\n");
ffffffffc0203b4c:	00007b97          	auipc	s7,0x7
ffffffffc0203b50:	dbcb8b93          	addi	s7,s7,-580 # ffffffffc020a908 <default_pmm_manager+0xa70>
ffffffffc0203b54:	a825                	j	ffffffffc0203b8c <swap_out+0x70>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203b56:	67a2                	ld	a5,8(sp)
ffffffffc0203b58:	8626                	mv	a2,s1
ffffffffc0203b5a:	85a2                	mv	a1,s0
ffffffffc0203b5c:	7f94                	ld	a3,56(a5)
ffffffffc0203b5e:	855a                	mv	a0,s6
     for (i = 0; i != n; ++ i)
ffffffffc0203b60:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203b62:	82b1                	srli	a3,a3,0xc
ffffffffc0203b64:	0685                	addi	a3,a3,1
ffffffffc0203b66:	e2cfc0ef          	jal	ra,ffffffffc0200192 <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0203b6a:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc0203b6c:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0203b6e:	7d1c                	ld	a5,56(a0)
ffffffffc0203b70:	83b1                	srli	a5,a5,0xc
ffffffffc0203b72:	0785                	addi	a5,a5,1
ffffffffc0203b74:	07a2                	slli	a5,a5,0x8
ffffffffc0203b76:	00fc3023          	sd	a5,0(s8)
                    free_page(page);
ffffffffc0203b7a:	b50fe0ef          	jal	ra,ffffffffc0201eca <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc0203b7e:	01893503          	ld	a0,24(s2)
ffffffffc0203b82:	85a6                	mv	a1,s1
ffffffffc0203b84:	f5eff0ef          	jal	ra,ffffffffc02032e2 <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc0203b88:	048a0d63          	beq	s4,s0,ffffffffc0203be2 <swap_out+0xc6>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc0203b8c:	0009b783          	ld	a5,0(s3)
ffffffffc0203b90:	8656                	mv	a2,s5
ffffffffc0203b92:	002c                	addi	a1,sp,8
ffffffffc0203b94:	7b9c                	ld	a5,48(a5)
ffffffffc0203b96:	854a                	mv	a0,s2
ffffffffc0203b98:	9782                	jalr	a5
          if (r != 0) {
ffffffffc0203b9a:	e12d                	bnez	a0,ffffffffc0203bfc <swap_out+0xe0>
          v=page->pra_vaddr; 
ffffffffc0203b9c:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203b9e:	01893503          	ld	a0,24(s2)
ffffffffc0203ba2:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc0203ba4:	7f84                	ld	s1,56(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203ba6:	85a6                	mv	a1,s1
ffffffffc0203ba8:	ba8fe0ef          	jal	ra,ffffffffc0201f50 <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc0203bac:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203bae:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc0203bb0:	8b85                	andi	a5,a5,1
ffffffffc0203bb2:	cfb9                	beqz	a5,ffffffffc0203c10 <swap_out+0xf4>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc0203bb4:	65a2                	ld	a1,8(sp)
ffffffffc0203bb6:	7d9c                	ld	a5,56(a1)
ffffffffc0203bb8:	83b1                	srli	a5,a5,0xc
ffffffffc0203bba:	00178513          	addi	a0,a5,1
ffffffffc0203bbe:	0522                	slli	a0,a0,0x8
ffffffffc0203bc0:	044010ef          	jal	ra,ffffffffc0204c04 <swapfs_write>
ffffffffc0203bc4:	d949                	beqz	a0,ffffffffc0203b56 <swap_out+0x3a>
                    cprintf("SWAP: failed to save\n");
ffffffffc0203bc6:	855e                	mv	a0,s7
ffffffffc0203bc8:	dcafc0ef          	jal	ra,ffffffffc0200192 <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0203bcc:	0009b783          	ld	a5,0(s3)
ffffffffc0203bd0:	6622                	ld	a2,8(sp)
ffffffffc0203bd2:	4681                	li	a3,0
ffffffffc0203bd4:	739c                	ld	a5,32(a5)
ffffffffc0203bd6:	85a6                	mv	a1,s1
ffffffffc0203bd8:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc0203bda:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0203bdc:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc0203bde:	fa8a17e3          	bne	s4,s0,ffffffffc0203b8c <swap_out+0x70>
}
ffffffffc0203be2:	8522                	mv	a0,s0
ffffffffc0203be4:	60e6                	ld	ra,88(sp)
ffffffffc0203be6:	6446                	ld	s0,80(sp)
ffffffffc0203be8:	64a6                	ld	s1,72(sp)
ffffffffc0203bea:	6906                	ld	s2,64(sp)
ffffffffc0203bec:	79e2                	ld	s3,56(sp)
ffffffffc0203bee:	7a42                	ld	s4,48(sp)
ffffffffc0203bf0:	7aa2                	ld	s5,40(sp)
ffffffffc0203bf2:	7b02                	ld	s6,32(sp)
ffffffffc0203bf4:	6be2                	ld	s7,24(sp)
ffffffffc0203bf6:	6c42                	ld	s8,16(sp)
ffffffffc0203bf8:	6125                	addi	sp,sp,96
ffffffffc0203bfa:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc0203bfc:	85a2                	mv	a1,s0
ffffffffc0203bfe:	00007517          	auipc	a0,0x7
ffffffffc0203c02:	cc250513          	addi	a0,a0,-830 # ffffffffc020a8c0 <default_pmm_manager+0xa28>
ffffffffc0203c06:	d8cfc0ef          	jal	ra,ffffffffc0200192 <cprintf>
                  break;
ffffffffc0203c0a:	bfe1                	j	ffffffffc0203be2 <swap_out+0xc6>
     for (i = 0; i != n; ++ i)
ffffffffc0203c0c:	4401                	li	s0,0
ffffffffc0203c0e:	bfd1                	j	ffffffffc0203be2 <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc0203c10:	00007697          	auipc	a3,0x7
ffffffffc0203c14:	ce068693          	addi	a3,a3,-800 # ffffffffc020a8f0 <default_pmm_manager+0xa58>
ffffffffc0203c18:	00006617          	auipc	a2,0x6
ffffffffc0203c1c:	b3860613          	addi	a2,a2,-1224 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0203c20:	06800593          	li	a1,104
ffffffffc0203c24:	00007517          	auipc	a0,0x7
ffffffffc0203c28:	a1450513          	addi	a0,a0,-1516 # ffffffffc020a638 <default_pmm_manager+0x7a0>
ffffffffc0203c2c:	85dfc0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0203c30 <swap_in>:
{
ffffffffc0203c30:	7179                	addi	sp,sp,-48
ffffffffc0203c32:	e84a                	sd	s2,16(sp)
ffffffffc0203c34:	892a                	mv	s2,a0
     struct Page *result = alloc_page();
ffffffffc0203c36:	4505                	li	a0,1
{
ffffffffc0203c38:	ec26                	sd	s1,24(sp)
ffffffffc0203c3a:	e44e                	sd	s3,8(sp)
ffffffffc0203c3c:	f406                	sd	ra,40(sp)
ffffffffc0203c3e:	f022                	sd	s0,32(sp)
ffffffffc0203c40:	84ae                	mv	s1,a1
ffffffffc0203c42:	89b2                	mv	s3,a2
     struct Page *result = alloc_page();
ffffffffc0203c44:	9fefe0ef          	jal	ra,ffffffffc0201e42 <alloc_pages>
     assert(result!=NULL);
ffffffffc0203c48:	c129                	beqz	a0,ffffffffc0203c8a <swap_in+0x5a>
     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
ffffffffc0203c4a:	842a                	mv	s0,a0
ffffffffc0203c4c:	01893503          	ld	a0,24(s2)
ffffffffc0203c50:	4601                	li	a2,0
ffffffffc0203c52:	85a6                	mv	a1,s1
ffffffffc0203c54:	afcfe0ef          	jal	ra,ffffffffc0201f50 <get_pte>
ffffffffc0203c58:	892a                	mv	s2,a0
     if ((r = swapfs_read((*ptep), result)) != 0)
ffffffffc0203c5a:	6108                	ld	a0,0(a0)
ffffffffc0203c5c:	85a2                	mv	a1,s0
ffffffffc0203c5e:	70f000ef          	jal	ra,ffffffffc0204b6c <swapfs_read>
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
ffffffffc0203c62:	00093583          	ld	a1,0(s2)
ffffffffc0203c66:	8626                	mv	a2,s1
ffffffffc0203c68:	00007517          	auipc	a0,0x7
ffffffffc0203c6c:	97050513          	addi	a0,a0,-1680 # ffffffffc020a5d8 <default_pmm_manager+0x740>
ffffffffc0203c70:	81a1                	srli	a1,a1,0x8
ffffffffc0203c72:	d20fc0ef          	jal	ra,ffffffffc0200192 <cprintf>
}
ffffffffc0203c76:	70a2                	ld	ra,40(sp)
     *ptr_result=result;
ffffffffc0203c78:	0089b023          	sd	s0,0(s3)
}
ffffffffc0203c7c:	7402                	ld	s0,32(sp)
ffffffffc0203c7e:	64e2                	ld	s1,24(sp)
ffffffffc0203c80:	6942                	ld	s2,16(sp)
ffffffffc0203c82:	69a2                	ld	s3,8(sp)
ffffffffc0203c84:	4501                	li	a0,0
ffffffffc0203c86:	6145                	addi	sp,sp,48
ffffffffc0203c88:	8082                	ret
     assert(result!=NULL);
ffffffffc0203c8a:	00007697          	auipc	a3,0x7
ffffffffc0203c8e:	93e68693          	addi	a3,a3,-1730 # ffffffffc020a5c8 <default_pmm_manager+0x730>
ffffffffc0203c92:	00006617          	auipc	a2,0x6
ffffffffc0203c96:	abe60613          	addi	a2,a2,-1346 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0203c9a:	07e00593          	li	a1,126
ffffffffc0203c9e:	00007517          	auipc	a0,0x7
ffffffffc0203ca2:	99a50513          	addi	a0,a0,-1638 # ffffffffc020a638 <default_pmm_manager+0x7a0>
ffffffffc0203ca6:	fe2fc0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0203caa <_fifo_init_mm>:
    elm->prev = elm->next = elm;
ffffffffc0203caa:	000c5797          	auipc	a5,0xc5
ffffffffc0203cae:	70e78793          	addi	a5,a5,1806 # ffffffffc02c93b8 <pra_list_head>
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{     
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
ffffffffc0203cb2:	f51c                	sd	a5,40(a0)
ffffffffc0203cb4:	e79c                	sd	a5,8(a5)
ffffffffc0203cb6:	e39c                	sd	a5,0(a5)
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
}
ffffffffc0203cb8:	4501                	li	a0,0
ffffffffc0203cba:	8082                	ret

ffffffffc0203cbc <_fifo_init>:

static int
_fifo_init(void)
{
    return 0;
}
ffffffffc0203cbc:	4501                	li	a0,0
ffffffffc0203cbe:	8082                	ret

ffffffffc0203cc0 <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc0203cc0:	4501                	li	a0,0
ffffffffc0203cc2:	8082                	ret

ffffffffc0203cc4 <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{ return 0; }
ffffffffc0203cc4:	4501                	li	a0,0
ffffffffc0203cc6:	8082                	ret

ffffffffc0203cc8 <_fifo_check_swap>:
_fifo_check_swap(void) {
ffffffffc0203cc8:	711d                	addi	sp,sp,-96
ffffffffc0203cca:	fc4e                	sd	s3,56(sp)
ffffffffc0203ccc:	f852                	sd	s4,48(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0203cce:	00007517          	auipc	a0,0x7
ffffffffc0203cd2:	c9250513          	addi	a0,a0,-878 # ffffffffc020a960 <default_pmm_manager+0xac8>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203cd6:	698d                	lui	s3,0x3
ffffffffc0203cd8:	4a31                	li	s4,12
_fifo_check_swap(void) {
ffffffffc0203cda:	e8a2                	sd	s0,80(sp)
ffffffffc0203cdc:	e4a6                	sd	s1,72(sp)
ffffffffc0203cde:	ec86                	sd	ra,88(sp)
ffffffffc0203ce0:	e0ca                	sd	s2,64(sp)
ffffffffc0203ce2:	f456                	sd	s5,40(sp)
ffffffffc0203ce4:	f05a                	sd	s6,32(sp)
ffffffffc0203ce6:	ec5e                	sd	s7,24(sp)
ffffffffc0203ce8:	e862                	sd	s8,16(sp)
ffffffffc0203cea:	e466                	sd	s9,8(sp)
    assert(pgfault_num==4);
ffffffffc0203cec:	000c5417          	auipc	s0,0xc5
ffffffffc0203cf0:	59040413          	addi	s0,s0,1424 # ffffffffc02c927c <pgfault_num>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0203cf4:	c9efc0ef          	jal	ra,ffffffffc0200192 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203cf8:	01498023          	sb	s4,0(s3) # 3000 <_binary_obj___user_faultread_out_size-0x6900>
    assert(pgfault_num==4);
ffffffffc0203cfc:	4004                	lw	s1,0(s0)
ffffffffc0203cfe:	4791                	li	a5,4
ffffffffc0203d00:	2481                	sext.w	s1,s1
ffffffffc0203d02:	14f49963          	bne	s1,a5,ffffffffc0203e54 <_fifo_check_swap+0x18c>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203d06:	00007517          	auipc	a0,0x7
ffffffffc0203d0a:	c9a50513          	addi	a0,a0,-870 # ffffffffc020a9a0 <default_pmm_manager+0xb08>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203d0e:	6a85                	lui	s5,0x1
ffffffffc0203d10:	4b29                	li	s6,10
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203d12:	c80fc0ef          	jal	ra,ffffffffc0200192 <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203d16:	016a8023          	sb	s6,0(s5) # 1000 <_binary_obj___user_faultread_out_size-0x8900>
    assert(pgfault_num==4);
ffffffffc0203d1a:	00042903          	lw	s2,0(s0)
ffffffffc0203d1e:	2901                	sext.w	s2,s2
ffffffffc0203d20:	2a991a63          	bne	s2,s1,ffffffffc0203fd4 <_fifo_check_swap+0x30c>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0203d24:	00007517          	auipc	a0,0x7
ffffffffc0203d28:	ca450513          	addi	a0,a0,-860 # ffffffffc020a9c8 <default_pmm_manager+0xb30>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203d2c:	6b91                	lui	s7,0x4
ffffffffc0203d2e:	4c35                	li	s8,13
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0203d30:	c62fc0ef          	jal	ra,ffffffffc0200192 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203d34:	018b8023          	sb	s8,0(s7) # 4000 <_binary_obj___user_faultread_out_size-0x5900>
    assert(pgfault_num==4);
ffffffffc0203d38:	4004                	lw	s1,0(s0)
ffffffffc0203d3a:	2481                	sext.w	s1,s1
ffffffffc0203d3c:	27249c63          	bne	s1,s2,ffffffffc0203fb4 <_fifo_check_swap+0x2ec>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203d40:	00007517          	auipc	a0,0x7
ffffffffc0203d44:	cb050513          	addi	a0,a0,-848 # ffffffffc020a9f0 <default_pmm_manager+0xb58>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203d48:	6909                	lui	s2,0x2
ffffffffc0203d4a:	4cad                	li	s9,11
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203d4c:	c46fc0ef          	jal	ra,ffffffffc0200192 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203d50:	01990023          	sb	s9,0(s2) # 2000 <_binary_obj___user_faultread_out_size-0x7900>
    assert(pgfault_num==4);
ffffffffc0203d54:	401c                	lw	a5,0(s0)
ffffffffc0203d56:	2781                	sext.w	a5,a5
ffffffffc0203d58:	22979e63          	bne	a5,s1,ffffffffc0203f94 <_fifo_check_swap+0x2cc>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc0203d5c:	00007517          	auipc	a0,0x7
ffffffffc0203d60:	cbc50513          	addi	a0,a0,-836 # ffffffffc020aa18 <default_pmm_manager+0xb80>
ffffffffc0203d64:	c2efc0ef          	jal	ra,ffffffffc0200192 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0203d68:	6795                	lui	a5,0x5
ffffffffc0203d6a:	4739                	li	a4,14
ffffffffc0203d6c:	00e78023          	sb	a4,0(a5) # 5000 <_binary_obj___user_faultread_out_size-0x4900>
    assert(pgfault_num==5);
ffffffffc0203d70:	4004                	lw	s1,0(s0)
ffffffffc0203d72:	4795                	li	a5,5
ffffffffc0203d74:	2481                	sext.w	s1,s1
ffffffffc0203d76:	1ef49f63          	bne	s1,a5,ffffffffc0203f74 <_fifo_check_swap+0x2ac>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203d7a:	00007517          	auipc	a0,0x7
ffffffffc0203d7e:	c7650513          	addi	a0,a0,-906 # ffffffffc020a9f0 <default_pmm_manager+0xb58>
ffffffffc0203d82:	c10fc0ef          	jal	ra,ffffffffc0200192 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203d86:	01990023          	sb	s9,0(s2)
    assert(pgfault_num==5);
ffffffffc0203d8a:	401c                	lw	a5,0(s0)
ffffffffc0203d8c:	2781                	sext.w	a5,a5
ffffffffc0203d8e:	1c979363          	bne	a5,s1,ffffffffc0203f54 <_fifo_check_swap+0x28c>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203d92:	00007517          	auipc	a0,0x7
ffffffffc0203d96:	c0e50513          	addi	a0,a0,-1010 # ffffffffc020a9a0 <default_pmm_manager+0xb08>
ffffffffc0203d9a:	bf8fc0ef          	jal	ra,ffffffffc0200192 <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203d9e:	016a8023          	sb	s6,0(s5)
    assert(pgfault_num==6);
ffffffffc0203da2:	401c                	lw	a5,0(s0)
ffffffffc0203da4:	4719                	li	a4,6
ffffffffc0203da6:	2781                	sext.w	a5,a5
ffffffffc0203da8:	18e79663          	bne	a5,a4,ffffffffc0203f34 <_fifo_check_swap+0x26c>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203dac:	00007517          	auipc	a0,0x7
ffffffffc0203db0:	c4450513          	addi	a0,a0,-956 # ffffffffc020a9f0 <default_pmm_manager+0xb58>
ffffffffc0203db4:	bdefc0ef          	jal	ra,ffffffffc0200192 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203db8:	01990023          	sb	s9,0(s2)
    assert(pgfault_num==7);
ffffffffc0203dbc:	401c                	lw	a5,0(s0)
ffffffffc0203dbe:	471d                	li	a4,7
ffffffffc0203dc0:	2781                	sext.w	a5,a5
ffffffffc0203dc2:	14e79963          	bne	a5,a4,ffffffffc0203f14 <_fifo_check_swap+0x24c>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0203dc6:	00007517          	auipc	a0,0x7
ffffffffc0203dca:	b9a50513          	addi	a0,a0,-1126 # ffffffffc020a960 <default_pmm_manager+0xac8>
ffffffffc0203dce:	bc4fc0ef          	jal	ra,ffffffffc0200192 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203dd2:	01498023          	sb	s4,0(s3)
    assert(pgfault_num==8);
ffffffffc0203dd6:	401c                	lw	a5,0(s0)
ffffffffc0203dd8:	4721                	li	a4,8
ffffffffc0203dda:	2781                	sext.w	a5,a5
ffffffffc0203ddc:	10e79c63          	bne	a5,a4,ffffffffc0203ef4 <_fifo_check_swap+0x22c>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0203de0:	00007517          	auipc	a0,0x7
ffffffffc0203de4:	be850513          	addi	a0,a0,-1048 # ffffffffc020a9c8 <default_pmm_manager+0xb30>
ffffffffc0203de8:	baafc0ef          	jal	ra,ffffffffc0200192 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203dec:	018b8023          	sb	s8,0(s7)
    assert(pgfault_num==9);
ffffffffc0203df0:	401c                	lw	a5,0(s0)
ffffffffc0203df2:	4725                	li	a4,9
ffffffffc0203df4:	2781                	sext.w	a5,a5
ffffffffc0203df6:	0ce79f63          	bne	a5,a4,ffffffffc0203ed4 <_fifo_check_swap+0x20c>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc0203dfa:	00007517          	auipc	a0,0x7
ffffffffc0203dfe:	c1e50513          	addi	a0,a0,-994 # ffffffffc020aa18 <default_pmm_manager+0xb80>
ffffffffc0203e02:	b90fc0ef          	jal	ra,ffffffffc0200192 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0203e06:	6795                	lui	a5,0x5
ffffffffc0203e08:	4739                	li	a4,14
ffffffffc0203e0a:	00e78023          	sb	a4,0(a5) # 5000 <_binary_obj___user_faultread_out_size-0x4900>
    assert(pgfault_num==10);
ffffffffc0203e0e:	4004                	lw	s1,0(s0)
ffffffffc0203e10:	47a9                	li	a5,10
ffffffffc0203e12:	2481                	sext.w	s1,s1
ffffffffc0203e14:	0af49063          	bne	s1,a5,ffffffffc0203eb4 <_fifo_check_swap+0x1ec>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203e18:	00007517          	auipc	a0,0x7
ffffffffc0203e1c:	b8850513          	addi	a0,a0,-1144 # ffffffffc020a9a0 <default_pmm_manager+0xb08>
ffffffffc0203e20:	b72fc0ef          	jal	ra,ffffffffc0200192 <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0203e24:	6785                	lui	a5,0x1
ffffffffc0203e26:	0007c783          	lbu	a5,0(a5) # 1000 <_binary_obj___user_faultread_out_size-0x8900>
ffffffffc0203e2a:	06979563          	bne	a5,s1,ffffffffc0203e94 <_fifo_check_swap+0x1cc>
    assert(pgfault_num==11);
ffffffffc0203e2e:	401c                	lw	a5,0(s0)
ffffffffc0203e30:	472d                	li	a4,11
ffffffffc0203e32:	2781                	sext.w	a5,a5
ffffffffc0203e34:	04e79063          	bne	a5,a4,ffffffffc0203e74 <_fifo_check_swap+0x1ac>
}
ffffffffc0203e38:	60e6                	ld	ra,88(sp)
ffffffffc0203e3a:	6446                	ld	s0,80(sp)
ffffffffc0203e3c:	64a6                	ld	s1,72(sp)
ffffffffc0203e3e:	6906                	ld	s2,64(sp)
ffffffffc0203e40:	79e2                	ld	s3,56(sp)
ffffffffc0203e42:	7a42                	ld	s4,48(sp)
ffffffffc0203e44:	7aa2                	ld	s5,40(sp)
ffffffffc0203e46:	7b02                	ld	s6,32(sp)
ffffffffc0203e48:	6be2                	ld	s7,24(sp)
ffffffffc0203e4a:	6c42                	ld	s8,16(sp)
ffffffffc0203e4c:	6ca2                	ld	s9,8(sp)
ffffffffc0203e4e:	4501                	li	a0,0
ffffffffc0203e50:	6125                	addi	sp,sp,96
ffffffffc0203e52:	8082                	ret
    assert(pgfault_num==4);
ffffffffc0203e54:	00007697          	auipc	a3,0x7
ffffffffc0203e58:	9ac68693          	addi	a3,a3,-1620 # ffffffffc020a800 <default_pmm_manager+0x968>
ffffffffc0203e5c:	00006617          	auipc	a2,0x6
ffffffffc0203e60:	8f460613          	addi	a2,a2,-1804 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0203e64:	05100593          	li	a1,81
ffffffffc0203e68:	00007517          	auipc	a0,0x7
ffffffffc0203e6c:	b2050513          	addi	a0,a0,-1248 # ffffffffc020a988 <default_pmm_manager+0xaf0>
ffffffffc0203e70:	e18fc0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(pgfault_num==11);
ffffffffc0203e74:	00007697          	auipc	a3,0x7
ffffffffc0203e78:	c5468693          	addi	a3,a3,-940 # ffffffffc020aac8 <default_pmm_manager+0xc30>
ffffffffc0203e7c:	00006617          	auipc	a2,0x6
ffffffffc0203e80:	8d460613          	addi	a2,a2,-1836 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0203e84:	07300593          	li	a1,115
ffffffffc0203e88:	00007517          	auipc	a0,0x7
ffffffffc0203e8c:	b0050513          	addi	a0,a0,-1280 # ffffffffc020a988 <default_pmm_manager+0xaf0>
ffffffffc0203e90:	df8fc0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0203e94:	00007697          	auipc	a3,0x7
ffffffffc0203e98:	c0c68693          	addi	a3,a3,-1012 # ffffffffc020aaa0 <default_pmm_manager+0xc08>
ffffffffc0203e9c:	00006617          	auipc	a2,0x6
ffffffffc0203ea0:	8b460613          	addi	a2,a2,-1868 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0203ea4:	07100593          	li	a1,113
ffffffffc0203ea8:	00007517          	auipc	a0,0x7
ffffffffc0203eac:	ae050513          	addi	a0,a0,-1312 # ffffffffc020a988 <default_pmm_manager+0xaf0>
ffffffffc0203eb0:	dd8fc0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(pgfault_num==10);
ffffffffc0203eb4:	00007697          	auipc	a3,0x7
ffffffffc0203eb8:	bdc68693          	addi	a3,a3,-1060 # ffffffffc020aa90 <default_pmm_manager+0xbf8>
ffffffffc0203ebc:	00006617          	auipc	a2,0x6
ffffffffc0203ec0:	89460613          	addi	a2,a2,-1900 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0203ec4:	06f00593          	li	a1,111
ffffffffc0203ec8:	00007517          	auipc	a0,0x7
ffffffffc0203ecc:	ac050513          	addi	a0,a0,-1344 # ffffffffc020a988 <default_pmm_manager+0xaf0>
ffffffffc0203ed0:	db8fc0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(pgfault_num==9);
ffffffffc0203ed4:	00007697          	auipc	a3,0x7
ffffffffc0203ed8:	bac68693          	addi	a3,a3,-1108 # ffffffffc020aa80 <default_pmm_manager+0xbe8>
ffffffffc0203edc:	00006617          	auipc	a2,0x6
ffffffffc0203ee0:	87460613          	addi	a2,a2,-1932 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0203ee4:	06c00593          	li	a1,108
ffffffffc0203ee8:	00007517          	auipc	a0,0x7
ffffffffc0203eec:	aa050513          	addi	a0,a0,-1376 # ffffffffc020a988 <default_pmm_manager+0xaf0>
ffffffffc0203ef0:	d98fc0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(pgfault_num==8);
ffffffffc0203ef4:	00007697          	auipc	a3,0x7
ffffffffc0203ef8:	b7c68693          	addi	a3,a3,-1156 # ffffffffc020aa70 <default_pmm_manager+0xbd8>
ffffffffc0203efc:	00006617          	auipc	a2,0x6
ffffffffc0203f00:	85460613          	addi	a2,a2,-1964 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0203f04:	06900593          	li	a1,105
ffffffffc0203f08:	00007517          	auipc	a0,0x7
ffffffffc0203f0c:	a8050513          	addi	a0,a0,-1408 # ffffffffc020a988 <default_pmm_manager+0xaf0>
ffffffffc0203f10:	d78fc0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(pgfault_num==7);
ffffffffc0203f14:	00007697          	auipc	a3,0x7
ffffffffc0203f18:	b4c68693          	addi	a3,a3,-1204 # ffffffffc020aa60 <default_pmm_manager+0xbc8>
ffffffffc0203f1c:	00006617          	auipc	a2,0x6
ffffffffc0203f20:	83460613          	addi	a2,a2,-1996 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0203f24:	06600593          	li	a1,102
ffffffffc0203f28:	00007517          	auipc	a0,0x7
ffffffffc0203f2c:	a6050513          	addi	a0,a0,-1440 # ffffffffc020a988 <default_pmm_manager+0xaf0>
ffffffffc0203f30:	d58fc0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(pgfault_num==6);
ffffffffc0203f34:	00007697          	auipc	a3,0x7
ffffffffc0203f38:	b1c68693          	addi	a3,a3,-1252 # ffffffffc020aa50 <default_pmm_manager+0xbb8>
ffffffffc0203f3c:	00006617          	auipc	a2,0x6
ffffffffc0203f40:	81460613          	addi	a2,a2,-2028 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0203f44:	06300593          	li	a1,99
ffffffffc0203f48:	00007517          	auipc	a0,0x7
ffffffffc0203f4c:	a4050513          	addi	a0,a0,-1472 # ffffffffc020a988 <default_pmm_manager+0xaf0>
ffffffffc0203f50:	d38fc0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(pgfault_num==5);
ffffffffc0203f54:	00007697          	auipc	a3,0x7
ffffffffc0203f58:	aec68693          	addi	a3,a3,-1300 # ffffffffc020aa40 <default_pmm_manager+0xba8>
ffffffffc0203f5c:	00005617          	auipc	a2,0x5
ffffffffc0203f60:	7f460613          	addi	a2,a2,2036 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0203f64:	06000593          	li	a1,96
ffffffffc0203f68:	00007517          	auipc	a0,0x7
ffffffffc0203f6c:	a2050513          	addi	a0,a0,-1504 # ffffffffc020a988 <default_pmm_manager+0xaf0>
ffffffffc0203f70:	d18fc0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(pgfault_num==5);
ffffffffc0203f74:	00007697          	auipc	a3,0x7
ffffffffc0203f78:	acc68693          	addi	a3,a3,-1332 # ffffffffc020aa40 <default_pmm_manager+0xba8>
ffffffffc0203f7c:	00005617          	auipc	a2,0x5
ffffffffc0203f80:	7d460613          	addi	a2,a2,2004 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0203f84:	05d00593          	li	a1,93
ffffffffc0203f88:	00007517          	auipc	a0,0x7
ffffffffc0203f8c:	a0050513          	addi	a0,a0,-1536 # ffffffffc020a988 <default_pmm_manager+0xaf0>
ffffffffc0203f90:	cf8fc0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(pgfault_num==4);
ffffffffc0203f94:	00007697          	auipc	a3,0x7
ffffffffc0203f98:	86c68693          	addi	a3,a3,-1940 # ffffffffc020a800 <default_pmm_manager+0x968>
ffffffffc0203f9c:	00005617          	auipc	a2,0x5
ffffffffc0203fa0:	7b460613          	addi	a2,a2,1972 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0203fa4:	05a00593          	li	a1,90
ffffffffc0203fa8:	00007517          	auipc	a0,0x7
ffffffffc0203fac:	9e050513          	addi	a0,a0,-1568 # ffffffffc020a988 <default_pmm_manager+0xaf0>
ffffffffc0203fb0:	cd8fc0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(pgfault_num==4);
ffffffffc0203fb4:	00007697          	auipc	a3,0x7
ffffffffc0203fb8:	84c68693          	addi	a3,a3,-1972 # ffffffffc020a800 <default_pmm_manager+0x968>
ffffffffc0203fbc:	00005617          	auipc	a2,0x5
ffffffffc0203fc0:	79460613          	addi	a2,a2,1940 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0203fc4:	05700593          	li	a1,87
ffffffffc0203fc8:	00007517          	auipc	a0,0x7
ffffffffc0203fcc:	9c050513          	addi	a0,a0,-1600 # ffffffffc020a988 <default_pmm_manager+0xaf0>
ffffffffc0203fd0:	cb8fc0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(pgfault_num==4);
ffffffffc0203fd4:	00007697          	auipc	a3,0x7
ffffffffc0203fd8:	82c68693          	addi	a3,a3,-2004 # ffffffffc020a800 <default_pmm_manager+0x968>
ffffffffc0203fdc:	00005617          	auipc	a2,0x5
ffffffffc0203fe0:	77460613          	addi	a2,a2,1908 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0203fe4:	05400593          	li	a1,84
ffffffffc0203fe8:	00007517          	auipc	a0,0x7
ffffffffc0203fec:	9a050513          	addi	a0,a0,-1632 # ffffffffc020a988 <default_pmm_manager+0xaf0>
ffffffffc0203ff0:	c98fc0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0203ff4 <_fifo_swap_out_victim>:
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc0203ff4:	751c                	ld	a5,40(a0)
{
ffffffffc0203ff6:	1141                	addi	sp,sp,-16
ffffffffc0203ff8:	e406                	sd	ra,8(sp)
         assert(head != NULL);
ffffffffc0203ffa:	cf91                	beqz	a5,ffffffffc0204016 <_fifo_swap_out_victim+0x22>
     assert(in_tick==0);
ffffffffc0203ffc:	ee0d                	bnez	a2,ffffffffc0204036 <_fifo_swap_out_victim+0x42>
    return listelm->next;
ffffffffc0203ffe:	679c                	ld	a5,8(a5)
}
ffffffffc0204000:	60a2                	ld	ra,8(sp)
ffffffffc0204002:	4501                	li	a0,0
    __list_del(listelm->prev, listelm->next);
ffffffffc0204004:	6394                	ld	a3,0(a5)
ffffffffc0204006:	6798                	ld	a4,8(a5)
    *ptr_page = le2page(entry, pra_page_link);
ffffffffc0204008:	fd878793          	addi	a5,a5,-40
    prev->next = next;
ffffffffc020400c:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc020400e:	e314                	sd	a3,0(a4)
ffffffffc0204010:	e19c                	sd	a5,0(a1)
}
ffffffffc0204012:	0141                	addi	sp,sp,16
ffffffffc0204014:	8082                	ret
         assert(head != NULL);
ffffffffc0204016:	00007697          	auipc	a3,0x7
ffffffffc020401a:	ae268693          	addi	a3,a3,-1310 # ffffffffc020aaf8 <default_pmm_manager+0xc60>
ffffffffc020401e:	00005617          	auipc	a2,0x5
ffffffffc0204022:	73260613          	addi	a2,a2,1842 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0204026:	04100593          	li	a1,65
ffffffffc020402a:	00007517          	auipc	a0,0x7
ffffffffc020402e:	95e50513          	addi	a0,a0,-1698 # ffffffffc020a988 <default_pmm_manager+0xaf0>
ffffffffc0204032:	c56fc0ef          	jal	ra,ffffffffc0200488 <__panic>
     assert(in_tick==0);
ffffffffc0204036:	00007697          	auipc	a3,0x7
ffffffffc020403a:	ad268693          	addi	a3,a3,-1326 # ffffffffc020ab08 <default_pmm_manager+0xc70>
ffffffffc020403e:	00005617          	auipc	a2,0x5
ffffffffc0204042:	71260613          	addi	a2,a2,1810 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0204046:	04200593          	li	a1,66
ffffffffc020404a:	00007517          	auipc	a0,0x7
ffffffffc020404e:	93e50513          	addi	a0,a0,-1730 # ffffffffc020a988 <default_pmm_manager+0xaf0>
ffffffffc0204052:	c36fc0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0204056 <_fifo_map_swappable>:
    list_entry_t *entry=&(page->pra_page_link);
ffffffffc0204056:	02860713          	addi	a4,a2,40
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc020405a:	751c                	ld	a5,40(a0)
    assert(entry != NULL && head != NULL);
ffffffffc020405c:	cb09                	beqz	a4,ffffffffc020406e <_fifo_map_swappable+0x18>
ffffffffc020405e:	cb81                	beqz	a5,ffffffffc020406e <_fifo_map_swappable+0x18>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0204060:	6394                	ld	a3,0(a5)
    prev->next = next->prev = elm;
ffffffffc0204062:	e398                	sd	a4,0(a5)
}
ffffffffc0204064:	4501                	li	a0,0
ffffffffc0204066:	e698                	sd	a4,8(a3)
    elm->next = next;
ffffffffc0204068:	fa1c                	sd	a5,48(a2)
    elm->prev = prev;
ffffffffc020406a:	f614                	sd	a3,40(a2)
ffffffffc020406c:	8082                	ret
{
ffffffffc020406e:	1141                	addi	sp,sp,-16
    assert(entry != NULL && head != NULL);
ffffffffc0204070:	00007697          	auipc	a3,0x7
ffffffffc0204074:	a6868693          	addi	a3,a3,-1432 # ffffffffc020aad8 <default_pmm_manager+0xc40>
ffffffffc0204078:	00005617          	auipc	a2,0x5
ffffffffc020407c:	6d860613          	addi	a2,a2,1752 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0204080:	03200593          	li	a1,50
ffffffffc0204084:	00007517          	auipc	a0,0x7
ffffffffc0204088:	90450513          	addi	a0,a0,-1788 # ffffffffc020a988 <default_pmm_manager+0xaf0>
{
ffffffffc020408c:	e406                	sd	ra,8(sp)
    assert(entry != NULL && head != NULL);
ffffffffc020408e:	bfafc0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0204092 <check_vma_overlap.isra.0.part.1>:
}


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0204092:	1141                	addi	sp,sp,-16
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc0204094:	00007697          	auipc	a3,0x7
ffffffffc0204098:	a9c68693          	addi	a3,a3,-1380 # ffffffffc020ab30 <default_pmm_manager+0xc98>
ffffffffc020409c:	00005617          	auipc	a2,0x5
ffffffffc02040a0:	6b460613          	addi	a2,a2,1716 # ffffffffc0209750 <commands+0x4c0>
ffffffffc02040a4:	06d00593          	li	a1,109
ffffffffc02040a8:	00007517          	auipc	a0,0x7
ffffffffc02040ac:	aa850513          	addi	a0,a0,-1368 # ffffffffc020ab50 <default_pmm_manager+0xcb8>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc02040b0:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc02040b2:	bd6fc0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc02040b6 <mm_create>:
mm_create(void) {
ffffffffc02040b6:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc02040b8:	04000513          	li	a0,64
mm_create(void) {
ffffffffc02040bc:	e022                	sd	s0,0(sp)
ffffffffc02040be:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc02040c0:	b87fd0ef          	jal	ra,ffffffffc0201c46 <kmalloc>
ffffffffc02040c4:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc02040c6:	c515                	beqz	a0,ffffffffc02040f2 <mm_create+0x3c>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc02040c8:	000c5797          	auipc	a5,0xc5
ffffffffc02040cc:	1b078793          	addi	a5,a5,432 # ffffffffc02c9278 <swap_init_ok>
ffffffffc02040d0:	439c                	lw	a5,0(a5)
    elm->prev = elm->next = elm;
ffffffffc02040d2:	e408                	sd	a0,8(s0)
ffffffffc02040d4:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;
ffffffffc02040d6:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc02040da:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc02040de:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc02040e2:	2781                	sext.w	a5,a5
ffffffffc02040e4:	ef81                	bnez	a5,ffffffffc02040fc <mm_create+0x46>
        else mm->sm_priv = NULL;
ffffffffc02040e6:	02053423          	sd	zero,40(a0)
    return mm->mm_count;
}

static inline void
set_mm_count(struct mm_struct *mm, int val) {
    mm->mm_count = val;
ffffffffc02040ea:	02042823          	sw	zero,48(s0)

typedef volatile bool lock_t;

static inline void
lock_init(lock_t *lock) {
    *lock = 0;
ffffffffc02040ee:	02043c23          	sd	zero,56(s0)
}
ffffffffc02040f2:	8522                	mv	a0,s0
ffffffffc02040f4:	60a2                	ld	ra,8(sp)
ffffffffc02040f6:	6402                	ld	s0,0(sp)
ffffffffc02040f8:	0141                	addi	sp,sp,16
ffffffffc02040fa:	8082                	ret
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc02040fc:	a01ff0ef          	jal	ra,ffffffffc0203afc <swap_init_mm>
ffffffffc0204100:	b7ed                	j	ffffffffc02040ea <mm_create+0x34>

ffffffffc0204102 <vma_create>:
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc0204102:	1101                	addi	sp,sp,-32
ffffffffc0204104:	e04a                	sd	s2,0(sp)
ffffffffc0204106:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0204108:	03000513          	li	a0,48
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc020410c:	e822                	sd	s0,16(sp)
ffffffffc020410e:	e426                	sd	s1,8(sp)
ffffffffc0204110:	ec06                	sd	ra,24(sp)
ffffffffc0204112:	84ae                	mv	s1,a1
ffffffffc0204114:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0204116:	b31fd0ef          	jal	ra,ffffffffc0201c46 <kmalloc>
    if (vma != NULL) {
ffffffffc020411a:	c509                	beqz	a0,ffffffffc0204124 <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc020411c:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc0204120:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0204122:	cd00                	sw	s0,24(a0)
}
ffffffffc0204124:	60e2                	ld	ra,24(sp)
ffffffffc0204126:	6442                	ld	s0,16(sp)
ffffffffc0204128:	64a2                	ld	s1,8(sp)
ffffffffc020412a:	6902                	ld	s2,0(sp)
ffffffffc020412c:	6105                	addi	sp,sp,32
ffffffffc020412e:	8082                	ret

ffffffffc0204130 <find_vma>:
    if (mm != NULL) {
ffffffffc0204130:	c51d                	beqz	a0,ffffffffc020415e <find_vma+0x2e>
        vma = mm->mmap_cache;
ffffffffc0204132:	691c                	ld	a5,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0204134:	c781                	beqz	a5,ffffffffc020413c <find_vma+0xc>
ffffffffc0204136:	6798                	ld	a4,8(a5)
ffffffffc0204138:	02e5f663          	bleu	a4,a1,ffffffffc0204164 <find_vma+0x34>
                list_entry_t *list = &(mm->mmap_list), *le = list;
ffffffffc020413c:	87aa                	mv	a5,a0
    return listelm->next;
ffffffffc020413e:	679c                	ld	a5,8(a5)
                while ((le = list_next(le)) != list) {
ffffffffc0204140:	00f50f63          	beq	a0,a5,ffffffffc020415e <find_vma+0x2e>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
ffffffffc0204144:	fe87b703          	ld	a4,-24(a5)
ffffffffc0204148:	fee5ebe3          	bltu	a1,a4,ffffffffc020413e <find_vma+0xe>
ffffffffc020414c:	ff07b703          	ld	a4,-16(a5)
ffffffffc0204150:	fee5f7e3          	bleu	a4,a1,ffffffffc020413e <find_vma+0xe>
                    vma = le2vma(le, list_link);
ffffffffc0204154:	1781                	addi	a5,a5,-32
        if (vma != NULL) {
ffffffffc0204156:	c781                	beqz	a5,ffffffffc020415e <find_vma+0x2e>
            mm->mmap_cache = vma;
ffffffffc0204158:	e91c                	sd	a5,16(a0)
}
ffffffffc020415a:	853e                	mv	a0,a5
ffffffffc020415c:	8082                	ret
    struct vma_struct *vma = NULL;
ffffffffc020415e:	4781                	li	a5,0
}
ffffffffc0204160:	853e                	mv	a0,a5
ffffffffc0204162:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0204164:	6b98                	ld	a4,16(a5)
ffffffffc0204166:	fce5fbe3          	bleu	a4,a1,ffffffffc020413c <find_vma+0xc>
            mm->mmap_cache = vma;
ffffffffc020416a:	e91c                	sd	a5,16(a0)
    return vma;
ffffffffc020416c:	b7fd                	j	ffffffffc020415a <find_vma+0x2a>

ffffffffc020416e <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    assert(vma->vm_start < vma->vm_end);
ffffffffc020416e:	6590                	ld	a2,8(a1)
ffffffffc0204170:	0105b803          	ld	a6,16(a1) # 1010 <_binary_obj___user_faultread_out_size-0x88f0>
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
ffffffffc0204174:	1141                	addi	sp,sp,-16
ffffffffc0204176:	e406                	sd	ra,8(sp)
ffffffffc0204178:	872a                	mv	a4,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc020417a:	01066863          	bltu	a2,a6,ffffffffc020418a <insert_vma_struct+0x1c>
ffffffffc020417e:	a8b9                	j	ffffffffc02041dc <insert_vma_struct+0x6e>
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc0204180:	fe87b683          	ld	a3,-24(a5)
ffffffffc0204184:	04d66763          	bltu	a2,a3,ffffffffc02041d2 <insert_vma_struct+0x64>
ffffffffc0204188:	873e                	mv	a4,a5
ffffffffc020418a:	671c                	ld	a5,8(a4)
        while ((le = list_next(le)) != list) {
ffffffffc020418c:	fef51ae3          	bne	a0,a5,ffffffffc0204180 <insert_vma_struct+0x12>
        }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list) {
ffffffffc0204190:	02a70463          	beq	a4,a0,ffffffffc02041b8 <insert_vma_struct+0x4a>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc0204194:	ff073683          	ld	a3,-16(a4)
    assert(prev->vm_start < prev->vm_end);
ffffffffc0204198:	fe873883          	ld	a7,-24(a4)
ffffffffc020419c:	08d8f063          	bleu	a3,a7,ffffffffc020421c <insert_vma_struct+0xae>
    assert(prev->vm_end <= next->vm_start);
ffffffffc02041a0:	04d66e63          	bltu	a2,a3,ffffffffc02041fc <insert_vma_struct+0x8e>
    }
    if (le_next != list) {
ffffffffc02041a4:	00f50a63          	beq	a0,a5,ffffffffc02041b8 <insert_vma_struct+0x4a>
ffffffffc02041a8:	fe87b683          	ld	a3,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc02041ac:	0506e863          	bltu	a3,a6,ffffffffc02041fc <insert_vma_struct+0x8e>
    assert(next->vm_start < next->vm_end);
ffffffffc02041b0:	ff07b603          	ld	a2,-16(a5)
ffffffffc02041b4:	02c6f263          	bleu	a2,a3,ffffffffc02041d8 <insert_vma_struct+0x6a>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count ++;
ffffffffc02041b8:	5114                	lw	a3,32(a0)
    vma->vm_mm = mm;
ffffffffc02041ba:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc02041bc:	02058613          	addi	a2,a1,32
    prev->next = next->prev = elm;
ffffffffc02041c0:	e390                	sd	a2,0(a5)
ffffffffc02041c2:	e710                	sd	a2,8(a4)
}
ffffffffc02041c4:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc02041c6:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc02041c8:	f198                	sd	a4,32(a1)
    mm->map_count ++;
ffffffffc02041ca:	2685                	addiw	a3,a3,1
ffffffffc02041cc:	d114                	sw	a3,32(a0)
}
ffffffffc02041ce:	0141                	addi	sp,sp,16
ffffffffc02041d0:	8082                	ret
    if (le_prev != list) {
ffffffffc02041d2:	fca711e3          	bne	a4,a0,ffffffffc0204194 <insert_vma_struct+0x26>
ffffffffc02041d6:	bfd9                	j	ffffffffc02041ac <insert_vma_struct+0x3e>
ffffffffc02041d8:	ebbff0ef          	jal	ra,ffffffffc0204092 <check_vma_overlap.isra.0.part.1>
    assert(vma->vm_start < vma->vm_end);
ffffffffc02041dc:	00007697          	auipc	a3,0x7
ffffffffc02041e0:	a8468693          	addi	a3,a3,-1404 # ffffffffc020ac60 <default_pmm_manager+0xdc8>
ffffffffc02041e4:	00005617          	auipc	a2,0x5
ffffffffc02041e8:	56c60613          	addi	a2,a2,1388 # ffffffffc0209750 <commands+0x4c0>
ffffffffc02041ec:	07400593          	li	a1,116
ffffffffc02041f0:	00007517          	auipc	a0,0x7
ffffffffc02041f4:	96050513          	addi	a0,a0,-1696 # ffffffffc020ab50 <default_pmm_manager+0xcb8>
ffffffffc02041f8:	a90fc0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc02041fc:	00007697          	auipc	a3,0x7
ffffffffc0204200:	aa468693          	addi	a3,a3,-1372 # ffffffffc020aca0 <default_pmm_manager+0xe08>
ffffffffc0204204:	00005617          	auipc	a2,0x5
ffffffffc0204208:	54c60613          	addi	a2,a2,1356 # ffffffffc0209750 <commands+0x4c0>
ffffffffc020420c:	06c00593          	li	a1,108
ffffffffc0204210:	00007517          	auipc	a0,0x7
ffffffffc0204214:	94050513          	addi	a0,a0,-1728 # ffffffffc020ab50 <default_pmm_manager+0xcb8>
ffffffffc0204218:	a70fc0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc020421c:	00007697          	auipc	a3,0x7
ffffffffc0204220:	a6468693          	addi	a3,a3,-1436 # ffffffffc020ac80 <default_pmm_manager+0xde8>
ffffffffc0204224:	00005617          	auipc	a2,0x5
ffffffffc0204228:	52c60613          	addi	a2,a2,1324 # ffffffffc0209750 <commands+0x4c0>
ffffffffc020422c:	06b00593          	li	a1,107
ffffffffc0204230:	00007517          	auipc	a0,0x7
ffffffffc0204234:	92050513          	addi	a0,a0,-1760 # ffffffffc020ab50 <default_pmm_manager+0xcb8>
ffffffffc0204238:	a50fc0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc020423c <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
    assert(mm_count(mm) == 0);
ffffffffc020423c:	591c                	lw	a5,48(a0)
mm_destroy(struct mm_struct *mm) {
ffffffffc020423e:	1141                	addi	sp,sp,-16
ffffffffc0204240:	e406                	sd	ra,8(sp)
ffffffffc0204242:	e022                	sd	s0,0(sp)
    assert(mm_count(mm) == 0);
ffffffffc0204244:	e78d                	bnez	a5,ffffffffc020426e <mm_destroy+0x32>
ffffffffc0204246:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc0204248:	6508                	ld	a0,8(a0)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
ffffffffc020424a:	00a40c63          	beq	s0,a0,ffffffffc0204262 <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc020424e:	6118                	ld	a4,0(a0)
ffffffffc0204250:	651c                	ld	a5,8(a0)
        list_del(le);
        kfree(le2vma(le, list_link));  //kfree vma        
ffffffffc0204252:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc0204254:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0204256:	e398                	sd	a4,0(a5)
ffffffffc0204258:	aabfd0ef          	jal	ra,ffffffffc0201d02 <kfree>
    return listelm->next;
ffffffffc020425c:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc020425e:	fea418e3          	bne	s0,a0,ffffffffc020424e <mm_destroy+0x12>
    }
    kfree(mm); //kfree mm
ffffffffc0204262:	8522                	mv	a0,s0
    mm=NULL;
}
ffffffffc0204264:	6402                	ld	s0,0(sp)
ffffffffc0204266:	60a2                	ld	ra,8(sp)
ffffffffc0204268:	0141                	addi	sp,sp,16
    kfree(mm); //kfree mm
ffffffffc020426a:	a99fd06f          	j	ffffffffc0201d02 <kfree>
    assert(mm_count(mm) == 0);
ffffffffc020426e:	00007697          	auipc	a3,0x7
ffffffffc0204272:	a5268693          	addi	a3,a3,-1454 # ffffffffc020acc0 <default_pmm_manager+0xe28>
ffffffffc0204276:	00005617          	auipc	a2,0x5
ffffffffc020427a:	4da60613          	addi	a2,a2,1242 # ffffffffc0209750 <commands+0x4c0>
ffffffffc020427e:	09400593          	li	a1,148
ffffffffc0204282:	00007517          	auipc	a0,0x7
ffffffffc0204286:	8ce50513          	addi	a0,a0,-1842 # ffffffffc020ab50 <default_pmm_manager+0xcb8>
ffffffffc020428a:	9fefc0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc020428e <mm_map>:

int
mm_map(struct mm_struct *mm, uintptr_t addr, size_t len, uint32_t vm_flags,
       struct vma_struct **vma_store) {
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc020428e:	6785                	lui	a5,0x1
       struct vma_struct **vma_store) {
ffffffffc0204290:	7139                	addi	sp,sp,-64
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc0204292:	17fd                	addi	a5,a5,-1
ffffffffc0204294:	787d                	lui	a6,0xfffff
       struct vma_struct **vma_store) {
ffffffffc0204296:	f822                	sd	s0,48(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc0204298:	00f60433          	add	s0,a2,a5
       struct vma_struct **vma_store) {
ffffffffc020429c:	f426                	sd	s1,40(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc020429e:	942e                	add	s0,s0,a1
       struct vma_struct **vma_store) {
ffffffffc02042a0:	fc06                	sd	ra,56(sp)
ffffffffc02042a2:	f04a                	sd	s2,32(sp)
ffffffffc02042a4:	ec4e                	sd	s3,24(sp)
ffffffffc02042a6:	e852                	sd	s4,16(sp)
ffffffffc02042a8:	e456                	sd	s5,8(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc02042aa:	0105f4b3          	and	s1,a1,a6
    if (!USER_ACCESS(start, end)) {
ffffffffc02042ae:	002007b7          	lui	a5,0x200
ffffffffc02042b2:	01047433          	and	s0,s0,a6
ffffffffc02042b6:	06f4e363          	bltu	s1,a5,ffffffffc020431c <mm_map+0x8e>
ffffffffc02042ba:	0684f163          	bleu	s0,s1,ffffffffc020431c <mm_map+0x8e>
ffffffffc02042be:	4785                	li	a5,1
ffffffffc02042c0:	07fe                	slli	a5,a5,0x1f
ffffffffc02042c2:	0487ed63          	bltu	a5,s0,ffffffffc020431c <mm_map+0x8e>
ffffffffc02042c6:	89aa                	mv	s3,a0
ffffffffc02042c8:	8a3a                	mv	s4,a4
ffffffffc02042ca:	8ab6                	mv	s5,a3
        return -E_INVAL;
    }

    assert(mm != NULL);
ffffffffc02042cc:	c931                	beqz	a0,ffffffffc0204320 <mm_map+0x92>

    int ret = -E_INVAL;

    struct vma_struct *vma;
    if ((vma = find_vma(mm, start)) != NULL && end > vma->vm_start) {
ffffffffc02042ce:	85a6                	mv	a1,s1
ffffffffc02042d0:	e61ff0ef          	jal	ra,ffffffffc0204130 <find_vma>
ffffffffc02042d4:	c501                	beqz	a0,ffffffffc02042dc <mm_map+0x4e>
ffffffffc02042d6:	651c                	ld	a5,8(a0)
ffffffffc02042d8:	0487e263          	bltu	a5,s0,ffffffffc020431c <mm_map+0x8e>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02042dc:	03000513          	li	a0,48
ffffffffc02042e0:	967fd0ef          	jal	ra,ffffffffc0201c46 <kmalloc>
ffffffffc02042e4:	892a                	mv	s2,a0
        goto out;
    }
    ret = -E_NO_MEM;
ffffffffc02042e6:	5571                	li	a0,-4
    if (vma != NULL) {
ffffffffc02042e8:	02090163          	beqz	s2,ffffffffc020430a <mm_map+0x7c>

    if ((vma = vma_create(start, end, vm_flags)) == NULL) {
        goto out;
    }
    insert_vma_struct(mm, vma);
ffffffffc02042ec:	854e                	mv	a0,s3
        vma->vm_start = vm_start;
ffffffffc02042ee:	00993423          	sd	s1,8(s2)
        vma->vm_end = vm_end;
ffffffffc02042f2:	00893823          	sd	s0,16(s2)
        vma->vm_flags = vm_flags;
ffffffffc02042f6:	01592c23          	sw	s5,24(s2)
    insert_vma_struct(mm, vma);
ffffffffc02042fa:	85ca                	mv	a1,s2
ffffffffc02042fc:	e73ff0ef          	jal	ra,ffffffffc020416e <insert_vma_struct>
    if (vma_store != NULL) {
        *vma_store = vma;
    }
    ret = 0;
ffffffffc0204300:	4501                	li	a0,0
    if (vma_store != NULL) {
ffffffffc0204302:	000a0463          	beqz	s4,ffffffffc020430a <mm_map+0x7c>
        *vma_store = vma;
ffffffffc0204306:	012a3023          	sd	s2,0(s4)

out:
    return ret;
}
ffffffffc020430a:	70e2                	ld	ra,56(sp)
ffffffffc020430c:	7442                	ld	s0,48(sp)
ffffffffc020430e:	74a2                	ld	s1,40(sp)
ffffffffc0204310:	7902                	ld	s2,32(sp)
ffffffffc0204312:	69e2                	ld	s3,24(sp)
ffffffffc0204314:	6a42                	ld	s4,16(sp)
ffffffffc0204316:	6aa2                	ld	s5,8(sp)
ffffffffc0204318:	6121                	addi	sp,sp,64
ffffffffc020431a:	8082                	ret
        return -E_INVAL;
ffffffffc020431c:	5575                	li	a0,-3
ffffffffc020431e:	b7f5                	j	ffffffffc020430a <mm_map+0x7c>
    assert(mm != NULL);
ffffffffc0204320:	00006697          	auipc	a3,0x6
ffffffffc0204324:	36868693          	addi	a3,a3,872 # ffffffffc020a688 <default_pmm_manager+0x7f0>
ffffffffc0204328:	00005617          	auipc	a2,0x5
ffffffffc020432c:	42860613          	addi	a2,a2,1064 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0204330:	0a700593          	li	a1,167
ffffffffc0204334:	00007517          	auipc	a0,0x7
ffffffffc0204338:	81c50513          	addi	a0,a0,-2020 # ffffffffc020ab50 <default_pmm_manager+0xcb8>
ffffffffc020433c:	94cfc0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0204340 <dup_mmap>:

int
dup_mmap(struct mm_struct *to, struct mm_struct *from) {
ffffffffc0204340:	7139                	addi	sp,sp,-64
ffffffffc0204342:	fc06                	sd	ra,56(sp)
ffffffffc0204344:	f822                	sd	s0,48(sp)
ffffffffc0204346:	f426                	sd	s1,40(sp)
ffffffffc0204348:	f04a                	sd	s2,32(sp)
ffffffffc020434a:	ec4e                	sd	s3,24(sp)
ffffffffc020434c:	e852                	sd	s4,16(sp)
ffffffffc020434e:	e456                	sd	s5,8(sp)
    assert(to != NULL && from != NULL);
ffffffffc0204350:	c535                	beqz	a0,ffffffffc02043bc <dup_mmap+0x7c>
ffffffffc0204352:	892a                	mv	s2,a0
ffffffffc0204354:	84ae                	mv	s1,a1
    list_entry_t *list = &(from->mmap_list), *le = list;
ffffffffc0204356:	842e                	mv	s0,a1
    assert(to != NULL && from != NULL);
ffffffffc0204358:	e59d                	bnez	a1,ffffffffc0204386 <dup_mmap+0x46>
ffffffffc020435a:	a08d                	j	ffffffffc02043bc <dup_mmap+0x7c>
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
        if (nvma == NULL) {
            return -E_NO_MEM;
        }

        insert_vma_struct(to, nvma);
ffffffffc020435c:	85aa                	mv	a1,a0
        vma->vm_start = vm_start;
ffffffffc020435e:	0157b423          	sd	s5,8(a5) # 200008 <_binary_obj___user_matrix_out_size+0x1f45a0>
        insert_vma_struct(to, nvma);
ffffffffc0204362:	854a                	mv	a0,s2
        vma->vm_end = vm_end;
ffffffffc0204364:	0147b823          	sd	s4,16(a5)
        vma->vm_flags = vm_flags;
ffffffffc0204368:	0137ac23          	sw	s3,24(a5)
        insert_vma_struct(to, nvma);
ffffffffc020436c:	e03ff0ef          	jal	ra,ffffffffc020416e <insert_vma_struct>

        bool share = 0;
        if (copy_range(to->pgdir, from->pgdir, vma->vm_start, vma->vm_end, share) != 0) {
ffffffffc0204370:	ff043683          	ld	a3,-16(s0)
ffffffffc0204374:	fe843603          	ld	a2,-24(s0)
ffffffffc0204378:	6c8c                	ld	a1,24(s1)
ffffffffc020437a:	01893503          	ld	a0,24(s2)
ffffffffc020437e:	4701                	li	a4,0
ffffffffc0204380:	d2ffe0ef          	jal	ra,ffffffffc02030ae <copy_range>
ffffffffc0204384:	e105                	bnez	a0,ffffffffc02043a4 <dup_mmap+0x64>
    return listelm->prev;
ffffffffc0204386:	6000                	ld	s0,0(s0)
    while ((le = list_prev(le)) != list) {
ffffffffc0204388:	02848863          	beq	s1,s0,ffffffffc02043b8 <dup_mmap+0x78>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020438c:	03000513          	li	a0,48
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
ffffffffc0204390:	fe843a83          	ld	s5,-24(s0)
ffffffffc0204394:	ff043a03          	ld	s4,-16(s0)
ffffffffc0204398:	ff842983          	lw	s3,-8(s0)
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020439c:	8abfd0ef          	jal	ra,ffffffffc0201c46 <kmalloc>
ffffffffc02043a0:	87aa                	mv	a5,a0
    if (vma != NULL) {
ffffffffc02043a2:	fd4d                	bnez	a0,ffffffffc020435c <dup_mmap+0x1c>
            return -E_NO_MEM;
ffffffffc02043a4:	5571                	li	a0,-4
            return -E_NO_MEM;
        }
    }
    return 0;
}
ffffffffc02043a6:	70e2                	ld	ra,56(sp)
ffffffffc02043a8:	7442                	ld	s0,48(sp)
ffffffffc02043aa:	74a2                	ld	s1,40(sp)
ffffffffc02043ac:	7902                	ld	s2,32(sp)
ffffffffc02043ae:	69e2                	ld	s3,24(sp)
ffffffffc02043b0:	6a42                	ld	s4,16(sp)
ffffffffc02043b2:	6aa2                	ld	s5,8(sp)
ffffffffc02043b4:	6121                	addi	sp,sp,64
ffffffffc02043b6:	8082                	ret
    return 0;
ffffffffc02043b8:	4501                	li	a0,0
ffffffffc02043ba:	b7f5                	j	ffffffffc02043a6 <dup_mmap+0x66>
    assert(to != NULL && from != NULL);
ffffffffc02043bc:	00007697          	auipc	a3,0x7
ffffffffc02043c0:	86468693          	addi	a3,a3,-1948 # ffffffffc020ac20 <default_pmm_manager+0xd88>
ffffffffc02043c4:	00005617          	auipc	a2,0x5
ffffffffc02043c8:	38c60613          	addi	a2,a2,908 # ffffffffc0209750 <commands+0x4c0>
ffffffffc02043cc:	0c000593          	li	a1,192
ffffffffc02043d0:	00006517          	auipc	a0,0x6
ffffffffc02043d4:	78050513          	addi	a0,a0,1920 # ffffffffc020ab50 <default_pmm_manager+0xcb8>
ffffffffc02043d8:	8b0fc0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc02043dc <exit_mmap>:

void
exit_mmap(struct mm_struct *mm) {
ffffffffc02043dc:	1101                	addi	sp,sp,-32
ffffffffc02043de:	ec06                	sd	ra,24(sp)
ffffffffc02043e0:	e822                	sd	s0,16(sp)
ffffffffc02043e2:	e426                	sd	s1,8(sp)
ffffffffc02043e4:	e04a                	sd	s2,0(sp)
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc02043e6:	c531                	beqz	a0,ffffffffc0204432 <exit_mmap+0x56>
ffffffffc02043e8:	591c                	lw	a5,48(a0)
ffffffffc02043ea:	84aa                	mv	s1,a0
ffffffffc02043ec:	e3b9                	bnez	a5,ffffffffc0204432 <exit_mmap+0x56>
    return listelm->next;
ffffffffc02043ee:	6500                	ld	s0,8(a0)
    pde_t *pgdir = mm->pgdir;
ffffffffc02043f0:	01853903          	ld	s2,24(a0)
    list_entry_t *list = &(mm->mmap_list), *le = list;
    while ((le = list_next(le)) != list) {
ffffffffc02043f4:	02850663          	beq	a0,s0,ffffffffc0204420 <exit_mmap+0x44>
        struct vma_struct *vma = le2vma(le, list_link);
        unmap_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc02043f8:	ff043603          	ld	a2,-16(s0)
ffffffffc02043fc:	fe843583          	ld	a1,-24(s0)
ffffffffc0204400:	854a                	mv	a0,s2
ffffffffc0204402:	d83fd0ef          	jal	ra,ffffffffc0202184 <unmap_range>
ffffffffc0204406:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list) {
ffffffffc0204408:	fe8498e3          	bne	s1,s0,ffffffffc02043f8 <exit_mmap+0x1c>
ffffffffc020440c:	6400                	ld	s0,8(s0)
    }
    while ((le = list_next(le)) != list) {
ffffffffc020440e:	00848c63          	beq	s1,s0,ffffffffc0204426 <exit_mmap+0x4a>
        struct vma_struct *vma = le2vma(le, list_link);
        exit_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc0204412:	ff043603          	ld	a2,-16(s0)
ffffffffc0204416:	fe843583          	ld	a1,-24(s0)
ffffffffc020441a:	854a                	mv	a0,s2
ffffffffc020441c:	e81fd0ef          	jal	ra,ffffffffc020229c <exit_range>
ffffffffc0204420:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list) {
ffffffffc0204422:	fe8498e3          	bne	s1,s0,ffffffffc0204412 <exit_mmap+0x36>
    }
}
ffffffffc0204426:	60e2                	ld	ra,24(sp)
ffffffffc0204428:	6442                	ld	s0,16(sp)
ffffffffc020442a:	64a2                	ld	s1,8(sp)
ffffffffc020442c:	6902                	ld	s2,0(sp)
ffffffffc020442e:	6105                	addi	sp,sp,32
ffffffffc0204430:	8082                	ret
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc0204432:	00007697          	auipc	a3,0x7
ffffffffc0204436:	80e68693          	addi	a3,a3,-2034 # ffffffffc020ac40 <default_pmm_manager+0xda8>
ffffffffc020443a:	00005617          	auipc	a2,0x5
ffffffffc020443e:	31660613          	addi	a2,a2,790 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0204442:	0d600593          	li	a1,214
ffffffffc0204446:	00006517          	auipc	a0,0x6
ffffffffc020444a:	70a50513          	addi	a0,a0,1802 # ffffffffc020ab50 <default_pmm_manager+0xcb8>
ffffffffc020444e:	83afc0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0204452 <vmm_init>:
}

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
ffffffffc0204452:	7139                	addi	sp,sp,-64
ffffffffc0204454:	f822                	sd	s0,48(sp)
ffffffffc0204456:	f426                	sd	s1,40(sp)
ffffffffc0204458:	fc06                	sd	ra,56(sp)
ffffffffc020445a:	f04a                	sd	s2,32(sp)
ffffffffc020445c:	ec4e                	sd	s3,24(sp)
ffffffffc020445e:	e852                	sd	s4,16(sp)
ffffffffc0204460:	e456                	sd	s5,8(sp)

static void
check_vma_struct(void) {
    // size_t nr_free_pages_store = nr_free_pages();

    struct mm_struct *mm = mm_create();
ffffffffc0204462:	c55ff0ef          	jal	ra,ffffffffc02040b6 <mm_create>
    assert(mm != NULL);
ffffffffc0204466:	842a                	mv	s0,a0
ffffffffc0204468:	03200493          	li	s1,50
ffffffffc020446c:	e919                	bnez	a0,ffffffffc0204482 <vmm_init+0x30>
ffffffffc020446e:	a989                	j	ffffffffc02048c0 <vmm_init+0x46e>
        vma->vm_start = vm_start;
ffffffffc0204470:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc0204472:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0204474:	00052c23          	sw	zero,24(a0)

    int i;
    for (i = step1; i >= 1; i --) {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0204478:	14ed                	addi	s1,s1,-5
ffffffffc020447a:	8522                	mv	a0,s0
ffffffffc020447c:	cf3ff0ef          	jal	ra,ffffffffc020416e <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
ffffffffc0204480:	c88d                	beqz	s1,ffffffffc02044b2 <vmm_init+0x60>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0204482:	03000513          	li	a0,48
ffffffffc0204486:	fc0fd0ef          	jal	ra,ffffffffc0201c46 <kmalloc>
ffffffffc020448a:	85aa                	mv	a1,a0
ffffffffc020448c:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc0204490:	f165                	bnez	a0,ffffffffc0204470 <vmm_init+0x1e>
        assert(vma != NULL);
ffffffffc0204492:	00006697          	auipc	a3,0x6
ffffffffc0204496:	22e68693          	addi	a3,a3,558 # ffffffffc020a6c0 <default_pmm_manager+0x828>
ffffffffc020449a:	00005617          	auipc	a2,0x5
ffffffffc020449e:	2b660613          	addi	a2,a2,694 # ffffffffc0209750 <commands+0x4c0>
ffffffffc02044a2:	11300593          	li	a1,275
ffffffffc02044a6:	00006517          	auipc	a0,0x6
ffffffffc02044aa:	6aa50513          	addi	a0,a0,1706 # ffffffffc020ab50 <default_pmm_manager+0xcb8>
ffffffffc02044ae:	fdbfb0ef          	jal	ra,ffffffffc0200488 <__panic>
    for (i = step1; i >= 1; i --) {
ffffffffc02044b2:	03700493          	li	s1,55
    }

    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc02044b6:	1f900913          	li	s2,505
ffffffffc02044ba:	a819                	j	ffffffffc02044d0 <vmm_init+0x7e>
        vma->vm_start = vm_start;
ffffffffc02044bc:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc02044be:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc02044c0:	00052c23          	sw	zero,24(a0)
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc02044c4:	0495                	addi	s1,s1,5
ffffffffc02044c6:	8522                	mv	a0,s0
ffffffffc02044c8:	ca7ff0ef          	jal	ra,ffffffffc020416e <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc02044cc:	03248a63          	beq	s1,s2,ffffffffc0204500 <vmm_init+0xae>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02044d0:	03000513          	li	a0,48
ffffffffc02044d4:	f72fd0ef          	jal	ra,ffffffffc0201c46 <kmalloc>
ffffffffc02044d8:	85aa                	mv	a1,a0
ffffffffc02044da:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc02044de:	fd79                	bnez	a0,ffffffffc02044bc <vmm_init+0x6a>
        assert(vma != NULL);
ffffffffc02044e0:	00006697          	auipc	a3,0x6
ffffffffc02044e4:	1e068693          	addi	a3,a3,480 # ffffffffc020a6c0 <default_pmm_manager+0x828>
ffffffffc02044e8:	00005617          	auipc	a2,0x5
ffffffffc02044ec:	26860613          	addi	a2,a2,616 # ffffffffc0209750 <commands+0x4c0>
ffffffffc02044f0:	11900593          	li	a1,281
ffffffffc02044f4:	00006517          	auipc	a0,0x6
ffffffffc02044f8:	65c50513          	addi	a0,a0,1628 # ffffffffc020ab50 <default_pmm_manager+0xcb8>
ffffffffc02044fc:	f8dfb0ef          	jal	ra,ffffffffc0200488 <__panic>
ffffffffc0204500:	6418                	ld	a4,8(s0)
ffffffffc0204502:	479d                	li	a5,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
ffffffffc0204504:	1fb00593          	li	a1,507
        assert(le != &(mm->mmap_list));
ffffffffc0204508:	2ee40063          	beq	s0,a4,ffffffffc02047e8 <vmm_init+0x396>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc020450c:	fe873603          	ld	a2,-24(a4)
ffffffffc0204510:	ffe78693          	addi	a3,a5,-2
ffffffffc0204514:	24d61a63          	bne	a2,a3,ffffffffc0204768 <vmm_init+0x316>
ffffffffc0204518:	ff073683          	ld	a3,-16(a4)
ffffffffc020451c:	24f69663          	bne	a3,a5,ffffffffc0204768 <vmm_init+0x316>
ffffffffc0204520:	0795                	addi	a5,a5,5
ffffffffc0204522:	6718                	ld	a4,8(a4)
    for (i = 1; i <= step2; i ++) {
ffffffffc0204524:	feb792e3          	bne	a5,a1,ffffffffc0204508 <vmm_init+0xb6>
ffffffffc0204528:	491d                	li	s2,7
ffffffffc020452a:	4495                	li	s1,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc020452c:	1f900a93          	li	s5,505
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc0204530:	85a6                	mv	a1,s1
ffffffffc0204532:	8522                	mv	a0,s0
ffffffffc0204534:	bfdff0ef          	jal	ra,ffffffffc0204130 <find_vma>
ffffffffc0204538:	8a2a                	mv	s4,a0
        assert(vma1 != NULL);
ffffffffc020453a:	30050763          	beqz	a0,ffffffffc0204848 <vmm_init+0x3f6>
        struct vma_struct *vma2 = find_vma(mm, i+1);
ffffffffc020453e:	00148593          	addi	a1,s1,1
ffffffffc0204542:	8522                	mv	a0,s0
ffffffffc0204544:	bedff0ef          	jal	ra,ffffffffc0204130 <find_vma>
ffffffffc0204548:	89aa                	mv	s3,a0
        assert(vma2 != NULL);
ffffffffc020454a:	2c050f63          	beqz	a0,ffffffffc0204828 <vmm_init+0x3d6>
        struct vma_struct *vma3 = find_vma(mm, i+2);
ffffffffc020454e:	85ca                	mv	a1,s2
ffffffffc0204550:	8522                	mv	a0,s0
ffffffffc0204552:	bdfff0ef          	jal	ra,ffffffffc0204130 <find_vma>
        assert(vma3 == NULL);
ffffffffc0204556:	2a051963          	bnez	a0,ffffffffc0204808 <vmm_init+0x3b6>
        struct vma_struct *vma4 = find_vma(mm, i+3);
ffffffffc020455a:	00348593          	addi	a1,s1,3
ffffffffc020455e:	8522                	mv	a0,s0
ffffffffc0204560:	bd1ff0ef          	jal	ra,ffffffffc0204130 <find_vma>
        assert(vma4 == NULL);
ffffffffc0204564:	32051263          	bnez	a0,ffffffffc0204888 <vmm_init+0x436>
        struct vma_struct *vma5 = find_vma(mm, i+4);
ffffffffc0204568:	00448593          	addi	a1,s1,4
ffffffffc020456c:	8522                	mv	a0,s0
ffffffffc020456e:	bc3ff0ef          	jal	ra,ffffffffc0204130 <find_vma>
        assert(vma5 == NULL);
ffffffffc0204572:	2e051b63          	bnez	a0,ffffffffc0204868 <vmm_init+0x416>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0204576:	008a3783          	ld	a5,8(s4)
ffffffffc020457a:	20979763          	bne	a5,s1,ffffffffc0204788 <vmm_init+0x336>
ffffffffc020457e:	010a3783          	ld	a5,16(s4)
ffffffffc0204582:	21279363          	bne	a5,s2,ffffffffc0204788 <vmm_init+0x336>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0204586:	0089b783          	ld	a5,8(s3)
ffffffffc020458a:	20979f63          	bne	a5,s1,ffffffffc02047a8 <vmm_init+0x356>
ffffffffc020458e:	0109b783          	ld	a5,16(s3)
ffffffffc0204592:	21279b63          	bne	a5,s2,ffffffffc02047a8 <vmm_init+0x356>
ffffffffc0204596:	0495                	addi	s1,s1,5
ffffffffc0204598:	0915                	addi	s2,s2,5
    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc020459a:	f9549be3          	bne	s1,s5,ffffffffc0204530 <vmm_init+0xde>
ffffffffc020459e:	4491                	li	s1,4
    }

    for (i =4; i>=0; i--) {
ffffffffc02045a0:	597d                	li	s2,-1
        struct vma_struct *vma_below_5= find_vma(mm,i);
ffffffffc02045a2:	85a6                	mv	a1,s1
ffffffffc02045a4:	8522                	mv	a0,s0
ffffffffc02045a6:	b8bff0ef          	jal	ra,ffffffffc0204130 <find_vma>
ffffffffc02045aa:	0004859b          	sext.w	a1,s1
        if (vma_below_5 != NULL ) {
ffffffffc02045ae:	c90d                	beqz	a0,ffffffffc02045e0 <vmm_init+0x18e>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
ffffffffc02045b0:	6914                	ld	a3,16(a0)
ffffffffc02045b2:	6510                	ld	a2,8(a0)
ffffffffc02045b4:	00007517          	auipc	a0,0x7
ffffffffc02045b8:	82450513          	addi	a0,a0,-2012 # ffffffffc020add8 <default_pmm_manager+0xf40>
ffffffffc02045bc:	bd7fb0ef          	jal	ra,ffffffffc0200192 <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc02045c0:	00007697          	auipc	a3,0x7
ffffffffc02045c4:	84068693          	addi	a3,a3,-1984 # ffffffffc020ae00 <default_pmm_manager+0xf68>
ffffffffc02045c8:	00005617          	auipc	a2,0x5
ffffffffc02045cc:	18860613          	addi	a2,a2,392 # ffffffffc0209750 <commands+0x4c0>
ffffffffc02045d0:	13b00593          	li	a1,315
ffffffffc02045d4:	00006517          	auipc	a0,0x6
ffffffffc02045d8:	57c50513          	addi	a0,a0,1404 # ffffffffc020ab50 <default_pmm_manager+0xcb8>
ffffffffc02045dc:	eadfb0ef          	jal	ra,ffffffffc0200488 <__panic>
ffffffffc02045e0:	14fd                	addi	s1,s1,-1
    for (i =4; i>=0; i--) {
ffffffffc02045e2:	fd2490e3          	bne	s1,s2,ffffffffc02045a2 <vmm_init+0x150>
    }

    mm_destroy(mm);
ffffffffc02045e6:	8522                	mv	a0,s0
ffffffffc02045e8:	c55ff0ef          	jal	ra,ffffffffc020423c <mm_destroy>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc02045ec:	00007517          	auipc	a0,0x7
ffffffffc02045f0:	82c50513          	addi	a0,a0,-2004 # ffffffffc020ae18 <default_pmm_manager+0xf80>
ffffffffc02045f4:	b9ffb0ef          	jal	ra,ffffffffc0200192 <cprintf>
struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc02045f8:	919fd0ef          	jal	ra,ffffffffc0201f10 <nr_free_pages>
ffffffffc02045fc:	89aa                	mv	s3,a0

    check_mm_struct = mm_create();
ffffffffc02045fe:	ab9ff0ef          	jal	ra,ffffffffc02040b6 <mm_create>
ffffffffc0204602:	000c5797          	auipc	a5,0xc5
ffffffffc0204606:	dca7b323          	sd	a0,-570(a5) # ffffffffc02c93c8 <check_mm_struct>
ffffffffc020460a:	84aa                	mv	s1,a0
    assert(check_mm_struct != NULL);
ffffffffc020460c:	36050663          	beqz	a0,ffffffffc0204978 <vmm_init+0x526>

    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0204610:	000c5797          	auipc	a5,0xc5
ffffffffc0204614:	c5078793          	addi	a5,a5,-944 # ffffffffc02c9260 <boot_pgdir>
ffffffffc0204618:	0007b903          	ld	s2,0(a5)
    assert(pgdir[0] == 0);
ffffffffc020461c:	00093783          	ld	a5,0(s2)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0204620:	01253c23          	sd	s2,24(a0)
    assert(pgdir[0] == 0);
ffffffffc0204624:	2c079e63          	bnez	a5,ffffffffc0204900 <vmm_init+0x4ae>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0204628:	03000513          	li	a0,48
ffffffffc020462c:	e1afd0ef          	jal	ra,ffffffffc0201c46 <kmalloc>
ffffffffc0204630:	842a                	mv	s0,a0
    if (vma != NULL) {
ffffffffc0204632:	18050b63          	beqz	a0,ffffffffc02047c8 <vmm_init+0x376>
        vma->vm_end = vm_end;
ffffffffc0204636:	002007b7          	lui	a5,0x200
ffffffffc020463a:	e81c                	sd	a5,16(s0)
        vma->vm_flags = vm_flags;
ffffffffc020463c:	4789                	li	a5,2

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc020463e:	85aa                	mv	a1,a0
        vma->vm_flags = vm_flags;
ffffffffc0204640:	cc1c                	sw	a5,24(s0)
    insert_vma_struct(mm, vma);
ffffffffc0204642:	8526                	mv	a0,s1
        vma->vm_start = vm_start;
ffffffffc0204644:	00043423          	sd	zero,8(s0)
    insert_vma_struct(mm, vma);
ffffffffc0204648:	b27ff0ef          	jal	ra,ffffffffc020416e <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc020464c:	10000593          	li	a1,256
ffffffffc0204650:	8526                	mv	a0,s1
ffffffffc0204652:	adfff0ef          	jal	ra,ffffffffc0204130 <find_vma>
ffffffffc0204656:	10000793          	li	a5,256

    int i, sum = 0;

    for (i = 0; i < 100; i ++) {
ffffffffc020465a:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc020465e:	2ca41163          	bne	s0,a0,ffffffffc0204920 <vmm_init+0x4ce>
        *(char *)(addr + i) = i;
ffffffffc0204662:	00f78023          	sb	a5,0(a5) # 200000 <_binary_obj___user_matrix_out_size+0x1f4598>
        sum += i;
ffffffffc0204666:	0785                	addi	a5,a5,1
    for (i = 0; i < 100; i ++) {
ffffffffc0204668:	fee79de3          	bne	a5,a4,ffffffffc0204662 <vmm_init+0x210>
        sum += i;
ffffffffc020466c:	6705                	lui	a4,0x1
    for (i = 0; i < 100; i ++) {
ffffffffc020466e:	10000793          	li	a5,256
        sum += i;
ffffffffc0204672:	35670713          	addi	a4,a4,854 # 1356 <_binary_obj___user_faultread_out_size-0x85aa>
    }
    for (i = 0; i < 100; i ++) {
ffffffffc0204676:	16400613          	li	a2,356
        sum -= *(char *)(addr + i);
ffffffffc020467a:	0007c683          	lbu	a3,0(a5)
ffffffffc020467e:	0785                	addi	a5,a5,1
ffffffffc0204680:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i ++) {
ffffffffc0204682:	fec79ce3          	bne	a5,a2,ffffffffc020467a <vmm_init+0x228>
    }

    assert(sum == 0);
ffffffffc0204686:	2c071963          	bnez	a4,ffffffffc0204958 <vmm_init+0x506>
    return pa2page(PDE_ADDR(pde));
ffffffffc020468a:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc020468e:	000c5a97          	auipc	s5,0xc5
ffffffffc0204692:	bdaa8a93          	addi	s5,s5,-1062 # ffffffffc02c9268 <npage>
ffffffffc0204696:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc020469a:	078a                	slli	a5,a5,0x2
ffffffffc020469c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020469e:	20e7f563          	bleu	a4,a5,ffffffffc02048a8 <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc02046a2:	00008697          	auipc	a3,0x8
ffffffffc02046a6:	8fe68693          	addi	a3,a3,-1794 # ffffffffc020bfa0 <nbase>
ffffffffc02046aa:	0006ba03          	ld	s4,0(a3)
ffffffffc02046ae:	414786b3          	sub	a3,a5,s4
ffffffffc02046b2:	069a                	slli	a3,a3,0x6
    return page - pages + nbase;
ffffffffc02046b4:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc02046b6:	57fd                	li	a5,-1
    return page - pages + nbase;
ffffffffc02046b8:	96d2                	add	a3,a3,s4
    return KADDR(page2pa(page));
ffffffffc02046ba:	83b1                	srli	a5,a5,0xc
ffffffffc02046bc:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc02046be:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02046c0:	28e7f063          	bleu	a4,a5,ffffffffc0204940 <vmm_init+0x4ee>
ffffffffc02046c4:	000c5797          	auipc	a5,0xc5
ffffffffc02046c8:	c1478793          	addi	a5,a5,-1004 # ffffffffc02c92d8 <va_pa_offset>
ffffffffc02046cc:	6380                	ld	s0,0(a5)

    pde_t *pd1=pgdir,*pd0=page2kva(pde2page(pgdir[0]));
    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc02046ce:	4581                	li	a1,0
ffffffffc02046d0:	854a                	mv	a0,s2
ffffffffc02046d2:	9436                	add	s0,s0,a3
ffffffffc02046d4:	e1ffd0ef          	jal	ra,ffffffffc02024f2 <page_remove>
    return pa2page(PDE_ADDR(pde));
ffffffffc02046d8:	601c                	ld	a5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc02046da:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc02046de:	078a                	slli	a5,a5,0x2
ffffffffc02046e0:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02046e2:	1ce7f363          	bleu	a4,a5,ffffffffc02048a8 <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc02046e6:	000c5417          	auipc	s0,0xc5
ffffffffc02046ea:	c0240413          	addi	s0,s0,-1022 # ffffffffc02c92e8 <pages>
ffffffffc02046ee:	6008                	ld	a0,0(s0)
ffffffffc02046f0:	414787b3          	sub	a5,a5,s4
ffffffffc02046f4:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd0[0]));
ffffffffc02046f6:	953e                	add	a0,a0,a5
ffffffffc02046f8:	4585                	li	a1,1
ffffffffc02046fa:	fd0fd0ef          	jal	ra,ffffffffc0201eca <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc02046fe:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0204702:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0204706:	078a                	slli	a5,a5,0x2
ffffffffc0204708:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020470a:	18e7ff63          	bleu	a4,a5,ffffffffc02048a8 <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc020470e:	6008                	ld	a0,0(s0)
ffffffffc0204710:	414787b3          	sub	a5,a5,s4
ffffffffc0204714:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc0204716:	4585                	li	a1,1
ffffffffc0204718:	953e                	add	a0,a0,a5
ffffffffc020471a:	fb0fd0ef          	jal	ra,ffffffffc0201eca <free_pages>
    pgdir[0] = 0;
ffffffffc020471e:	00093023          	sd	zero,0(s2)
  asm volatile("sfence.vma");
ffffffffc0204722:	12000073          	sfence.vma
    flush_tlb();

    mm->pgdir = NULL;
ffffffffc0204726:	0004bc23          	sd	zero,24(s1)
    mm_destroy(mm);
ffffffffc020472a:	8526                	mv	a0,s1
ffffffffc020472c:	b11ff0ef          	jal	ra,ffffffffc020423c <mm_destroy>
    check_mm_struct = NULL;
ffffffffc0204730:	000c5797          	auipc	a5,0xc5
ffffffffc0204734:	c807bc23          	sd	zero,-872(a5) # ffffffffc02c93c8 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0204738:	fd8fd0ef          	jal	ra,ffffffffc0201f10 <nr_free_pages>
ffffffffc020473c:	1aa99263          	bne	s3,a0,ffffffffc02048e0 <vmm_init+0x48e>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc0204740:	00006517          	auipc	a0,0x6
ffffffffc0204744:	76850513          	addi	a0,a0,1896 # ffffffffc020aea8 <default_pmm_manager+0x1010>
ffffffffc0204748:	a4bfb0ef          	jal	ra,ffffffffc0200192 <cprintf>
}
ffffffffc020474c:	7442                	ld	s0,48(sp)
ffffffffc020474e:	70e2                	ld	ra,56(sp)
ffffffffc0204750:	74a2                	ld	s1,40(sp)
ffffffffc0204752:	7902                	ld	s2,32(sp)
ffffffffc0204754:	69e2                	ld	s3,24(sp)
ffffffffc0204756:	6a42                	ld	s4,16(sp)
ffffffffc0204758:	6aa2                	ld	s5,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc020475a:	00006517          	auipc	a0,0x6
ffffffffc020475e:	76e50513          	addi	a0,a0,1902 # ffffffffc020aec8 <default_pmm_manager+0x1030>
}
ffffffffc0204762:	6121                	addi	sp,sp,64
    cprintf("check_vmm() succeeded.\n");
ffffffffc0204764:	a2ffb06f          	j	ffffffffc0200192 <cprintf>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0204768:	00006697          	auipc	a3,0x6
ffffffffc020476c:	58868693          	addi	a3,a3,1416 # ffffffffc020acf0 <default_pmm_manager+0xe58>
ffffffffc0204770:	00005617          	auipc	a2,0x5
ffffffffc0204774:	fe060613          	addi	a2,a2,-32 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0204778:	12200593          	li	a1,290
ffffffffc020477c:	00006517          	auipc	a0,0x6
ffffffffc0204780:	3d450513          	addi	a0,a0,980 # ffffffffc020ab50 <default_pmm_manager+0xcb8>
ffffffffc0204784:	d05fb0ef          	jal	ra,ffffffffc0200488 <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0204788:	00006697          	auipc	a3,0x6
ffffffffc020478c:	5f068693          	addi	a3,a3,1520 # ffffffffc020ad78 <default_pmm_manager+0xee0>
ffffffffc0204790:	00005617          	auipc	a2,0x5
ffffffffc0204794:	fc060613          	addi	a2,a2,-64 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0204798:	13200593          	li	a1,306
ffffffffc020479c:	00006517          	auipc	a0,0x6
ffffffffc02047a0:	3b450513          	addi	a0,a0,948 # ffffffffc020ab50 <default_pmm_manager+0xcb8>
ffffffffc02047a4:	ce5fb0ef          	jal	ra,ffffffffc0200488 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc02047a8:	00006697          	auipc	a3,0x6
ffffffffc02047ac:	60068693          	addi	a3,a3,1536 # ffffffffc020ada8 <default_pmm_manager+0xf10>
ffffffffc02047b0:	00005617          	auipc	a2,0x5
ffffffffc02047b4:	fa060613          	addi	a2,a2,-96 # ffffffffc0209750 <commands+0x4c0>
ffffffffc02047b8:	13300593          	li	a1,307
ffffffffc02047bc:	00006517          	auipc	a0,0x6
ffffffffc02047c0:	39450513          	addi	a0,a0,916 # ffffffffc020ab50 <default_pmm_manager+0xcb8>
ffffffffc02047c4:	cc5fb0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(vma != NULL);
ffffffffc02047c8:	00006697          	auipc	a3,0x6
ffffffffc02047cc:	ef868693          	addi	a3,a3,-264 # ffffffffc020a6c0 <default_pmm_manager+0x828>
ffffffffc02047d0:	00005617          	auipc	a2,0x5
ffffffffc02047d4:	f8060613          	addi	a2,a2,-128 # ffffffffc0209750 <commands+0x4c0>
ffffffffc02047d8:	15200593          	li	a1,338
ffffffffc02047dc:	00006517          	auipc	a0,0x6
ffffffffc02047e0:	37450513          	addi	a0,a0,884 # ffffffffc020ab50 <default_pmm_manager+0xcb8>
ffffffffc02047e4:	ca5fb0ef          	jal	ra,ffffffffc0200488 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc02047e8:	00006697          	auipc	a3,0x6
ffffffffc02047ec:	4f068693          	addi	a3,a3,1264 # ffffffffc020acd8 <default_pmm_manager+0xe40>
ffffffffc02047f0:	00005617          	auipc	a2,0x5
ffffffffc02047f4:	f6060613          	addi	a2,a2,-160 # ffffffffc0209750 <commands+0x4c0>
ffffffffc02047f8:	12000593          	li	a1,288
ffffffffc02047fc:	00006517          	auipc	a0,0x6
ffffffffc0204800:	35450513          	addi	a0,a0,852 # ffffffffc020ab50 <default_pmm_manager+0xcb8>
ffffffffc0204804:	c85fb0ef          	jal	ra,ffffffffc0200488 <__panic>
        assert(vma3 == NULL);
ffffffffc0204808:	00006697          	auipc	a3,0x6
ffffffffc020480c:	54068693          	addi	a3,a3,1344 # ffffffffc020ad48 <default_pmm_manager+0xeb0>
ffffffffc0204810:	00005617          	auipc	a2,0x5
ffffffffc0204814:	f4060613          	addi	a2,a2,-192 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0204818:	12c00593          	li	a1,300
ffffffffc020481c:	00006517          	auipc	a0,0x6
ffffffffc0204820:	33450513          	addi	a0,a0,820 # ffffffffc020ab50 <default_pmm_manager+0xcb8>
ffffffffc0204824:	c65fb0ef          	jal	ra,ffffffffc0200488 <__panic>
        assert(vma2 != NULL);
ffffffffc0204828:	00006697          	auipc	a3,0x6
ffffffffc020482c:	51068693          	addi	a3,a3,1296 # ffffffffc020ad38 <default_pmm_manager+0xea0>
ffffffffc0204830:	00005617          	auipc	a2,0x5
ffffffffc0204834:	f2060613          	addi	a2,a2,-224 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0204838:	12a00593          	li	a1,298
ffffffffc020483c:	00006517          	auipc	a0,0x6
ffffffffc0204840:	31450513          	addi	a0,a0,788 # ffffffffc020ab50 <default_pmm_manager+0xcb8>
ffffffffc0204844:	c45fb0ef          	jal	ra,ffffffffc0200488 <__panic>
        assert(vma1 != NULL);
ffffffffc0204848:	00006697          	auipc	a3,0x6
ffffffffc020484c:	4e068693          	addi	a3,a3,1248 # ffffffffc020ad28 <default_pmm_manager+0xe90>
ffffffffc0204850:	00005617          	auipc	a2,0x5
ffffffffc0204854:	f0060613          	addi	a2,a2,-256 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0204858:	12800593          	li	a1,296
ffffffffc020485c:	00006517          	auipc	a0,0x6
ffffffffc0204860:	2f450513          	addi	a0,a0,756 # ffffffffc020ab50 <default_pmm_manager+0xcb8>
ffffffffc0204864:	c25fb0ef          	jal	ra,ffffffffc0200488 <__panic>
        assert(vma5 == NULL);
ffffffffc0204868:	00006697          	auipc	a3,0x6
ffffffffc020486c:	50068693          	addi	a3,a3,1280 # ffffffffc020ad68 <default_pmm_manager+0xed0>
ffffffffc0204870:	00005617          	auipc	a2,0x5
ffffffffc0204874:	ee060613          	addi	a2,a2,-288 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0204878:	13000593          	li	a1,304
ffffffffc020487c:	00006517          	auipc	a0,0x6
ffffffffc0204880:	2d450513          	addi	a0,a0,724 # ffffffffc020ab50 <default_pmm_manager+0xcb8>
ffffffffc0204884:	c05fb0ef          	jal	ra,ffffffffc0200488 <__panic>
        assert(vma4 == NULL);
ffffffffc0204888:	00006697          	auipc	a3,0x6
ffffffffc020488c:	4d068693          	addi	a3,a3,1232 # ffffffffc020ad58 <default_pmm_manager+0xec0>
ffffffffc0204890:	00005617          	auipc	a2,0x5
ffffffffc0204894:	ec060613          	addi	a2,a2,-320 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0204898:	12e00593          	li	a1,302
ffffffffc020489c:	00006517          	auipc	a0,0x6
ffffffffc02048a0:	2b450513          	addi	a0,a0,692 # ffffffffc020ab50 <default_pmm_manager+0xcb8>
ffffffffc02048a4:	be5fb0ef          	jal	ra,ffffffffc0200488 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02048a8:	00005617          	auipc	a2,0x5
ffffffffc02048ac:	6a060613          	addi	a2,a2,1696 # ffffffffc0209f48 <default_pmm_manager+0xb0>
ffffffffc02048b0:	06200593          	li	a1,98
ffffffffc02048b4:	00005517          	auipc	a0,0x5
ffffffffc02048b8:	65c50513          	addi	a0,a0,1628 # ffffffffc0209f10 <default_pmm_manager+0x78>
ffffffffc02048bc:	bcdfb0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(mm != NULL);
ffffffffc02048c0:	00006697          	auipc	a3,0x6
ffffffffc02048c4:	dc868693          	addi	a3,a3,-568 # ffffffffc020a688 <default_pmm_manager+0x7f0>
ffffffffc02048c8:	00005617          	auipc	a2,0x5
ffffffffc02048cc:	e8860613          	addi	a2,a2,-376 # ffffffffc0209750 <commands+0x4c0>
ffffffffc02048d0:	10c00593          	li	a1,268
ffffffffc02048d4:	00006517          	auipc	a0,0x6
ffffffffc02048d8:	27c50513          	addi	a0,a0,636 # ffffffffc020ab50 <default_pmm_manager+0xcb8>
ffffffffc02048dc:	badfb0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02048e0:	00006697          	auipc	a3,0x6
ffffffffc02048e4:	5a068693          	addi	a3,a3,1440 # ffffffffc020ae80 <default_pmm_manager+0xfe8>
ffffffffc02048e8:	00005617          	auipc	a2,0x5
ffffffffc02048ec:	e6860613          	addi	a2,a2,-408 # ffffffffc0209750 <commands+0x4c0>
ffffffffc02048f0:	17000593          	li	a1,368
ffffffffc02048f4:	00006517          	auipc	a0,0x6
ffffffffc02048f8:	25c50513          	addi	a0,a0,604 # ffffffffc020ab50 <default_pmm_manager+0xcb8>
ffffffffc02048fc:	b8dfb0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(pgdir[0] == 0);
ffffffffc0204900:	00006697          	auipc	a3,0x6
ffffffffc0204904:	db068693          	addi	a3,a3,-592 # ffffffffc020a6b0 <default_pmm_manager+0x818>
ffffffffc0204908:	00005617          	auipc	a2,0x5
ffffffffc020490c:	e4860613          	addi	a2,a2,-440 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0204910:	14f00593          	li	a1,335
ffffffffc0204914:	00006517          	auipc	a0,0x6
ffffffffc0204918:	23c50513          	addi	a0,a0,572 # ffffffffc020ab50 <default_pmm_manager+0xcb8>
ffffffffc020491c:	b6dfb0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc0204920:	00006697          	auipc	a3,0x6
ffffffffc0204924:	53068693          	addi	a3,a3,1328 # ffffffffc020ae50 <default_pmm_manager+0xfb8>
ffffffffc0204928:	00005617          	auipc	a2,0x5
ffffffffc020492c:	e2860613          	addi	a2,a2,-472 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0204930:	15700593          	li	a1,343
ffffffffc0204934:	00006517          	auipc	a0,0x6
ffffffffc0204938:	21c50513          	addi	a0,a0,540 # ffffffffc020ab50 <default_pmm_manager+0xcb8>
ffffffffc020493c:	b4dfb0ef          	jal	ra,ffffffffc0200488 <__panic>
    return KADDR(page2pa(page));
ffffffffc0204940:	00005617          	auipc	a2,0x5
ffffffffc0204944:	5a860613          	addi	a2,a2,1448 # ffffffffc0209ee8 <default_pmm_manager+0x50>
ffffffffc0204948:	06900593          	li	a1,105
ffffffffc020494c:	00005517          	auipc	a0,0x5
ffffffffc0204950:	5c450513          	addi	a0,a0,1476 # ffffffffc0209f10 <default_pmm_manager+0x78>
ffffffffc0204954:	b35fb0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(sum == 0);
ffffffffc0204958:	00006697          	auipc	a3,0x6
ffffffffc020495c:	51868693          	addi	a3,a3,1304 # ffffffffc020ae70 <default_pmm_manager+0xfd8>
ffffffffc0204960:	00005617          	auipc	a2,0x5
ffffffffc0204964:	df060613          	addi	a2,a2,-528 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0204968:	16300593          	li	a1,355
ffffffffc020496c:	00006517          	auipc	a0,0x6
ffffffffc0204970:	1e450513          	addi	a0,a0,484 # ffffffffc020ab50 <default_pmm_manager+0xcb8>
ffffffffc0204974:	b15fb0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(check_mm_struct != NULL);
ffffffffc0204978:	00006697          	auipc	a3,0x6
ffffffffc020497c:	4c068693          	addi	a3,a3,1216 # ffffffffc020ae38 <default_pmm_manager+0xfa0>
ffffffffc0204980:	00005617          	auipc	a2,0x5
ffffffffc0204984:	dd060613          	addi	a2,a2,-560 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0204988:	14b00593          	li	a1,331
ffffffffc020498c:	00006517          	auipc	a0,0x6
ffffffffc0204990:	1c450513          	addi	a0,a0,452 # ffffffffc020ab50 <default_pmm_manager+0xcb8>
ffffffffc0204994:	af5fb0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0204998 <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0204998:	7139                	addi	sp,sp,-64
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc020499a:	85b2                	mv	a1,a2
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc020499c:	f822                	sd	s0,48(sp)
ffffffffc020499e:	f426                	sd	s1,40(sp)
ffffffffc02049a0:	fc06                	sd	ra,56(sp)
ffffffffc02049a2:	f04a                	sd	s2,32(sp)
ffffffffc02049a4:	ec4e                	sd	s3,24(sp)
ffffffffc02049a6:	8432                	mv	s0,a2
ffffffffc02049a8:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc02049aa:	f86ff0ef          	jal	ra,ffffffffc0204130 <find_vma>

    pgfault_num++;
ffffffffc02049ae:	000c5797          	auipc	a5,0xc5
ffffffffc02049b2:	8ce78793          	addi	a5,a5,-1842 # ffffffffc02c927c <pgfault_num>
ffffffffc02049b6:	439c                	lw	a5,0(a5)
ffffffffc02049b8:	2785                	addiw	a5,a5,1
ffffffffc02049ba:	000c5717          	auipc	a4,0xc5
ffffffffc02049be:	8cf72123          	sw	a5,-1854(a4) # ffffffffc02c927c <pgfault_num>
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc02049c2:	c555                	beqz	a0,ffffffffc0204a6e <do_pgfault+0xd6>
ffffffffc02049c4:	651c                	ld	a5,8(a0)
ffffffffc02049c6:	0af46463          	bltu	s0,a5,ffffffffc0204a6e <do_pgfault+0xd6>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc02049ca:	4d1c                	lw	a5,24(a0)
    uint32_t perm = PTE_U;
ffffffffc02049cc:	49c1                	li	s3,16
    if (vma->vm_flags & VM_WRITE) {
ffffffffc02049ce:	8b89                	andi	a5,a5,2
ffffffffc02049d0:	e3a5                	bnez	a5,ffffffffc0204a30 <do_pgfault+0x98>
        perm |= READ_WRITE;
    }
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc02049d2:	767d                	lui	a2,0xfffff
    *   mm->pgdir : the PDT of these vma
    *
    */
    // try to find a pte, if pte's PT(Page Table) isn't existed, then create a PT.
    // (notice the 3th parameter '1')
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc02049d4:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc02049d6:	8c71                	and	s0,s0,a2
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc02049d8:	85a2                	mv	a1,s0
ffffffffc02049da:	4605                	li	a2,1
ffffffffc02049dc:	d74fd0ef          	jal	ra,ffffffffc0201f50 <get_pte>
ffffffffc02049e0:	c945                	beqz	a0,ffffffffc0204a90 <do_pgfault+0xf8>
        cprintf("get_pte in do_pgfault failed\n");
        goto failed;
    }
    
    if (*ptep == 0) { // if the phy addr isn't exist, then alloc a page & map the phy addr with logical addr
ffffffffc02049e2:	610c                	ld	a1,0(a0)
ffffffffc02049e4:	c5b5                	beqz	a1,ffffffffc0204a50 <do_pgfault+0xb8>
        *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
        *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */
        if(swap_init_ok) {
ffffffffc02049e6:	000c5797          	auipc	a5,0xc5
ffffffffc02049ea:	89278793          	addi	a5,a5,-1902 # ffffffffc02c9278 <swap_init_ok>
ffffffffc02049ee:	439c                	lw	a5,0(a5)
ffffffffc02049f0:	2781                	sext.w	a5,a5
ffffffffc02049f2:	c7d9                	beqz	a5,ffffffffc0204a80 <do_pgfault+0xe8>
            //(2) According to the mm,
            //addr AND page, setup the
            //map of phy addr <--->
            //logical addr
            //(3) make the page swappable.
            if ((ret = swap_in(mm, addr, &page)) != 0) {
ffffffffc02049f4:	0030                	addi	a2,sp,8
ffffffffc02049f6:	85a2                	mv	a1,s0
ffffffffc02049f8:	8526                	mv	a0,s1
            struct Page *page=NULL;
ffffffffc02049fa:	e402                	sd	zero,8(sp)
            if ((ret = swap_in(mm, addr, &page)) != 0) {
ffffffffc02049fc:	a34ff0ef          	jal	ra,ffffffffc0203c30 <swap_in>
ffffffffc0204a00:	892a                	mv	s2,a0
ffffffffc0204a02:	e90d                	bnez	a0,ffffffffc0204a34 <do_pgfault+0x9c>
                cprintf("swap_in in do_pgfault failed\n");
                goto failed;
            }    
            page_insert(mm->pgdir, page, addr, perm);
ffffffffc0204a04:	65a2                	ld	a1,8(sp)
ffffffffc0204a06:	6c88                	ld	a0,24(s1)
ffffffffc0204a08:	86ce                	mv	a3,s3
ffffffffc0204a0a:	8622                	mv	a2,s0
ffffffffc0204a0c:	b5bfd0ef          	jal	ra,ffffffffc0202566 <page_insert>
            swap_map_swappable(mm, addr, page, 1);
ffffffffc0204a10:	6622                	ld	a2,8(sp)
ffffffffc0204a12:	4685                	li	a3,1
ffffffffc0204a14:	85a2                	mv	a1,s0
ffffffffc0204a16:	8526                	mv	a0,s1
ffffffffc0204a18:	8f4ff0ef          	jal	ra,ffffffffc0203b0c <swap_map_swappable>
            page->pra_vaddr = addr;
ffffffffc0204a1c:	67a2                	ld	a5,8(sp)
ffffffffc0204a1e:	ff80                	sd	s0,56(a5)
        }
   }
   ret = 0;
failed:
    return ret;
}
ffffffffc0204a20:	70e2                	ld	ra,56(sp)
ffffffffc0204a22:	7442                	ld	s0,48(sp)
ffffffffc0204a24:	854a                	mv	a0,s2
ffffffffc0204a26:	74a2                	ld	s1,40(sp)
ffffffffc0204a28:	7902                	ld	s2,32(sp)
ffffffffc0204a2a:	69e2                	ld	s3,24(sp)
ffffffffc0204a2c:	6121                	addi	sp,sp,64
ffffffffc0204a2e:	8082                	ret
        perm |= READ_WRITE;
ffffffffc0204a30:	49dd                	li	s3,23
ffffffffc0204a32:	b745                	j	ffffffffc02049d2 <do_pgfault+0x3a>
                cprintf("swap_in in do_pgfault failed\n");
ffffffffc0204a34:	00006517          	auipc	a0,0x6
ffffffffc0204a38:	1a450513          	addi	a0,a0,420 # ffffffffc020abd8 <default_pmm_manager+0xd40>
ffffffffc0204a3c:	f56fb0ef          	jal	ra,ffffffffc0200192 <cprintf>
}
ffffffffc0204a40:	70e2                	ld	ra,56(sp)
ffffffffc0204a42:	7442                	ld	s0,48(sp)
ffffffffc0204a44:	854a                	mv	a0,s2
ffffffffc0204a46:	74a2                	ld	s1,40(sp)
ffffffffc0204a48:	7902                	ld	s2,32(sp)
ffffffffc0204a4a:	69e2                	ld	s3,24(sp)
ffffffffc0204a4c:	6121                	addi	sp,sp,64
ffffffffc0204a4e:	8082                	ret
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0204a50:	6c88                	ld	a0,24(s1)
ffffffffc0204a52:	864e                	mv	a2,s3
ffffffffc0204a54:	85a2                	mv	a1,s0
ffffffffc0204a56:	893fe0ef          	jal	ra,ffffffffc02032e8 <pgdir_alloc_page>
   ret = 0;
ffffffffc0204a5a:	4901                	li	s2,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0204a5c:	f171                	bnez	a0,ffffffffc0204a20 <do_pgfault+0x88>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc0204a5e:	00006517          	auipc	a0,0x6
ffffffffc0204a62:	15250513          	addi	a0,a0,338 # ffffffffc020abb0 <default_pmm_manager+0xd18>
ffffffffc0204a66:	f2cfb0ef          	jal	ra,ffffffffc0200192 <cprintf>
    ret = -E_NO_MEM;
ffffffffc0204a6a:	5971                	li	s2,-4
            goto failed;
ffffffffc0204a6c:	bf55                	j	ffffffffc0204a20 <do_pgfault+0x88>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc0204a6e:	85a2                	mv	a1,s0
ffffffffc0204a70:	00006517          	auipc	a0,0x6
ffffffffc0204a74:	0f050513          	addi	a0,a0,240 # ffffffffc020ab60 <default_pmm_manager+0xcc8>
ffffffffc0204a78:	f1afb0ef          	jal	ra,ffffffffc0200192 <cprintf>
    int ret = -E_INVAL;
ffffffffc0204a7c:	5975                	li	s2,-3
        goto failed;
ffffffffc0204a7e:	b74d                	j	ffffffffc0204a20 <do_pgfault+0x88>
            cprintf("no swap_init_ok but ptep is %x, failed\n",*ptep);
ffffffffc0204a80:	00006517          	auipc	a0,0x6
ffffffffc0204a84:	17850513          	addi	a0,a0,376 # ffffffffc020abf8 <default_pmm_manager+0xd60>
ffffffffc0204a88:	f0afb0ef          	jal	ra,ffffffffc0200192 <cprintf>
    ret = -E_NO_MEM;
ffffffffc0204a8c:	5971                	li	s2,-4
            goto failed;
ffffffffc0204a8e:	bf49                	j	ffffffffc0204a20 <do_pgfault+0x88>
        cprintf("get_pte in do_pgfault failed\n");
ffffffffc0204a90:	00006517          	auipc	a0,0x6
ffffffffc0204a94:	10050513          	addi	a0,a0,256 # ffffffffc020ab90 <default_pmm_manager+0xcf8>
ffffffffc0204a98:	efafb0ef          	jal	ra,ffffffffc0200192 <cprintf>
    ret = -E_NO_MEM;
ffffffffc0204a9c:	5971                	li	s2,-4
        goto failed;
ffffffffc0204a9e:	b749                	j	ffffffffc0204a20 <do_pgfault+0x88>

ffffffffc0204aa0 <user_mem_check>:

bool
user_mem_check(struct mm_struct *mm, uintptr_t addr, size_t len, bool write) {
ffffffffc0204aa0:	7179                	addi	sp,sp,-48
ffffffffc0204aa2:	f022                	sd	s0,32(sp)
ffffffffc0204aa4:	f406                	sd	ra,40(sp)
ffffffffc0204aa6:	ec26                	sd	s1,24(sp)
ffffffffc0204aa8:	e84a                	sd	s2,16(sp)
ffffffffc0204aaa:	e44e                	sd	s3,8(sp)
ffffffffc0204aac:	e052                	sd	s4,0(sp)
ffffffffc0204aae:	842e                	mv	s0,a1
    if (mm != NULL) {
ffffffffc0204ab0:	c135                	beqz	a0,ffffffffc0204b14 <user_mem_check+0x74>
        if (!USER_ACCESS(addr, addr + len)) {
ffffffffc0204ab2:	002007b7          	lui	a5,0x200
ffffffffc0204ab6:	04f5e663          	bltu	a1,a5,ffffffffc0204b02 <user_mem_check+0x62>
ffffffffc0204aba:	00c584b3          	add	s1,a1,a2
ffffffffc0204abe:	0495f263          	bleu	s1,a1,ffffffffc0204b02 <user_mem_check+0x62>
ffffffffc0204ac2:	4785                	li	a5,1
ffffffffc0204ac4:	07fe                	slli	a5,a5,0x1f
ffffffffc0204ac6:	0297ee63          	bltu	a5,s1,ffffffffc0204b02 <user_mem_check+0x62>
ffffffffc0204aca:	892a                	mv	s2,a0
ffffffffc0204acc:	89b6                	mv	s3,a3
            }
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
                return 0;
            }
            if (write && (vma->vm_flags & VM_STACK)) {
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc0204ace:	6a05                	lui	s4,0x1
ffffffffc0204ad0:	a821                	j	ffffffffc0204ae8 <user_mem_check+0x48>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc0204ad2:	0027f693          	andi	a3,a5,2
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc0204ad6:	9752                	add	a4,a4,s4
            if (write && (vma->vm_flags & VM_STACK)) {
ffffffffc0204ad8:	8ba1                	andi	a5,a5,8
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc0204ada:	c685                	beqz	a3,ffffffffc0204b02 <user_mem_check+0x62>
            if (write && (vma->vm_flags & VM_STACK)) {
ffffffffc0204adc:	c399                	beqz	a5,ffffffffc0204ae2 <user_mem_check+0x42>
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc0204ade:	02e46263          	bltu	s0,a4,ffffffffc0204b02 <user_mem_check+0x62>
                    return 0;
                }
            }
            start = vma->vm_end;
ffffffffc0204ae2:	6900                	ld	s0,16(a0)
        while (start < end) {
ffffffffc0204ae4:	04947663          	bleu	s1,s0,ffffffffc0204b30 <user_mem_check+0x90>
            if ((vma = find_vma(mm, start)) == NULL || start < vma->vm_start) {
ffffffffc0204ae8:	85a2                	mv	a1,s0
ffffffffc0204aea:	854a                	mv	a0,s2
ffffffffc0204aec:	e44ff0ef          	jal	ra,ffffffffc0204130 <find_vma>
ffffffffc0204af0:	c909                	beqz	a0,ffffffffc0204b02 <user_mem_check+0x62>
ffffffffc0204af2:	6518                	ld	a4,8(a0)
ffffffffc0204af4:	00e46763          	bltu	s0,a4,ffffffffc0204b02 <user_mem_check+0x62>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc0204af8:	4d1c                	lw	a5,24(a0)
ffffffffc0204afa:	fc099ce3          	bnez	s3,ffffffffc0204ad2 <user_mem_check+0x32>
ffffffffc0204afe:	8b85                	andi	a5,a5,1
ffffffffc0204b00:	f3ed                	bnez	a5,ffffffffc0204ae2 <user_mem_check+0x42>
            return 0;
ffffffffc0204b02:	4501                	li	a0,0
        }
        return 1;
    }
    return KERN_ACCESS(addr, addr + len);
}
ffffffffc0204b04:	70a2                	ld	ra,40(sp)
ffffffffc0204b06:	7402                	ld	s0,32(sp)
ffffffffc0204b08:	64e2                	ld	s1,24(sp)
ffffffffc0204b0a:	6942                	ld	s2,16(sp)
ffffffffc0204b0c:	69a2                	ld	s3,8(sp)
ffffffffc0204b0e:	6a02                	ld	s4,0(sp)
ffffffffc0204b10:	6145                	addi	sp,sp,48
ffffffffc0204b12:	8082                	ret
    return KERN_ACCESS(addr, addr + len);
ffffffffc0204b14:	c02007b7          	lui	a5,0xc0200
ffffffffc0204b18:	4501                	li	a0,0
ffffffffc0204b1a:	fef5e5e3          	bltu	a1,a5,ffffffffc0204b04 <user_mem_check+0x64>
ffffffffc0204b1e:	962e                	add	a2,a2,a1
ffffffffc0204b20:	fec5f2e3          	bleu	a2,a1,ffffffffc0204b04 <user_mem_check+0x64>
ffffffffc0204b24:	c8000537          	lui	a0,0xc8000
ffffffffc0204b28:	0505                	addi	a0,a0,1
ffffffffc0204b2a:	00a63533          	sltu	a0,a2,a0
ffffffffc0204b2e:	bfd9                	j	ffffffffc0204b04 <user_mem_check+0x64>
        return 1;
ffffffffc0204b30:	4505                	li	a0,1
ffffffffc0204b32:	bfc9                	j	ffffffffc0204b04 <user_mem_check+0x64>

ffffffffc0204b34 <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc0204b34:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0204b36:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc0204b38:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0204b3a:	abdfb0ef          	jal	ra,ffffffffc02005f6 <ide_device_valid>
ffffffffc0204b3e:	cd01                	beqz	a0,ffffffffc0204b56 <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0204b40:	4505                	li	a0,1
ffffffffc0204b42:	abbfb0ef          	jal	ra,ffffffffc02005fc <ide_device_size>
}
ffffffffc0204b46:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0204b48:	810d                	srli	a0,a0,0x3
ffffffffc0204b4a:	000c5797          	auipc	a5,0xc5
ffffffffc0204b4e:	82a7b723          	sd	a0,-2002(a5) # ffffffffc02c9378 <max_swap_offset>
}
ffffffffc0204b52:	0141                	addi	sp,sp,16
ffffffffc0204b54:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc0204b56:	00006617          	auipc	a2,0x6
ffffffffc0204b5a:	38a60613          	addi	a2,a2,906 # ffffffffc020aee0 <default_pmm_manager+0x1048>
ffffffffc0204b5e:	45b5                	li	a1,13
ffffffffc0204b60:	00006517          	auipc	a0,0x6
ffffffffc0204b64:	3a050513          	addi	a0,a0,928 # ffffffffc020af00 <default_pmm_manager+0x1068>
ffffffffc0204b68:	921fb0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0204b6c <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
ffffffffc0204b6c:	1141                	addi	sp,sp,-16
ffffffffc0204b6e:	e406                	sd	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204b70:	00855793          	srli	a5,a0,0x8
ffffffffc0204b74:	cfb9                	beqz	a5,ffffffffc0204bd2 <swapfs_read+0x66>
ffffffffc0204b76:	000c5717          	auipc	a4,0xc5
ffffffffc0204b7a:	80270713          	addi	a4,a4,-2046 # ffffffffc02c9378 <max_swap_offset>
ffffffffc0204b7e:	6318                	ld	a4,0(a4)
ffffffffc0204b80:	04e7f963          	bleu	a4,a5,ffffffffc0204bd2 <swapfs_read+0x66>
    return page - pages + nbase;
ffffffffc0204b84:	000c4717          	auipc	a4,0xc4
ffffffffc0204b88:	76470713          	addi	a4,a4,1892 # ffffffffc02c92e8 <pages>
ffffffffc0204b8c:	6310                	ld	a2,0(a4)
ffffffffc0204b8e:	00007717          	auipc	a4,0x7
ffffffffc0204b92:	41270713          	addi	a4,a4,1042 # ffffffffc020bfa0 <nbase>
    return KADDR(page2pa(page));
ffffffffc0204b96:	000c4697          	auipc	a3,0xc4
ffffffffc0204b9a:	6d268693          	addi	a3,a3,1746 # ffffffffc02c9268 <npage>
    return page - pages + nbase;
ffffffffc0204b9e:	40c58633          	sub	a2,a1,a2
ffffffffc0204ba2:	630c                	ld	a1,0(a4)
ffffffffc0204ba4:	8619                	srai	a2,a2,0x6
    return KADDR(page2pa(page));
ffffffffc0204ba6:	577d                	li	a4,-1
ffffffffc0204ba8:	6294                	ld	a3,0(a3)
    return page - pages + nbase;
ffffffffc0204baa:	962e                	add	a2,a2,a1
    return KADDR(page2pa(page));
ffffffffc0204bac:	8331                	srli	a4,a4,0xc
ffffffffc0204bae:	8f71                	and	a4,a4,a2
ffffffffc0204bb0:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204bb4:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc0204bb6:	02d77a63          	bleu	a3,a4,ffffffffc0204bea <swapfs_read+0x7e>
ffffffffc0204bba:	000c4797          	auipc	a5,0xc4
ffffffffc0204bbe:	71e78793          	addi	a5,a5,1822 # ffffffffc02c92d8 <va_pa_offset>
ffffffffc0204bc2:	639c                	ld	a5,0(a5)
}
ffffffffc0204bc4:	60a2                	ld	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204bc6:	46a1                	li	a3,8
ffffffffc0204bc8:	963e                	add	a2,a2,a5
ffffffffc0204bca:	4505                	li	a0,1
}
ffffffffc0204bcc:	0141                	addi	sp,sp,16
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204bce:	a35fb06f          	j	ffffffffc0200602 <ide_read_secs>
ffffffffc0204bd2:	86aa                	mv	a3,a0
ffffffffc0204bd4:	00006617          	auipc	a2,0x6
ffffffffc0204bd8:	34460613          	addi	a2,a2,836 # ffffffffc020af18 <default_pmm_manager+0x1080>
ffffffffc0204bdc:	45d1                	li	a1,20
ffffffffc0204bde:	00006517          	auipc	a0,0x6
ffffffffc0204be2:	32250513          	addi	a0,a0,802 # ffffffffc020af00 <default_pmm_manager+0x1068>
ffffffffc0204be6:	8a3fb0ef          	jal	ra,ffffffffc0200488 <__panic>
ffffffffc0204bea:	86b2                	mv	a3,a2
ffffffffc0204bec:	06900593          	li	a1,105
ffffffffc0204bf0:	00005617          	auipc	a2,0x5
ffffffffc0204bf4:	2f860613          	addi	a2,a2,760 # ffffffffc0209ee8 <default_pmm_manager+0x50>
ffffffffc0204bf8:	00005517          	auipc	a0,0x5
ffffffffc0204bfc:	31850513          	addi	a0,a0,792 # ffffffffc0209f10 <default_pmm_manager+0x78>
ffffffffc0204c00:	889fb0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0204c04 <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc0204c04:	1141                	addi	sp,sp,-16
ffffffffc0204c06:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204c08:	00855793          	srli	a5,a0,0x8
ffffffffc0204c0c:	cfb9                	beqz	a5,ffffffffc0204c6a <swapfs_write+0x66>
ffffffffc0204c0e:	000c4717          	auipc	a4,0xc4
ffffffffc0204c12:	76a70713          	addi	a4,a4,1898 # ffffffffc02c9378 <max_swap_offset>
ffffffffc0204c16:	6318                	ld	a4,0(a4)
ffffffffc0204c18:	04e7f963          	bleu	a4,a5,ffffffffc0204c6a <swapfs_write+0x66>
    return page - pages + nbase;
ffffffffc0204c1c:	000c4717          	auipc	a4,0xc4
ffffffffc0204c20:	6cc70713          	addi	a4,a4,1740 # ffffffffc02c92e8 <pages>
ffffffffc0204c24:	6310                	ld	a2,0(a4)
ffffffffc0204c26:	00007717          	auipc	a4,0x7
ffffffffc0204c2a:	37a70713          	addi	a4,a4,890 # ffffffffc020bfa0 <nbase>
    return KADDR(page2pa(page));
ffffffffc0204c2e:	000c4697          	auipc	a3,0xc4
ffffffffc0204c32:	63a68693          	addi	a3,a3,1594 # ffffffffc02c9268 <npage>
    return page - pages + nbase;
ffffffffc0204c36:	40c58633          	sub	a2,a1,a2
ffffffffc0204c3a:	630c                	ld	a1,0(a4)
ffffffffc0204c3c:	8619                	srai	a2,a2,0x6
    return KADDR(page2pa(page));
ffffffffc0204c3e:	577d                	li	a4,-1
ffffffffc0204c40:	6294                	ld	a3,0(a3)
    return page - pages + nbase;
ffffffffc0204c42:	962e                	add	a2,a2,a1
    return KADDR(page2pa(page));
ffffffffc0204c44:	8331                	srli	a4,a4,0xc
ffffffffc0204c46:	8f71                	and	a4,a4,a2
ffffffffc0204c48:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204c4c:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc0204c4e:	02d77a63          	bleu	a3,a4,ffffffffc0204c82 <swapfs_write+0x7e>
ffffffffc0204c52:	000c4797          	auipc	a5,0xc4
ffffffffc0204c56:	68678793          	addi	a5,a5,1670 # ffffffffc02c92d8 <va_pa_offset>
ffffffffc0204c5a:	639c                	ld	a5,0(a5)
}
ffffffffc0204c5c:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204c5e:	46a1                	li	a3,8
ffffffffc0204c60:	963e                	add	a2,a2,a5
ffffffffc0204c62:	4505                	li	a0,1
}
ffffffffc0204c64:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204c66:	9c1fb06f          	j	ffffffffc0200626 <ide_write_secs>
ffffffffc0204c6a:	86aa                	mv	a3,a0
ffffffffc0204c6c:	00006617          	auipc	a2,0x6
ffffffffc0204c70:	2ac60613          	addi	a2,a2,684 # ffffffffc020af18 <default_pmm_manager+0x1080>
ffffffffc0204c74:	45e5                	li	a1,25
ffffffffc0204c76:	00006517          	auipc	a0,0x6
ffffffffc0204c7a:	28a50513          	addi	a0,a0,650 # ffffffffc020af00 <default_pmm_manager+0x1068>
ffffffffc0204c7e:	80bfb0ef          	jal	ra,ffffffffc0200488 <__panic>
ffffffffc0204c82:	86b2                	mv	a3,a2
ffffffffc0204c84:	06900593          	li	a1,105
ffffffffc0204c88:	00005617          	auipc	a2,0x5
ffffffffc0204c8c:	26060613          	addi	a2,a2,608 # ffffffffc0209ee8 <default_pmm_manager+0x50>
ffffffffc0204c90:	00005517          	auipc	a0,0x5
ffffffffc0204c94:	28050513          	addi	a0,a0,640 # ffffffffc0209f10 <default_pmm_manager+0x78>
ffffffffc0204c98:	ff0fb0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0204c9c <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)
	move a0, s1
ffffffffc0204c9c:	8526                	mv	a0,s1
	jalr s0
ffffffffc0204c9e:	9402                	jalr	s0

	jal do_exit
ffffffffc0204ca0:	756000ef          	jal	ra,ffffffffc02053f6 <do_exit>

ffffffffc0204ca4 <alloc_proc>:
void forkrets(struct trapframe *tf);
void switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void) {
ffffffffc0204ca4:	1141                	addi	sp,sp,-16
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0204ca6:	14800513          	li	a0,328
alloc_proc(void) {
ffffffffc0204caa:	e022                	sd	s0,0(sp)
ffffffffc0204cac:	e406                	sd	ra,8(sp)
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0204cae:	f99fc0ef          	jal	ra,ffffffffc0201c46 <kmalloc>
ffffffffc0204cb2:	842a                	mv	s0,a0
    if (proc != NULL) {
ffffffffc0204cb4:	cd3d                	beqz	a0,ffffffffc0204d32 <alloc_proc+0x8e>
     *     int time_slice;                             // time slice for occupying the CPU
     *     skew_heap_entry_t lab6_run_pool;            // FOR LAB6 ONLY: the entry in the run pool
     *     uint32_t lab6_stride;                       // FOR LAB6 ONLY: the current stride of the process
     *     uint32_t lab6_priority;                     // FOR LAB6 ONLY: the priority of process, set by lab6_set_priority(uint32_t)
     */
        proc->state = PROC_UNINIT;
ffffffffc0204cb6:	57fd                	li	a5,-1
ffffffffc0204cb8:	1782                	slli	a5,a5,0x20
ffffffffc0204cba:	e11c                	sd	a5,0(a0)
        proc->runs = 0;
        proc->kstack = 0;
        proc->need_resched = 0;
        proc->parent = NULL;
        proc->mm = NULL;
        memset(&(proc->context), 0, sizeof(struct context));
ffffffffc0204cbc:	07000613          	li	a2,112
ffffffffc0204cc0:	4581                	li	a1,0
        proc->runs = 0;
ffffffffc0204cc2:	00052423          	sw	zero,8(a0)
        proc->kstack = 0;
ffffffffc0204cc6:	00053823          	sd	zero,16(a0)
        proc->need_resched = 0;
ffffffffc0204cca:	00053c23          	sd	zero,24(a0)
        proc->parent = NULL;
ffffffffc0204cce:	02053023          	sd	zero,32(a0)
        proc->mm = NULL;
ffffffffc0204cd2:	02053423          	sd	zero,40(a0)
        memset(&(proc->context), 0, sizeof(struct context));
ffffffffc0204cd6:	03050513          	addi	a0,a0,48
ffffffffc0204cda:	45c040ef          	jal	ra,ffffffffc0209136 <memset>
        proc->tf = NULL;
        proc->cr3 = boot_cr3;
ffffffffc0204cde:	000c4797          	auipc	a5,0xc4
ffffffffc0204ce2:	60278793          	addi	a5,a5,1538 # ffffffffc02c92e0 <boot_cr3>
ffffffffc0204ce6:	639c                	ld	a5,0(a5)
        proc->tf = NULL;
ffffffffc0204ce8:	0a043023          	sd	zero,160(s0)
        proc->flags = 0;
ffffffffc0204cec:	0a042823          	sw	zero,176(s0)
        proc->cr3 = boot_cr3;
ffffffffc0204cf0:	f45c                	sd	a5,168(s0)
        memset(proc->name, 0, PROC_NAME_LEN);
ffffffffc0204cf2:	463d                	li	a2,15
ffffffffc0204cf4:	4581                	li	a1,0
ffffffffc0204cf6:	0b440513          	addi	a0,s0,180
ffffffffc0204cfa:	43c040ef          	jal	ra,ffffffffc0209136 <memset>
        proc->wait_state = 0;
        proc->cptr = NULL;
        proc->optr = NULL;
        proc->yptr = NULL;
        proc->rq = NULL;
        list_init(&(proc->run_link));
ffffffffc0204cfe:	11040793          	addi	a5,s0,272
        proc->wait_state = 0;
ffffffffc0204d02:	0e042623          	sw	zero,236(s0)
        proc->cptr = NULL;
ffffffffc0204d06:	0e043823          	sd	zero,240(s0)
        proc->optr = NULL;
ffffffffc0204d0a:	10043023          	sd	zero,256(s0)
        proc->yptr = NULL;
ffffffffc0204d0e:	0e043c23          	sd	zero,248(s0)
        proc->rq = NULL;
ffffffffc0204d12:	10043423          	sd	zero,264(s0)
    elm->prev = elm->next = elm;
ffffffffc0204d16:	10f43c23          	sd	a5,280(s0)
ffffffffc0204d1a:	10f43823          	sd	a5,272(s0)
        proc->time_slice = 0;
ffffffffc0204d1e:	12042023          	sw	zero,288(s0)
     compare_f comp) __attribute__((always_inline));

static inline void
skew_heap_init(skew_heap_entry_t *a)
{
     a->left = a->right = a->parent = NULL;
ffffffffc0204d22:	12043423          	sd	zero,296(s0)
ffffffffc0204d26:	12043823          	sd	zero,304(s0)
ffffffffc0204d2a:	12043c23          	sd	zero,312(s0)
        skew_heap_init(&(proc->lab6_run_pool));
        proc->lab6_stride = 0;
ffffffffc0204d2e:	14043023          	sd	zero,320(s0)
        proc->lab6_priority = 0;
    }
    return proc;
}
ffffffffc0204d32:	8522                	mv	a0,s0
ffffffffc0204d34:	60a2                	ld	ra,8(sp)
ffffffffc0204d36:	6402                	ld	s0,0(sp)
ffffffffc0204d38:	0141                	addi	sp,sp,16
ffffffffc0204d3a:	8082                	ret

ffffffffc0204d3c <forkret>:
// forkret -- the first kernel entry point of a new thread/process
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void) {
    forkrets(current->tf);
ffffffffc0204d3c:	000c4797          	auipc	a5,0xc4
ffffffffc0204d40:	54478793          	addi	a5,a5,1348 # ffffffffc02c9280 <current>
ffffffffc0204d44:	639c                	ld	a5,0(a5)
ffffffffc0204d46:	73c8                	ld	a0,160(a5)
ffffffffc0204d48:	852fc06f          	j	ffffffffc0200d9a <forkrets>

ffffffffc0204d4c <user_main>:

// user_main - kernel thread used to exec a user program
static int
user_main(void *arg) {
#ifdef TEST
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204d4c:	000c4797          	auipc	a5,0xc4
ffffffffc0204d50:	53478793          	addi	a5,a5,1332 # ffffffffc02c9280 <current>
ffffffffc0204d54:	639c                	ld	a5,0(a5)
user_main(void *arg) {
ffffffffc0204d56:	7139                	addi	sp,sp,-64
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204d58:	00006617          	auipc	a2,0x6
ffffffffc0204d5c:	5e860613          	addi	a2,a2,1512 # ffffffffc020b340 <default_pmm_manager+0x14a8>
ffffffffc0204d60:	43cc                	lw	a1,4(a5)
ffffffffc0204d62:	00006517          	auipc	a0,0x6
ffffffffc0204d66:	5ee50513          	addi	a0,a0,1518 # ffffffffc020b350 <default_pmm_manager+0x14b8>
user_main(void *arg) {
ffffffffc0204d6a:	fc06                	sd	ra,56(sp)
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204d6c:	c26fb0ef          	jal	ra,ffffffffc0200192 <cprintf>
ffffffffc0204d70:	00006797          	auipc	a5,0x6
ffffffffc0204d74:	5d078793          	addi	a5,a5,1488 # ffffffffc020b340 <default_pmm_manager+0x14a8>
ffffffffc0204d78:	3fe06717          	auipc	a4,0x3fe06
ffffffffc0204d7c:	0f070713          	addi	a4,a4,240 # ae68 <_binary_obj___user_priority_out_size>
ffffffffc0204d80:	e43a                	sd	a4,8(sp)
    int64_t ret=0, len = strlen(name);
ffffffffc0204d82:	853e                	mv	a0,a5
ffffffffc0204d84:	0007b717          	auipc	a4,0x7b
ffffffffc0204d88:	09c70713          	addi	a4,a4,156 # ffffffffc027fe20 <_binary_obj___user_priority_out_start>
ffffffffc0204d8c:	f03a                	sd	a4,32(sp)
ffffffffc0204d8e:	f43e                	sd	a5,40(sp)
ffffffffc0204d90:	e802                	sd	zero,16(sp)
ffffffffc0204d92:	306040ef          	jal	ra,ffffffffc0209098 <strlen>
ffffffffc0204d96:	ec2a                	sd	a0,24(sp)
    asm volatile(
ffffffffc0204d98:	4511                	li	a0,4
ffffffffc0204d9a:	55a2                	lw	a1,40(sp)
ffffffffc0204d9c:	4662                	lw	a2,24(sp)
ffffffffc0204d9e:	5682                	lw	a3,32(sp)
ffffffffc0204da0:	4722                	lw	a4,8(sp)
ffffffffc0204da2:	48a9                	li	a7,10
ffffffffc0204da4:	9002                	ebreak
ffffffffc0204da6:	c82a                	sw	a0,16(sp)
    cprintf("ret = %d\n", ret);
ffffffffc0204da8:	65c2                	ld	a1,16(sp)
ffffffffc0204daa:	00006517          	auipc	a0,0x6
ffffffffc0204dae:	5ce50513          	addi	a0,a0,1486 # ffffffffc020b378 <default_pmm_manager+0x14e0>
ffffffffc0204db2:	be0fb0ef          	jal	ra,ffffffffc0200192 <cprintf>
#else
    KERNEL_EXECVE(priority);
#endif
    panic("user_main execve failed.\n");
ffffffffc0204db6:	00006617          	auipc	a2,0x6
ffffffffc0204dba:	5d260613          	addi	a2,a2,1490 # ffffffffc020b388 <default_pmm_manager+0x14f0>
ffffffffc0204dbe:	35f00593          	li	a1,863
ffffffffc0204dc2:	00006517          	auipc	a0,0x6
ffffffffc0204dc6:	5e650513          	addi	a0,a0,1510 # ffffffffc020b3a8 <default_pmm_manager+0x1510>
ffffffffc0204dca:	ebefb0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0204dce <put_pgdir>:
    return pa2page(PADDR(kva));
ffffffffc0204dce:	6d14                	ld	a3,24(a0)
put_pgdir(struct mm_struct *mm) {
ffffffffc0204dd0:	1141                	addi	sp,sp,-16
ffffffffc0204dd2:	e406                	sd	ra,8(sp)
ffffffffc0204dd4:	c02007b7          	lui	a5,0xc0200
ffffffffc0204dd8:	04f6e263          	bltu	a3,a5,ffffffffc0204e1c <put_pgdir+0x4e>
ffffffffc0204ddc:	000c4797          	auipc	a5,0xc4
ffffffffc0204de0:	4fc78793          	addi	a5,a5,1276 # ffffffffc02c92d8 <va_pa_offset>
ffffffffc0204de4:	6388                	ld	a0,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0204de6:	000c4797          	auipc	a5,0xc4
ffffffffc0204dea:	48278793          	addi	a5,a5,1154 # ffffffffc02c9268 <npage>
ffffffffc0204dee:	639c                	ld	a5,0(a5)
    return pa2page(PADDR(kva));
ffffffffc0204df0:	8e89                	sub	a3,a3,a0
    if (PPN(pa) >= npage) {
ffffffffc0204df2:	82b1                	srli	a3,a3,0xc
ffffffffc0204df4:	04f6f063          	bleu	a5,a3,ffffffffc0204e34 <put_pgdir+0x66>
    return &pages[PPN(pa) - nbase];
ffffffffc0204df8:	00007797          	auipc	a5,0x7
ffffffffc0204dfc:	1a878793          	addi	a5,a5,424 # ffffffffc020bfa0 <nbase>
ffffffffc0204e00:	639c                	ld	a5,0(a5)
ffffffffc0204e02:	000c4717          	auipc	a4,0xc4
ffffffffc0204e06:	4e670713          	addi	a4,a4,1254 # ffffffffc02c92e8 <pages>
ffffffffc0204e0a:	6308                	ld	a0,0(a4)
}
ffffffffc0204e0c:	60a2                	ld	ra,8(sp)
ffffffffc0204e0e:	8e9d                	sub	a3,a3,a5
ffffffffc0204e10:	069a                	slli	a3,a3,0x6
    free_page(kva2page(mm->pgdir));
ffffffffc0204e12:	4585                	li	a1,1
ffffffffc0204e14:	9536                	add	a0,a0,a3
}
ffffffffc0204e16:	0141                	addi	sp,sp,16
    free_page(kva2page(mm->pgdir));
ffffffffc0204e18:	8b2fd06f          	j	ffffffffc0201eca <free_pages>
    return pa2page(PADDR(kva));
ffffffffc0204e1c:	00005617          	auipc	a2,0x5
ffffffffc0204e20:	10460613          	addi	a2,a2,260 # ffffffffc0209f20 <default_pmm_manager+0x88>
ffffffffc0204e24:	06e00593          	li	a1,110
ffffffffc0204e28:	00005517          	auipc	a0,0x5
ffffffffc0204e2c:	0e850513          	addi	a0,a0,232 # ffffffffc0209f10 <default_pmm_manager+0x78>
ffffffffc0204e30:	e58fb0ef          	jal	ra,ffffffffc0200488 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0204e34:	00005617          	auipc	a2,0x5
ffffffffc0204e38:	11460613          	addi	a2,a2,276 # ffffffffc0209f48 <default_pmm_manager+0xb0>
ffffffffc0204e3c:	06200593          	li	a1,98
ffffffffc0204e40:	00005517          	auipc	a0,0x5
ffffffffc0204e44:	0d050513          	addi	a0,a0,208 # ffffffffc0209f10 <default_pmm_manager+0x78>
ffffffffc0204e48:	e40fb0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0204e4c <setup_pgdir>:
setup_pgdir(struct mm_struct *mm) {
ffffffffc0204e4c:	1101                	addi	sp,sp,-32
ffffffffc0204e4e:	e426                	sd	s1,8(sp)
ffffffffc0204e50:	84aa                	mv	s1,a0
    if ((page = alloc_page()) == NULL) {
ffffffffc0204e52:	4505                	li	a0,1
setup_pgdir(struct mm_struct *mm) {
ffffffffc0204e54:	ec06                	sd	ra,24(sp)
ffffffffc0204e56:	e822                	sd	s0,16(sp)
    if ((page = alloc_page()) == NULL) {
ffffffffc0204e58:	febfc0ef          	jal	ra,ffffffffc0201e42 <alloc_pages>
ffffffffc0204e5c:	c125                	beqz	a0,ffffffffc0204ebc <setup_pgdir+0x70>
    return page - pages + nbase;
ffffffffc0204e5e:	000c4797          	auipc	a5,0xc4
ffffffffc0204e62:	48a78793          	addi	a5,a5,1162 # ffffffffc02c92e8 <pages>
ffffffffc0204e66:	6394                	ld	a3,0(a5)
ffffffffc0204e68:	00007797          	auipc	a5,0x7
ffffffffc0204e6c:	13878793          	addi	a5,a5,312 # ffffffffc020bfa0 <nbase>
ffffffffc0204e70:	6380                	ld	s0,0(a5)
ffffffffc0204e72:	40d506b3          	sub	a3,a0,a3
    return KADDR(page2pa(page));
ffffffffc0204e76:	000c4717          	auipc	a4,0xc4
ffffffffc0204e7a:	3f270713          	addi	a4,a4,1010 # ffffffffc02c9268 <npage>
    return page - pages + nbase;
ffffffffc0204e7e:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0204e80:	57fd                	li	a5,-1
ffffffffc0204e82:	6318                	ld	a4,0(a4)
    return page - pages + nbase;
ffffffffc0204e84:	96a2                	add	a3,a3,s0
    return KADDR(page2pa(page));
ffffffffc0204e86:	83b1                	srli	a5,a5,0xc
ffffffffc0204e88:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204e8a:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204e8c:	02e7fa63          	bleu	a4,a5,ffffffffc0204ec0 <setup_pgdir+0x74>
ffffffffc0204e90:	000c4797          	auipc	a5,0xc4
ffffffffc0204e94:	44878793          	addi	a5,a5,1096 # ffffffffc02c92d8 <va_pa_offset>
ffffffffc0204e98:	6380                	ld	s0,0(a5)
    memcpy(pgdir, boot_pgdir, PGSIZE);
ffffffffc0204e9a:	000c4797          	auipc	a5,0xc4
ffffffffc0204e9e:	3c678793          	addi	a5,a5,966 # ffffffffc02c9260 <boot_pgdir>
ffffffffc0204ea2:	638c                	ld	a1,0(a5)
ffffffffc0204ea4:	9436                	add	s0,s0,a3
ffffffffc0204ea6:	6605                	lui	a2,0x1
ffffffffc0204ea8:	8522                	mv	a0,s0
ffffffffc0204eaa:	29e040ef          	jal	ra,ffffffffc0209148 <memcpy>
    return 0;
ffffffffc0204eae:	4501                	li	a0,0
    mm->pgdir = pgdir;
ffffffffc0204eb0:	ec80                	sd	s0,24(s1)
}
ffffffffc0204eb2:	60e2                	ld	ra,24(sp)
ffffffffc0204eb4:	6442                	ld	s0,16(sp)
ffffffffc0204eb6:	64a2                	ld	s1,8(sp)
ffffffffc0204eb8:	6105                	addi	sp,sp,32
ffffffffc0204eba:	8082                	ret
        return -E_NO_MEM;
ffffffffc0204ebc:	5571                	li	a0,-4
ffffffffc0204ebe:	bfd5                	j	ffffffffc0204eb2 <setup_pgdir+0x66>
ffffffffc0204ec0:	00005617          	auipc	a2,0x5
ffffffffc0204ec4:	02860613          	addi	a2,a2,40 # ffffffffc0209ee8 <default_pmm_manager+0x50>
ffffffffc0204ec8:	06900593          	li	a1,105
ffffffffc0204ecc:	00005517          	auipc	a0,0x5
ffffffffc0204ed0:	04450513          	addi	a0,a0,68 # ffffffffc0209f10 <default_pmm_manager+0x78>
ffffffffc0204ed4:	db4fb0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0204ed8 <set_proc_name>:
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc0204ed8:	1101                	addi	sp,sp,-32
ffffffffc0204eda:	e822                	sd	s0,16(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204edc:	0b450413          	addi	s0,a0,180
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc0204ee0:	e426                	sd	s1,8(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204ee2:	4641                	li	a2,16
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc0204ee4:	84ae                	mv	s1,a1
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204ee6:	8522                	mv	a0,s0
ffffffffc0204ee8:	4581                	li	a1,0
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc0204eea:	ec06                	sd	ra,24(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204eec:	24a040ef          	jal	ra,ffffffffc0209136 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204ef0:	8522                	mv	a0,s0
}
ffffffffc0204ef2:	6442                	ld	s0,16(sp)
ffffffffc0204ef4:	60e2                	ld	ra,24(sp)
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204ef6:	85a6                	mv	a1,s1
}
ffffffffc0204ef8:	64a2                	ld	s1,8(sp)
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204efa:	463d                	li	a2,15
}
ffffffffc0204efc:	6105                	addi	sp,sp,32
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204efe:	24a0406f          	j	ffffffffc0209148 <memcpy>

ffffffffc0204f02 <proc_run>:
proc_run(struct proc_struct *proc) {
ffffffffc0204f02:	1101                	addi	sp,sp,-32
    if (proc != current) {
ffffffffc0204f04:	000c4797          	auipc	a5,0xc4
ffffffffc0204f08:	37c78793          	addi	a5,a5,892 # ffffffffc02c9280 <current>
proc_run(struct proc_struct *proc) {
ffffffffc0204f0c:	e426                	sd	s1,8(sp)
    if (proc != current) {
ffffffffc0204f0e:	6384                	ld	s1,0(a5)
proc_run(struct proc_struct *proc) {
ffffffffc0204f10:	ec06                	sd	ra,24(sp)
ffffffffc0204f12:	e822                	sd	s0,16(sp)
ffffffffc0204f14:	e04a                	sd	s2,0(sp)
    if (proc != current) {
ffffffffc0204f16:	02a48b63          	beq	s1,a0,ffffffffc0204f4c <proc_run+0x4a>
ffffffffc0204f1a:	842a                	mv	s0,a0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204f1c:	100027f3          	csrr	a5,sstatus
ffffffffc0204f20:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0204f22:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204f24:	e3a9                	bnez	a5,ffffffffc0204f66 <proc_run+0x64>

#define barrier() __asm__ __volatile__ ("fence" ::: "memory")

static inline void
lcr3(unsigned long cr3) {
    write_csr(satp, 0x8000000000000000 | (cr3 >> RISCV_PGSHIFT));
ffffffffc0204f26:	745c                	ld	a5,168(s0)
            current = proc;
ffffffffc0204f28:	000c4717          	auipc	a4,0xc4
ffffffffc0204f2c:	34873c23          	sd	s0,856(a4) # ffffffffc02c9280 <current>
ffffffffc0204f30:	577d                	li	a4,-1
ffffffffc0204f32:	177e                	slli	a4,a4,0x3f
ffffffffc0204f34:	83b1                	srli	a5,a5,0xc
ffffffffc0204f36:	8fd9                	or	a5,a5,a4
ffffffffc0204f38:	18079073          	csrw	satp,a5
            switch_to(&(prev->context), &(next->context));
ffffffffc0204f3c:	03040593          	addi	a1,s0,48
ffffffffc0204f40:	03048513          	addi	a0,s1,48
ffffffffc0204f44:	00a010ef          	jal	ra,ffffffffc0205f4e <switch_to>
    if (flag) {
ffffffffc0204f48:	00091863          	bnez	s2,ffffffffc0204f58 <proc_run+0x56>
}
ffffffffc0204f4c:	60e2                	ld	ra,24(sp)
ffffffffc0204f4e:	6442                	ld	s0,16(sp)
ffffffffc0204f50:	64a2                	ld	s1,8(sp)
ffffffffc0204f52:	6902                	ld	s2,0(sp)
ffffffffc0204f54:	6105                	addi	sp,sp,32
ffffffffc0204f56:	8082                	ret
ffffffffc0204f58:	6442                	ld	s0,16(sp)
ffffffffc0204f5a:	60e2                	ld	ra,24(sp)
ffffffffc0204f5c:	64a2                	ld	s1,8(sp)
ffffffffc0204f5e:	6902                	ld	s2,0(sp)
ffffffffc0204f60:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0204f62:	eeafb06f          	j	ffffffffc020064c <intr_enable>
        intr_disable();
ffffffffc0204f66:	eecfb0ef          	jal	ra,ffffffffc0200652 <intr_disable>
        return 1;
ffffffffc0204f6a:	4905                	li	s2,1
ffffffffc0204f6c:	bf6d                	j	ffffffffc0204f26 <proc_run+0x24>

ffffffffc0204f6e <find_proc>:
    if (0 < pid && pid < MAX_PID) {
ffffffffc0204f6e:	0005071b          	sext.w	a4,a0
ffffffffc0204f72:	6789                	lui	a5,0x2
ffffffffc0204f74:	fff7069b          	addiw	a3,a4,-1
ffffffffc0204f78:	17f9                	addi	a5,a5,-2
ffffffffc0204f7a:	04d7e063          	bltu	a5,a3,ffffffffc0204fba <find_proc+0x4c>
find_proc(int pid) {
ffffffffc0204f7e:	1141                	addi	sp,sp,-16
ffffffffc0204f80:	e022                	sd	s0,0(sp)
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0204f82:	45a9                	li	a1,10
ffffffffc0204f84:	842a                	mv	s0,a0
ffffffffc0204f86:	853a                	mv	a0,a4
find_proc(int pid) {
ffffffffc0204f88:	e406                	sd	ra,8(sp)
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0204f8a:	4ff030ef          	jal	ra,ffffffffc0208c88 <hash32>
ffffffffc0204f8e:	02051693          	slli	a3,a0,0x20
ffffffffc0204f92:	82f1                	srli	a3,a3,0x1c
ffffffffc0204f94:	000c0517          	auipc	a0,0xc0
ffffffffc0204f98:	28450513          	addi	a0,a0,644 # ffffffffc02c5218 <hash_list>
ffffffffc0204f9c:	96aa                	add	a3,a3,a0
ffffffffc0204f9e:	87b6                	mv	a5,a3
        while ((le = list_next(le)) != list) {
ffffffffc0204fa0:	a029                	j	ffffffffc0204faa <find_proc+0x3c>
            if (proc->pid == pid) {
ffffffffc0204fa2:	f2c7a703          	lw	a4,-212(a5) # 1f2c <_binary_obj___user_faultread_out_size-0x79d4>
ffffffffc0204fa6:	00870c63          	beq	a4,s0,ffffffffc0204fbe <find_proc+0x50>
    return listelm->next;
ffffffffc0204faa:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0204fac:	fef69be3          	bne	a3,a5,ffffffffc0204fa2 <find_proc+0x34>
}
ffffffffc0204fb0:	60a2                	ld	ra,8(sp)
ffffffffc0204fb2:	6402                	ld	s0,0(sp)
    return NULL;
ffffffffc0204fb4:	4501                	li	a0,0
}
ffffffffc0204fb6:	0141                	addi	sp,sp,16
ffffffffc0204fb8:	8082                	ret
    return NULL;
ffffffffc0204fba:	4501                	li	a0,0
}
ffffffffc0204fbc:	8082                	ret
ffffffffc0204fbe:	60a2                	ld	ra,8(sp)
ffffffffc0204fc0:	6402                	ld	s0,0(sp)
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc0204fc2:	f2878513          	addi	a0,a5,-216
}
ffffffffc0204fc6:	0141                	addi	sp,sp,16
ffffffffc0204fc8:	8082                	ret

ffffffffc0204fca <do_fork>:
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc0204fca:	7159                	addi	sp,sp,-112
ffffffffc0204fcc:	e0d2                	sd	s4,64(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc0204fce:	000c4a17          	auipc	s4,0xc4
ffffffffc0204fd2:	2caa0a13          	addi	s4,s4,714 # ffffffffc02c9298 <nr_process>
ffffffffc0204fd6:	000a2703          	lw	a4,0(s4)
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc0204fda:	f486                	sd	ra,104(sp)
ffffffffc0204fdc:	f0a2                	sd	s0,96(sp)
ffffffffc0204fde:	eca6                	sd	s1,88(sp)
ffffffffc0204fe0:	e8ca                	sd	s2,80(sp)
ffffffffc0204fe2:	e4ce                	sd	s3,72(sp)
ffffffffc0204fe4:	fc56                	sd	s5,56(sp)
ffffffffc0204fe6:	f85a                	sd	s6,48(sp)
ffffffffc0204fe8:	f45e                	sd	s7,40(sp)
ffffffffc0204fea:	f062                	sd	s8,32(sp)
ffffffffc0204fec:	ec66                	sd	s9,24(sp)
ffffffffc0204fee:	e86a                	sd	s10,16(sp)
ffffffffc0204ff0:	e46e                	sd	s11,8(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc0204ff2:	6785                	lui	a5,0x1
ffffffffc0204ff4:	30f75a63          	ble	a5,a4,ffffffffc0205308 <do_fork+0x33e>
ffffffffc0204ff8:	89aa                	mv	s3,a0
ffffffffc0204ffa:	892e                	mv	s2,a1
ffffffffc0204ffc:	84b2                	mv	s1,a2
    if((proc = alloc_proc()) == NULL) {
ffffffffc0204ffe:	ca7ff0ef          	jal	ra,ffffffffc0204ca4 <alloc_proc>
ffffffffc0205002:	842a                	mv	s0,a0
ffffffffc0205004:	2e050463          	beqz	a0,ffffffffc02052ec <do_fork+0x322>
    proc->parent = current;
ffffffffc0205008:	000c4c17          	auipc	s8,0xc4
ffffffffc020500c:	278c0c13          	addi	s8,s8,632 # ffffffffc02c9280 <current>
ffffffffc0205010:	000c3783          	ld	a5,0(s8)
    assert(current->wait_state == 0);
ffffffffc0205014:	0ec7a703          	lw	a4,236(a5) # 10ec <_binary_obj___user_faultread_out_size-0x8814>
    proc->parent = current;
ffffffffc0205018:	f11c                	sd	a5,32(a0)
    assert(current->wait_state == 0);
ffffffffc020501a:	30071563          	bnez	a4,ffffffffc0205324 <do_fork+0x35a>
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc020501e:	4509                	li	a0,2
ffffffffc0205020:	e23fc0ef          	jal	ra,ffffffffc0201e42 <alloc_pages>
    if (page != NULL) {
ffffffffc0205024:	2c050163          	beqz	a0,ffffffffc02052e6 <do_fork+0x31c>
    return page - pages + nbase;
ffffffffc0205028:	000c4a97          	auipc	s5,0xc4
ffffffffc020502c:	2c0a8a93          	addi	s5,s5,704 # ffffffffc02c92e8 <pages>
ffffffffc0205030:	000ab683          	ld	a3,0(s5)
ffffffffc0205034:	00007b17          	auipc	s6,0x7
ffffffffc0205038:	f6cb0b13          	addi	s6,s6,-148 # ffffffffc020bfa0 <nbase>
ffffffffc020503c:	000b3783          	ld	a5,0(s6)
ffffffffc0205040:	40d506b3          	sub	a3,a0,a3
    return KADDR(page2pa(page));
ffffffffc0205044:	000c4b97          	auipc	s7,0xc4
ffffffffc0205048:	224b8b93          	addi	s7,s7,548 # ffffffffc02c9268 <npage>
    return page - pages + nbase;
ffffffffc020504c:	8699                	srai	a3,a3,0x6
ffffffffc020504e:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0205050:	000bb703          	ld	a4,0(s7)
ffffffffc0205054:	57fd                	li	a5,-1
ffffffffc0205056:	83b1                	srli	a5,a5,0xc
ffffffffc0205058:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc020505a:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020505c:	2ae7f863          	bleu	a4,a5,ffffffffc020530c <do_fork+0x342>
ffffffffc0205060:	000c4c97          	auipc	s9,0xc4
ffffffffc0205064:	278c8c93          	addi	s9,s9,632 # ffffffffc02c92d8 <va_pa_offset>
    struct mm_struct *mm, *oldmm = current->mm;
ffffffffc0205068:	000c3703          	ld	a4,0(s8)
ffffffffc020506c:	000cb783          	ld	a5,0(s9)
ffffffffc0205070:	02873c03          	ld	s8,40(a4)
ffffffffc0205074:	96be                	add	a3,a3,a5
        proc->kstack = (uintptr_t)page2kva(page);
ffffffffc0205076:	e814                	sd	a3,16(s0)
    if (oldmm == NULL) {
ffffffffc0205078:	020c0863          	beqz	s8,ffffffffc02050a8 <do_fork+0xde>
    if (clone_flags & CLONE_VM) {
ffffffffc020507c:	1009f993          	andi	s3,s3,256
ffffffffc0205080:	1e098163          	beqz	s3,ffffffffc0205262 <do_fork+0x298>
}

static inline int
mm_count_inc(struct mm_struct *mm) {
    mm->mm_count += 1;
ffffffffc0205084:	030c2703          	lw	a4,48(s8)
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc0205088:	018c3783          	ld	a5,24(s8)
ffffffffc020508c:	c02006b7          	lui	a3,0xc0200
ffffffffc0205090:	2705                	addiw	a4,a4,1
ffffffffc0205092:	02ec2823          	sw	a4,48(s8)
    proc->mm = mm;
ffffffffc0205096:	03843423          	sd	s8,40(s0)
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc020509a:	2ad7e563          	bltu	a5,a3,ffffffffc0205344 <do_fork+0x37a>
ffffffffc020509e:	000cb703          	ld	a4,0(s9)
ffffffffc02050a2:	6814                	ld	a3,16(s0)
ffffffffc02050a4:	8f99                	sub	a5,a5,a4
ffffffffc02050a6:	f45c                	sd	a5,168(s0)
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc02050a8:	6789                	lui	a5,0x2
ffffffffc02050aa:	ee078793          	addi	a5,a5,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x7a20>
ffffffffc02050ae:	96be                	add	a3,a3,a5
ffffffffc02050b0:	f054                	sd	a3,160(s0)
    *(proc->tf) = *tf;
ffffffffc02050b2:	87b6                	mv	a5,a3
ffffffffc02050b4:	12048813          	addi	a6,s1,288
ffffffffc02050b8:	6088                	ld	a0,0(s1)
ffffffffc02050ba:	648c                	ld	a1,8(s1)
ffffffffc02050bc:	6890                	ld	a2,16(s1)
ffffffffc02050be:	6c98                	ld	a4,24(s1)
ffffffffc02050c0:	e388                	sd	a0,0(a5)
ffffffffc02050c2:	e78c                	sd	a1,8(a5)
ffffffffc02050c4:	eb90                	sd	a2,16(a5)
ffffffffc02050c6:	ef98                	sd	a4,24(a5)
ffffffffc02050c8:	02048493          	addi	s1,s1,32
ffffffffc02050cc:	02078793          	addi	a5,a5,32
ffffffffc02050d0:	ff0494e3          	bne	s1,a6,ffffffffc02050b8 <do_fork+0xee>
    proc->tf->gpr.a0 = 0;
ffffffffc02050d4:	0406b823          	sd	zero,80(a3) # ffffffffc0200050 <kern_init+0x1a>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc02050d8:	12090e63          	beqz	s2,ffffffffc0205214 <do_fork+0x24a>
ffffffffc02050dc:	0126b823          	sd	s2,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc02050e0:	00000797          	auipc	a5,0x0
ffffffffc02050e4:	c5c78793          	addi	a5,a5,-932 # ffffffffc0204d3c <forkret>
ffffffffc02050e8:	f81c                	sd	a5,48(s0)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc02050ea:	fc14                	sd	a3,56(s0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02050ec:	100027f3          	csrr	a5,sstatus
ffffffffc02050f0:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02050f2:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02050f4:	12079f63          	bnez	a5,ffffffffc0205232 <do_fork+0x268>
    if (++ last_pid >= MAX_PID) {
ffffffffc02050f8:	000b9797          	auipc	a5,0xb9
ffffffffc02050fc:	d1878793          	addi	a5,a5,-744 # ffffffffc02bde10 <last_pid.1768>
ffffffffc0205100:	439c                	lw	a5,0(a5)
ffffffffc0205102:	6709                	lui	a4,0x2
ffffffffc0205104:	0017851b          	addiw	a0,a5,1
ffffffffc0205108:	000b9697          	auipc	a3,0xb9
ffffffffc020510c:	d0a6a423          	sw	a0,-760(a3) # ffffffffc02bde10 <last_pid.1768>
ffffffffc0205110:	14e55263          	ble	a4,a0,ffffffffc0205254 <do_fork+0x28a>
    if (last_pid >= next_safe) {
ffffffffc0205114:	000b9797          	auipc	a5,0xb9
ffffffffc0205118:	d0078793          	addi	a5,a5,-768 # ffffffffc02bde14 <next_safe.1767>
ffffffffc020511c:	439c                	lw	a5,0(a5)
ffffffffc020511e:	000c4497          	auipc	s1,0xc4
ffffffffc0205122:	2b248493          	addi	s1,s1,690 # ffffffffc02c93d0 <proc_list>
ffffffffc0205126:	06f54063          	blt	a0,a5,ffffffffc0205186 <do_fork+0x1bc>
        next_safe = MAX_PID;
ffffffffc020512a:	6789                	lui	a5,0x2
ffffffffc020512c:	000b9717          	auipc	a4,0xb9
ffffffffc0205130:	cef72423          	sw	a5,-792(a4) # ffffffffc02bde14 <next_safe.1767>
ffffffffc0205134:	4581                	li	a1,0
ffffffffc0205136:	87aa                	mv	a5,a0
ffffffffc0205138:	000c4497          	auipc	s1,0xc4
ffffffffc020513c:	29848493          	addi	s1,s1,664 # ffffffffc02c93d0 <proc_list>
    repeat:
ffffffffc0205140:	6889                	lui	a7,0x2
ffffffffc0205142:	882e                	mv	a6,a1
ffffffffc0205144:	6609                	lui	a2,0x2
        le = list;
ffffffffc0205146:	000c4697          	auipc	a3,0xc4
ffffffffc020514a:	28a68693          	addi	a3,a3,650 # ffffffffc02c93d0 <proc_list>
ffffffffc020514e:	6694                	ld	a3,8(a3)
        while ((le = list_next(le)) != list) {
ffffffffc0205150:	00968f63          	beq	a3,s1,ffffffffc020516e <do_fork+0x1a4>
            if (proc->pid == last_pid) {
ffffffffc0205154:	f3c6a703          	lw	a4,-196(a3)
ffffffffc0205158:	0ae78963          	beq	a5,a4,ffffffffc020520a <do_fork+0x240>
            else if (proc->pid > last_pid && next_safe > proc->pid) {
ffffffffc020515c:	fee7d9e3          	ble	a4,a5,ffffffffc020514e <do_fork+0x184>
ffffffffc0205160:	fec757e3          	ble	a2,a4,ffffffffc020514e <do_fork+0x184>
ffffffffc0205164:	6694                	ld	a3,8(a3)
ffffffffc0205166:	863a                	mv	a2,a4
ffffffffc0205168:	4805                	li	a6,1
        while ((le = list_next(le)) != list) {
ffffffffc020516a:	fe9695e3          	bne	a3,s1,ffffffffc0205154 <do_fork+0x18a>
ffffffffc020516e:	c591                	beqz	a1,ffffffffc020517a <do_fork+0x1b0>
ffffffffc0205170:	000b9717          	auipc	a4,0xb9
ffffffffc0205174:	caf72023          	sw	a5,-864(a4) # ffffffffc02bde10 <last_pid.1768>
ffffffffc0205178:	853e                	mv	a0,a5
ffffffffc020517a:	00080663          	beqz	a6,ffffffffc0205186 <do_fork+0x1bc>
ffffffffc020517e:	000b9797          	auipc	a5,0xb9
ffffffffc0205182:	c8c7ab23          	sw	a2,-874(a5) # ffffffffc02bde14 <next_safe.1767>
        proc->pid = get_pid();
ffffffffc0205186:	c048                	sw	a0,4(s0)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc0205188:	45a9                	li	a1,10
ffffffffc020518a:	2501                	sext.w	a0,a0
ffffffffc020518c:	2fd030ef          	jal	ra,ffffffffc0208c88 <hash32>
ffffffffc0205190:	1502                	slli	a0,a0,0x20
ffffffffc0205192:	000c0797          	auipc	a5,0xc0
ffffffffc0205196:	08678793          	addi	a5,a5,134 # ffffffffc02c5218 <hash_list>
ffffffffc020519a:	8171                	srli	a0,a0,0x1c
ffffffffc020519c:	953e                	add	a0,a0,a5
    __list_add(elm, listelm, listelm->next);
ffffffffc020519e:	650c                	ld	a1,8(a0)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc02051a0:	7014                	ld	a3,32(s0)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc02051a2:	0d840793          	addi	a5,s0,216
    prev->next = next->prev = elm;
ffffffffc02051a6:	e19c                	sd	a5,0(a1)
    __list_add(elm, listelm, listelm->next);
ffffffffc02051a8:	6490                	ld	a2,8(s1)
    prev->next = next->prev = elm;
ffffffffc02051aa:	e51c                	sd	a5,8(a0)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc02051ac:	7af8                	ld	a4,240(a3)
    list_add(&proc_list, &(proc->list_link));
ffffffffc02051ae:	0c840793          	addi	a5,s0,200
    elm->next = next;
ffffffffc02051b2:	f06c                	sd	a1,224(s0)
    elm->prev = prev;
ffffffffc02051b4:	ec68                	sd	a0,216(s0)
    prev->next = next->prev = elm;
ffffffffc02051b6:	e21c                	sd	a5,0(a2)
ffffffffc02051b8:	000c4597          	auipc	a1,0xc4
ffffffffc02051bc:	22f5b023          	sd	a5,544(a1) # ffffffffc02c93d8 <proc_list+0x8>
    elm->next = next;
ffffffffc02051c0:	e870                	sd	a2,208(s0)
    elm->prev = prev;
ffffffffc02051c2:	e464                	sd	s1,200(s0)
    proc->yptr = NULL;
ffffffffc02051c4:	0e043c23          	sd	zero,248(s0)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc02051c8:	10e43023          	sd	a4,256(s0)
ffffffffc02051cc:	c311                	beqz	a4,ffffffffc02051d0 <do_fork+0x206>
        proc->optr->yptr = proc;
ffffffffc02051ce:	ff60                	sd	s0,248(a4)
    nr_process ++;
ffffffffc02051d0:	000a2783          	lw	a5,0(s4)
    proc->parent->cptr = proc;
ffffffffc02051d4:	fae0                	sd	s0,240(a3)
    nr_process ++;
ffffffffc02051d6:	2785                	addiw	a5,a5,1
ffffffffc02051d8:	000c4717          	auipc	a4,0xc4
ffffffffc02051dc:	0cf72023          	sw	a5,192(a4) # ffffffffc02c9298 <nr_process>
    if (flag) {
ffffffffc02051e0:	10091863          	bnez	s2,ffffffffc02052f0 <do_fork+0x326>
    wakeup_proc(proc);
ffffffffc02051e4:	8522                	mv	a0,s0
ffffffffc02051e6:	019030ef          	jal	ra,ffffffffc02089fe <wakeup_proc>
    ret = proc->pid;
ffffffffc02051ea:	4048                	lw	a0,4(s0)
}
ffffffffc02051ec:	70a6                	ld	ra,104(sp)
ffffffffc02051ee:	7406                	ld	s0,96(sp)
ffffffffc02051f0:	64e6                	ld	s1,88(sp)
ffffffffc02051f2:	6946                	ld	s2,80(sp)
ffffffffc02051f4:	69a6                	ld	s3,72(sp)
ffffffffc02051f6:	6a06                	ld	s4,64(sp)
ffffffffc02051f8:	7ae2                	ld	s5,56(sp)
ffffffffc02051fa:	7b42                	ld	s6,48(sp)
ffffffffc02051fc:	7ba2                	ld	s7,40(sp)
ffffffffc02051fe:	7c02                	ld	s8,32(sp)
ffffffffc0205200:	6ce2                	ld	s9,24(sp)
ffffffffc0205202:	6d42                	ld	s10,16(sp)
ffffffffc0205204:	6da2                	ld	s11,8(sp)
ffffffffc0205206:	6165                	addi	sp,sp,112
ffffffffc0205208:	8082                	ret
                if (++ last_pid >= next_safe) {
ffffffffc020520a:	2785                	addiw	a5,a5,1
ffffffffc020520c:	0ec7d563          	ble	a2,a5,ffffffffc02052f6 <do_fork+0x32c>
ffffffffc0205210:	4585                	li	a1,1
ffffffffc0205212:	bf35                	j	ffffffffc020514e <do_fork+0x184>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc0205214:	8936                	mv	s2,a3
ffffffffc0205216:	0126b823          	sd	s2,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc020521a:	00000797          	auipc	a5,0x0
ffffffffc020521e:	b2278793          	addi	a5,a5,-1246 # ffffffffc0204d3c <forkret>
ffffffffc0205222:	f81c                	sd	a5,48(s0)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc0205224:	fc14                	sd	a3,56(s0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205226:	100027f3          	csrr	a5,sstatus
ffffffffc020522a:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020522c:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020522e:	ec0785e3          	beqz	a5,ffffffffc02050f8 <do_fork+0x12e>
        intr_disable();
ffffffffc0205232:	c20fb0ef          	jal	ra,ffffffffc0200652 <intr_disable>
    if (++ last_pid >= MAX_PID) {
ffffffffc0205236:	000b9797          	auipc	a5,0xb9
ffffffffc020523a:	bda78793          	addi	a5,a5,-1062 # ffffffffc02bde10 <last_pid.1768>
ffffffffc020523e:	439c                	lw	a5,0(a5)
ffffffffc0205240:	6709                	lui	a4,0x2
        return 1;
ffffffffc0205242:	4905                	li	s2,1
ffffffffc0205244:	0017851b          	addiw	a0,a5,1
ffffffffc0205248:	000b9697          	auipc	a3,0xb9
ffffffffc020524c:	bca6a423          	sw	a0,-1080(a3) # ffffffffc02bde10 <last_pid.1768>
ffffffffc0205250:	ece542e3          	blt	a0,a4,ffffffffc0205114 <do_fork+0x14a>
        last_pid = 1;
ffffffffc0205254:	4785                	li	a5,1
ffffffffc0205256:	000b9717          	auipc	a4,0xb9
ffffffffc020525a:	baf72d23          	sw	a5,-1094(a4) # ffffffffc02bde10 <last_pid.1768>
ffffffffc020525e:	4505                	li	a0,1
ffffffffc0205260:	b5e9                	j	ffffffffc020512a <do_fork+0x160>
    if ((mm = mm_create()) == NULL) {
ffffffffc0205262:	e55fe0ef          	jal	ra,ffffffffc02040b6 <mm_create>
ffffffffc0205266:	8d2a                	mv	s10,a0
ffffffffc0205268:	c539                	beqz	a0,ffffffffc02052b6 <do_fork+0x2ec>
    if (setup_pgdir(mm) != 0) {
ffffffffc020526a:	be3ff0ef          	jal	ra,ffffffffc0204e4c <setup_pgdir>
ffffffffc020526e:	e949                	bnez	a0,ffffffffc0205300 <do_fork+0x336>
}

static inline void
lock_mm(struct mm_struct *mm) {
    if (mm != NULL) {
        lock(&(mm->mm_lock));
ffffffffc0205270:	038c0d93          	addi	s11,s8,56
 * test_and_set_bit - Atomically set a bit and return its old value
 * @nr:     the bit to set
 * @addr:   the address to count from
 * */
static inline bool test_and_set_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0205274:	4785                	li	a5,1
ffffffffc0205276:	40fdb7af          	amoor.d	a5,a5,(s11)
ffffffffc020527a:	8b85                	andi	a5,a5,1
ffffffffc020527c:	4985                	li	s3,1
    return !test_and_set_bit(0, lock);
}

static inline void
lock(lock_t *lock) {
    while (!try_lock(lock)) {
ffffffffc020527e:	c799                	beqz	a5,ffffffffc020528c <do_fork+0x2c2>
        schedule();
ffffffffc0205280:	039030ef          	jal	ra,ffffffffc0208ab8 <schedule>
ffffffffc0205284:	413db7af          	amoor.d	a5,s3,(s11)
ffffffffc0205288:	8b85                	andi	a5,a5,1
    while (!try_lock(lock)) {
ffffffffc020528a:	fbfd                	bnez	a5,ffffffffc0205280 <do_fork+0x2b6>
        ret = dup_mmap(mm, oldmm);
ffffffffc020528c:	85e2                	mv	a1,s8
ffffffffc020528e:	856a                	mv	a0,s10
ffffffffc0205290:	8b0ff0ef          	jal	ra,ffffffffc0204340 <dup_mmap>
 * test_and_clear_bit - Atomically clear a bit and return its old value
 * @nr:     the bit to clear
 * @addr:   the address to count from
 * */
static inline bool test_and_clear_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0205294:	57f9                	li	a5,-2
ffffffffc0205296:	60fdb7af          	amoand.d	a5,a5,(s11)
ffffffffc020529a:	8b85                	andi	a5,a5,1
    }
}

static inline void
unlock(lock_t *lock) {
    if (!test_and_clear_bit(0, lock)) {
ffffffffc020529c:	c3e9                	beqz	a5,ffffffffc020535e <do_fork+0x394>
    if (ret != 0) {
ffffffffc020529e:	8c6a                	mv	s8,s10
ffffffffc02052a0:	de0502e3          	beqz	a0,ffffffffc0205084 <do_fork+0xba>
    exit_mmap(mm);
ffffffffc02052a4:	856a                	mv	a0,s10
ffffffffc02052a6:	936ff0ef          	jal	ra,ffffffffc02043dc <exit_mmap>
    put_pgdir(mm);
ffffffffc02052aa:	856a                	mv	a0,s10
ffffffffc02052ac:	b23ff0ef          	jal	ra,ffffffffc0204dce <put_pgdir>
    mm_destroy(mm);
ffffffffc02052b0:	856a                	mv	a0,s10
ffffffffc02052b2:	f8bfe0ef          	jal	ra,ffffffffc020423c <mm_destroy>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc02052b6:	6814                	ld	a3,16(s0)
    return pa2page(PADDR(kva));
ffffffffc02052b8:	c02007b7          	lui	a5,0xc0200
ffffffffc02052bc:	0cf6e963          	bltu	a3,a5,ffffffffc020538e <do_fork+0x3c4>
ffffffffc02052c0:	000cb783          	ld	a5,0(s9)
    if (PPN(pa) >= npage) {
ffffffffc02052c4:	000bb703          	ld	a4,0(s7)
    return pa2page(PADDR(kva));
ffffffffc02052c8:	40f687b3          	sub	a5,a3,a5
    if (PPN(pa) >= npage) {
ffffffffc02052cc:	83b1                	srli	a5,a5,0xc
ffffffffc02052ce:	0ae7f463          	bleu	a4,a5,ffffffffc0205376 <do_fork+0x3ac>
    return &pages[PPN(pa) - nbase];
ffffffffc02052d2:	000b3703          	ld	a4,0(s6)
ffffffffc02052d6:	000ab503          	ld	a0,0(s5)
ffffffffc02052da:	4589                	li	a1,2
ffffffffc02052dc:	8f99                	sub	a5,a5,a4
ffffffffc02052de:	079a                	slli	a5,a5,0x6
ffffffffc02052e0:	953e                	add	a0,a0,a5
ffffffffc02052e2:	be9fc0ef          	jal	ra,ffffffffc0201eca <free_pages>
    kfree(proc);
ffffffffc02052e6:	8522                	mv	a0,s0
ffffffffc02052e8:	a1bfc0ef          	jal	ra,ffffffffc0201d02 <kfree>
    ret = -E_NO_MEM;
ffffffffc02052ec:	5571                	li	a0,-4
    return ret;
ffffffffc02052ee:	bdfd                	j	ffffffffc02051ec <do_fork+0x222>
        intr_enable();
ffffffffc02052f0:	b5cfb0ef          	jal	ra,ffffffffc020064c <intr_enable>
ffffffffc02052f4:	bdc5                	j	ffffffffc02051e4 <do_fork+0x21a>
                    if (last_pid >= MAX_PID) {
ffffffffc02052f6:	0117c363          	blt	a5,a7,ffffffffc02052fc <do_fork+0x332>
                        last_pid = 1;
ffffffffc02052fa:	4785                	li	a5,1
                    goto repeat;
ffffffffc02052fc:	4585                	li	a1,1
ffffffffc02052fe:	b591                	j	ffffffffc0205142 <do_fork+0x178>
    mm_destroy(mm);
ffffffffc0205300:	856a                	mv	a0,s10
ffffffffc0205302:	f3bfe0ef          	jal	ra,ffffffffc020423c <mm_destroy>
ffffffffc0205306:	bf45                	j	ffffffffc02052b6 <do_fork+0x2ec>
    int ret = -E_NO_FREE_PROC;
ffffffffc0205308:	556d                	li	a0,-5
ffffffffc020530a:	b5cd                	j	ffffffffc02051ec <do_fork+0x222>
    return KADDR(page2pa(page));
ffffffffc020530c:	00005617          	auipc	a2,0x5
ffffffffc0205310:	bdc60613          	addi	a2,a2,-1060 # ffffffffc0209ee8 <default_pmm_manager+0x50>
ffffffffc0205314:	06900593          	li	a1,105
ffffffffc0205318:	00005517          	auipc	a0,0x5
ffffffffc020531c:	bf850513          	addi	a0,a0,-1032 # ffffffffc0209f10 <default_pmm_manager+0x78>
ffffffffc0205320:	968fb0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(current->wait_state == 0);
ffffffffc0205324:	00006697          	auipc	a3,0x6
ffffffffc0205328:	ddc68693          	addi	a3,a3,-548 # ffffffffc020b100 <default_pmm_manager+0x1268>
ffffffffc020532c:	00004617          	auipc	a2,0x4
ffffffffc0205330:	42460613          	addi	a2,a2,1060 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0205334:	1c100593          	li	a1,449
ffffffffc0205338:	00006517          	auipc	a0,0x6
ffffffffc020533c:	07050513          	addi	a0,a0,112 # ffffffffc020b3a8 <default_pmm_manager+0x1510>
ffffffffc0205340:	948fb0ef          	jal	ra,ffffffffc0200488 <__panic>
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc0205344:	86be                	mv	a3,a5
ffffffffc0205346:	00005617          	auipc	a2,0x5
ffffffffc020534a:	bda60613          	addi	a2,a2,-1062 # ffffffffc0209f20 <default_pmm_manager+0x88>
ffffffffc020534e:	17500593          	li	a1,373
ffffffffc0205352:	00006517          	auipc	a0,0x6
ffffffffc0205356:	05650513          	addi	a0,a0,86 # ffffffffc020b3a8 <default_pmm_manager+0x1510>
ffffffffc020535a:	92efb0ef          	jal	ra,ffffffffc0200488 <__panic>
        panic("Unlock failed.\n");
ffffffffc020535e:	00006617          	auipc	a2,0x6
ffffffffc0205362:	dc260613          	addi	a2,a2,-574 # ffffffffc020b120 <default_pmm_manager+0x1288>
ffffffffc0205366:	03200593          	li	a1,50
ffffffffc020536a:	00006517          	auipc	a0,0x6
ffffffffc020536e:	dc650513          	addi	a0,a0,-570 # ffffffffc020b130 <default_pmm_manager+0x1298>
ffffffffc0205372:	916fb0ef          	jal	ra,ffffffffc0200488 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0205376:	00005617          	auipc	a2,0x5
ffffffffc020537a:	bd260613          	addi	a2,a2,-1070 # ffffffffc0209f48 <default_pmm_manager+0xb0>
ffffffffc020537e:	06200593          	li	a1,98
ffffffffc0205382:	00005517          	auipc	a0,0x5
ffffffffc0205386:	b8e50513          	addi	a0,a0,-1138 # ffffffffc0209f10 <default_pmm_manager+0x78>
ffffffffc020538a:	8fefb0ef          	jal	ra,ffffffffc0200488 <__panic>
    return pa2page(PADDR(kva));
ffffffffc020538e:	00005617          	auipc	a2,0x5
ffffffffc0205392:	b9260613          	addi	a2,a2,-1134 # ffffffffc0209f20 <default_pmm_manager+0x88>
ffffffffc0205396:	06e00593          	li	a1,110
ffffffffc020539a:	00005517          	auipc	a0,0x5
ffffffffc020539e:	b7650513          	addi	a0,a0,-1162 # ffffffffc0209f10 <default_pmm_manager+0x78>
ffffffffc02053a2:	8e6fb0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc02053a6 <kernel_thread>:
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc02053a6:	7129                	addi	sp,sp,-320
ffffffffc02053a8:	fa22                	sd	s0,304(sp)
ffffffffc02053aa:	f626                	sd	s1,296(sp)
ffffffffc02053ac:	f24a                	sd	s2,288(sp)
ffffffffc02053ae:	84ae                	mv	s1,a1
ffffffffc02053b0:	892a                	mv	s2,a0
ffffffffc02053b2:	8432                	mv	s0,a2
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc02053b4:	4581                	li	a1,0
ffffffffc02053b6:	12000613          	li	a2,288
ffffffffc02053ba:	850a                	mv	a0,sp
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc02053bc:	fe06                	sd	ra,312(sp)
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc02053be:	579030ef          	jal	ra,ffffffffc0209136 <memset>
    tf.gpr.s0 = (uintptr_t)fn;
ffffffffc02053c2:	e0ca                	sd	s2,64(sp)
    tf.gpr.s1 = (uintptr_t)arg;
ffffffffc02053c4:	e4a6                	sd	s1,72(sp)
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
ffffffffc02053c6:	100027f3          	csrr	a5,sstatus
ffffffffc02053ca:	edd7f793          	andi	a5,a5,-291
ffffffffc02053ce:	1207e793          	ori	a5,a5,288
ffffffffc02053d2:	e23e                	sd	a5,256(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc02053d4:	860a                	mv	a2,sp
ffffffffc02053d6:	10046513          	ori	a0,s0,256
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc02053da:	00000797          	auipc	a5,0x0
ffffffffc02053de:	8c278793          	addi	a5,a5,-1854 # ffffffffc0204c9c <kernel_thread_entry>
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc02053e2:	4581                	li	a1,0
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc02053e4:	e63e                	sd	a5,264(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc02053e6:	be5ff0ef          	jal	ra,ffffffffc0204fca <do_fork>
}
ffffffffc02053ea:	70f2                	ld	ra,312(sp)
ffffffffc02053ec:	7452                	ld	s0,304(sp)
ffffffffc02053ee:	74b2                	ld	s1,296(sp)
ffffffffc02053f0:	7912                	ld	s2,288(sp)
ffffffffc02053f2:	6131                	addi	sp,sp,320
ffffffffc02053f4:	8082                	ret

ffffffffc02053f6 <do_exit>:
do_exit(int error_code) {
ffffffffc02053f6:	7179                	addi	sp,sp,-48
ffffffffc02053f8:	e84a                	sd	s2,16(sp)
    if (current == idleproc) {
ffffffffc02053fa:	000c4717          	auipc	a4,0xc4
ffffffffc02053fe:	e8e70713          	addi	a4,a4,-370 # ffffffffc02c9288 <idleproc>
ffffffffc0205402:	000c4917          	auipc	s2,0xc4
ffffffffc0205406:	e7e90913          	addi	s2,s2,-386 # ffffffffc02c9280 <current>
ffffffffc020540a:	00093783          	ld	a5,0(s2)
ffffffffc020540e:	6318                	ld	a4,0(a4)
do_exit(int error_code) {
ffffffffc0205410:	f406                	sd	ra,40(sp)
ffffffffc0205412:	f022                	sd	s0,32(sp)
ffffffffc0205414:	ec26                	sd	s1,24(sp)
ffffffffc0205416:	e44e                	sd	s3,8(sp)
ffffffffc0205418:	e052                	sd	s4,0(sp)
    if (current == idleproc) {
ffffffffc020541a:	0ce78c63          	beq	a5,a4,ffffffffc02054f2 <do_exit+0xfc>
    if (current == initproc) {
ffffffffc020541e:	000c4417          	auipc	s0,0xc4
ffffffffc0205422:	e7240413          	addi	s0,s0,-398 # ffffffffc02c9290 <initproc>
ffffffffc0205426:	6018                	ld	a4,0(s0)
ffffffffc0205428:	0ee78b63          	beq	a5,a4,ffffffffc020551e <do_exit+0x128>
    struct mm_struct *mm = current->mm;
ffffffffc020542c:	7784                	ld	s1,40(a5)
ffffffffc020542e:	89aa                	mv	s3,a0
    if (mm != NULL) {
ffffffffc0205430:	c48d                	beqz	s1,ffffffffc020545a <do_exit+0x64>
        lcr3(boot_cr3);
ffffffffc0205432:	000c4797          	auipc	a5,0xc4
ffffffffc0205436:	eae78793          	addi	a5,a5,-338 # ffffffffc02c92e0 <boot_cr3>
ffffffffc020543a:	639c                	ld	a5,0(a5)
ffffffffc020543c:	577d                	li	a4,-1
ffffffffc020543e:	177e                	slli	a4,a4,0x3f
ffffffffc0205440:	83b1                	srli	a5,a5,0xc
ffffffffc0205442:	8fd9                	or	a5,a5,a4
ffffffffc0205444:	18079073          	csrw	satp,a5
    mm->mm_count -= 1;
ffffffffc0205448:	589c                	lw	a5,48(s1)
ffffffffc020544a:	fff7871b          	addiw	a4,a5,-1
ffffffffc020544e:	d898                	sw	a4,48(s1)
        if (mm_count_dec(mm) == 0) {
ffffffffc0205450:	cf4d                	beqz	a4,ffffffffc020550a <do_exit+0x114>
        current->mm = NULL;
ffffffffc0205452:	00093783          	ld	a5,0(s2)
ffffffffc0205456:	0207b423          	sd	zero,40(a5)
    current->state = PROC_ZOMBIE;
ffffffffc020545a:	00093783          	ld	a5,0(s2)
ffffffffc020545e:	470d                	li	a4,3
ffffffffc0205460:	c398                	sw	a4,0(a5)
    current->exit_code = error_code;
ffffffffc0205462:	0f37a423          	sw	s3,232(a5)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205466:	100027f3          	csrr	a5,sstatus
ffffffffc020546a:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020546c:	4a01                	li	s4,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020546e:	e7e1                	bnez	a5,ffffffffc0205536 <do_exit+0x140>
        proc = current->parent;
ffffffffc0205470:	00093703          	ld	a4,0(s2)
        if (proc->wait_state == WT_CHILD) {
ffffffffc0205474:	800007b7          	lui	a5,0x80000
ffffffffc0205478:	0785                	addi	a5,a5,1
        proc = current->parent;
ffffffffc020547a:	7308                	ld	a0,32(a4)
        if (proc->wait_state == WT_CHILD) {
ffffffffc020547c:	0ec52703          	lw	a4,236(a0)
ffffffffc0205480:	0af70f63          	beq	a4,a5,ffffffffc020553e <do_exit+0x148>
ffffffffc0205484:	00093683          	ld	a3,0(s2)
                if (initproc->wait_state == WT_CHILD) {
ffffffffc0205488:	800009b7          	lui	s3,0x80000
            if (proc->state == PROC_ZOMBIE) {
ffffffffc020548c:	448d                	li	s1,3
                if (initproc->wait_state == WT_CHILD) {
ffffffffc020548e:	0985                	addi	s3,s3,1
        while (current->cptr != NULL) {
ffffffffc0205490:	7afc                	ld	a5,240(a3)
ffffffffc0205492:	cb95                	beqz	a5,ffffffffc02054c6 <do_exit+0xd0>
            current->cptr = proc->optr;
ffffffffc0205494:	1007b703          	ld	a4,256(a5) # ffffffff80000100 <_binary_obj___user_matrix_out_size+0xffffffff7fff4698>
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc0205498:	6008                	ld	a0,0(s0)
            current->cptr = proc->optr;
ffffffffc020549a:	faf8                	sd	a4,240(a3)
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc020549c:	7978                	ld	a4,240(a0)
            proc->yptr = NULL;
ffffffffc020549e:	0e07bc23          	sd	zero,248(a5)
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc02054a2:	10e7b023          	sd	a4,256(a5)
ffffffffc02054a6:	c311                	beqz	a4,ffffffffc02054aa <do_exit+0xb4>
                initproc->cptr->yptr = proc;
ffffffffc02054a8:	ff7c                	sd	a5,248(a4)
            if (proc->state == PROC_ZOMBIE) {
ffffffffc02054aa:	4398                	lw	a4,0(a5)
            proc->parent = initproc;
ffffffffc02054ac:	f388                	sd	a0,32(a5)
            initproc->cptr = proc;
ffffffffc02054ae:	f97c                	sd	a5,240(a0)
            if (proc->state == PROC_ZOMBIE) {
ffffffffc02054b0:	fe9710e3          	bne	a4,s1,ffffffffc0205490 <do_exit+0x9a>
                if (initproc->wait_state == WT_CHILD) {
ffffffffc02054b4:	0ec52783          	lw	a5,236(a0)
ffffffffc02054b8:	fd379ce3          	bne	a5,s3,ffffffffc0205490 <do_exit+0x9a>
                    wakeup_proc(initproc);
ffffffffc02054bc:	542030ef          	jal	ra,ffffffffc02089fe <wakeup_proc>
ffffffffc02054c0:	00093683          	ld	a3,0(s2)
ffffffffc02054c4:	b7f1                	j	ffffffffc0205490 <do_exit+0x9a>
    if (flag) {
ffffffffc02054c6:	020a1363          	bnez	s4,ffffffffc02054ec <do_exit+0xf6>
    schedule();
ffffffffc02054ca:	5ee030ef          	jal	ra,ffffffffc0208ab8 <schedule>
    panic("do_exit will not return!! %d.\n", current->pid);
ffffffffc02054ce:	00093783          	ld	a5,0(s2)
ffffffffc02054d2:	00006617          	auipc	a2,0x6
ffffffffc02054d6:	c0e60613          	addi	a2,a2,-1010 # ffffffffc020b0e0 <default_pmm_manager+0x1248>
ffffffffc02054da:	21400593          	li	a1,532
ffffffffc02054de:	43d4                	lw	a3,4(a5)
ffffffffc02054e0:	00006517          	auipc	a0,0x6
ffffffffc02054e4:	ec850513          	addi	a0,a0,-312 # ffffffffc020b3a8 <default_pmm_manager+0x1510>
ffffffffc02054e8:	fa1fa0ef          	jal	ra,ffffffffc0200488 <__panic>
        intr_enable();
ffffffffc02054ec:	960fb0ef          	jal	ra,ffffffffc020064c <intr_enable>
ffffffffc02054f0:	bfe9                	j	ffffffffc02054ca <do_exit+0xd4>
        panic("idleproc exit.\n");
ffffffffc02054f2:	00006617          	auipc	a2,0x6
ffffffffc02054f6:	bce60613          	addi	a2,a2,-1074 # ffffffffc020b0c0 <default_pmm_manager+0x1228>
ffffffffc02054fa:	1e800593          	li	a1,488
ffffffffc02054fe:	00006517          	auipc	a0,0x6
ffffffffc0205502:	eaa50513          	addi	a0,a0,-342 # ffffffffc020b3a8 <default_pmm_manager+0x1510>
ffffffffc0205506:	f83fa0ef          	jal	ra,ffffffffc0200488 <__panic>
            exit_mmap(mm);
ffffffffc020550a:	8526                	mv	a0,s1
ffffffffc020550c:	ed1fe0ef          	jal	ra,ffffffffc02043dc <exit_mmap>
            put_pgdir(mm);
ffffffffc0205510:	8526                	mv	a0,s1
ffffffffc0205512:	8bdff0ef          	jal	ra,ffffffffc0204dce <put_pgdir>
            mm_destroy(mm);
ffffffffc0205516:	8526                	mv	a0,s1
ffffffffc0205518:	d25fe0ef          	jal	ra,ffffffffc020423c <mm_destroy>
ffffffffc020551c:	bf1d                	j	ffffffffc0205452 <do_exit+0x5c>
        panic("initproc exit.\n");
ffffffffc020551e:	00006617          	auipc	a2,0x6
ffffffffc0205522:	bb260613          	addi	a2,a2,-1102 # ffffffffc020b0d0 <default_pmm_manager+0x1238>
ffffffffc0205526:	1eb00593          	li	a1,491
ffffffffc020552a:	00006517          	auipc	a0,0x6
ffffffffc020552e:	e7e50513          	addi	a0,a0,-386 # ffffffffc020b3a8 <default_pmm_manager+0x1510>
ffffffffc0205532:	f57fa0ef          	jal	ra,ffffffffc0200488 <__panic>
        intr_disable();
ffffffffc0205536:	91cfb0ef          	jal	ra,ffffffffc0200652 <intr_disable>
        return 1;
ffffffffc020553a:	4a05                	li	s4,1
ffffffffc020553c:	bf15                	j	ffffffffc0205470 <do_exit+0x7a>
            wakeup_proc(proc);
ffffffffc020553e:	4c0030ef          	jal	ra,ffffffffc02089fe <wakeup_proc>
ffffffffc0205542:	b789                	j	ffffffffc0205484 <do_exit+0x8e>

ffffffffc0205544 <do_wait.part.1>:
do_wait(int pid, int *code_store) {
ffffffffc0205544:	7139                	addi	sp,sp,-64
ffffffffc0205546:	e852                	sd	s4,16(sp)
        current->wait_state = WT_CHILD;
ffffffffc0205548:	80000a37          	lui	s4,0x80000
do_wait(int pid, int *code_store) {
ffffffffc020554c:	f426                	sd	s1,40(sp)
ffffffffc020554e:	f04a                	sd	s2,32(sp)
ffffffffc0205550:	ec4e                	sd	s3,24(sp)
ffffffffc0205552:	e456                	sd	s5,8(sp)
ffffffffc0205554:	e05a                	sd	s6,0(sp)
ffffffffc0205556:	fc06                	sd	ra,56(sp)
ffffffffc0205558:	f822                	sd	s0,48(sp)
ffffffffc020555a:	89aa                	mv	s3,a0
ffffffffc020555c:	8b2e                	mv	s6,a1
        proc = current->cptr;
ffffffffc020555e:	000c4917          	auipc	s2,0xc4
ffffffffc0205562:	d2290913          	addi	s2,s2,-734 # ffffffffc02c9280 <current>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0205566:	448d                	li	s1,3
        current->state = PROC_SLEEPING;
ffffffffc0205568:	4a85                	li	s5,1
        current->wait_state = WT_CHILD;
ffffffffc020556a:	2a05                	addiw	s4,s4,1
    if (pid != 0) {
ffffffffc020556c:	02098f63          	beqz	s3,ffffffffc02055aa <do_wait.part.1+0x66>
        proc = find_proc(pid);
ffffffffc0205570:	854e                	mv	a0,s3
ffffffffc0205572:	9fdff0ef          	jal	ra,ffffffffc0204f6e <find_proc>
ffffffffc0205576:	842a                	mv	s0,a0
        if (proc != NULL && proc->parent == current) {
ffffffffc0205578:	12050063          	beqz	a0,ffffffffc0205698 <do_wait.part.1+0x154>
ffffffffc020557c:	00093703          	ld	a4,0(s2)
ffffffffc0205580:	711c                	ld	a5,32(a0)
ffffffffc0205582:	10e79b63          	bne	a5,a4,ffffffffc0205698 <do_wait.part.1+0x154>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0205586:	411c                	lw	a5,0(a0)
ffffffffc0205588:	02978c63          	beq	a5,s1,ffffffffc02055c0 <do_wait.part.1+0x7c>
        current->state = PROC_SLEEPING;
ffffffffc020558c:	01572023          	sw	s5,0(a4)
        current->wait_state = WT_CHILD;
ffffffffc0205590:	0f472623          	sw	s4,236(a4)
        schedule();
ffffffffc0205594:	524030ef          	jal	ra,ffffffffc0208ab8 <schedule>
        if (current->flags & PF_EXITING) {
ffffffffc0205598:	00093783          	ld	a5,0(s2)
ffffffffc020559c:	0b07a783          	lw	a5,176(a5)
ffffffffc02055a0:	8b85                	andi	a5,a5,1
ffffffffc02055a2:	d7e9                	beqz	a5,ffffffffc020556c <do_wait.part.1+0x28>
            do_exit(-E_KILLED);
ffffffffc02055a4:	555d                	li	a0,-9
ffffffffc02055a6:	e51ff0ef          	jal	ra,ffffffffc02053f6 <do_exit>
        proc = current->cptr;
ffffffffc02055aa:	00093703          	ld	a4,0(s2)
ffffffffc02055ae:	7b60                	ld	s0,240(a4)
        for (; proc != NULL; proc = proc->optr) {
ffffffffc02055b0:	e409                	bnez	s0,ffffffffc02055ba <do_wait.part.1+0x76>
ffffffffc02055b2:	a0dd                	j	ffffffffc0205698 <do_wait.part.1+0x154>
ffffffffc02055b4:	10043403          	ld	s0,256(s0)
ffffffffc02055b8:	d871                	beqz	s0,ffffffffc020558c <do_wait.part.1+0x48>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc02055ba:	401c                	lw	a5,0(s0)
ffffffffc02055bc:	fe979ce3          	bne	a5,s1,ffffffffc02055b4 <do_wait.part.1+0x70>
    if (proc == idleproc || proc == initproc) {
ffffffffc02055c0:	000c4797          	auipc	a5,0xc4
ffffffffc02055c4:	cc878793          	addi	a5,a5,-824 # ffffffffc02c9288 <idleproc>
ffffffffc02055c8:	639c                	ld	a5,0(a5)
ffffffffc02055ca:	0c878d63          	beq	a5,s0,ffffffffc02056a4 <do_wait.part.1+0x160>
ffffffffc02055ce:	000c4797          	auipc	a5,0xc4
ffffffffc02055d2:	cc278793          	addi	a5,a5,-830 # ffffffffc02c9290 <initproc>
ffffffffc02055d6:	639c                	ld	a5,0(a5)
ffffffffc02055d8:	0cf40663          	beq	s0,a5,ffffffffc02056a4 <do_wait.part.1+0x160>
    if (code_store != NULL) {
ffffffffc02055dc:	000b0663          	beqz	s6,ffffffffc02055e8 <do_wait.part.1+0xa4>
        *code_store = proc->exit_code;
ffffffffc02055e0:	0e842783          	lw	a5,232(s0)
ffffffffc02055e4:	00fb2023          	sw	a5,0(s6)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02055e8:	100027f3          	csrr	a5,sstatus
ffffffffc02055ec:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02055ee:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02055f0:	e7d5                	bnez	a5,ffffffffc020569c <do_wait.part.1+0x158>
    __list_del(listelm->prev, listelm->next);
ffffffffc02055f2:	6c70                	ld	a2,216(s0)
ffffffffc02055f4:	7074                	ld	a3,224(s0)
    if (proc->optr != NULL) {
ffffffffc02055f6:	10043703          	ld	a4,256(s0)
ffffffffc02055fa:	7c7c                	ld	a5,248(s0)
    prev->next = next;
ffffffffc02055fc:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc02055fe:	e290                	sd	a2,0(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc0205600:	6470                	ld	a2,200(s0)
ffffffffc0205602:	6874                	ld	a3,208(s0)
    prev->next = next;
ffffffffc0205604:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc0205606:	e290                	sd	a2,0(a3)
ffffffffc0205608:	c319                	beqz	a4,ffffffffc020560e <do_wait.part.1+0xca>
        proc->optr->yptr = proc->yptr;
ffffffffc020560a:	ff7c                	sd	a5,248(a4)
ffffffffc020560c:	7c7c                	ld	a5,248(s0)
    if (proc->yptr != NULL) {
ffffffffc020560e:	c3d1                	beqz	a5,ffffffffc0205692 <do_wait.part.1+0x14e>
        proc->yptr->optr = proc->optr;
ffffffffc0205610:	10e7b023          	sd	a4,256(a5)
    nr_process --;
ffffffffc0205614:	000c4797          	auipc	a5,0xc4
ffffffffc0205618:	c8478793          	addi	a5,a5,-892 # ffffffffc02c9298 <nr_process>
ffffffffc020561c:	439c                	lw	a5,0(a5)
ffffffffc020561e:	37fd                	addiw	a5,a5,-1
ffffffffc0205620:	000c4717          	auipc	a4,0xc4
ffffffffc0205624:	c6f72c23          	sw	a5,-904(a4) # ffffffffc02c9298 <nr_process>
    if (flag) {
ffffffffc0205628:	e1b5                	bnez	a1,ffffffffc020568c <do_wait.part.1+0x148>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc020562a:	6814                	ld	a3,16(s0)
ffffffffc020562c:	c02007b7          	lui	a5,0xc0200
ffffffffc0205630:	0af6e263          	bltu	a3,a5,ffffffffc02056d4 <do_wait.part.1+0x190>
ffffffffc0205634:	000c4797          	auipc	a5,0xc4
ffffffffc0205638:	ca478793          	addi	a5,a5,-860 # ffffffffc02c92d8 <va_pa_offset>
ffffffffc020563c:	6398                	ld	a4,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc020563e:	000c4797          	auipc	a5,0xc4
ffffffffc0205642:	c2a78793          	addi	a5,a5,-982 # ffffffffc02c9268 <npage>
ffffffffc0205646:	639c                	ld	a5,0(a5)
    return pa2page(PADDR(kva));
ffffffffc0205648:	8e99                	sub	a3,a3,a4
    if (PPN(pa) >= npage) {
ffffffffc020564a:	82b1                	srli	a3,a3,0xc
ffffffffc020564c:	06f6f863          	bleu	a5,a3,ffffffffc02056bc <do_wait.part.1+0x178>
    return &pages[PPN(pa) - nbase];
ffffffffc0205650:	00007797          	auipc	a5,0x7
ffffffffc0205654:	95078793          	addi	a5,a5,-1712 # ffffffffc020bfa0 <nbase>
ffffffffc0205658:	639c                	ld	a5,0(a5)
ffffffffc020565a:	000c4717          	auipc	a4,0xc4
ffffffffc020565e:	c8e70713          	addi	a4,a4,-882 # ffffffffc02c92e8 <pages>
ffffffffc0205662:	6308                	ld	a0,0(a4)
ffffffffc0205664:	8e9d                	sub	a3,a3,a5
ffffffffc0205666:	069a                	slli	a3,a3,0x6
ffffffffc0205668:	9536                	add	a0,a0,a3
ffffffffc020566a:	4589                	li	a1,2
ffffffffc020566c:	85ffc0ef          	jal	ra,ffffffffc0201eca <free_pages>
    kfree(proc);
ffffffffc0205670:	8522                	mv	a0,s0
ffffffffc0205672:	e90fc0ef          	jal	ra,ffffffffc0201d02 <kfree>
    return 0;
ffffffffc0205676:	4501                	li	a0,0
}
ffffffffc0205678:	70e2                	ld	ra,56(sp)
ffffffffc020567a:	7442                	ld	s0,48(sp)
ffffffffc020567c:	74a2                	ld	s1,40(sp)
ffffffffc020567e:	7902                	ld	s2,32(sp)
ffffffffc0205680:	69e2                	ld	s3,24(sp)
ffffffffc0205682:	6a42                	ld	s4,16(sp)
ffffffffc0205684:	6aa2                	ld	s5,8(sp)
ffffffffc0205686:	6b02                	ld	s6,0(sp)
ffffffffc0205688:	6121                	addi	sp,sp,64
ffffffffc020568a:	8082                	ret
        intr_enable();
ffffffffc020568c:	fc1fa0ef          	jal	ra,ffffffffc020064c <intr_enable>
ffffffffc0205690:	bf69                	j	ffffffffc020562a <do_wait.part.1+0xe6>
       proc->parent->cptr = proc->optr;
ffffffffc0205692:	701c                	ld	a5,32(s0)
ffffffffc0205694:	fbf8                	sd	a4,240(a5)
ffffffffc0205696:	bfbd                	j	ffffffffc0205614 <do_wait.part.1+0xd0>
    return -E_BAD_PROC;
ffffffffc0205698:	5579                	li	a0,-2
ffffffffc020569a:	bff9                	j	ffffffffc0205678 <do_wait.part.1+0x134>
        intr_disable();
ffffffffc020569c:	fb7fa0ef          	jal	ra,ffffffffc0200652 <intr_disable>
        return 1;
ffffffffc02056a0:	4585                	li	a1,1
ffffffffc02056a2:	bf81                	j	ffffffffc02055f2 <do_wait.part.1+0xae>
        panic("wait idleproc or initproc.\n");
ffffffffc02056a4:	00006617          	auipc	a2,0x6
ffffffffc02056a8:	aa460613          	addi	a2,a2,-1372 # ffffffffc020b148 <default_pmm_manager+0x12b0>
ffffffffc02056ac:	30e00593          	li	a1,782
ffffffffc02056b0:	00006517          	auipc	a0,0x6
ffffffffc02056b4:	cf850513          	addi	a0,a0,-776 # ffffffffc020b3a8 <default_pmm_manager+0x1510>
ffffffffc02056b8:	dd1fa0ef          	jal	ra,ffffffffc0200488 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02056bc:	00005617          	auipc	a2,0x5
ffffffffc02056c0:	88c60613          	addi	a2,a2,-1908 # ffffffffc0209f48 <default_pmm_manager+0xb0>
ffffffffc02056c4:	06200593          	li	a1,98
ffffffffc02056c8:	00005517          	auipc	a0,0x5
ffffffffc02056cc:	84850513          	addi	a0,a0,-1976 # ffffffffc0209f10 <default_pmm_manager+0x78>
ffffffffc02056d0:	db9fa0ef          	jal	ra,ffffffffc0200488 <__panic>
    return pa2page(PADDR(kva));
ffffffffc02056d4:	00005617          	auipc	a2,0x5
ffffffffc02056d8:	84c60613          	addi	a2,a2,-1972 # ffffffffc0209f20 <default_pmm_manager+0x88>
ffffffffc02056dc:	06e00593          	li	a1,110
ffffffffc02056e0:	00005517          	auipc	a0,0x5
ffffffffc02056e4:	83050513          	addi	a0,a0,-2000 # ffffffffc0209f10 <default_pmm_manager+0x78>
ffffffffc02056e8:	da1fa0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc02056ec <init_main>:
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg) {
ffffffffc02056ec:	1141                	addi	sp,sp,-16
ffffffffc02056ee:	e406                	sd	ra,8(sp)
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc02056f0:	821fc0ef          	jal	ra,ffffffffc0201f10 <nr_free_pages>
    size_t kernel_allocated_store = kallocated();
ffffffffc02056f4:	d4efc0ef          	jal	ra,ffffffffc0201c42 <kallocated>

    int pid = kernel_thread(user_main, NULL, 0);
ffffffffc02056f8:	4601                	li	a2,0
ffffffffc02056fa:	4581                	li	a1,0
ffffffffc02056fc:	fffff517          	auipc	a0,0xfffff
ffffffffc0205700:	65050513          	addi	a0,a0,1616 # ffffffffc0204d4c <user_main>
ffffffffc0205704:	ca3ff0ef          	jal	ra,ffffffffc02053a6 <kernel_thread>
    if (pid <= 0) {
ffffffffc0205708:	00a04563          	bgtz	a0,ffffffffc0205712 <init_main+0x26>
ffffffffc020570c:	a841                	j	ffffffffc020579c <init_main+0xb0>
        panic("create user_main failed.\n");
    }

    while (do_wait(0, NULL) == 0) {
        schedule();
ffffffffc020570e:	3aa030ef          	jal	ra,ffffffffc0208ab8 <schedule>
    if (code_store != NULL) {
ffffffffc0205712:	4581                	li	a1,0
ffffffffc0205714:	4501                	li	a0,0
ffffffffc0205716:	e2fff0ef          	jal	ra,ffffffffc0205544 <do_wait.part.1>
    while (do_wait(0, NULL) == 0) {
ffffffffc020571a:	d975                	beqz	a0,ffffffffc020570e <init_main+0x22>
    }

    cprintf("all user-mode processes have quit.\n");
ffffffffc020571c:	00006517          	auipc	a0,0x6
ffffffffc0205720:	a6c50513          	addi	a0,a0,-1428 # ffffffffc020b188 <default_pmm_manager+0x12f0>
ffffffffc0205724:	a6ffa0ef          	jal	ra,ffffffffc0200192 <cprintf>
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc0205728:	000c4797          	auipc	a5,0xc4
ffffffffc020572c:	b6878793          	addi	a5,a5,-1176 # ffffffffc02c9290 <initproc>
ffffffffc0205730:	639c                	ld	a5,0(a5)
ffffffffc0205732:	7bf8                	ld	a4,240(a5)
ffffffffc0205734:	e721                	bnez	a4,ffffffffc020577c <init_main+0x90>
ffffffffc0205736:	7ff8                	ld	a4,248(a5)
ffffffffc0205738:	e331                	bnez	a4,ffffffffc020577c <init_main+0x90>
ffffffffc020573a:	1007b703          	ld	a4,256(a5)
ffffffffc020573e:	ef1d                	bnez	a4,ffffffffc020577c <init_main+0x90>
    assert(nr_process == 2);
ffffffffc0205740:	000c4717          	auipc	a4,0xc4
ffffffffc0205744:	b5870713          	addi	a4,a4,-1192 # ffffffffc02c9298 <nr_process>
ffffffffc0205748:	4314                	lw	a3,0(a4)
ffffffffc020574a:	4709                	li	a4,2
ffffffffc020574c:	0ae69463          	bne	a3,a4,ffffffffc02057f4 <init_main+0x108>
    return listelm->next;
ffffffffc0205750:	000c4697          	auipc	a3,0xc4
ffffffffc0205754:	c8068693          	addi	a3,a3,-896 # ffffffffc02c93d0 <proc_list>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc0205758:	6698                	ld	a4,8(a3)
ffffffffc020575a:	0c878793          	addi	a5,a5,200
ffffffffc020575e:	06f71b63          	bne	a4,a5,ffffffffc02057d4 <init_main+0xe8>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc0205762:	629c                	ld	a5,0(a3)
ffffffffc0205764:	04f71863          	bne	a4,a5,ffffffffc02057b4 <init_main+0xc8>

    cprintf("init check memory pass.\n");
ffffffffc0205768:	00006517          	auipc	a0,0x6
ffffffffc020576c:	b0850513          	addi	a0,a0,-1272 # ffffffffc020b270 <default_pmm_manager+0x13d8>
ffffffffc0205770:	a23fa0ef          	jal	ra,ffffffffc0200192 <cprintf>
    return 0;
}
ffffffffc0205774:	60a2                	ld	ra,8(sp)
ffffffffc0205776:	4501                	li	a0,0
ffffffffc0205778:	0141                	addi	sp,sp,16
ffffffffc020577a:	8082                	ret
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc020577c:	00006697          	auipc	a3,0x6
ffffffffc0205780:	a3468693          	addi	a3,a3,-1484 # ffffffffc020b1b0 <default_pmm_manager+0x1318>
ffffffffc0205784:	00004617          	auipc	a2,0x4
ffffffffc0205788:	fcc60613          	addi	a2,a2,-52 # ffffffffc0209750 <commands+0x4c0>
ffffffffc020578c:	37200593          	li	a1,882
ffffffffc0205790:	00006517          	auipc	a0,0x6
ffffffffc0205794:	c1850513          	addi	a0,a0,-1000 # ffffffffc020b3a8 <default_pmm_manager+0x1510>
ffffffffc0205798:	cf1fa0ef          	jal	ra,ffffffffc0200488 <__panic>
        panic("create user_main failed.\n");
ffffffffc020579c:	00006617          	auipc	a2,0x6
ffffffffc02057a0:	9cc60613          	addi	a2,a2,-1588 # ffffffffc020b168 <default_pmm_manager+0x12d0>
ffffffffc02057a4:	36a00593          	li	a1,874
ffffffffc02057a8:	00006517          	auipc	a0,0x6
ffffffffc02057ac:	c0050513          	addi	a0,a0,-1024 # ffffffffc020b3a8 <default_pmm_manager+0x1510>
ffffffffc02057b0:	cd9fa0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc02057b4:	00006697          	auipc	a3,0x6
ffffffffc02057b8:	a8c68693          	addi	a3,a3,-1396 # ffffffffc020b240 <default_pmm_manager+0x13a8>
ffffffffc02057bc:	00004617          	auipc	a2,0x4
ffffffffc02057c0:	f9460613          	addi	a2,a2,-108 # ffffffffc0209750 <commands+0x4c0>
ffffffffc02057c4:	37500593          	li	a1,885
ffffffffc02057c8:	00006517          	auipc	a0,0x6
ffffffffc02057cc:	be050513          	addi	a0,a0,-1056 # ffffffffc020b3a8 <default_pmm_manager+0x1510>
ffffffffc02057d0:	cb9fa0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc02057d4:	00006697          	auipc	a3,0x6
ffffffffc02057d8:	a3c68693          	addi	a3,a3,-1476 # ffffffffc020b210 <default_pmm_manager+0x1378>
ffffffffc02057dc:	00004617          	auipc	a2,0x4
ffffffffc02057e0:	f7460613          	addi	a2,a2,-140 # ffffffffc0209750 <commands+0x4c0>
ffffffffc02057e4:	37400593          	li	a1,884
ffffffffc02057e8:	00006517          	auipc	a0,0x6
ffffffffc02057ec:	bc050513          	addi	a0,a0,-1088 # ffffffffc020b3a8 <default_pmm_manager+0x1510>
ffffffffc02057f0:	c99fa0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(nr_process == 2);
ffffffffc02057f4:	00006697          	auipc	a3,0x6
ffffffffc02057f8:	a0c68693          	addi	a3,a3,-1524 # ffffffffc020b200 <default_pmm_manager+0x1368>
ffffffffc02057fc:	00004617          	auipc	a2,0x4
ffffffffc0205800:	f5460613          	addi	a2,a2,-172 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0205804:	37300593          	li	a1,883
ffffffffc0205808:	00006517          	auipc	a0,0x6
ffffffffc020580c:	ba050513          	addi	a0,a0,-1120 # ffffffffc020b3a8 <default_pmm_manager+0x1510>
ffffffffc0205810:	c79fa0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0205814 <do_execve>:
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc0205814:	7135                	addi	sp,sp,-160
ffffffffc0205816:	f8d2                	sd	s4,112(sp)
    struct mm_struct *mm = current->mm;
ffffffffc0205818:	000c4a17          	auipc	s4,0xc4
ffffffffc020581c:	a68a0a13          	addi	s4,s4,-1432 # ffffffffc02c9280 <current>
ffffffffc0205820:	000a3783          	ld	a5,0(s4)
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc0205824:	e14a                	sd	s2,128(sp)
ffffffffc0205826:	e922                	sd	s0,144(sp)
    struct mm_struct *mm = current->mm;
ffffffffc0205828:	0287b903          	ld	s2,40(a5)
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc020582c:	fcce                	sd	s3,120(sp)
ffffffffc020582e:	f0da                	sd	s6,96(sp)
ffffffffc0205830:	89aa                	mv	s3,a0
ffffffffc0205832:	842e                	mv	s0,a1
ffffffffc0205834:	8b32                	mv	s6,a2
    if (!user_mem_check(mm, (uintptr_t)name, len, 0)) {
ffffffffc0205836:	4681                	li	a3,0
ffffffffc0205838:	862e                	mv	a2,a1
ffffffffc020583a:	85aa                	mv	a1,a0
ffffffffc020583c:	854a                	mv	a0,s2
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc020583e:	ed06                	sd	ra,152(sp)
ffffffffc0205840:	e526                	sd	s1,136(sp)
ffffffffc0205842:	f4d6                	sd	s5,104(sp)
ffffffffc0205844:	ecde                	sd	s7,88(sp)
ffffffffc0205846:	e8e2                	sd	s8,80(sp)
ffffffffc0205848:	e4e6                	sd	s9,72(sp)
ffffffffc020584a:	e0ea                	sd	s10,64(sp)
ffffffffc020584c:	fc6e                	sd	s11,56(sp)
    if (!user_mem_check(mm, (uintptr_t)name, len, 0)) {
ffffffffc020584e:	a52ff0ef          	jal	ra,ffffffffc0204aa0 <user_mem_check>
ffffffffc0205852:	40050463          	beqz	a0,ffffffffc0205c5a <do_execve+0x446>
    memset(local_name, 0, sizeof(local_name));
ffffffffc0205856:	4641                	li	a2,16
ffffffffc0205858:	4581                	li	a1,0
ffffffffc020585a:	1008                	addi	a0,sp,32
ffffffffc020585c:	0db030ef          	jal	ra,ffffffffc0209136 <memset>
    memcpy(local_name, name, len);
ffffffffc0205860:	47bd                	li	a5,15
ffffffffc0205862:	8622                	mv	a2,s0
ffffffffc0205864:	0687ee63          	bltu	a5,s0,ffffffffc02058e0 <do_execve+0xcc>
ffffffffc0205868:	85ce                	mv	a1,s3
ffffffffc020586a:	1008                	addi	a0,sp,32
ffffffffc020586c:	0dd030ef          	jal	ra,ffffffffc0209148 <memcpy>
    if (mm != NULL) {
ffffffffc0205870:	06090f63          	beqz	s2,ffffffffc02058ee <do_execve+0xda>
        cputs("mm != NULL");
ffffffffc0205874:	00005517          	auipc	a0,0x5
ffffffffc0205878:	e1450513          	addi	a0,a0,-492 # ffffffffc020a688 <default_pmm_manager+0x7f0>
ffffffffc020587c:	94ffa0ef          	jal	ra,ffffffffc02001ca <cputs>
        lcr3(boot_cr3);
ffffffffc0205880:	000c4797          	auipc	a5,0xc4
ffffffffc0205884:	a6078793          	addi	a5,a5,-1440 # ffffffffc02c92e0 <boot_cr3>
ffffffffc0205888:	639c                	ld	a5,0(a5)
ffffffffc020588a:	577d                	li	a4,-1
ffffffffc020588c:	177e                	slli	a4,a4,0x3f
ffffffffc020588e:	83b1                	srli	a5,a5,0xc
ffffffffc0205890:	8fd9                	or	a5,a5,a4
ffffffffc0205892:	18079073          	csrw	satp,a5
ffffffffc0205896:	03092783          	lw	a5,48(s2)
ffffffffc020589a:	fff7871b          	addiw	a4,a5,-1
ffffffffc020589e:	02e92823          	sw	a4,48(s2)
        if (mm_count_dec(mm) == 0) {
ffffffffc02058a2:	28070b63          	beqz	a4,ffffffffc0205b38 <do_execve+0x324>
        current->mm = NULL;
ffffffffc02058a6:	000a3783          	ld	a5,0(s4)
ffffffffc02058aa:	0207b423          	sd	zero,40(a5)
    if ((mm = mm_create()) == NULL) {
ffffffffc02058ae:	809fe0ef          	jal	ra,ffffffffc02040b6 <mm_create>
ffffffffc02058b2:	892a                	mv	s2,a0
ffffffffc02058b4:	c135                	beqz	a0,ffffffffc0205918 <do_execve+0x104>
    if (setup_pgdir(mm) != 0) {
ffffffffc02058b6:	d96ff0ef          	jal	ra,ffffffffc0204e4c <setup_pgdir>
ffffffffc02058ba:	e931                	bnez	a0,ffffffffc020590e <do_execve+0xfa>
    if (elf->e_magic != ELF_MAGIC) {
ffffffffc02058bc:	000b2703          	lw	a4,0(s6)
ffffffffc02058c0:	464c47b7          	lui	a5,0x464c4
ffffffffc02058c4:	57f78793          	addi	a5,a5,1407 # 464c457f <_binary_obj___user_matrix_out_size+0x464b8b17>
ffffffffc02058c8:	04f70a63          	beq	a4,a5,ffffffffc020591c <do_execve+0x108>
    put_pgdir(mm);
ffffffffc02058cc:	854a                	mv	a0,s2
ffffffffc02058ce:	d00ff0ef          	jal	ra,ffffffffc0204dce <put_pgdir>
    mm_destroy(mm);
ffffffffc02058d2:	854a                	mv	a0,s2
ffffffffc02058d4:	969fe0ef          	jal	ra,ffffffffc020423c <mm_destroy>
        ret = -E_INVAL_ELF;
ffffffffc02058d8:	59e1                	li	s3,-8
    do_exit(ret);
ffffffffc02058da:	854e                	mv	a0,s3
ffffffffc02058dc:	b1bff0ef          	jal	ra,ffffffffc02053f6 <do_exit>
    memcpy(local_name, name, len);
ffffffffc02058e0:	463d                	li	a2,15
ffffffffc02058e2:	85ce                	mv	a1,s3
ffffffffc02058e4:	1008                	addi	a0,sp,32
ffffffffc02058e6:	063030ef          	jal	ra,ffffffffc0209148 <memcpy>
    if (mm != NULL) {
ffffffffc02058ea:	f80915e3          	bnez	s2,ffffffffc0205874 <do_execve+0x60>
    if (current->mm != NULL) {
ffffffffc02058ee:	000a3783          	ld	a5,0(s4)
ffffffffc02058f2:	779c                	ld	a5,40(a5)
ffffffffc02058f4:	dfcd                	beqz	a5,ffffffffc02058ae <do_execve+0x9a>
        panic("load_icode: current->mm must be empty.\n");
ffffffffc02058f6:	00005617          	auipc	a2,0x5
ffffffffc02058fa:	64260613          	addi	a2,a2,1602 # ffffffffc020af38 <default_pmm_manager+0x10a0>
ffffffffc02058fe:	21e00593          	li	a1,542
ffffffffc0205902:	00006517          	auipc	a0,0x6
ffffffffc0205906:	aa650513          	addi	a0,a0,-1370 # ffffffffc020b3a8 <default_pmm_manager+0x1510>
ffffffffc020590a:	b7ffa0ef          	jal	ra,ffffffffc0200488 <__panic>
    mm_destroy(mm);
ffffffffc020590e:	854a                	mv	a0,s2
ffffffffc0205910:	92dfe0ef          	jal	ra,ffffffffc020423c <mm_destroy>
    int ret = -E_NO_MEM;
ffffffffc0205914:	59f1                	li	s3,-4
ffffffffc0205916:	b7d1                	j	ffffffffc02058da <do_execve+0xc6>
ffffffffc0205918:	59f1                	li	s3,-4
ffffffffc020591a:	b7c1                	j	ffffffffc02058da <do_execve+0xc6>
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc020591c:	038b5703          	lhu	a4,56(s6)
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc0205920:	020b3403          	ld	s0,32(s6)
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0205924:	00371793          	slli	a5,a4,0x3
ffffffffc0205928:	8f99                	sub	a5,a5,a4
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc020592a:	945a                	add	s0,s0,s6
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc020592c:	078e                	slli	a5,a5,0x3
ffffffffc020592e:	97a2                	add	a5,a5,s0
ffffffffc0205930:	ec3e                	sd	a5,24(sp)
    for (; ph < ph_end; ph ++) {
ffffffffc0205932:	02f47b63          	bleu	a5,s0,ffffffffc0205968 <do_execve+0x154>
    return KADDR(page2pa(page));
ffffffffc0205936:	5bfd                	li	s7,-1
ffffffffc0205938:	00cbd793          	srli	a5,s7,0xc
    return page - pages + nbase;
ffffffffc020593c:	000c4d97          	auipc	s11,0xc4
ffffffffc0205940:	9acd8d93          	addi	s11,s11,-1620 # ffffffffc02c92e8 <pages>
ffffffffc0205944:	00006d17          	auipc	s10,0x6
ffffffffc0205948:	65cd0d13          	addi	s10,s10,1628 # ffffffffc020bfa0 <nbase>
    return KADDR(page2pa(page));
ffffffffc020594c:	e43e                	sd	a5,8(sp)
ffffffffc020594e:	000c4c97          	auipc	s9,0xc4
ffffffffc0205952:	91ac8c93          	addi	s9,s9,-1766 # ffffffffc02c9268 <npage>
        if (ph->p_type != ELF_PT_LOAD) {
ffffffffc0205956:	4018                	lw	a4,0(s0)
ffffffffc0205958:	4785                	li	a5,1
ffffffffc020595a:	0ef70d63          	beq	a4,a5,ffffffffc0205a54 <do_execve+0x240>
    for (; ph < ph_end; ph ++) {
ffffffffc020595e:	67e2                	ld	a5,24(sp)
ffffffffc0205960:	03840413          	addi	s0,s0,56
ffffffffc0205964:	fef469e3          	bltu	s0,a5,ffffffffc0205956 <do_execve+0x142>
    if ((ret = mm_map(mm, USTACKTOP - USTACKSIZE, USTACKSIZE, vm_flags, NULL)) != 0) {
ffffffffc0205968:	4701                	li	a4,0
ffffffffc020596a:	46ad                	li	a3,11
ffffffffc020596c:	00100637          	lui	a2,0x100
ffffffffc0205970:	7ff005b7          	lui	a1,0x7ff00
ffffffffc0205974:	854a                	mv	a0,s2
ffffffffc0205976:	919fe0ef          	jal	ra,ffffffffc020428e <mm_map>
ffffffffc020597a:	89aa                	mv	s3,a0
ffffffffc020597c:	1a051463          	bnez	a0,ffffffffc0205b24 <do_execve+0x310>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
ffffffffc0205980:	01893503          	ld	a0,24(s2)
ffffffffc0205984:	467d                	li	a2,31
ffffffffc0205986:	7ffff5b7          	lui	a1,0x7ffff
ffffffffc020598a:	95ffd0ef          	jal	ra,ffffffffc02032e8 <pgdir_alloc_page>
ffffffffc020598e:	36050263          	beqz	a0,ffffffffc0205cf2 <do_execve+0x4de>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
ffffffffc0205992:	01893503          	ld	a0,24(s2)
ffffffffc0205996:	467d                	li	a2,31
ffffffffc0205998:	7fffe5b7          	lui	a1,0x7fffe
ffffffffc020599c:	94dfd0ef          	jal	ra,ffffffffc02032e8 <pgdir_alloc_page>
ffffffffc02059a0:	32050963          	beqz	a0,ffffffffc0205cd2 <do_execve+0x4be>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
ffffffffc02059a4:	01893503          	ld	a0,24(s2)
ffffffffc02059a8:	467d                	li	a2,31
ffffffffc02059aa:	7fffd5b7          	lui	a1,0x7fffd
ffffffffc02059ae:	93bfd0ef          	jal	ra,ffffffffc02032e8 <pgdir_alloc_page>
ffffffffc02059b2:	30050063          	beqz	a0,ffffffffc0205cb2 <do_execve+0x49e>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
ffffffffc02059b6:	01893503          	ld	a0,24(s2)
ffffffffc02059ba:	467d                	li	a2,31
ffffffffc02059bc:	7fffc5b7          	lui	a1,0x7fffc
ffffffffc02059c0:	929fd0ef          	jal	ra,ffffffffc02032e8 <pgdir_alloc_page>
ffffffffc02059c4:	2c050763          	beqz	a0,ffffffffc0205c92 <do_execve+0x47e>
    mm->mm_count += 1;
ffffffffc02059c8:	03092783          	lw	a5,48(s2)
    current->mm = mm;
ffffffffc02059cc:	000a3603          	ld	a2,0(s4)
    current->cr3 = PADDR(mm->pgdir);
ffffffffc02059d0:	01893683          	ld	a3,24(s2)
ffffffffc02059d4:	2785                	addiw	a5,a5,1
ffffffffc02059d6:	02f92823          	sw	a5,48(s2)
    current->mm = mm;
ffffffffc02059da:	03263423          	sd	s2,40(a2) # 100028 <_binary_obj___user_matrix_out_size+0xf45c0>
    current->cr3 = PADDR(mm->pgdir);
ffffffffc02059de:	c02007b7          	lui	a5,0xc0200
ffffffffc02059e2:	28f6ec63          	bltu	a3,a5,ffffffffc0205c7a <do_execve+0x466>
ffffffffc02059e6:	000c4797          	auipc	a5,0xc4
ffffffffc02059ea:	8f278793          	addi	a5,a5,-1806 # ffffffffc02c92d8 <va_pa_offset>
ffffffffc02059ee:	639c                	ld	a5,0(a5)
ffffffffc02059f0:	577d                	li	a4,-1
ffffffffc02059f2:	177e                	slli	a4,a4,0x3f
ffffffffc02059f4:	8e9d                	sub	a3,a3,a5
ffffffffc02059f6:	00c6d793          	srli	a5,a3,0xc
ffffffffc02059fa:	f654                	sd	a3,168(a2)
ffffffffc02059fc:	8fd9                	or	a5,a5,a4
ffffffffc02059fe:	18079073          	csrw	satp,a5
    struct trapframe *tf = current->tf;
ffffffffc0205a02:	7240                	ld	s0,160(a2)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc0205a04:	4581                	li	a1,0
ffffffffc0205a06:	12000613          	li	a2,288
ffffffffc0205a0a:	8522                	mv	a0,s0
    uintptr_t sstatus = tf->status;
ffffffffc0205a0c:	10043483          	ld	s1,256(s0)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc0205a10:	726030ef          	jal	ra,ffffffffc0209136 <memset>
    tf->epc = elf->e_entry;
ffffffffc0205a14:	018b3703          	ld	a4,24(s6)
    tf->gpr.sp = USTACKTOP;
ffffffffc0205a18:	4785                	li	a5,1
    set_proc_name(current, local_name);
ffffffffc0205a1a:	000a3503          	ld	a0,0(s4)
    tf->status = sstatus & ~(SSTATUS_SPP | SSTATUS_SPIE);
ffffffffc0205a1e:	edf4f493          	andi	s1,s1,-289
    tf->gpr.sp = USTACKTOP;
ffffffffc0205a22:	07fe                	slli	a5,a5,0x1f
ffffffffc0205a24:	e81c                	sd	a5,16(s0)
    tf->epc = elf->e_entry;
ffffffffc0205a26:	10e43423          	sd	a4,264(s0)
    tf->status = sstatus & ~(SSTATUS_SPP | SSTATUS_SPIE);
ffffffffc0205a2a:	10943023          	sd	s1,256(s0)
    set_proc_name(current, local_name);
ffffffffc0205a2e:	100c                	addi	a1,sp,32
ffffffffc0205a30:	ca8ff0ef          	jal	ra,ffffffffc0204ed8 <set_proc_name>
}
ffffffffc0205a34:	60ea                	ld	ra,152(sp)
ffffffffc0205a36:	644a                	ld	s0,144(sp)
ffffffffc0205a38:	854e                	mv	a0,s3
ffffffffc0205a3a:	64aa                	ld	s1,136(sp)
ffffffffc0205a3c:	690a                	ld	s2,128(sp)
ffffffffc0205a3e:	79e6                	ld	s3,120(sp)
ffffffffc0205a40:	7a46                	ld	s4,112(sp)
ffffffffc0205a42:	7aa6                	ld	s5,104(sp)
ffffffffc0205a44:	7b06                	ld	s6,96(sp)
ffffffffc0205a46:	6be6                	ld	s7,88(sp)
ffffffffc0205a48:	6c46                	ld	s8,80(sp)
ffffffffc0205a4a:	6ca6                	ld	s9,72(sp)
ffffffffc0205a4c:	6d06                	ld	s10,64(sp)
ffffffffc0205a4e:	7de2                	ld	s11,56(sp)
ffffffffc0205a50:	610d                	addi	sp,sp,160
ffffffffc0205a52:	8082                	ret
        if (ph->p_filesz > ph->p_memsz) {
ffffffffc0205a54:	7410                	ld	a2,40(s0)
ffffffffc0205a56:	701c                	ld	a5,32(s0)
ffffffffc0205a58:	20f66363          	bltu	a2,a5,ffffffffc0205c5e <do_execve+0x44a>
        if (ph->p_flags & ELF_PF_X) vm_flags |= VM_EXEC;
ffffffffc0205a5c:	405c                	lw	a5,4(s0)
ffffffffc0205a5e:	0017f693          	andi	a3,a5,1
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205a62:	0027f713          	andi	a4,a5,2
        if (ph->p_flags & ELF_PF_X) vm_flags |= VM_EXEC;
ffffffffc0205a66:	068a                	slli	a3,a3,0x2
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205a68:	0e071263          	bnez	a4,ffffffffc0205b4c <do_execve+0x338>
        vm_flags = 0, perm = PTE_U | PTE_V;
ffffffffc0205a6c:	4745                	li	a4,17
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205a6e:	8b91                	andi	a5,a5,4
        vm_flags = 0, perm = PTE_U | PTE_V;
ffffffffc0205a70:	e03a                	sd	a4,0(sp)
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205a72:	c789                	beqz	a5,ffffffffc0205a7c <do_execve+0x268>
        if (vm_flags & VM_READ) perm |= PTE_R;
ffffffffc0205a74:	47cd                	li	a5,19
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205a76:	0016e693          	ori	a3,a3,1
        if (vm_flags & VM_READ) perm |= PTE_R;
ffffffffc0205a7a:	e03e                	sd	a5,0(sp)
        if (vm_flags & VM_WRITE) perm |= (PTE_W | PTE_R);
ffffffffc0205a7c:	0026f793          	andi	a5,a3,2
ffffffffc0205a80:	efe1                	bnez	a5,ffffffffc0205b58 <do_execve+0x344>
        if (vm_flags & VM_EXEC) perm |= PTE_X;
ffffffffc0205a82:	0046f793          	andi	a5,a3,4
ffffffffc0205a86:	c789                	beqz	a5,ffffffffc0205a90 <do_execve+0x27c>
ffffffffc0205a88:	6782                	ld	a5,0(sp)
ffffffffc0205a8a:	0087e793          	ori	a5,a5,8
ffffffffc0205a8e:	e03e                	sd	a5,0(sp)
        if ((ret = mm_map(mm, ph->p_va, ph->p_memsz, vm_flags, NULL)) != 0) {
ffffffffc0205a90:	680c                	ld	a1,16(s0)
ffffffffc0205a92:	4701                	li	a4,0
ffffffffc0205a94:	854a                	mv	a0,s2
ffffffffc0205a96:	ff8fe0ef          	jal	ra,ffffffffc020428e <mm_map>
ffffffffc0205a9a:	89aa                	mv	s3,a0
ffffffffc0205a9c:	e541                	bnez	a0,ffffffffc0205b24 <do_execve+0x310>
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0205a9e:	01043b83          	ld	s7,16(s0)
        end = ph->p_va + ph->p_filesz;
ffffffffc0205aa2:	02043983          	ld	s3,32(s0)
        unsigned char *from = binary + ph->p_offset;
ffffffffc0205aa6:	00843a83          	ld	s5,8(s0)
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0205aaa:	77fd                	lui	a5,0xfffff
        end = ph->p_va + ph->p_filesz;
ffffffffc0205aac:	99de                	add	s3,s3,s7
        unsigned char *from = binary + ph->p_offset;
ffffffffc0205aae:	9ada                	add	s5,s5,s6
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0205ab0:	00fbfc33          	and	s8,s7,a5
        while (start < end) {
ffffffffc0205ab4:	053bef63          	bltu	s7,s3,ffffffffc0205b12 <do_execve+0x2fe>
ffffffffc0205ab8:	aa79                	j	ffffffffc0205c56 <do_execve+0x442>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0205aba:	6785                	lui	a5,0x1
ffffffffc0205abc:	418b8533          	sub	a0,s7,s8
ffffffffc0205ac0:	9c3e                	add	s8,s8,a5
ffffffffc0205ac2:	417c0833          	sub	a6,s8,s7
            if (end < la) {
ffffffffc0205ac6:	0189f463          	bleu	s8,s3,ffffffffc0205ace <do_execve+0x2ba>
                size -= la - end;
ffffffffc0205aca:	41798833          	sub	a6,s3,s7
    return page - pages + nbase;
ffffffffc0205ace:	000db683          	ld	a3,0(s11)
ffffffffc0205ad2:	000d3583          	ld	a1,0(s10)
    return KADDR(page2pa(page));
ffffffffc0205ad6:	67a2                	ld	a5,8(sp)
    return page - pages + nbase;
ffffffffc0205ad8:	40d486b3          	sub	a3,s1,a3
ffffffffc0205adc:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0205ade:	000cb603          	ld	a2,0(s9)
    return page - pages + nbase;
ffffffffc0205ae2:	96ae                	add	a3,a3,a1
    return KADDR(page2pa(page));
ffffffffc0205ae4:	00f6f5b3          	and	a1,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205ae8:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205aea:	16c5fc63          	bleu	a2,a1,ffffffffc0205c62 <do_execve+0x44e>
ffffffffc0205aee:	000c3797          	auipc	a5,0xc3
ffffffffc0205af2:	7ea78793          	addi	a5,a5,2026 # ffffffffc02c92d8 <va_pa_offset>
ffffffffc0205af6:	0007b883          	ld	a7,0(a5)
            memcpy(page2kva(page) + off, from, size);
ffffffffc0205afa:	85d6                	mv	a1,s5
ffffffffc0205afc:	8642                	mv	a2,a6
ffffffffc0205afe:	96c6                	add	a3,a3,a7
ffffffffc0205b00:	9536                	add	a0,a0,a3
            start += size, from += size;
ffffffffc0205b02:	9bc2                	add	s7,s7,a6
ffffffffc0205b04:	e842                	sd	a6,16(sp)
            memcpy(page2kva(page) + off, from, size);
ffffffffc0205b06:	642030ef          	jal	ra,ffffffffc0209148 <memcpy>
            start += size, from += size;
ffffffffc0205b0a:	6842                	ld	a6,16(sp)
ffffffffc0205b0c:	9ac2                	add	s5,s5,a6
        while (start < end) {
ffffffffc0205b0e:	053bf863          	bleu	s3,s7,ffffffffc0205b5e <do_execve+0x34a>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
ffffffffc0205b12:	01893503          	ld	a0,24(s2)
ffffffffc0205b16:	6602                	ld	a2,0(sp)
ffffffffc0205b18:	85e2                	mv	a1,s8
ffffffffc0205b1a:	fcefd0ef          	jal	ra,ffffffffc02032e8 <pgdir_alloc_page>
ffffffffc0205b1e:	84aa                	mv	s1,a0
ffffffffc0205b20:	fd49                	bnez	a0,ffffffffc0205aba <do_execve+0x2a6>
        ret = -E_NO_MEM;
ffffffffc0205b22:	59f1                	li	s3,-4
    exit_mmap(mm);
ffffffffc0205b24:	854a                	mv	a0,s2
ffffffffc0205b26:	8b7fe0ef          	jal	ra,ffffffffc02043dc <exit_mmap>
    put_pgdir(mm);
ffffffffc0205b2a:	854a                	mv	a0,s2
ffffffffc0205b2c:	aa2ff0ef          	jal	ra,ffffffffc0204dce <put_pgdir>
    mm_destroy(mm);
ffffffffc0205b30:	854a                	mv	a0,s2
ffffffffc0205b32:	f0afe0ef          	jal	ra,ffffffffc020423c <mm_destroy>
    return ret;
ffffffffc0205b36:	b355                	j	ffffffffc02058da <do_execve+0xc6>
            exit_mmap(mm);
ffffffffc0205b38:	854a                	mv	a0,s2
ffffffffc0205b3a:	8a3fe0ef          	jal	ra,ffffffffc02043dc <exit_mmap>
            put_pgdir(mm);
ffffffffc0205b3e:	854a                	mv	a0,s2
ffffffffc0205b40:	a8eff0ef          	jal	ra,ffffffffc0204dce <put_pgdir>
            mm_destroy(mm);
ffffffffc0205b44:	854a                	mv	a0,s2
ffffffffc0205b46:	ef6fe0ef          	jal	ra,ffffffffc020423c <mm_destroy>
ffffffffc0205b4a:	bbb1                	j	ffffffffc02058a6 <do_execve+0x92>
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205b4c:	0026e693          	ori	a3,a3,2
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205b50:	8b91                	andi	a5,a5,4
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205b52:	2681                	sext.w	a3,a3
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205b54:	f20790e3          	bnez	a5,ffffffffc0205a74 <do_execve+0x260>
        if (vm_flags & VM_WRITE) perm |= (PTE_W | PTE_R);
ffffffffc0205b58:	47dd                	li	a5,23
ffffffffc0205b5a:	e03e                	sd	a5,0(sp)
ffffffffc0205b5c:	b71d                	j	ffffffffc0205a82 <do_execve+0x26e>
ffffffffc0205b5e:	01043983          	ld	s3,16(s0)
        end = ph->p_va + ph->p_memsz;
ffffffffc0205b62:	7414                	ld	a3,40(s0)
ffffffffc0205b64:	99b6                	add	s3,s3,a3
        if (start < la) {
ffffffffc0205b66:	098bf163          	bleu	s8,s7,ffffffffc0205be8 <do_execve+0x3d4>
            if (start == end) {
ffffffffc0205b6a:	df798ae3          	beq	s3,s7,ffffffffc020595e <do_execve+0x14a>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0205b6e:	6505                	lui	a0,0x1
ffffffffc0205b70:	955e                	add	a0,a0,s7
ffffffffc0205b72:	41850533          	sub	a0,a0,s8
                size -= la - end;
ffffffffc0205b76:	41798ab3          	sub	s5,s3,s7
            if (end < la) {
ffffffffc0205b7a:	0d89fb63          	bleu	s8,s3,ffffffffc0205c50 <do_execve+0x43c>
    return page - pages + nbase;
ffffffffc0205b7e:	000db683          	ld	a3,0(s11)
ffffffffc0205b82:	000d3583          	ld	a1,0(s10)
    return KADDR(page2pa(page));
ffffffffc0205b86:	67a2                	ld	a5,8(sp)
    return page - pages + nbase;
ffffffffc0205b88:	40d486b3          	sub	a3,s1,a3
ffffffffc0205b8c:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0205b8e:	000cb603          	ld	a2,0(s9)
    return page - pages + nbase;
ffffffffc0205b92:	96ae                	add	a3,a3,a1
    return KADDR(page2pa(page));
ffffffffc0205b94:	00f6f5b3          	and	a1,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205b98:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205b9a:	0cc5f463          	bleu	a2,a1,ffffffffc0205c62 <do_execve+0x44e>
ffffffffc0205b9e:	000c3617          	auipc	a2,0xc3
ffffffffc0205ba2:	73a60613          	addi	a2,a2,1850 # ffffffffc02c92d8 <va_pa_offset>
ffffffffc0205ba6:	00063803          	ld	a6,0(a2)
            memset(page2kva(page) + off, 0, size);
ffffffffc0205baa:	4581                	li	a1,0
ffffffffc0205bac:	8656                	mv	a2,s5
ffffffffc0205bae:	96c2                	add	a3,a3,a6
ffffffffc0205bb0:	9536                	add	a0,a0,a3
ffffffffc0205bb2:	584030ef          	jal	ra,ffffffffc0209136 <memset>
            start += size;
ffffffffc0205bb6:	017a8733          	add	a4,s5,s7
            assert((end < la && start == end) || (end >= la && start == la));
ffffffffc0205bba:	0389f463          	bleu	s8,s3,ffffffffc0205be2 <do_execve+0x3ce>
ffffffffc0205bbe:	dae980e3          	beq	s3,a4,ffffffffc020595e <do_execve+0x14a>
ffffffffc0205bc2:	00005697          	auipc	a3,0x5
ffffffffc0205bc6:	39e68693          	addi	a3,a3,926 # ffffffffc020af60 <default_pmm_manager+0x10c8>
ffffffffc0205bca:	00004617          	auipc	a2,0x4
ffffffffc0205bce:	b8660613          	addi	a2,a2,-1146 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0205bd2:	27300593          	li	a1,627
ffffffffc0205bd6:	00005517          	auipc	a0,0x5
ffffffffc0205bda:	7d250513          	addi	a0,a0,2002 # ffffffffc020b3a8 <default_pmm_manager+0x1510>
ffffffffc0205bde:	8abfa0ef          	jal	ra,ffffffffc0200488 <__panic>
ffffffffc0205be2:	ff8710e3          	bne	a4,s8,ffffffffc0205bc2 <do_execve+0x3ae>
ffffffffc0205be6:	8be2                	mv	s7,s8
ffffffffc0205be8:	000c3a97          	auipc	s5,0xc3
ffffffffc0205bec:	6f0a8a93          	addi	s5,s5,1776 # ffffffffc02c92d8 <va_pa_offset>
        while (start < end) {
ffffffffc0205bf0:	053be763          	bltu	s7,s3,ffffffffc0205c3e <do_execve+0x42a>
ffffffffc0205bf4:	b3ad                	j	ffffffffc020595e <do_execve+0x14a>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0205bf6:	6785                	lui	a5,0x1
ffffffffc0205bf8:	418b8533          	sub	a0,s7,s8
ffffffffc0205bfc:	9c3e                	add	s8,s8,a5
ffffffffc0205bfe:	417c0633          	sub	a2,s8,s7
            if (end < la) {
ffffffffc0205c02:	0189f463          	bleu	s8,s3,ffffffffc0205c0a <do_execve+0x3f6>
                size -= la - end;
ffffffffc0205c06:	41798633          	sub	a2,s3,s7
    return page - pages + nbase;
ffffffffc0205c0a:	000db683          	ld	a3,0(s11)
ffffffffc0205c0e:	000d3803          	ld	a6,0(s10)
    return KADDR(page2pa(page));
ffffffffc0205c12:	67a2                	ld	a5,8(sp)
    return page - pages + nbase;
ffffffffc0205c14:	40d486b3          	sub	a3,s1,a3
ffffffffc0205c18:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0205c1a:	000cb583          	ld	a1,0(s9)
    return page - pages + nbase;
ffffffffc0205c1e:	96c2                	add	a3,a3,a6
    return KADDR(page2pa(page));
ffffffffc0205c20:	00f6f833          	and	a6,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205c24:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205c26:	02b87e63          	bleu	a1,a6,ffffffffc0205c62 <do_execve+0x44e>
ffffffffc0205c2a:	000ab803          	ld	a6,0(s5)
            start += size;
ffffffffc0205c2e:	9bb2                	add	s7,s7,a2
            memset(page2kva(page) + off, 0, size);
ffffffffc0205c30:	4581                	li	a1,0
ffffffffc0205c32:	96c2                	add	a3,a3,a6
ffffffffc0205c34:	9536                	add	a0,a0,a3
ffffffffc0205c36:	500030ef          	jal	ra,ffffffffc0209136 <memset>
        while (start < end) {
ffffffffc0205c3a:	d33bf2e3          	bleu	s3,s7,ffffffffc020595e <do_execve+0x14a>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
ffffffffc0205c3e:	01893503          	ld	a0,24(s2)
ffffffffc0205c42:	6602                	ld	a2,0(sp)
ffffffffc0205c44:	85e2                	mv	a1,s8
ffffffffc0205c46:	ea2fd0ef          	jal	ra,ffffffffc02032e8 <pgdir_alloc_page>
ffffffffc0205c4a:	84aa                	mv	s1,a0
ffffffffc0205c4c:	f54d                	bnez	a0,ffffffffc0205bf6 <do_execve+0x3e2>
ffffffffc0205c4e:	bdd1                	j	ffffffffc0205b22 <do_execve+0x30e>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0205c50:	417c0ab3          	sub	s5,s8,s7
ffffffffc0205c54:	b72d                	j	ffffffffc0205b7e <do_execve+0x36a>
        while (start < end) {
ffffffffc0205c56:	89de                	mv	s3,s7
ffffffffc0205c58:	b729                	j	ffffffffc0205b62 <do_execve+0x34e>
        return -E_INVAL;
ffffffffc0205c5a:	59f5                	li	s3,-3
ffffffffc0205c5c:	bbe1                	j	ffffffffc0205a34 <do_execve+0x220>
            ret = -E_INVAL_ELF;
ffffffffc0205c5e:	59e1                	li	s3,-8
ffffffffc0205c60:	b5d1                	j	ffffffffc0205b24 <do_execve+0x310>
ffffffffc0205c62:	00004617          	auipc	a2,0x4
ffffffffc0205c66:	28660613          	addi	a2,a2,646 # ffffffffc0209ee8 <default_pmm_manager+0x50>
ffffffffc0205c6a:	06900593          	li	a1,105
ffffffffc0205c6e:	00004517          	auipc	a0,0x4
ffffffffc0205c72:	2a250513          	addi	a0,a0,674 # ffffffffc0209f10 <default_pmm_manager+0x78>
ffffffffc0205c76:	813fa0ef          	jal	ra,ffffffffc0200488 <__panic>
    current->cr3 = PADDR(mm->pgdir);
ffffffffc0205c7a:	00004617          	auipc	a2,0x4
ffffffffc0205c7e:	2a660613          	addi	a2,a2,678 # ffffffffc0209f20 <default_pmm_manager+0x88>
ffffffffc0205c82:	28e00593          	li	a1,654
ffffffffc0205c86:	00005517          	auipc	a0,0x5
ffffffffc0205c8a:	72250513          	addi	a0,a0,1826 # ffffffffc020b3a8 <default_pmm_manager+0x1510>
ffffffffc0205c8e:	ffafa0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
ffffffffc0205c92:	00005697          	auipc	a3,0x5
ffffffffc0205c96:	3e668693          	addi	a3,a3,998 # ffffffffc020b078 <default_pmm_manager+0x11e0>
ffffffffc0205c9a:	00004617          	auipc	a2,0x4
ffffffffc0205c9e:	ab660613          	addi	a2,a2,-1354 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0205ca2:	28900593          	li	a1,649
ffffffffc0205ca6:	00005517          	auipc	a0,0x5
ffffffffc0205caa:	70250513          	addi	a0,a0,1794 # ffffffffc020b3a8 <default_pmm_manager+0x1510>
ffffffffc0205cae:	fdafa0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
ffffffffc0205cb2:	00005697          	auipc	a3,0x5
ffffffffc0205cb6:	37e68693          	addi	a3,a3,894 # ffffffffc020b030 <default_pmm_manager+0x1198>
ffffffffc0205cba:	00004617          	auipc	a2,0x4
ffffffffc0205cbe:	a9660613          	addi	a2,a2,-1386 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0205cc2:	28800593          	li	a1,648
ffffffffc0205cc6:	00005517          	auipc	a0,0x5
ffffffffc0205cca:	6e250513          	addi	a0,a0,1762 # ffffffffc020b3a8 <default_pmm_manager+0x1510>
ffffffffc0205cce:	fbafa0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
ffffffffc0205cd2:	00005697          	auipc	a3,0x5
ffffffffc0205cd6:	31668693          	addi	a3,a3,790 # ffffffffc020afe8 <default_pmm_manager+0x1150>
ffffffffc0205cda:	00004617          	auipc	a2,0x4
ffffffffc0205cde:	a7660613          	addi	a2,a2,-1418 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0205ce2:	28700593          	li	a1,647
ffffffffc0205ce6:	00005517          	auipc	a0,0x5
ffffffffc0205cea:	6c250513          	addi	a0,a0,1730 # ffffffffc020b3a8 <default_pmm_manager+0x1510>
ffffffffc0205cee:	f9afa0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
ffffffffc0205cf2:	00005697          	auipc	a3,0x5
ffffffffc0205cf6:	2ae68693          	addi	a3,a3,686 # ffffffffc020afa0 <default_pmm_manager+0x1108>
ffffffffc0205cfa:	00004617          	auipc	a2,0x4
ffffffffc0205cfe:	a5660613          	addi	a2,a2,-1450 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0205d02:	28600593          	li	a1,646
ffffffffc0205d06:	00005517          	auipc	a0,0x5
ffffffffc0205d0a:	6a250513          	addi	a0,a0,1698 # ffffffffc020b3a8 <default_pmm_manager+0x1510>
ffffffffc0205d0e:	f7afa0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0205d12 <do_yield>:
    current->need_resched = 1;
ffffffffc0205d12:	000c3797          	auipc	a5,0xc3
ffffffffc0205d16:	56e78793          	addi	a5,a5,1390 # ffffffffc02c9280 <current>
ffffffffc0205d1a:	639c                	ld	a5,0(a5)
ffffffffc0205d1c:	4705                	li	a4,1
}
ffffffffc0205d1e:	4501                	li	a0,0
    current->need_resched = 1;
ffffffffc0205d20:	ef98                	sd	a4,24(a5)
}
ffffffffc0205d22:	8082                	ret

ffffffffc0205d24 <do_wait>:
do_wait(int pid, int *code_store) {
ffffffffc0205d24:	1101                	addi	sp,sp,-32
ffffffffc0205d26:	e822                	sd	s0,16(sp)
ffffffffc0205d28:	e426                	sd	s1,8(sp)
ffffffffc0205d2a:	ec06                	sd	ra,24(sp)
ffffffffc0205d2c:	842e                	mv	s0,a1
ffffffffc0205d2e:	84aa                	mv	s1,a0
    if (code_store != NULL) {
ffffffffc0205d30:	cd81                	beqz	a1,ffffffffc0205d48 <do_wait+0x24>
    struct mm_struct *mm = current->mm;
ffffffffc0205d32:	000c3797          	auipc	a5,0xc3
ffffffffc0205d36:	54e78793          	addi	a5,a5,1358 # ffffffffc02c9280 <current>
ffffffffc0205d3a:	639c                	ld	a5,0(a5)
        if (!user_mem_check(mm, (uintptr_t)code_store, sizeof(int), 1)) {
ffffffffc0205d3c:	4685                	li	a3,1
ffffffffc0205d3e:	4611                	li	a2,4
ffffffffc0205d40:	7788                	ld	a0,40(a5)
ffffffffc0205d42:	d5ffe0ef          	jal	ra,ffffffffc0204aa0 <user_mem_check>
ffffffffc0205d46:	c909                	beqz	a0,ffffffffc0205d58 <do_wait+0x34>
ffffffffc0205d48:	85a2                	mv	a1,s0
}
ffffffffc0205d4a:	6442                	ld	s0,16(sp)
ffffffffc0205d4c:	60e2                	ld	ra,24(sp)
ffffffffc0205d4e:	8526                	mv	a0,s1
ffffffffc0205d50:	64a2                	ld	s1,8(sp)
ffffffffc0205d52:	6105                	addi	sp,sp,32
ffffffffc0205d54:	ff0ff06f          	j	ffffffffc0205544 <do_wait.part.1>
ffffffffc0205d58:	60e2                	ld	ra,24(sp)
ffffffffc0205d5a:	6442                	ld	s0,16(sp)
ffffffffc0205d5c:	64a2                	ld	s1,8(sp)
ffffffffc0205d5e:	5575                	li	a0,-3
ffffffffc0205d60:	6105                	addi	sp,sp,32
ffffffffc0205d62:	8082                	ret

ffffffffc0205d64 <do_kill>:
do_kill(int pid) {
ffffffffc0205d64:	1141                	addi	sp,sp,-16
ffffffffc0205d66:	e406                	sd	ra,8(sp)
ffffffffc0205d68:	e022                	sd	s0,0(sp)
    if ((proc = find_proc(pid)) != NULL) {
ffffffffc0205d6a:	a04ff0ef          	jal	ra,ffffffffc0204f6e <find_proc>
ffffffffc0205d6e:	cd0d                	beqz	a0,ffffffffc0205da8 <do_kill+0x44>
        if (!(proc->flags & PF_EXITING)) {
ffffffffc0205d70:	0b052703          	lw	a4,176(a0)
ffffffffc0205d74:	00177693          	andi	a3,a4,1
ffffffffc0205d78:	e695                	bnez	a3,ffffffffc0205da4 <do_kill+0x40>
            if (proc->wait_state & WT_INTERRUPTED) {
ffffffffc0205d7a:	0ec52683          	lw	a3,236(a0)
            proc->flags |= PF_EXITING;
ffffffffc0205d7e:	00176713          	ori	a4,a4,1
ffffffffc0205d82:	0ae52823          	sw	a4,176(a0)
            return 0;
ffffffffc0205d86:	4401                	li	s0,0
            if (proc->wait_state & WT_INTERRUPTED) {
ffffffffc0205d88:	0006c763          	bltz	a3,ffffffffc0205d96 <do_kill+0x32>
}
ffffffffc0205d8c:	8522                	mv	a0,s0
ffffffffc0205d8e:	60a2                	ld	ra,8(sp)
ffffffffc0205d90:	6402                	ld	s0,0(sp)
ffffffffc0205d92:	0141                	addi	sp,sp,16
ffffffffc0205d94:	8082                	ret
                wakeup_proc(proc);
ffffffffc0205d96:	469020ef          	jal	ra,ffffffffc02089fe <wakeup_proc>
}
ffffffffc0205d9a:	8522                	mv	a0,s0
ffffffffc0205d9c:	60a2                	ld	ra,8(sp)
ffffffffc0205d9e:	6402                	ld	s0,0(sp)
ffffffffc0205da0:	0141                	addi	sp,sp,16
ffffffffc0205da2:	8082                	ret
        return -E_KILLED;
ffffffffc0205da4:	545d                	li	s0,-9
ffffffffc0205da6:	b7dd                	j	ffffffffc0205d8c <do_kill+0x28>
    return -E_INVAL;
ffffffffc0205da8:	5475                	li	s0,-3
ffffffffc0205daa:	b7cd                	j	ffffffffc0205d8c <do_kill+0x28>

ffffffffc0205dac <proc_init>:
    elm->prev = elm->next = elm;
ffffffffc0205dac:	000c3797          	auipc	a5,0xc3
ffffffffc0205db0:	62478793          	addi	a5,a5,1572 # ffffffffc02c93d0 <proc_list>

// proc_init - set up the first kernel thread idleproc "idle" by itself and 
//           - create the second kernel thread init_main
void
proc_init(void) {
ffffffffc0205db4:	1101                	addi	sp,sp,-32
ffffffffc0205db6:	000c3717          	auipc	a4,0xc3
ffffffffc0205dba:	62f73123          	sd	a5,1570(a4) # ffffffffc02c93d8 <proc_list+0x8>
ffffffffc0205dbe:	000c3717          	auipc	a4,0xc3
ffffffffc0205dc2:	60f73923          	sd	a5,1554(a4) # ffffffffc02c93d0 <proc_list>
ffffffffc0205dc6:	ec06                	sd	ra,24(sp)
ffffffffc0205dc8:	e822                	sd	s0,16(sp)
ffffffffc0205dca:	e426                	sd	s1,8(sp)
ffffffffc0205dcc:	000bf797          	auipc	a5,0xbf
ffffffffc0205dd0:	44c78793          	addi	a5,a5,1100 # ffffffffc02c5218 <hash_list>
ffffffffc0205dd4:	000c3717          	auipc	a4,0xc3
ffffffffc0205dd8:	44470713          	addi	a4,a4,1092 # ffffffffc02c9218 <__rq>
ffffffffc0205ddc:	e79c                	sd	a5,8(a5)
ffffffffc0205dde:	e39c                	sd	a5,0(a5)
ffffffffc0205de0:	07c1                	addi	a5,a5,16
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
ffffffffc0205de2:	fee79de3          	bne	a5,a4,ffffffffc0205ddc <proc_init+0x30>
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL) {
ffffffffc0205de6:	ebffe0ef          	jal	ra,ffffffffc0204ca4 <alloc_proc>
ffffffffc0205dea:	000c3717          	auipc	a4,0xc3
ffffffffc0205dee:	48a73f23          	sd	a0,1182(a4) # ffffffffc02c9288 <idleproc>
ffffffffc0205df2:	000c3497          	auipc	s1,0xc3
ffffffffc0205df6:	49648493          	addi	s1,s1,1174 # ffffffffc02c9288 <idleproc>
ffffffffc0205dfa:	c559                	beqz	a0,ffffffffc0205e88 <proc_init+0xdc>
        panic("cannot alloc idleproc.\n");
    }

    idleproc->pid = 0;
    idleproc->state = PROC_RUNNABLE;
ffffffffc0205dfc:	4709                	li	a4,2
ffffffffc0205dfe:	e118                	sd	a4,0(a0)
    idleproc->kstack = (uintptr_t)bootstack;
    idleproc->need_resched = 1;
ffffffffc0205e00:	4405                	li	s0,1
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0205e02:	00006717          	auipc	a4,0x6
ffffffffc0205e06:	1fe70713          	addi	a4,a4,510 # ffffffffc020c000 <bootstack>
    set_proc_name(idleproc, "idle");
ffffffffc0205e0a:	00005597          	auipc	a1,0x5
ffffffffc0205e0e:	4b658593          	addi	a1,a1,1206 # ffffffffc020b2c0 <default_pmm_manager+0x1428>
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0205e12:	e918                	sd	a4,16(a0)
    idleproc->need_resched = 1;
ffffffffc0205e14:	ed00                	sd	s0,24(a0)
    set_proc_name(idleproc, "idle");
ffffffffc0205e16:	8c2ff0ef          	jal	ra,ffffffffc0204ed8 <set_proc_name>
    nr_process ++;
ffffffffc0205e1a:	000c3797          	auipc	a5,0xc3
ffffffffc0205e1e:	47e78793          	addi	a5,a5,1150 # ffffffffc02c9298 <nr_process>
ffffffffc0205e22:	439c                	lw	a5,0(a5)

    current = idleproc;
ffffffffc0205e24:	6098                	ld	a4,0(s1)

    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205e26:	4601                	li	a2,0
    nr_process ++;
ffffffffc0205e28:	2785                	addiw	a5,a5,1
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205e2a:	4581                	li	a1,0
ffffffffc0205e2c:	00000517          	auipc	a0,0x0
ffffffffc0205e30:	8c050513          	addi	a0,a0,-1856 # ffffffffc02056ec <init_main>
    nr_process ++;
ffffffffc0205e34:	000c3697          	auipc	a3,0xc3
ffffffffc0205e38:	46f6a223          	sw	a5,1124(a3) # ffffffffc02c9298 <nr_process>
    current = idleproc;
ffffffffc0205e3c:	000c3797          	auipc	a5,0xc3
ffffffffc0205e40:	44e7b223          	sd	a4,1092(a5) # ffffffffc02c9280 <current>
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205e44:	d62ff0ef          	jal	ra,ffffffffc02053a6 <kernel_thread>
    if (pid <= 0) {
ffffffffc0205e48:	08a05c63          	blez	a0,ffffffffc0205ee0 <proc_init+0x134>
        panic("create init_main failed.\n");
    }

    initproc = find_proc(pid);
ffffffffc0205e4c:	922ff0ef          	jal	ra,ffffffffc0204f6e <find_proc>
    set_proc_name(initproc, "init");
ffffffffc0205e50:	00005597          	auipc	a1,0x5
ffffffffc0205e54:	49858593          	addi	a1,a1,1176 # ffffffffc020b2e8 <default_pmm_manager+0x1450>
    initproc = find_proc(pid);
ffffffffc0205e58:	000c3797          	auipc	a5,0xc3
ffffffffc0205e5c:	42a7bc23          	sd	a0,1080(a5) # ffffffffc02c9290 <initproc>
    set_proc_name(initproc, "init");
ffffffffc0205e60:	878ff0ef          	jal	ra,ffffffffc0204ed8 <set_proc_name>

    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0205e64:	609c                	ld	a5,0(s1)
ffffffffc0205e66:	cfa9                	beqz	a5,ffffffffc0205ec0 <proc_init+0x114>
ffffffffc0205e68:	43dc                	lw	a5,4(a5)
ffffffffc0205e6a:	ebb9                	bnez	a5,ffffffffc0205ec0 <proc_init+0x114>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0205e6c:	000c3797          	auipc	a5,0xc3
ffffffffc0205e70:	42478793          	addi	a5,a5,1060 # ffffffffc02c9290 <initproc>
ffffffffc0205e74:	639c                	ld	a5,0(a5)
ffffffffc0205e76:	c78d                	beqz	a5,ffffffffc0205ea0 <proc_init+0xf4>
ffffffffc0205e78:	43dc                	lw	a5,4(a5)
ffffffffc0205e7a:	02879363          	bne	a5,s0,ffffffffc0205ea0 <proc_init+0xf4>
}
ffffffffc0205e7e:	60e2                	ld	ra,24(sp)
ffffffffc0205e80:	6442                	ld	s0,16(sp)
ffffffffc0205e82:	64a2                	ld	s1,8(sp)
ffffffffc0205e84:	6105                	addi	sp,sp,32
ffffffffc0205e86:	8082                	ret
        panic("cannot alloc idleproc.\n");
ffffffffc0205e88:	00005617          	auipc	a2,0x5
ffffffffc0205e8c:	42060613          	addi	a2,a2,1056 # ffffffffc020b2a8 <default_pmm_manager+0x1410>
ffffffffc0205e90:	38700593          	li	a1,903
ffffffffc0205e94:	00005517          	auipc	a0,0x5
ffffffffc0205e98:	51450513          	addi	a0,a0,1300 # ffffffffc020b3a8 <default_pmm_manager+0x1510>
ffffffffc0205e9c:	decfa0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0205ea0:	00005697          	auipc	a3,0x5
ffffffffc0205ea4:	47868693          	addi	a3,a3,1144 # ffffffffc020b318 <default_pmm_manager+0x1480>
ffffffffc0205ea8:	00004617          	auipc	a2,0x4
ffffffffc0205eac:	8a860613          	addi	a2,a2,-1880 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0205eb0:	39c00593          	li	a1,924
ffffffffc0205eb4:	00005517          	auipc	a0,0x5
ffffffffc0205eb8:	4f450513          	addi	a0,a0,1268 # ffffffffc020b3a8 <default_pmm_manager+0x1510>
ffffffffc0205ebc:	dccfa0ef          	jal	ra,ffffffffc0200488 <__panic>
    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0205ec0:	00005697          	auipc	a3,0x5
ffffffffc0205ec4:	43068693          	addi	a3,a3,1072 # ffffffffc020b2f0 <default_pmm_manager+0x1458>
ffffffffc0205ec8:	00004617          	auipc	a2,0x4
ffffffffc0205ecc:	88860613          	addi	a2,a2,-1912 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0205ed0:	39b00593          	li	a1,923
ffffffffc0205ed4:	00005517          	auipc	a0,0x5
ffffffffc0205ed8:	4d450513          	addi	a0,a0,1236 # ffffffffc020b3a8 <default_pmm_manager+0x1510>
ffffffffc0205edc:	dacfa0ef          	jal	ra,ffffffffc0200488 <__panic>
        panic("create init_main failed.\n");
ffffffffc0205ee0:	00005617          	auipc	a2,0x5
ffffffffc0205ee4:	3e860613          	addi	a2,a2,1000 # ffffffffc020b2c8 <default_pmm_manager+0x1430>
ffffffffc0205ee8:	39500593          	li	a1,917
ffffffffc0205eec:	00005517          	auipc	a0,0x5
ffffffffc0205ef0:	4bc50513          	addi	a0,a0,1212 # ffffffffc020b3a8 <default_pmm_manager+0x1510>
ffffffffc0205ef4:	d94fa0ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0205ef8 <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void
cpu_idle(void) {
ffffffffc0205ef8:	1141                	addi	sp,sp,-16
ffffffffc0205efa:	e022                	sd	s0,0(sp)
ffffffffc0205efc:	e406                	sd	ra,8(sp)
ffffffffc0205efe:	000c3417          	auipc	s0,0xc3
ffffffffc0205f02:	38240413          	addi	s0,s0,898 # ffffffffc02c9280 <current>
    while (1) {
        if (current->need_resched) {
ffffffffc0205f06:	6018                	ld	a4,0(s0)
ffffffffc0205f08:	6f1c                	ld	a5,24(a4)
ffffffffc0205f0a:	dffd                	beqz	a5,ffffffffc0205f08 <cpu_idle+0x10>
            schedule();
ffffffffc0205f0c:	3ad020ef          	jal	ra,ffffffffc0208ab8 <schedule>
ffffffffc0205f10:	bfdd                	j	ffffffffc0205f06 <cpu_idle+0xe>

ffffffffc0205f12 <lab6_set_priority>:
    }
}
//FOR LAB6, set the process's priority (bigger value will get more CPU time)
void
lab6_set_priority(uint32_t priority)
{
ffffffffc0205f12:	1141                	addi	sp,sp,-16
ffffffffc0205f14:	e022                	sd	s0,0(sp)
    cprintf("set priority to %d\n", priority);
ffffffffc0205f16:	85aa                	mv	a1,a0
{
ffffffffc0205f18:	842a                	mv	s0,a0
    cprintf("set priority to %d\n", priority);
ffffffffc0205f1a:	00005517          	auipc	a0,0x5
ffffffffc0205f1e:	37650513          	addi	a0,a0,886 # ffffffffc020b290 <default_pmm_manager+0x13f8>
{
ffffffffc0205f22:	e406                	sd	ra,8(sp)
    cprintf("set priority to %d\n", priority);
ffffffffc0205f24:	a6efa0ef          	jal	ra,ffffffffc0200192 <cprintf>
    if (priority == 0)
        current->lab6_priority = 1;
ffffffffc0205f28:	000c3797          	auipc	a5,0xc3
ffffffffc0205f2c:	35878793          	addi	a5,a5,856 # ffffffffc02c9280 <current>
ffffffffc0205f30:	639c                	ld	a5,0(a5)
    if (priority == 0)
ffffffffc0205f32:	e801                	bnez	s0,ffffffffc0205f42 <lab6_set_priority+0x30>
    else current->lab6_priority = priority;
}
ffffffffc0205f34:	60a2                	ld	ra,8(sp)
ffffffffc0205f36:	6402                	ld	s0,0(sp)
        current->lab6_priority = 1;
ffffffffc0205f38:	4705                	li	a4,1
ffffffffc0205f3a:	14e7a223          	sw	a4,324(a5)
}
ffffffffc0205f3e:	0141                	addi	sp,sp,16
ffffffffc0205f40:	8082                	ret
    else current->lab6_priority = priority;
ffffffffc0205f42:	1487a223          	sw	s0,324(a5)
}
ffffffffc0205f46:	60a2                	ld	ra,8(sp)
ffffffffc0205f48:	6402                	ld	s0,0(sp)
ffffffffc0205f4a:	0141                	addi	sp,sp,16
ffffffffc0205f4c:	8082                	ret

ffffffffc0205f4e <switch_to>:
.text
# void switch_to(struct proc_struct* from, struct proc_struct* to)
.globl switch_to
switch_to:
    # save from's registers
    STORE ra, 0*REGBYTES(a0)
ffffffffc0205f4e:	00153023          	sd	ra,0(a0)
    STORE sp, 1*REGBYTES(a0)
ffffffffc0205f52:	00253423          	sd	sp,8(a0)
    STORE s0, 2*REGBYTES(a0)
ffffffffc0205f56:	e900                	sd	s0,16(a0)
    STORE s1, 3*REGBYTES(a0)
ffffffffc0205f58:	ed04                	sd	s1,24(a0)
    STORE s2, 4*REGBYTES(a0)
ffffffffc0205f5a:	03253023          	sd	s2,32(a0)
    STORE s3, 5*REGBYTES(a0)
ffffffffc0205f5e:	03353423          	sd	s3,40(a0)
    STORE s4, 6*REGBYTES(a0)
ffffffffc0205f62:	03453823          	sd	s4,48(a0)
    STORE s5, 7*REGBYTES(a0)
ffffffffc0205f66:	03553c23          	sd	s5,56(a0)
    STORE s6, 8*REGBYTES(a0)
ffffffffc0205f6a:	05653023          	sd	s6,64(a0)
    STORE s7, 9*REGBYTES(a0)
ffffffffc0205f6e:	05753423          	sd	s7,72(a0)
    STORE s8, 10*REGBYTES(a0)
ffffffffc0205f72:	05853823          	sd	s8,80(a0)
    STORE s9, 11*REGBYTES(a0)
ffffffffc0205f76:	05953c23          	sd	s9,88(a0)
    STORE s10, 12*REGBYTES(a0)
ffffffffc0205f7a:	07a53023          	sd	s10,96(a0)
    STORE s11, 13*REGBYTES(a0)
ffffffffc0205f7e:	07b53423          	sd	s11,104(a0)

    # restore to's registers
    LOAD ra, 0*REGBYTES(a1)
ffffffffc0205f82:	0005b083          	ld	ra,0(a1)
    LOAD sp, 1*REGBYTES(a1)
ffffffffc0205f86:	0085b103          	ld	sp,8(a1)
    LOAD s0, 2*REGBYTES(a1)
ffffffffc0205f8a:	6980                	ld	s0,16(a1)
    LOAD s1, 3*REGBYTES(a1)
ffffffffc0205f8c:	6d84                	ld	s1,24(a1)
    LOAD s2, 4*REGBYTES(a1)
ffffffffc0205f8e:	0205b903          	ld	s2,32(a1)
    LOAD s3, 5*REGBYTES(a1)
ffffffffc0205f92:	0285b983          	ld	s3,40(a1)
    LOAD s4, 6*REGBYTES(a1)
ffffffffc0205f96:	0305ba03          	ld	s4,48(a1)
    LOAD s5, 7*REGBYTES(a1)
ffffffffc0205f9a:	0385ba83          	ld	s5,56(a1)
    LOAD s6, 8*REGBYTES(a1)
ffffffffc0205f9e:	0405bb03          	ld	s6,64(a1)
    LOAD s7, 9*REGBYTES(a1)
ffffffffc0205fa2:	0485bb83          	ld	s7,72(a1)
    LOAD s8, 10*REGBYTES(a1)
ffffffffc0205fa6:	0505bc03          	ld	s8,80(a1)
    LOAD s9, 11*REGBYTES(a1)
ffffffffc0205faa:	0585bc83          	ld	s9,88(a1)
    LOAD s10, 12*REGBYTES(a1)
ffffffffc0205fae:	0605bd03          	ld	s10,96(a1)
    LOAD s11, 13*REGBYTES(a1)
ffffffffc0205fb2:	0685bd83          	ld	s11,104(a1)

    ret
ffffffffc0205fb6:	8082                	ret

ffffffffc0205fb8 <proc_stride_comp_f>:
static int
proc_stride_comp_f(void *a, void *b)
{
     struct proc_struct *p = le2proc(a, lab6_run_pool);
     struct proc_struct *q = le2proc(b, lab6_run_pool);
     int32_t c = p->lab6_stride - q->lab6_stride;
ffffffffc0205fb8:	4d08                	lw	a0,24(a0)
ffffffffc0205fba:	4d9c                	lw	a5,24(a1)
ffffffffc0205fbc:	9d1d                	subw	a0,a0,a5
     if (c > 0) return 1;
ffffffffc0205fbe:	00a04763          	bgtz	a0,ffffffffc0205fcc <proc_stride_comp_f+0x14>
     else if (c == 0) return 0;
ffffffffc0205fc2:	00a03533          	snez	a0,a0
ffffffffc0205fc6:	40a0053b          	negw	a0,a0
ffffffffc0205fca:	8082                	ret
     if (c > 0) return 1;
ffffffffc0205fcc:	4505                	li	a0,1
     else return -1;
}
ffffffffc0205fce:	8082                	ret

ffffffffc0205fd0 <stride_init>:
ffffffffc0205fd0:	e508                	sd	a0,8(a0)
ffffffffc0205fd2:	e108                	sd	a0,0(a0)
      * (1) init the ready process list: rq->run_list
      * (2) init the run pool: rq->lab6_run_pool
      * (3) set number of process: rq->proc_num to 0       
      */
    list_init(&(rq->run_list));
    rq->lab6_run_pool = NULL;
ffffffffc0205fd4:	00053c23          	sd	zero,24(a0)
    rq->proc_num = 0;
ffffffffc0205fd8:	00052823          	sw	zero,16(a0)

}
ffffffffc0205fdc:	8082                	ret

ffffffffc0205fde <stride_pick_next>:
             (1.1) If using skew_heap, we can use le2proc get the p from rq->lab6_run_pol
             (1.2) If using list, we have to search list to find the p with minimum stride value
      * (2) update p;s stride value: p->lab6_stride
      * (3) return p
      */
    if(rq->lab6_run_pool == NULL)
ffffffffc0205fde:	6d1c                	ld	a5,24(a0)
ffffffffc0205fe0:	cf89                	beqz	a5,ffffffffc0205ffa <stride_pick_next+0x1c>
        return NULL;
    struct proc_struct* proc = le2proc(rq->lab6_run_pool, lab6_run_pool);
    proc->lab6_stride += BIG_STRIDE / proc->lab6_priority;
ffffffffc0205fe2:	4fd4                	lw	a3,28(a5)
ffffffffc0205fe4:	6761                	lui	a4,0x18
ffffffffc0205fe6:	6a07071b          	addiw	a4,a4,1696
ffffffffc0205fea:	02d7573b          	divuw	a4,a4,a3
ffffffffc0205fee:	4f94                	lw	a3,24(a5)
    struct proc_struct* proc = le2proc(rq->lab6_run_pool, lab6_run_pool);
ffffffffc0205ff0:	ed878513          	addi	a0,a5,-296
    proc->lab6_stride += BIG_STRIDE / proc->lab6_priority;
ffffffffc0205ff4:	9f35                	addw	a4,a4,a3
ffffffffc0205ff6:	cf98                	sw	a4,24(a5)
    return proc;
ffffffffc0205ff8:	8082                	ret
        return NULL;
ffffffffc0205ffa:	4501                	li	a0,0
}
ffffffffc0205ffc:	8082                	ret

ffffffffc0205ffe <stride_proc_tick>:
 * switching.
 */
static void
stride_proc_tick(struct run_queue *rq, struct proc_struct *proc) {
     /* LAB6: YOUR CODE */
    if(proc->time_slice > 0) {
ffffffffc0205ffe:	1205a783          	lw	a5,288(a1)
ffffffffc0206002:	00f05563          	blez	a5,ffffffffc020600c <stride_proc_tick+0xe>
        proc->time_slice--;
ffffffffc0206006:	37fd                	addiw	a5,a5,-1
ffffffffc0206008:	12f5a023          	sw	a5,288(a1)
    }
    if(proc->time_slice == 0) {
ffffffffc020600c:	e399                	bnez	a5,ffffffffc0206012 <stride_proc_tick+0x14>
        proc->need_resched = 1;
ffffffffc020600e:	4785                	li	a5,1
ffffffffc0206010:	ed9c                	sd	a5,24(a1)
    }
}
ffffffffc0206012:	8082                	ret

ffffffffc0206014 <skew_heap_merge.constprop.2>:
}

static inline skew_heap_entry_t *
skew_heap_merge(skew_heap_entry_t *a, skew_heap_entry_t *b,
ffffffffc0206014:	1101                	addi	sp,sp,-32
ffffffffc0206016:	e822                	sd	s0,16(sp)
ffffffffc0206018:	ec06                	sd	ra,24(sp)
ffffffffc020601a:	e426                	sd	s1,8(sp)
ffffffffc020601c:	e04a                	sd	s2,0(sp)
ffffffffc020601e:	842e                	mv	s0,a1
                compare_f comp)
{
     if (a == NULL) return b;
ffffffffc0206020:	c11d                	beqz	a0,ffffffffc0206046 <skew_heap_merge.constprop.2+0x32>
ffffffffc0206022:	84aa                	mv	s1,a0
     else if (b == NULL) return a;
ffffffffc0206024:	c1b9                	beqz	a1,ffffffffc020606a <skew_heap_merge.constprop.2+0x56>
     
     skew_heap_entry_t *l, *r;
     if (comp(a, b) == -1)
ffffffffc0206026:	f93ff0ef          	jal	ra,ffffffffc0205fb8 <proc_stride_comp_f>
ffffffffc020602a:	57fd                	li	a5,-1
ffffffffc020602c:	02f50463          	beq	a0,a5,ffffffffc0206054 <skew_heap_merge.constprop.2+0x40>
          return a;
     }
     else
     {
          r = b->left;
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206030:	680c                	ld	a1,16(s0)
          r = b->left;
ffffffffc0206032:	00843903          	ld	s2,8(s0)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206036:	8526                	mv	a0,s1
ffffffffc0206038:	fddff0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          
          b->left = l;
ffffffffc020603c:	e408                	sd	a0,8(s0)
          b->right = r;
ffffffffc020603e:	01243823          	sd	s2,16(s0)
          if (l) l->parent = b;
ffffffffc0206042:	c111                	beqz	a0,ffffffffc0206046 <skew_heap_merge.constprop.2+0x32>
ffffffffc0206044:	e100                	sd	s0,0(a0)
ffffffffc0206046:	8522                	mv	a0,s0

          return b;
     }
}
ffffffffc0206048:	60e2                	ld	ra,24(sp)
ffffffffc020604a:	6442                	ld	s0,16(sp)
ffffffffc020604c:	64a2                	ld	s1,8(sp)
ffffffffc020604e:	6902                	ld	s2,0(sp)
ffffffffc0206050:	6105                	addi	sp,sp,32
ffffffffc0206052:	8082                	ret
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0206054:	6888                	ld	a0,16(s1)
          r = a->left;
ffffffffc0206056:	0084b903          	ld	s2,8(s1)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc020605a:	85a2                	mv	a1,s0
ffffffffc020605c:	fb9ff0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->left = l;
ffffffffc0206060:	e488                	sd	a0,8(s1)
          a->right = r;
ffffffffc0206062:	0124b823          	sd	s2,16(s1)
          if (l) l->parent = a;
ffffffffc0206066:	c111                	beqz	a0,ffffffffc020606a <skew_heap_merge.constprop.2+0x56>
ffffffffc0206068:	e104                	sd	s1,0(a0)
}
ffffffffc020606a:	60e2                	ld	ra,24(sp)
ffffffffc020606c:	6442                	ld	s0,16(sp)
          if (l) l->parent = a;
ffffffffc020606e:	8526                	mv	a0,s1
}
ffffffffc0206070:	6902                	ld	s2,0(sp)
ffffffffc0206072:	64a2                	ld	s1,8(sp)
ffffffffc0206074:	6105                	addi	sp,sp,32
ffffffffc0206076:	8082                	ret

ffffffffc0206078 <stride_enqueue>:
stride_enqueue(struct run_queue *rq, struct proc_struct *proc) {
ffffffffc0206078:	7119                	addi	sp,sp,-128
ffffffffc020607a:	ecce                	sd	s3,88(sp)
    rq->lab6_run_pool = skew_heap_insert(rq->lab6_run_pool, &(proc->lab6_run_pool), proc_stride_comp_f);
ffffffffc020607c:	01853983          	ld	s3,24(a0)
stride_enqueue(struct run_queue *rq, struct proc_struct *proc) {
ffffffffc0206080:	f8a2                	sd	s0,112(sp)
ffffffffc0206082:	f4a6                	sd	s1,104(sp)
ffffffffc0206084:	f0ca                	sd	s2,96(sp)
ffffffffc0206086:	fc86                	sd	ra,120(sp)
ffffffffc0206088:	e8d2                	sd	s4,80(sp)
ffffffffc020608a:	e4d6                	sd	s5,72(sp)
ffffffffc020608c:	e0da                	sd	s6,64(sp)
ffffffffc020608e:	fc5e                	sd	s7,56(sp)
ffffffffc0206090:	f862                	sd	s8,48(sp)
ffffffffc0206092:	f466                	sd	s9,40(sp)
ffffffffc0206094:	f06a                	sd	s10,32(sp)
ffffffffc0206096:	ec6e                	sd	s11,24(sp)
     a->left = a->right = a->parent = NULL;
ffffffffc0206098:	1205b423          	sd	zero,296(a1)
ffffffffc020609c:	1205bc23          	sd	zero,312(a1)
ffffffffc02060a0:	1205b823          	sd	zero,304(a1)
ffffffffc02060a4:	84aa                	mv	s1,a0
ffffffffc02060a6:	842e                	mv	s0,a1
    rq->lab6_run_pool = skew_heap_insert(rq->lab6_run_pool, &(proc->lab6_run_pool), proc_stride_comp_f);
ffffffffc02060a8:	12858913          	addi	s2,a1,296
     if (a == NULL) return b;
ffffffffc02060ac:	02098063          	beqz	s3,ffffffffc02060cc <stride_enqueue+0x54>
     else if (b == NULL) return a;
ffffffffc02060b0:	08090f63          	beqz	s2,ffffffffc020614e <stride_enqueue+0xd6>
     if (comp(a, b) == -1)
ffffffffc02060b4:	85ca                	mv	a1,s2
ffffffffc02060b6:	854e                	mv	a0,s3
ffffffffc02060b8:	f01ff0ef          	jal	ra,ffffffffc0205fb8 <proc_stride_comp_f>
ffffffffc02060bc:	57fd                	li	a5,-1
ffffffffc02060be:	8a2a                	mv	s4,a0
ffffffffc02060c0:	04f50e63          	beq	a0,a5,ffffffffc020611c <stride_enqueue+0xa4>
          b->left = l;
ffffffffc02060c4:	13343823          	sd	s3,304(s0)
          if (l) l->parent = b;
ffffffffc02060c8:	0129b023          	sd	s2,0(s3) # ffffffff80000000 <_binary_obj___user_matrix_out_size+0xffffffff7fff4598>
    __list_add(elm, listelm->prev, listelm);
ffffffffc02060cc:	6098                	ld	a4,0(s1)
    list_add_before(&(rq->run_list), &(proc->run_link));
ffffffffc02060ce:	11040793          	addi	a5,s0,272
    prev->next = next->prev = elm;
ffffffffc02060d2:	e09c                	sd	a5,0(s1)
    rq->lab6_run_pool = skew_heap_insert(rq->lab6_run_pool, &(proc->lab6_run_pool), proc_stride_comp_f);
ffffffffc02060d4:	0124bc23          	sd	s2,24(s1)
    if(proc->time_slice == 0 || proc->time_slice > rq->max_time_slice) {
ffffffffc02060d8:	12042683          	lw	a3,288(s0)
ffffffffc02060dc:	e71c                	sd	a5,8(a4)
    elm->next = next;
ffffffffc02060de:	10943c23          	sd	s1,280(s0)
    elm->prev = prev;
ffffffffc02060e2:	10e43823          	sd	a4,272(s0)
ffffffffc02060e6:	48dc                	lw	a5,20(s1)
ffffffffc02060e8:	e69d                	bnez	a3,ffffffffc0206116 <stride_enqueue+0x9e>
        proc->time_slice = rq->max_time_slice;
ffffffffc02060ea:	12f42023          	sw	a5,288(s0)
    rq->proc_num++;
ffffffffc02060ee:	489c                	lw	a5,16(s1)
}
ffffffffc02060f0:	70e6                	ld	ra,120(sp)
    proc->rq = rq;
ffffffffc02060f2:	10943423          	sd	s1,264(s0)
}
ffffffffc02060f6:	7446                	ld	s0,112(sp)
    rq->proc_num++;
ffffffffc02060f8:	2785                	addiw	a5,a5,1
ffffffffc02060fa:	c89c                	sw	a5,16(s1)
}
ffffffffc02060fc:	7906                	ld	s2,96(sp)
ffffffffc02060fe:	74a6                	ld	s1,104(sp)
ffffffffc0206100:	69e6                	ld	s3,88(sp)
ffffffffc0206102:	6a46                	ld	s4,80(sp)
ffffffffc0206104:	6aa6                	ld	s5,72(sp)
ffffffffc0206106:	6b06                	ld	s6,64(sp)
ffffffffc0206108:	7be2                	ld	s7,56(sp)
ffffffffc020610a:	7c42                	ld	s8,48(sp)
ffffffffc020610c:	7ca2                	ld	s9,40(sp)
ffffffffc020610e:	7d02                	ld	s10,32(sp)
ffffffffc0206110:	6de2                	ld	s11,24(sp)
ffffffffc0206112:	6109                	addi	sp,sp,128
ffffffffc0206114:	8082                	ret
    if(proc->time_slice == 0 || proc->time_slice > rq->max_time_slice) {
ffffffffc0206116:	fcd7dce3          	ble	a3,a5,ffffffffc02060ee <stride_enqueue+0x76>
ffffffffc020611a:	bfc1                	j	ffffffffc02060ea <stride_enqueue+0x72>
          l = skew_heap_merge(a->right, b, comp);
ffffffffc020611c:	0109ba83          	ld	s5,16(s3)
          r = a->left;
ffffffffc0206120:	0089bb03          	ld	s6,8(s3)
     if (a == NULL) return b;
ffffffffc0206124:	000a8d63          	beqz	s5,ffffffffc020613e <stride_enqueue+0xc6>
     if (comp(a, b) == -1)
ffffffffc0206128:	85ca                	mv	a1,s2
ffffffffc020612a:	8556                	mv	a0,s5
ffffffffc020612c:	e8dff0ef          	jal	ra,ffffffffc0205fb8 <proc_stride_comp_f>
ffffffffc0206130:	8baa                	mv	s7,a0
ffffffffc0206132:	03450063          	beq	a0,s4,ffffffffc0206152 <stride_enqueue+0xda>
          b->left = l;
ffffffffc0206136:	13543823          	sd	s5,304(s0)
          if (l) l->parent = b;
ffffffffc020613a:	012ab023          	sd	s2,0(s5)
          a->left = l;
ffffffffc020613e:	0129b423          	sd	s2,8(s3)
          a->right = r;
ffffffffc0206142:	0169b823          	sd	s6,16(s3)
          if (l) l->parent = a;
ffffffffc0206146:	01393023          	sd	s3,0(s2)
ffffffffc020614a:	894e                	mv	s2,s3
ffffffffc020614c:	b741                	j	ffffffffc02060cc <stride_enqueue+0x54>
     else if (b == NULL) return a;
ffffffffc020614e:	894e                	mv	s2,s3
ffffffffc0206150:	bfb5                	j	ffffffffc02060cc <stride_enqueue+0x54>
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0206152:	010aba03          	ld	s4,16(s5)
          r = a->left;
ffffffffc0206156:	008abc03          	ld	s8,8(s5)
     if (a == NULL) return b;
ffffffffc020615a:	000a0d63          	beqz	s4,ffffffffc0206174 <stride_enqueue+0xfc>
     if (comp(a, b) == -1)
ffffffffc020615e:	85ca                	mv	a1,s2
ffffffffc0206160:	8552                	mv	a0,s4
ffffffffc0206162:	e57ff0ef          	jal	ra,ffffffffc0205fb8 <proc_stride_comp_f>
ffffffffc0206166:	8caa                	mv	s9,a0
ffffffffc0206168:	01750e63          	beq	a0,s7,ffffffffc0206184 <stride_enqueue+0x10c>
          b->left = l;
ffffffffc020616c:	13443823          	sd	s4,304(s0)
          if (l) l->parent = b;
ffffffffc0206170:	012a3023          	sd	s2,0(s4)
          a->left = l;
ffffffffc0206174:	012ab423          	sd	s2,8(s5)
          a->right = r;
ffffffffc0206178:	018ab823          	sd	s8,16(s5)
          if (l) l->parent = a;
ffffffffc020617c:	01593023          	sd	s5,0(s2)
ffffffffc0206180:	8956                	mv	s2,s5
ffffffffc0206182:	bf75                	j	ffffffffc020613e <stride_enqueue+0xc6>
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0206184:	010a3b83          	ld	s7,16(s4)
          r = a->left;
ffffffffc0206188:	008a3d03          	ld	s10,8(s4)
     if (a == NULL) return b;
ffffffffc020618c:	000b8c63          	beqz	s7,ffffffffc02061a4 <stride_enqueue+0x12c>
     if (comp(a, b) == -1)
ffffffffc0206190:	85ca                	mv	a1,s2
ffffffffc0206192:	855e                	mv	a0,s7
ffffffffc0206194:	e25ff0ef          	jal	ra,ffffffffc0205fb8 <proc_stride_comp_f>
ffffffffc0206198:	01950e63          	beq	a0,s9,ffffffffc02061b4 <stride_enqueue+0x13c>
          b->left = l;
ffffffffc020619c:	13743823          	sd	s7,304(s0)
          if (l) l->parent = b;
ffffffffc02061a0:	012bb023          	sd	s2,0(s7)
          a->left = l;
ffffffffc02061a4:	012a3423          	sd	s2,8(s4)
          a->right = r;
ffffffffc02061a8:	01aa3823          	sd	s10,16(s4)
          if (l) l->parent = a;
ffffffffc02061ac:	01493023          	sd	s4,0(s2)
ffffffffc02061b0:	8952                	mv	s2,s4
ffffffffc02061b2:	b7c9                	j	ffffffffc0206174 <stride_enqueue+0xfc>
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02061b4:	010bbc83          	ld	s9,16(s7)
          r = a->left;
ffffffffc02061b8:	008bbd83          	ld	s11,8(s7)
     if (a == NULL) return b;
ffffffffc02061bc:	000c8d63          	beqz	s9,ffffffffc02061d6 <stride_enqueue+0x15e>
     if (comp(a, b) == -1)
ffffffffc02061c0:	85ca                	mv	a1,s2
ffffffffc02061c2:	8566                	mv	a0,s9
ffffffffc02061c4:	df5ff0ef          	jal	ra,ffffffffc0205fb8 <proc_stride_comp_f>
ffffffffc02061c8:	57fd                	li	a5,-1
ffffffffc02061ca:	00f50e63          	beq	a0,a5,ffffffffc02061e6 <stride_enqueue+0x16e>
          b->left = l;
ffffffffc02061ce:	13943823          	sd	s9,304(s0)
          if (l) l->parent = b;
ffffffffc02061d2:	012cb023          	sd	s2,0(s9)
          a->left = l;
ffffffffc02061d6:	012bb423          	sd	s2,8(s7)
          a->right = r;
ffffffffc02061da:	01bbb823          	sd	s11,16(s7)
          if (l) l->parent = a;
ffffffffc02061de:	01793023          	sd	s7,0(s2)
ffffffffc02061e2:	895e                	mv	s2,s7
ffffffffc02061e4:	b7c1                	j	ffffffffc02061a4 <stride_enqueue+0x12c>
          r = a->left;
ffffffffc02061e6:	008cb783          	ld	a5,8(s9)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02061ea:	010cb503          	ld	a0,16(s9)
ffffffffc02061ee:	85ca                	mv	a1,s2
          r = a->left;
ffffffffc02061f0:	e43e                	sd	a5,8(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02061f2:	e23ff0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->right = r;
ffffffffc02061f6:	67a2                	ld	a5,8(sp)
          a->left = l;
ffffffffc02061f8:	00acb423          	sd	a0,8(s9)
          a->right = r;
ffffffffc02061fc:	00fcb823          	sd	a5,16(s9)
          if (l) l->parent = a;
ffffffffc0206200:	c509                	beqz	a0,ffffffffc020620a <stride_enqueue+0x192>
ffffffffc0206202:	01953023          	sd	s9,0(a0)
ffffffffc0206206:	8966                	mv	s2,s9
ffffffffc0206208:	b7f9                	j	ffffffffc02061d6 <stride_enqueue+0x15e>
ffffffffc020620a:	8966                	mv	s2,s9
ffffffffc020620c:	b7e9                	j	ffffffffc02061d6 <stride_enqueue+0x15e>

ffffffffc020620e <stride_dequeue>:
stride_dequeue(struct run_queue *rq, struct proc_struct *proc) {
ffffffffc020620e:	7171                	addi	sp,sp,-176
ffffffffc0206210:	e94a                	sd	s2,144(sp)
static inline skew_heap_entry_t *
skew_heap_remove(skew_heap_entry_t *a, skew_heap_entry_t *b,
                 compare_f comp)
{
     skew_heap_entry_t *p   = b->parent;
     skew_heap_entry_t *rep = skew_heap_merge(b->left, b->right, comp);
ffffffffc0206212:	1305b903          	ld	s2,304(a1)
ffffffffc0206216:	f122                	sd	s0,160(sp)
ffffffffc0206218:	ed26                	sd	s1,152(sp)
ffffffffc020621a:	e54e                	sd	s3,136(sp)
ffffffffc020621c:	e152                	sd	s4,128(sp)
ffffffffc020621e:	fcd6                	sd	s5,120(sp)
ffffffffc0206220:	f506                	sd	ra,168(sp)
ffffffffc0206222:	f8da                	sd	s6,112(sp)
ffffffffc0206224:	f4de                	sd	s7,104(sp)
ffffffffc0206226:	f0e2                	sd	s8,96(sp)
ffffffffc0206228:	ece6                	sd	s9,88(sp)
ffffffffc020622a:	e8ea                	sd	s10,80(sp)
ffffffffc020622c:	e4ee                	sd	s11,72(sp)
ffffffffc020622e:	842e                	mv	s0,a1
ffffffffc0206230:	89aa                	mv	s3,a0
    rq->lab6_run_pool =  skew_heap_remove(rq->lab6_run_pool, &(proc->lab6_run_pool), proc_stride_comp_f);
ffffffffc0206232:	01853a83          	ld	s5,24(a0)
     skew_heap_entry_t *p   = b->parent;
ffffffffc0206236:	1285ba03          	ld	s4,296(a1)
     skew_heap_entry_t *rep = skew_heap_merge(b->left, b->right, comp);
ffffffffc020623a:	1385b483          	ld	s1,312(a1)
     if (a == NULL) return b;
ffffffffc020623e:	2e090363          	beqz	s2,ffffffffc0206524 <stride_dequeue+0x316>
     else if (b == NULL) return a;
ffffffffc0206242:	40048163          	beqz	s1,ffffffffc0206644 <stride_dequeue+0x436>
     if (comp(a, b) == -1)
ffffffffc0206246:	85a6                	mv	a1,s1
ffffffffc0206248:	854a                	mv	a0,s2
ffffffffc020624a:	d6fff0ef          	jal	ra,ffffffffc0205fb8 <proc_stride_comp_f>
ffffffffc020624e:	5cfd                	li	s9,-1
ffffffffc0206250:	8b2a                	mv	s6,a0
ffffffffc0206252:	19950b63          	beq	a0,s9,ffffffffc02063e8 <stride_dequeue+0x1da>
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206256:	0104bd83          	ld	s11,16(s1)
          r = b->left;
ffffffffc020625a:	0084bb03          	ld	s6,8(s1)
     else if (b == NULL) return a;
ffffffffc020625e:	120d8163          	beqz	s11,ffffffffc0206380 <stride_dequeue+0x172>
     if (comp(a, b) == -1)
ffffffffc0206262:	85ee                	mv	a1,s11
ffffffffc0206264:	854a                	mv	a0,s2
ffffffffc0206266:	d53ff0ef          	jal	ra,ffffffffc0205fb8 <proc_stride_comp_f>
ffffffffc020626a:	8d2a                	mv	s10,a0
ffffffffc020626c:	2d950563          	beq	a0,s9,ffffffffc0206536 <stride_dequeue+0x328>
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206270:	010dbc03          	ld	s8,16(s11)
          r = b->left;
ffffffffc0206274:	008dbb83          	ld	s7,8(s11)
     else if (b == NULL) return a;
ffffffffc0206278:	0e0c0d63          	beqz	s8,ffffffffc0206372 <stride_dequeue+0x164>
     if (comp(a, b) == -1)
ffffffffc020627c:	85e2                	mv	a1,s8
ffffffffc020627e:	854a                	mv	a0,s2
ffffffffc0206280:	d39ff0ef          	jal	ra,ffffffffc0205fb8 <proc_stride_comp_f>
ffffffffc0206284:	8d2a                	mv	s10,a0
ffffffffc0206286:	77950d63          	beq	a0,s9,ffffffffc0206a00 <stride_dequeue+0x7f2>
          r = b->left;
ffffffffc020628a:	008c3783          	ld	a5,8(s8)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc020628e:	010c3d03          	ld	s10,16(s8)
          r = b->left;
ffffffffc0206292:	e43e                	sd	a5,8(sp)
     else if (b == NULL) return a;
ffffffffc0206294:	0c0d0763          	beqz	s10,ffffffffc0206362 <stride_dequeue+0x154>
     if (comp(a, b) == -1)
ffffffffc0206298:	85ea                	mv	a1,s10
ffffffffc020629a:	854a                	mv	a0,s2
ffffffffc020629c:	d1dff0ef          	jal	ra,ffffffffc0205fb8 <proc_stride_comp_f>
ffffffffc02062a0:	6b950163          	beq	a0,s9,ffffffffc0206942 <stride_dequeue+0x734>
          r = b->left;
ffffffffc02062a4:	008d3783          	ld	a5,8(s10)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02062a8:	010d3c83          	ld	s9,16(s10)
          r = b->left;
ffffffffc02062ac:	e83e                	sd	a5,16(sp)
     else if (b == NULL) return a;
ffffffffc02062ae:	0a0c8263          	beqz	s9,ffffffffc0206352 <stride_dequeue+0x144>
     if (comp(a, b) == -1)
ffffffffc02062b2:	85e6                	mv	a1,s9
ffffffffc02062b4:	854a                	mv	a0,s2
ffffffffc02062b6:	d03ff0ef          	jal	ra,ffffffffc0205fb8 <proc_stride_comp_f>
ffffffffc02062ba:	58fd                	li	a7,-1
ffffffffc02062bc:	371506e3          	beq	a0,a7,ffffffffc0206e28 <stride_dequeue+0xc1a>
          r = b->left;
ffffffffc02062c0:	008cb703          	ld	a4,8(s9)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02062c4:	010cb783          	ld	a5,16(s9)
          r = b->left;
ffffffffc02062c8:	ec3a                	sd	a4,24(sp)
     else if (b == NULL) return a;
ffffffffc02062ca:	cfa5                	beqz	a5,ffffffffc0206342 <stride_dequeue+0x134>
     if (comp(a, b) == -1)
ffffffffc02062cc:	85be                	mv	a1,a5
ffffffffc02062ce:	854a                	mv	a0,s2
ffffffffc02062d0:	f03e                	sd	a5,32(sp)
ffffffffc02062d2:	ce7ff0ef          	jal	ra,ffffffffc0205fb8 <proc_stride_comp_f>
ffffffffc02062d6:	58fd                	li	a7,-1
ffffffffc02062d8:	7782                	ld	a5,32(sp)
ffffffffc02062da:	01151463          	bne	a0,a7,ffffffffc02062e2 <stride_dequeue+0xd4>
ffffffffc02062de:	0820106f          	j	ffffffffc0207360 <stride_dequeue+0x1152>
          r = b->left;
ffffffffc02062e2:	6798                	ld	a4,8(a5)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02062e4:	0107b303          	ld	t1,16(a5)
          r = b->left;
ffffffffc02062e8:	f03a                	sd	a4,32(sp)
     else if (b == NULL) return a;
ffffffffc02062ea:	00031463          	bnez	t1,ffffffffc02062f2 <stride_dequeue+0xe4>
ffffffffc02062ee:	6d00106f          	j	ffffffffc02079be <stride_dequeue+0x17b0>
     if (comp(a, b) == -1)
ffffffffc02062f2:	859a                	mv	a1,t1
ffffffffc02062f4:	854a                	mv	a0,s2
ffffffffc02062f6:	f83e                	sd	a5,48(sp)
ffffffffc02062f8:	f41a                	sd	t1,40(sp)
ffffffffc02062fa:	cbfff0ef          	jal	ra,ffffffffc0205fb8 <proc_stride_comp_f>
ffffffffc02062fe:	58fd                	li	a7,-1
ffffffffc0206300:	7322                	ld	t1,40(sp)
ffffffffc0206302:	77c2                	ld	a5,48(sp)
ffffffffc0206304:	01151463          	bne	a0,a7,ffffffffc020630c <stride_dequeue+0xfe>
ffffffffc0206308:	68e0106f          	j	ffffffffc0207996 <stride_dequeue+0x1788>
          r = b->left;
ffffffffc020630c:	00833883          	ld	a7,8(t1) # ffffffffc0000008 <_binary_obj___user_matrix_out_size+0xffffffffbfff45a0>
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206310:	01033583          	ld	a1,16(t1)
ffffffffc0206314:	854a                	mv	a0,s2
ffffffffc0206316:	fc3e                	sd	a5,56(sp)
          r = b->left;
ffffffffc0206318:	f81a                	sd	t1,48(sp)
ffffffffc020631a:	f446                	sd	a7,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc020631c:	cf9ff0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          b->left = l;
ffffffffc0206320:	7342                	ld	t1,48(sp)
          b->right = r;
ffffffffc0206322:	78a2                	ld	a7,40(sp)
          if (l) l->parent = b;
ffffffffc0206324:	77e2                	ld	a5,56(sp)
          b->left = l;
ffffffffc0206326:	00a33423          	sd	a0,8(t1)
          b->right = r;
ffffffffc020632a:	01133823          	sd	a7,16(t1)
          if (l) l->parent = b;
ffffffffc020632e:	c119                	beqz	a0,ffffffffc0206334 <stride_dequeue+0x126>
ffffffffc0206330:	00653023          	sd	t1,0(a0)
          b->right = r;
ffffffffc0206334:	7702                	ld	a4,32(sp)
          b->left = l;
ffffffffc0206336:	0067b423          	sd	t1,8(a5)
          if (l) l->parent = b;
ffffffffc020633a:	893e                	mv	s2,a5
          b->right = r;
ffffffffc020633c:	eb98                	sd	a4,16(a5)
          if (l) l->parent = b;
ffffffffc020633e:	00f33023          	sd	a5,0(t1)
          b->right = r;
ffffffffc0206342:	67e2                	ld	a5,24(sp)
          b->left = l;
ffffffffc0206344:	012cb423          	sd	s2,8(s9)
          b->right = r;
ffffffffc0206348:	00fcb823          	sd	a5,16(s9)
          if (l) l->parent = b;
ffffffffc020634c:	01993023          	sd	s9,0(s2)
ffffffffc0206350:	8966                	mv	s2,s9
          b->right = r;
ffffffffc0206352:	67c2                	ld	a5,16(sp)
          b->left = l;
ffffffffc0206354:	012d3423          	sd	s2,8(s10)
          b->right = r;
ffffffffc0206358:	00fd3823          	sd	a5,16(s10)
          if (l) l->parent = b;
ffffffffc020635c:	01a93023          	sd	s10,0(s2)
ffffffffc0206360:	896a                	mv	s2,s10
          b->right = r;
ffffffffc0206362:	67a2                	ld	a5,8(sp)
          b->left = l;
ffffffffc0206364:	012c3423          	sd	s2,8(s8)
          b->right = r;
ffffffffc0206368:	00fc3823          	sd	a5,16(s8)
          if (l) l->parent = b;
ffffffffc020636c:	01893023          	sd	s8,0(s2)
ffffffffc0206370:	8962                	mv	s2,s8
          b->left = l;
ffffffffc0206372:	012db423          	sd	s2,8(s11)
          b->right = r;
ffffffffc0206376:	017db823          	sd	s7,16(s11)
          if (l) l->parent = b;
ffffffffc020637a:	01b93023          	sd	s11,0(s2)
ffffffffc020637e:	896e                	mv	s2,s11
          b->left = l;
ffffffffc0206380:	0124b423          	sd	s2,8(s1)
          b->right = r;
ffffffffc0206384:	0164b823          	sd	s6,16(s1)
          if (l) l->parent = b;
ffffffffc0206388:	00993023          	sd	s1,0(s2)
     if (rep) rep->parent = p;
ffffffffc020638c:	0144b023          	sd	s4,0(s1)
     
     if (p)
ffffffffc0206390:	180a0e63          	beqz	s4,ffffffffc020652c <stride_dequeue+0x31e>
     {
          if (p->left == b)
ffffffffc0206394:	008a3703          	ld	a4,8(s4)
ffffffffc0206398:	12840793          	addi	a5,s0,296
ffffffffc020639c:	18f70a63          	beq	a4,a5,ffffffffc0206530 <stride_dequeue+0x322>
               p->left = rep;
          else p->right = rep;
ffffffffc02063a0:	009a3823          	sd	s1,16(s4)
    __list_del(listelm->prev, listelm->next);
ffffffffc02063a4:	11843703          	ld	a4,280(s0)
ffffffffc02063a8:	11043683          	ld	a3,272(s0)
ffffffffc02063ac:	0159bc23          	sd	s5,24(s3)
    rq->proc_num--;
ffffffffc02063b0:	0109a783          	lw	a5,16(s3)
    prev->next = next;
ffffffffc02063b4:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc02063b6:	e314                	sd	a3,0(a4)
    list_del_init(&(proc->run_link));
ffffffffc02063b8:	11040713          	addi	a4,s0,272
    elm->prev = elm->next = elm;
ffffffffc02063bc:	10e43c23          	sd	a4,280(s0)
ffffffffc02063c0:	10e43823          	sd	a4,272(s0)
}
ffffffffc02063c4:	70aa                	ld	ra,168(sp)
ffffffffc02063c6:	740a                	ld	s0,160(sp)
    rq->proc_num--;
ffffffffc02063c8:	37fd                	addiw	a5,a5,-1
ffffffffc02063ca:	00f9a823          	sw	a5,16(s3)
}
ffffffffc02063ce:	64ea                	ld	s1,152(sp)
ffffffffc02063d0:	694a                	ld	s2,144(sp)
ffffffffc02063d2:	69aa                	ld	s3,136(sp)
ffffffffc02063d4:	6a0a                	ld	s4,128(sp)
ffffffffc02063d6:	7ae6                	ld	s5,120(sp)
ffffffffc02063d8:	7b46                	ld	s6,112(sp)
ffffffffc02063da:	7ba6                	ld	s7,104(sp)
ffffffffc02063dc:	7c06                	ld	s8,96(sp)
ffffffffc02063de:	6ce6                	ld	s9,88(sp)
ffffffffc02063e0:	6d46                	ld	s10,80(sp)
ffffffffc02063e2:	6da6                	ld	s11,72(sp)
ffffffffc02063e4:	614d                	addi	sp,sp,176
ffffffffc02063e6:	8082                	ret
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02063e8:	01093d83          	ld	s11,16(s2)
          r = a->left;
ffffffffc02063ec:	00893b83          	ld	s7,8(s2)
     if (a == NULL) return b;
ffffffffc02063f0:	120d8063          	beqz	s11,ffffffffc0206510 <stride_dequeue+0x302>
     if (comp(a, b) == -1)
ffffffffc02063f4:	85a6                	mv	a1,s1
ffffffffc02063f6:	856e                	mv	a0,s11
ffffffffc02063f8:	bc1ff0ef          	jal	ra,ffffffffc0205fb8 <proc_stride_comp_f>
ffffffffc02063fc:	8caa                	mv	s9,a0
ffffffffc02063fe:	25650763          	beq	a0,s6,ffffffffc020664c <stride_dequeue+0x43e>
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206402:	0104bd03          	ld	s10,16(s1)
          r = b->left;
ffffffffc0206406:	0084bc03          	ld	s8,8(s1)
     else if (b == NULL) return a;
ffffffffc020640a:	0e0d0d63          	beqz	s10,ffffffffc0206504 <stride_dequeue+0x2f6>
     if (comp(a, b) == -1)
ffffffffc020640e:	85ea                	mv	a1,s10
ffffffffc0206410:	856e                	mv	a0,s11
ffffffffc0206412:	ba7ff0ef          	jal	ra,ffffffffc0205fb8 <proc_stride_comp_f>
ffffffffc0206416:	8caa                	mv	s9,a0
ffffffffc0206418:	35650263          	beq	a0,s6,ffffffffc020675c <stride_dequeue+0x54e>
          r = b->left;
ffffffffc020641c:	008d3783          	ld	a5,8(s10)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206420:	010d3c83          	ld	s9,16(s10)
          r = b->left;
ffffffffc0206424:	e43e                	sd	a5,8(sp)
     else if (b == NULL) return a;
ffffffffc0206426:	0c0c8763          	beqz	s9,ffffffffc02064f4 <stride_dequeue+0x2e6>
     if (comp(a, b) == -1)
ffffffffc020642a:	85e6                	mv	a1,s9
ffffffffc020642c:	856e                	mv	a0,s11
ffffffffc020642e:	b8bff0ef          	jal	ra,ffffffffc0205fb8 <proc_stride_comp_f>
ffffffffc0206432:	7b650163          	beq	a0,s6,ffffffffc0206bd4 <stride_dequeue+0x9c6>
          r = b->left;
ffffffffc0206436:	008cb783          	ld	a5,8(s9)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc020643a:	010cbb03          	ld	s6,16(s9)
          r = b->left;
ffffffffc020643e:	e83e                	sd	a5,16(sp)
     else if (b == NULL) return a;
ffffffffc0206440:	0a0b0263          	beqz	s6,ffffffffc02064e4 <stride_dequeue+0x2d6>
     if (comp(a, b) == -1)
ffffffffc0206444:	85da                	mv	a1,s6
ffffffffc0206446:	856e                	mv	a0,s11
ffffffffc0206448:	b71ff0ef          	jal	ra,ffffffffc0205fb8 <proc_stride_comp_f>
ffffffffc020644c:	58fd                	li	a7,-1
ffffffffc020644e:	4b150ee3          	beq	a0,a7,ffffffffc020710a <stride_dequeue+0xefc>
          r = b->left;
ffffffffc0206452:	008b3703          	ld	a4,8(s6)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206456:	010b3783          	ld	a5,16(s6)
          r = b->left;
ffffffffc020645a:	ec3a                	sd	a4,24(sp)
     else if (b == NULL) return a;
ffffffffc020645c:	cfa5                	beqz	a5,ffffffffc02064d4 <stride_dequeue+0x2c6>
     if (comp(a, b) == -1)
ffffffffc020645e:	85be                	mv	a1,a5
ffffffffc0206460:	856e                	mv	a0,s11
ffffffffc0206462:	f03e                	sd	a5,32(sp)
ffffffffc0206464:	b55ff0ef          	jal	ra,ffffffffc0205fb8 <proc_stride_comp_f>
ffffffffc0206468:	58fd                	li	a7,-1
ffffffffc020646a:	7782                	ld	a5,32(sp)
ffffffffc020646c:	01151463          	bne	a0,a7,ffffffffc0206474 <stride_dequeue+0x266>
ffffffffc0206470:	4240106f          	j	ffffffffc0207894 <stride_dequeue+0x1686>
          r = b->left;
ffffffffc0206474:	6798                	ld	a4,8(a5)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206476:	0107b303          	ld	t1,16(a5)
          r = b->left;
ffffffffc020647a:	f03a                	sd	a4,32(sp)
     else if (b == NULL) return a;
ffffffffc020647c:	00031463          	bnez	t1,ffffffffc0206484 <stride_dequeue+0x276>
ffffffffc0206480:	0cf0106f          	j	ffffffffc0207d4e <stride_dequeue+0x1b40>
     if (comp(a, b) == -1)
ffffffffc0206484:	859a                	mv	a1,t1
ffffffffc0206486:	856e                	mv	a0,s11
ffffffffc0206488:	f83e                	sd	a5,48(sp)
ffffffffc020648a:	f41a                	sd	t1,40(sp)
ffffffffc020648c:	b2dff0ef          	jal	ra,ffffffffc0205fb8 <proc_stride_comp_f>
ffffffffc0206490:	58fd                	li	a7,-1
ffffffffc0206492:	7322                	ld	t1,40(sp)
ffffffffc0206494:	77c2                	ld	a5,48(sp)
ffffffffc0206496:	01151463          	bne	a0,a7,ffffffffc020649e <stride_dequeue+0x290>
ffffffffc020649a:	2450106f          	j	ffffffffc0207ede <stride_dequeue+0x1cd0>
          r = b->left;
ffffffffc020649e:	00833883          	ld	a7,8(t1)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02064a2:	01033583          	ld	a1,16(t1)
ffffffffc02064a6:	856e                	mv	a0,s11
ffffffffc02064a8:	fc3e                	sd	a5,56(sp)
          r = b->left;
ffffffffc02064aa:	f81a                	sd	t1,48(sp)
ffffffffc02064ac:	f446                	sd	a7,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02064ae:	b67ff0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          b->left = l;
ffffffffc02064b2:	7342                	ld	t1,48(sp)
          b->right = r;
ffffffffc02064b4:	78a2                	ld	a7,40(sp)
          if (l) l->parent = b;
ffffffffc02064b6:	77e2                	ld	a5,56(sp)
          b->left = l;
ffffffffc02064b8:	00a33423          	sd	a0,8(t1)
          b->right = r;
ffffffffc02064bc:	01133823          	sd	a7,16(t1)
          if (l) l->parent = b;
ffffffffc02064c0:	c119                	beqz	a0,ffffffffc02064c6 <stride_dequeue+0x2b8>
ffffffffc02064c2:	00653023          	sd	t1,0(a0)
          b->right = r;
ffffffffc02064c6:	7702                	ld	a4,32(sp)
          b->left = l;
ffffffffc02064c8:	0067b423          	sd	t1,8(a5)
          if (l) l->parent = b;
ffffffffc02064cc:	8dbe                	mv	s11,a5
          b->right = r;
ffffffffc02064ce:	eb98                	sd	a4,16(a5)
          if (l) l->parent = b;
ffffffffc02064d0:	00f33023          	sd	a5,0(t1)
          b->right = r;
ffffffffc02064d4:	67e2                	ld	a5,24(sp)
          b->left = l;
ffffffffc02064d6:	01bb3423          	sd	s11,8(s6)
          b->right = r;
ffffffffc02064da:	00fb3823          	sd	a5,16(s6)
          if (l) l->parent = b;
ffffffffc02064de:	016db023          	sd	s6,0(s11)
ffffffffc02064e2:	8dda                	mv	s11,s6
          b->right = r;
ffffffffc02064e4:	67c2                	ld	a5,16(sp)
          b->left = l;
ffffffffc02064e6:	01bcb423          	sd	s11,8(s9)
          b->right = r;
ffffffffc02064ea:	00fcb823          	sd	a5,16(s9)
          if (l) l->parent = b;
ffffffffc02064ee:	019db023          	sd	s9,0(s11)
ffffffffc02064f2:	8de6                	mv	s11,s9
          b->right = r;
ffffffffc02064f4:	67a2                	ld	a5,8(sp)
          b->left = l;
ffffffffc02064f6:	01bd3423          	sd	s11,8(s10)
          b->right = r;
ffffffffc02064fa:	00fd3823          	sd	a5,16(s10)
          if (l) l->parent = b;
ffffffffc02064fe:	01adb023          	sd	s10,0(s11)
ffffffffc0206502:	8dea                	mv	s11,s10
          b->left = l;
ffffffffc0206504:	01b4b423          	sd	s11,8(s1)
          b->right = r;
ffffffffc0206508:	0184b823          	sd	s8,16(s1)
          if (l) l->parent = b;
ffffffffc020650c:	009db023          	sd	s1,0(s11)
          a->left = l;
ffffffffc0206510:	00993423          	sd	s1,8(s2)
          a->right = r;
ffffffffc0206514:	01793823          	sd	s7,16(s2)
          if (l) l->parent = a;
ffffffffc0206518:	0124b023          	sd	s2,0(s1)
ffffffffc020651c:	84ca                	mv	s1,s2
     if (rep) rep->parent = p;
ffffffffc020651e:	0144b023          	sd	s4,0(s1)
ffffffffc0206522:	b5bd                	j	ffffffffc0206390 <stride_dequeue+0x182>
ffffffffc0206524:	e60494e3          	bnez	s1,ffffffffc020638c <stride_dequeue+0x17e>
     if (p)
ffffffffc0206528:	e60a16e3          	bnez	s4,ffffffffc0206394 <stride_dequeue+0x186>
ffffffffc020652c:	8aa6                	mv	s5,s1
ffffffffc020652e:	bd9d                	j	ffffffffc02063a4 <stride_dequeue+0x196>
               p->left = rep;
ffffffffc0206530:	009a3423          	sd	s1,8(s4)
ffffffffc0206534:	bd85                	j	ffffffffc02063a4 <stride_dequeue+0x196>
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0206536:	01093c03          	ld	s8,16(s2)
          r = a->left;
ffffffffc020653a:	00893b83          	ld	s7,8(s2)
     if (a == NULL) return b;
ffffffffc020653e:	0e0c0c63          	beqz	s8,ffffffffc0206636 <stride_dequeue+0x428>
     if (comp(a, b) == -1)
ffffffffc0206542:	85ee                	mv	a1,s11
ffffffffc0206544:	8562                	mv	a0,s8
ffffffffc0206546:	a73ff0ef          	jal	ra,ffffffffc0205fb8 <proc_stride_comp_f>
ffffffffc020654a:	8caa                	mv	s9,a0
ffffffffc020654c:	31a50263          	beq	a0,s10,ffffffffc0206850 <stride_dequeue+0x642>
          r = b->left;
ffffffffc0206550:	008db783          	ld	a5,8(s11)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206554:	010dbc83          	ld	s9,16(s11)
          r = b->left;
ffffffffc0206558:	e43e                	sd	a5,8(sp)
     else if (b == NULL) return a;
ffffffffc020655a:	0c0c8763          	beqz	s9,ffffffffc0206628 <stride_dequeue+0x41a>
     if (comp(a, b) == -1)
ffffffffc020655e:	85e6                	mv	a1,s9
ffffffffc0206560:	8562                	mv	a0,s8
ffffffffc0206562:	a57ff0ef          	jal	ra,ffffffffc0205fb8 <proc_stride_comp_f>
ffffffffc0206566:	7fa50f63          	beq	a0,s10,ffffffffc0206d64 <stride_dequeue+0xb56>
          r = b->left;
ffffffffc020656a:	008cb783          	ld	a5,8(s9)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc020656e:	010cbd03          	ld	s10,16(s9)
          r = b->left;
ffffffffc0206572:	e83e                	sd	a5,16(sp)
     else if (b == NULL) return a;
ffffffffc0206574:	0a0d0263          	beqz	s10,ffffffffc0206618 <stride_dequeue+0x40a>
     if (comp(a, b) == -1)
ffffffffc0206578:	85ea                	mv	a1,s10
ffffffffc020657a:	8562                	mv	a0,s8
ffffffffc020657c:	a3dff0ef          	jal	ra,ffffffffc0205fb8 <proc_stride_comp_f>
ffffffffc0206580:	58fd                	li	a7,-1
ffffffffc0206582:	41150fe3          	beq	a0,a7,ffffffffc02071a0 <stride_dequeue+0xf92>
          r = b->left;
ffffffffc0206586:	008d3703          	ld	a4,8(s10)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc020658a:	010d3783          	ld	a5,16(s10)
          r = b->left;
ffffffffc020658e:	ec3a                	sd	a4,24(sp)
     else if (b == NULL) return a;
ffffffffc0206590:	cfa5                	beqz	a5,ffffffffc0206608 <stride_dequeue+0x3fa>
     if (comp(a, b) == -1)
ffffffffc0206592:	85be                	mv	a1,a5
ffffffffc0206594:	8562                	mv	a0,s8
ffffffffc0206596:	f03e                	sd	a5,32(sp)
ffffffffc0206598:	a21ff0ef          	jal	ra,ffffffffc0205fb8 <proc_stride_comp_f>
ffffffffc020659c:	58fd                	li	a7,-1
ffffffffc020659e:	7782                	ld	a5,32(sp)
ffffffffc02065a0:	01151463          	bne	a0,a7,ffffffffc02065a8 <stride_dequeue+0x39a>
ffffffffc02065a4:	3460106f          	j	ffffffffc02078ea <stride_dequeue+0x16dc>
          r = b->left;
ffffffffc02065a8:	6798                	ld	a4,8(a5)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02065aa:	0107b303          	ld	t1,16(a5)
          r = b->left;
ffffffffc02065ae:	f03a                	sd	a4,32(sp)
     else if (b == NULL) return a;
ffffffffc02065b0:	00031463          	bnez	t1,ffffffffc02065b8 <stride_dequeue+0x3aa>
ffffffffc02065b4:	7a00106f          	j	ffffffffc0207d54 <stride_dequeue+0x1b46>
     if (comp(a, b) == -1)
ffffffffc02065b8:	859a                	mv	a1,t1
ffffffffc02065ba:	8562                	mv	a0,s8
ffffffffc02065bc:	f83e                	sd	a5,48(sp)
ffffffffc02065be:	f41a                	sd	t1,40(sp)
ffffffffc02065c0:	9f9ff0ef          	jal	ra,ffffffffc0205fb8 <proc_stride_comp_f>
ffffffffc02065c4:	58fd                	li	a7,-1
ffffffffc02065c6:	7322                	ld	t1,40(sp)
ffffffffc02065c8:	77c2                	ld	a5,48(sp)
ffffffffc02065ca:	01151463          	bne	a0,a7,ffffffffc02065d2 <stride_dequeue+0x3c4>
ffffffffc02065ce:	13b0106f          	j	ffffffffc0207f08 <stride_dequeue+0x1cfa>
          r = b->left;
ffffffffc02065d2:	00833883          	ld	a7,8(t1)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02065d6:	01033583          	ld	a1,16(t1)
ffffffffc02065da:	8562                	mv	a0,s8
ffffffffc02065dc:	fc3e                	sd	a5,56(sp)
          r = b->left;
ffffffffc02065de:	f81a                	sd	t1,48(sp)
ffffffffc02065e0:	f446                	sd	a7,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02065e2:	a33ff0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          b->left = l;
ffffffffc02065e6:	7342                	ld	t1,48(sp)
          b->right = r;
ffffffffc02065e8:	78a2                	ld	a7,40(sp)
          if (l) l->parent = b;
ffffffffc02065ea:	77e2                	ld	a5,56(sp)
          b->left = l;
ffffffffc02065ec:	00a33423          	sd	a0,8(t1)
          b->right = r;
ffffffffc02065f0:	01133823          	sd	a7,16(t1)
          if (l) l->parent = b;
ffffffffc02065f4:	c119                	beqz	a0,ffffffffc02065fa <stride_dequeue+0x3ec>
ffffffffc02065f6:	00653023          	sd	t1,0(a0)
          b->right = r;
ffffffffc02065fa:	7702                	ld	a4,32(sp)
          b->left = l;
ffffffffc02065fc:	0067b423          	sd	t1,8(a5)
          if (l) l->parent = b;
ffffffffc0206600:	8c3e                	mv	s8,a5
          b->right = r;
ffffffffc0206602:	eb98                	sd	a4,16(a5)
          if (l) l->parent = b;
ffffffffc0206604:	00f33023          	sd	a5,0(t1)
          b->right = r;
ffffffffc0206608:	67e2                	ld	a5,24(sp)
          b->left = l;
ffffffffc020660a:	018d3423          	sd	s8,8(s10)
          b->right = r;
ffffffffc020660e:	00fd3823          	sd	a5,16(s10)
          if (l) l->parent = b;
ffffffffc0206612:	01ac3023          	sd	s10,0(s8)
ffffffffc0206616:	8c6a                	mv	s8,s10
          b->right = r;
ffffffffc0206618:	67c2                	ld	a5,16(sp)
          b->left = l;
ffffffffc020661a:	018cb423          	sd	s8,8(s9)
          b->right = r;
ffffffffc020661e:	00fcb823          	sd	a5,16(s9)
          if (l) l->parent = b;
ffffffffc0206622:	019c3023          	sd	s9,0(s8)
ffffffffc0206626:	8c66                	mv	s8,s9
          b->right = r;
ffffffffc0206628:	67a2                	ld	a5,8(sp)
          b->left = l;
ffffffffc020662a:	018db423          	sd	s8,8(s11)
          b->right = r;
ffffffffc020662e:	00fdb823          	sd	a5,16(s11)
          if (l) l->parent = b;
ffffffffc0206632:	01bc3023          	sd	s11,0(s8)
          a->left = l;
ffffffffc0206636:	01b93423          	sd	s11,8(s2)
          a->right = r;
ffffffffc020663a:	01793823          	sd	s7,16(s2)
          if (l) l->parent = a;
ffffffffc020663e:	012db023          	sd	s2,0(s11)
ffffffffc0206642:	bb3d                	j	ffffffffc0206380 <stride_dequeue+0x172>
     else if (b == NULL) return a;
ffffffffc0206644:	84ca                	mv	s1,s2
     if (rep) rep->parent = p;
ffffffffc0206646:	0144b023          	sd	s4,0(s1)
ffffffffc020664a:	b399                	j	ffffffffc0206390 <stride_dequeue+0x182>
          l = skew_heap_merge(a->right, b, comp);
ffffffffc020664c:	010dbc03          	ld	s8,16(s11)
          r = a->left;
ffffffffc0206650:	008dbb03          	ld	s6,8(s11)
     if (a == NULL) return b;
ffffffffc0206654:	0e0c0c63          	beqz	s8,ffffffffc020674c <stride_dequeue+0x53e>
     if (comp(a, b) == -1)
ffffffffc0206658:	85a6                	mv	a1,s1
ffffffffc020665a:	8562                	mv	a0,s8
ffffffffc020665c:	95dff0ef          	jal	ra,ffffffffc0205fb8 <proc_stride_comp_f>
ffffffffc0206660:	8d2a                	mv	s10,a0
ffffffffc0206662:	49950363          	beq	a0,s9,ffffffffc0206ae8 <stride_dequeue+0x8da>
          r = b->left;
ffffffffc0206666:	649c                	ld	a5,8(s1)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206668:	0104bd03          	ld	s10,16(s1)
          r = b->left;
ffffffffc020666c:	e43e                	sd	a5,8(sp)
     else if (b == NULL) return a;
ffffffffc020666e:	0c0d0963          	beqz	s10,ffffffffc0206740 <stride_dequeue+0x532>
     if (comp(a, b) == -1)
ffffffffc0206672:	85ea                	mv	a1,s10
ffffffffc0206674:	8562                	mv	a0,s8
ffffffffc0206676:	943ff0ef          	jal	ra,ffffffffc0205fb8 <proc_stride_comp_f>
ffffffffc020667a:	1d9505e3          	beq	a0,s9,ffffffffc0207044 <stride_dequeue+0xe36>
          r = b->left;
ffffffffc020667e:	008d3783          	ld	a5,8(s10)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206682:	010d3c83          	ld	s9,16(s10)
          r = b->left;
ffffffffc0206686:	e83e                	sd	a5,16(sp)
     else if (b == NULL) return a;
ffffffffc0206688:	0a0c8463          	beqz	s9,ffffffffc0206730 <stride_dequeue+0x522>
     if (comp(a, b) == -1)
ffffffffc020668c:	85e6                	mv	a1,s9
ffffffffc020668e:	8562                	mv	a0,s8
ffffffffc0206690:	929ff0ef          	jal	ra,ffffffffc0205fb8 <proc_stride_comp_f>
ffffffffc0206694:	58fd                	li	a7,-1
ffffffffc0206696:	651500e3          	beq	a0,a7,ffffffffc02074d6 <stride_dequeue+0x12c8>
          r = b->left;
ffffffffc020669a:	008cb703          	ld	a4,8(s9)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc020669e:	010cb783          	ld	a5,16(s9)
          r = b->left;
ffffffffc02066a2:	ec3a                	sd	a4,24(sp)
     else if (b == NULL) return a;
ffffffffc02066a4:	e399                	bnez	a5,ffffffffc02066aa <stride_dequeue+0x49c>
ffffffffc02066a6:	1330106f          	j	ffffffffc0207fd8 <stride_dequeue+0x1dca>
     if (comp(a, b) == -1)
ffffffffc02066aa:	85be                	mv	a1,a5
ffffffffc02066ac:	8562                	mv	a0,s8
ffffffffc02066ae:	f03e                	sd	a5,32(sp)
ffffffffc02066b0:	909ff0ef          	jal	ra,ffffffffc0205fb8 <proc_stride_comp_f>
ffffffffc02066b4:	58fd                	li	a7,-1
ffffffffc02066b6:	7782                	ld	a5,32(sp)
ffffffffc02066b8:	01151463          	bne	a0,a7,ffffffffc02066c0 <stride_dequeue+0x4b2>
ffffffffc02066bc:	7020106f          	j	ffffffffc0207dbe <stride_dequeue+0x1bb0>
          r = b->left;
ffffffffc02066c0:	6798                	ld	a4,8(a5)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02066c2:	0107b303          	ld	t1,16(a5)
          r = b->left;
ffffffffc02066c6:	f03a                	sd	a4,32(sp)
     else if (b == NULL) return a;
ffffffffc02066c8:	04030663          	beqz	t1,ffffffffc0206714 <stride_dequeue+0x506>
     if (comp(a, b) == -1)
ffffffffc02066cc:	859a                	mv	a1,t1
ffffffffc02066ce:	8562                	mv	a0,s8
ffffffffc02066d0:	f83e                	sd	a5,48(sp)
ffffffffc02066d2:	f41a                	sd	t1,40(sp)
ffffffffc02066d4:	8e5ff0ef          	jal	ra,ffffffffc0205fb8 <proc_stride_comp_f>
ffffffffc02066d8:	58fd                	li	a7,-1
ffffffffc02066da:	7322                	ld	t1,40(sp)
ffffffffc02066dc:	77c2                	ld	a5,48(sp)
ffffffffc02066de:	01151463          	bne	a0,a7,ffffffffc02066e6 <stride_dequeue+0x4d8>
ffffffffc02066e2:	42b0106f          	j	ffffffffc020830c <stride_dequeue+0x20fe>
          r = b->left;
ffffffffc02066e6:	00833883          	ld	a7,8(t1)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02066ea:	01033583          	ld	a1,16(t1)
ffffffffc02066ee:	8562                	mv	a0,s8
ffffffffc02066f0:	fc3e                	sd	a5,56(sp)
          r = b->left;
ffffffffc02066f2:	f81a                	sd	t1,48(sp)
ffffffffc02066f4:	f446                	sd	a7,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02066f6:	91fff0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          b->left = l;
ffffffffc02066fa:	7342                	ld	t1,48(sp)
          b->right = r;
ffffffffc02066fc:	78a2                	ld	a7,40(sp)
          if (l) l->parent = b;
ffffffffc02066fe:	77e2                	ld	a5,56(sp)
          b->left = l;
ffffffffc0206700:	00a33423          	sd	a0,8(t1)
          b->right = r;
ffffffffc0206704:	01133823          	sd	a7,16(t1)
          if (l) l->parent = b;
ffffffffc0206708:	e119                	bnez	a0,ffffffffc020670e <stride_dequeue+0x500>
ffffffffc020670a:	58d0106f          	j	ffffffffc0208496 <stride_dequeue+0x2288>
ffffffffc020670e:	00653023          	sd	t1,0(a0)
ffffffffc0206712:	8c1a                	mv	s8,t1
          b->right = r;
ffffffffc0206714:	7702                	ld	a4,32(sp)
          b->left = l;
ffffffffc0206716:	0187b423          	sd	s8,8(a5)
          b->right = r;
ffffffffc020671a:	eb98                	sd	a4,16(a5)
          if (l) l->parent = b;
ffffffffc020671c:	00fc3023          	sd	a5,0(s8)
          b->right = r;
ffffffffc0206720:	6762                	ld	a4,24(sp)
          b->left = l;
ffffffffc0206722:	00fcb423          	sd	a5,8(s9)
          if (l) l->parent = b;
ffffffffc0206726:	8c66                	mv	s8,s9
          b->right = r;
ffffffffc0206728:	00ecb823          	sd	a4,16(s9)
          if (l) l->parent = b;
ffffffffc020672c:	0197b023          	sd	s9,0(a5)
          b->right = r;
ffffffffc0206730:	67c2                	ld	a5,16(sp)
          b->left = l;
ffffffffc0206732:	018d3423          	sd	s8,8(s10)
          b->right = r;
ffffffffc0206736:	00fd3823          	sd	a5,16(s10)
          if (l) l->parent = b;
ffffffffc020673a:	01ac3023          	sd	s10,0(s8)
ffffffffc020673e:	8c6a                	mv	s8,s10
          b->right = r;
ffffffffc0206740:	67a2                	ld	a5,8(sp)
          b->left = l;
ffffffffc0206742:	0184b423          	sd	s8,8(s1)
          b->right = r;
ffffffffc0206746:	e89c                	sd	a5,16(s1)
          if (l) l->parent = b;
ffffffffc0206748:	009c3023          	sd	s1,0(s8)
          a->left = l;
ffffffffc020674c:	009db423          	sd	s1,8(s11)
          a->right = r;
ffffffffc0206750:	016db823          	sd	s6,16(s11)
          if (l) l->parent = a;
ffffffffc0206754:	01b4b023          	sd	s11,0(s1)
ffffffffc0206758:	84ee                	mv	s1,s11
ffffffffc020675a:	bb5d                	j	ffffffffc0206510 <stride_dequeue+0x302>
          r = a->left;
ffffffffc020675c:	008db783          	ld	a5,8(s11)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0206760:	010dbb03          	ld	s6,16(s11)
          r = a->left;
ffffffffc0206764:	e43e                	sd	a5,8(sp)
     if (a == NULL) return b;
ffffffffc0206766:	0c0b0d63          	beqz	s6,ffffffffc0206840 <stride_dequeue+0x632>
     if (comp(a, b) == -1)
ffffffffc020676a:	85ea                	mv	a1,s10
ffffffffc020676c:	855a                	mv	a0,s6
ffffffffc020676e:	84bff0ef          	jal	ra,ffffffffc0205fb8 <proc_stride_comp_f>
ffffffffc0206772:	75950363          	beq	a0,s9,ffffffffc0206eb8 <stride_dequeue+0xcaa>
          r = b->left;
ffffffffc0206776:	008d3783          	ld	a5,8(s10)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc020677a:	010d3c83          	ld	s9,16(s10)
          r = b->left;
ffffffffc020677e:	e83e                	sd	a5,16(sp)
     else if (b == NULL) return a;
ffffffffc0206780:	0a0c8963          	beqz	s9,ffffffffc0206832 <stride_dequeue+0x624>
     if (comp(a, b) == -1)
ffffffffc0206784:	85e6                	mv	a1,s9
ffffffffc0206786:	855a                	mv	a0,s6
ffffffffc0206788:	831ff0ef          	jal	ra,ffffffffc0205fb8 <proc_stride_comp_f>
ffffffffc020678c:	58fd                	li	a7,-1
ffffffffc020678e:	01151463          	bne	a0,a7,ffffffffc0206796 <stride_dequeue+0x588>
ffffffffc0206792:	7190006f          	j	ffffffffc02076aa <stride_dequeue+0x149c>
          r = b->left;
ffffffffc0206796:	008cb783          	ld	a5,8(s9)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc020679a:	010cb803          	ld	a6,16(s9)
          r = b->left;
ffffffffc020679e:	ec3e                	sd	a5,24(sp)
     else if (b == NULL) return a;
ffffffffc02067a0:	00081463          	bnez	a6,ffffffffc02067a8 <stride_dequeue+0x59a>
ffffffffc02067a4:	03b0106f          	j	ffffffffc0207fde <stride_dequeue+0x1dd0>
     if (comp(a, b) == -1)
ffffffffc02067a8:	85c2                	mv	a1,a6
ffffffffc02067aa:	855a                	mv	a0,s6
ffffffffc02067ac:	f042                	sd	a6,32(sp)
ffffffffc02067ae:	80bff0ef          	jal	ra,ffffffffc0205fb8 <proc_stride_comp_f>
ffffffffc02067b2:	58fd                	li	a7,-1
ffffffffc02067b4:	7802                	ld	a6,32(sp)
ffffffffc02067b6:	01151463          	bne	a0,a7,ffffffffc02067be <stride_dequeue+0x5b0>
ffffffffc02067ba:	5360106f          	j	ffffffffc0207cf0 <stride_dequeue+0x1ae2>
          r = b->left;
ffffffffc02067be:	00883783          	ld	a5,8(a6) # fffffffffffff008 <end+0x3fd35c28>
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02067c2:	01083303          	ld	t1,16(a6)
          r = b->left;
ffffffffc02067c6:	f03e                	sd	a5,32(sp)
     else if (b == NULL) return a;
ffffffffc02067c8:	04030663          	beqz	t1,ffffffffc0206814 <stride_dequeue+0x606>
     if (comp(a, b) == -1)
ffffffffc02067cc:	859a                	mv	a1,t1
ffffffffc02067ce:	855a                	mv	a0,s6
ffffffffc02067d0:	f842                	sd	a6,48(sp)
ffffffffc02067d2:	f41a                	sd	t1,40(sp)
ffffffffc02067d4:	fe4ff0ef          	jal	ra,ffffffffc0205fb8 <proc_stride_comp_f>
ffffffffc02067d8:	58fd                	li	a7,-1
ffffffffc02067da:	7322                	ld	t1,40(sp)
ffffffffc02067dc:	7842                	ld	a6,48(sp)
ffffffffc02067de:	01151463          	bne	a0,a7,ffffffffc02067e6 <stride_dequeue+0x5d8>
ffffffffc02067e2:	0bd0106f          	j	ffffffffc020809e <stride_dequeue+0x1e90>
          r = b->left;
ffffffffc02067e6:	00833883          	ld	a7,8(t1)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02067ea:	01033583          	ld	a1,16(t1)
ffffffffc02067ee:	855a                	mv	a0,s6
ffffffffc02067f0:	fc42                	sd	a6,56(sp)
          r = b->left;
ffffffffc02067f2:	f81a                	sd	t1,48(sp)
ffffffffc02067f4:	f446                	sd	a7,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02067f6:	81fff0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          b->left = l;
ffffffffc02067fa:	7342                	ld	t1,48(sp)
          b->right = r;
ffffffffc02067fc:	78a2                	ld	a7,40(sp)
          if (l) l->parent = b;
ffffffffc02067fe:	7862                	ld	a6,56(sp)
          b->left = l;
ffffffffc0206800:	00a33423          	sd	a0,8(t1)
          b->right = r;
ffffffffc0206804:	01133823          	sd	a7,16(t1)
          if (l) l->parent = b;
ffffffffc0206808:	e119                	bnez	a0,ffffffffc020680e <stride_dequeue+0x600>
ffffffffc020680a:	50d0106f          	j	ffffffffc0208516 <stride_dequeue+0x2308>
ffffffffc020680e:	00653023          	sd	t1,0(a0)
ffffffffc0206812:	8b1a                	mv	s6,t1
          b->right = r;
ffffffffc0206814:	7782                	ld	a5,32(sp)
          b->left = l;
ffffffffc0206816:	01683423          	sd	s6,8(a6)
          b->right = r;
ffffffffc020681a:	00f83823          	sd	a5,16(a6)
          if (l) l->parent = b;
ffffffffc020681e:	010b3023          	sd	a6,0(s6)
          b->right = r;
ffffffffc0206822:	67e2                	ld	a5,24(sp)
          b->left = l;
ffffffffc0206824:	010cb423          	sd	a6,8(s9)
          if (l) l->parent = b;
ffffffffc0206828:	8b66                	mv	s6,s9
          b->right = r;
ffffffffc020682a:	00fcb823          	sd	a5,16(s9)
          if (l) l->parent = b;
ffffffffc020682e:	01983023          	sd	s9,0(a6)
          b->right = r;
ffffffffc0206832:	67c2                	ld	a5,16(sp)
          b->left = l;
ffffffffc0206834:	016d3423          	sd	s6,8(s10)
          b->right = r;
ffffffffc0206838:	00fd3823          	sd	a5,16(s10)
          if (l) l->parent = b;
ffffffffc020683c:	01ab3023          	sd	s10,0(s6)
          a->right = r;
ffffffffc0206840:	67a2                	ld	a5,8(sp)
          a->left = l;
ffffffffc0206842:	01adb423          	sd	s10,8(s11)
          a->right = r;
ffffffffc0206846:	00fdb823          	sd	a5,16(s11)
          if (l) l->parent = a;
ffffffffc020684a:	01bd3023          	sd	s11,0(s10)
ffffffffc020684e:	b95d                	j	ffffffffc0206504 <stride_dequeue+0x2f6>
          r = a->left;
ffffffffc0206850:	008c3783          	ld	a5,8(s8)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0206854:	010c3d03          	ld	s10,16(s8)
          r = a->left;
ffffffffc0206858:	e43e                	sd	a5,8(sp)
     if (a == NULL) return b;
ffffffffc020685a:	0c0d0b63          	beqz	s10,ffffffffc0206930 <stride_dequeue+0x722>
     if (comp(a, b) == -1)
ffffffffc020685e:	85ee                	mv	a1,s11
ffffffffc0206860:	856a                	mv	a0,s10
ffffffffc0206862:	f56ff0ef          	jal	ra,ffffffffc0205fb8 <proc_stride_comp_f>
ffffffffc0206866:	71950c63          	beq	a0,s9,ffffffffc0206f7e <stride_dequeue+0xd70>
          r = b->left;
ffffffffc020686a:	008db783          	ld	a5,8(s11)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc020686e:	010dbc83          	ld	s9,16(s11)
          r = b->left;
ffffffffc0206872:	e83e                	sd	a5,16(sp)
     else if (b == NULL) return a;
ffffffffc0206874:	0a0c8763          	beqz	s9,ffffffffc0206922 <stride_dequeue+0x714>
     if (comp(a, b) == -1)
ffffffffc0206878:	85e6                	mv	a1,s9
ffffffffc020687a:	856a                	mv	a0,s10
ffffffffc020687c:	f3cff0ef          	jal	ra,ffffffffc0205fb8 <proc_stride_comp_f>
ffffffffc0206880:	58fd                	li	a7,-1
ffffffffc0206882:	6d1500e3          	beq	a0,a7,ffffffffc0207742 <stride_dequeue+0x1534>
          r = b->left;
ffffffffc0206886:	008cb783          	ld	a5,8(s9)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc020688a:	010cb803          	ld	a6,16(s9)
          r = b->left;
ffffffffc020688e:	ec3e                	sd	a5,24(sp)
     else if (b == NULL) return a;
ffffffffc0206890:	00081463          	bnez	a6,ffffffffc0206898 <stride_dequeue+0x68a>
ffffffffc0206894:	7620106f          	j	ffffffffc0207ff6 <stride_dequeue+0x1de8>
     if (comp(a, b) == -1)
ffffffffc0206898:	85c2                	mv	a1,a6
ffffffffc020689a:	856a                	mv	a0,s10
ffffffffc020689c:	f042                	sd	a6,32(sp)
ffffffffc020689e:	f1aff0ef          	jal	ra,ffffffffc0205fb8 <proc_stride_comp_f>
ffffffffc02068a2:	58fd                	li	a7,-1
ffffffffc02068a4:	7802                	ld	a6,32(sp)
ffffffffc02068a6:	01151463          	bne	a0,a7,ffffffffc02068ae <stride_dequeue+0x6a0>
ffffffffc02068aa:	4b60106f          	j	ffffffffc0207d60 <stride_dequeue+0x1b52>
          r = b->left;
ffffffffc02068ae:	00883783          	ld	a5,8(a6)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02068b2:	01083303          	ld	t1,16(a6)
          r = b->left;
ffffffffc02068b6:	f03e                	sd	a5,32(sp)
     else if (b == NULL) return a;
ffffffffc02068b8:	04030663          	beqz	t1,ffffffffc0206904 <stride_dequeue+0x6f6>
     if (comp(a, b) == -1)
ffffffffc02068bc:	859a                	mv	a1,t1
ffffffffc02068be:	856a                	mv	a0,s10
ffffffffc02068c0:	f842                	sd	a6,48(sp)
ffffffffc02068c2:	f41a                	sd	t1,40(sp)
ffffffffc02068c4:	ef4ff0ef          	jal	ra,ffffffffc0205fb8 <proc_stride_comp_f>
ffffffffc02068c8:	58fd                	li	a7,-1
ffffffffc02068ca:	7322                	ld	t1,40(sp)
ffffffffc02068cc:	7842                	ld	a6,48(sp)
ffffffffc02068ce:	01151463          	bne	a0,a7,ffffffffc02068d6 <stride_dequeue+0x6c8>
ffffffffc02068d2:	3090106f          	j	ffffffffc02083da <stride_dequeue+0x21cc>
          r = b->left;
ffffffffc02068d6:	00833883          	ld	a7,8(t1)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02068da:	01033583          	ld	a1,16(t1)
ffffffffc02068de:	856a                	mv	a0,s10
ffffffffc02068e0:	fc42                	sd	a6,56(sp)
          r = b->left;
ffffffffc02068e2:	f81a                	sd	t1,48(sp)
ffffffffc02068e4:	f446                	sd	a7,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02068e6:	f2eff0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          b->left = l;
ffffffffc02068ea:	7342                	ld	t1,48(sp)
          b->right = r;
ffffffffc02068ec:	78a2                	ld	a7,40(sp)
          if (l) l->parent = b;
ffffffffc02068ee:	7862                	ld	a6,56(sp)
          b->left = l;
ffffffffc02068f0:	00a33423          	sd	a0,8(t1)
          b->right = r;
ffffffffc02068f4:	01133823          	sd	a7,16(t1)
          if (l) l->parent = b;
ffffffffc02068f8:	e119                	bnez	a0,ffffffffc02068fe <stride_dequeue+0x6f0>
ffffffffc02068fa:	36b0106f          	j	ffffffffc0208464 <stride_dequeue+0x2256>
ffffffffc02068fe:	00653023          	sd	t1,0(a0)
ffffffffc0206902:	8d1a                	mv	s10,t1
          b->right = r;
ffffffffc0206904:	7782                	ld	a5,32(sp)
          b->left = l;
ffffffffc0206906:	01a83423          	sd	s10,8(a6)
          b->right = r;
ffffffffc020690a:	00f83823          	sd	a5,16(a6)
          if (l) l->parent = b;
ffffffffc020690e:	010d3023          	sd	a6,0(s10)
          b->right = r;
ffffffffc0206912:	67e2                	ld	a5,24(sp)
          b->left = l;
ffffffffc0206914:	010cb423          	sd	a6,8(s9)
          if (l) l->parent = b;
ffffffffc0206918:	8d66                	mv	s10,s9
          b->right = r;
ffffffffc020691a:	00fcb823          	sd	a5,16(s9)
          if (l) l->parent = b;
ffffffffc020691e:	01983023          	sd	s9,0(a6)
          b->right = r;
ffffffffc0206922:	67c2                	ld	a5,16(sp)
          b->left = l;
ffffffffc0206924:	01adb423          	sd	s10,8(s11)
          b->right = r;
ffffffffc0206928:	00fdb823          	sd	a5,16(s11)
          if (l) l->parent = b;
ffffffffc020692c:	01bd3023          	sd	s11,0(s10)
          a->right = r;
ffffffffc0206930:	67a2                	ld	a5,8(sp)
          a->left = l;
ffffffffc0206932:	01bc3423          	sd	s11,8(s8)
          a->right = r;
ffffffffc0206936:	00fc3823          	sd	a5,16(s8)
          if (l) l->parent = a;
ffffffffc020693a:	018db023          	sd	s8,0(s11)
ffffffffc020693e:	8de2                	mv	s11,s8
ffffffffc0206940:	b9dd                	j	ffffffffc0206636 <stride_dequeue+0x428>
          r = a->left;
ffffffffc0206942:	00893783          	ld	a5,8(s2)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0206946:	01093c83          	ld	s9,16(s2)
          r = a->left;
ffffffffc020694a:	e83e                	sd	a5,16(sp)
     if (a == NULL) return b;
ffffffffc020694c:	0a0c8263          	beqz	s9,ffffffffc02069f0 <stride_dequeue+0x7e2>
     if (comp(a, b) == -1)
ffffffffc0206950:	85ea                	mv	a1,s10
ffffffffc0206952:	8566                	mv	a0,s9
ffffffffc0206954:	e64ff0ef          	jal	ra,ffffffffc0205fb8 <proc_stride_comp_f>
ffffffffc0206958:	58fd                	li	a7,-1
ffffffffc020695a:	171507e3          	beq	a0,a7,ffffffffc02072c8 <stride_dequeue+0x10ba>
          r = b->left;
ffffffffc020695e:	008d3783          	ld	a5,8(s10)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206962:	010d3803          	ld	a6,16(s10)
          r = b->left;
ffffffffc0206966:	ec3e                	sd	a5,24(sp)
     else if (b == NULL) return a;
ffffffffc0206968:	06080d63          	beqz	a6,ffffffffc02069e2 <stride_dequeue+0x7d4>
     if (comp(a, b) == -1)
ffffffffc020696c:	85c2                	mv	a1,a6
ffffffffc020696e:	8566                	mv	a0,s9
ffffffffc0206970:	f042                	sd	a6,32(sp)
ffffffffc0206972:	e46ff0ef          	jal	ra,ffffffffc0205fb8 <proc_stride_comp_f>
ffffffffc0206976:	58fd                	li	a7,-1
ffffffffc0206978:	7802                	ld	a6,32(sp)
ffffffffc020697a:	6b150fe3          	beq	a0,a7,ffffffffc0207838 <stride_dequeue+0x162a>
          r = b->left;
ffffffffc020697e:	00883783          	ld	a5,8(a6)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206982:	01083303          	ld	t1,16(a6)
          r = b->left;
ffffffffc0206986:	f03e                	sd	a5,32(sp)
     else if (b == NULL) return a;
ffffffffc0206988:	00031463          	bnez	t1,ffffffffc0206990 <stride_dequeue+0x782>
ffffffffc020698c:	4e80106f          	j	ffffffffc0207e74 <stride_dequeue+0x1c66>
     if (comp(a, b) == -1)
ffffffffc0206990:	859a                	mv	a1,t1
ffffffffc0206992:	8566                	mv	a0,s9
ffffffffc0206994:	f842                	sd	a6,48(sp)
ffffffffc0206996:	f41a                	sd	t1,40(sp)
ffffffffc0206998:	e20ff0ef          	jal	ra,ffffffffc0205fb8 <proc_stride_comp_f>
ffffffffc020699c:	58fd                	li	a7,-1
ffffffffc020699e:	7322                	ld	t1,40(sp)
ffffffffc02069a0:	7842                	ld	a6,48(sp)
ffffffffc02069a2:	01151463          	bne	a0,a7,ffffffffc02069aa <stride_dequeue+0x79c>
ffffffffc02069a6:	58c0106f          	j	ffffffffc0207f32 <stride_dequeue+0x1d24>
          r = b->left;
ffffffffc02069aa:	00833883          	ld	a7,8(t1)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02069ae:	01033583          	ld	a1,16(t1)
ffffffffc02069b2:	8566                	mv	a0,s9
ffffffffc02069b4:	fc42                	sd	a6,56(sp)
          r = b->left;
ffffffffc02069b6:	f81a                	sd	t1,48(sp)
ffffffffc02069b8:	f446                	sd	a7,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02069ba:	e5aff0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          b->left = l;
ffffffffc02069be:	7342                	ld	t1,48(sp)
          b->right = r;
ffffffffc02069c0:	78a2                	ld	a7,40(sp)
          if (l) l->parent = b;
ffffffffc02069c2:	7862                	ld	a6,56(sp)
          b->left = l;
ffffffffc02069c4:	00a33423          	sd	a0,8(t1)
          b->right = r;
ffffffffc02069c8:	01133823          	sd	a7,16(t1)
          if (l) l->parent = b;
ffffffffc02069cc:	c119                	beqz	a0,ffffffffc02069d2 <stride_dequeue+0x7c4>
ffffffffc02069ce:	00653023          	sd	t1,0(a0)
          b->right = r;
ffffffffc02069d2:	7782                	ld	a5,32(sp)
          b->left = l;
ffffffffc02069d4:	00683423          	sd	t1,8(a6)
          if (l) l->parent = b;
ffffffffc02069d8:	8cc2                	mv	s9,a6
          b->right = r;
ffffffffc02069da:	00f83823          	sd	a5,16(a6)
          if (l) l->parent = b;
ffffffffc02069de:	01033023          	sd	a6,0(t1)
          b->right = r;
ffffffffc02069e2:	67e2                	ld	a5,24(sp)
          b->left = l;
ffffffffc02069e4:	019d3423          	sd	s9,8(s10)
          b->right = r;
ffffffffc02069e8:	00fd3823          	sd	a5,16(s10)
          if (l) l->parent = b;
ffffffffc02069ec:	01acb023          	sd	s10,0(s9)
          a->right = r;
ffffffffc02069f0:	67c2                	ld	a5,16(sp)
          a->left = l;
ffffffffc02069f2:	01a93423          	sd	s10,8(s2)
          a->right = r;
ffffffffc02069f6:	00f93823          	sd	a5,16(s2)
          if (l) l->parent = a;
ffffffffc02069fa:	012d3023          	sd	s2,0(s10)
ffffffffc02069fe:	b295                	j	ffffffffc0206362 <stride_dequeue+0x154>
          r = a->left;
ffffffffc0206a00:	00893783          	ld	a5,8(s2)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0206a04:	01093c83          	ld	s9,16(s2)
          r = a->left;
ffffffffc0206a08:	e43e                	sd	a5,8(sp)
     if (a == NULL) return b;
ffffffffc0206a0a:	0c0c8663          	beqz	s9,ffffffffc0206ad6 <stride_dequeue+0x8c8>
     if (comp(a, b) == -1)
ffffffffc0206a0e:	85e2                	mv	a1,s8
ffffffffc0206a10:	8566                	mv	a0,s9
ffffffffc0206a12:	da6ff0ef          	jal	ra,ffffffffc0205fb8 <proc_stride_comp_f>
ffffffffc0206a16:	29a50363          	beq	a0,s10,ffffffffc0206c9c <stride_dequeue+0xa8e>
          r = b->left;
ffffffffc0206a1a:	008c3783          	ld	a5,8(s8)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206a1e:	010c3d03          	ld	s10,16(s8)
          r = b->left;
ffffffffc0206a22:	e83e                	sd	a5,16(sp)
     else if (b == NULL) return a;
ffffffffc0206a24:	0a0d0263          	beqz	s10,ffffffffc0206ac8 <stride_dequeue+0x8ba>
     if (comp(a, b) == -1)
ffffffffc0206a28:	85ea                	mv	a1,s10
ffffffffc0206a2a:	8566                	mv	a0,s9
ffffffffc0206a2c:	d8cff0ef          	jal	ra,ffffffffc0205fb8 <proc_stride_comp_f>
ffffffffc0206a30:	58fd                	li	a7,-1
ffffffffc0206a32:	011502e3          	beq	a0,a7,ffffffffc0207236 <stride_dequeue+0x1028>
          r = b->left;
ffffffffc0206a36:	008d3703          	ld	a4,8(s10)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206a3a:	010d3783          	ld	a5,16(s10)
          r = b->left;
ffffffffc0206a3e:	ec3a                	sd	a4,24(sp)
     else if (b == NULL) return a;
ffffffffc0206a40:	cfa5                	beqz	a5,ffffffffc0206ab8 <stride_dequeue+0x8aa>
     if (comp(a, b) == -1)
ffffffffc0206a42:	85be                	mv	a1,a5
ffffffffc0206a44:	8566                	mv	a0,s9
ffffffffc0206a46:	f03e                	sd	a5,32(sp)
ffffffffc0206a48:	d70ff0ef          	jal	ra,ffffffffc0205fb8 <proc_stride_comp_f>
ffffffffc0206a4c:	58fd                	li	a7,-1
ffffffffc0206a4e:	7782                	ld	a5,32(sp)
ffffffffc0206a50:	01151463          	bne	a0,a7,ffffffffc0206a58 <stride_dequeue+0x84a>
ffffffffc0206a54:	6ed0006f          	j	ffffffffc0207940 <stride_dequeue+0x1732>
          r = b->left;
ffffffffc0206a58:	6798                	ld	a4,8(a5)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206a5a:	0107b303          	ld	t1,16(a5)
          r = b->left;
ffffffffc0206a5e:	f03a                	sd	a4,32(sp)
     else if (b == NULL) return a;
ffffffffc0206a60:	00031463          	bnez	t1,ffffffffc0206a68 <stride_dequeue+0x85a>
ffffffffc0206a64:	4160106f          	j	ffffffffc0207e7a <stride_dequeue+0x1c6c>
     if (comp(a, b) == -1)
ffffffffc0206a68:	859a                	mv	a1,t1
ffffffffc0206a6a:	8566                	mv	a0,s9
ffffffffc0206a6c:	f83e                	sd	a5,48(sp)
ffffffffc0206a6e:	f41a                	sd	t1,40(sp)
ffffffffc0206a70:	d48ff0ef          	jal	ra,ffffffffc0205fb8 <proc_stride_comp_f>
ffffffffc0206a74:	58fd                	li	a7,-1
ffffffffc0206a76:	7322                	ld	t1,40(sp)
ffffffffc0206a78:	77c2                	ld	a5,48(sp)
ffffffffc0206a7a:	01151463          	bne	a0,a7,ffffffffc0206a82 <stride_dequeue+0x874>
ffffffffc0206a7e:	5300106f          	j	ffffffffc0207fae <stride_dequeue+0x1da0>
          r = b->left;
ffffffffc0206a82:	00833883          	ld	a7,8(t1)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206a86:	01033583          	ld	a1,16(t1)
ffffffffc0206a8a:	8566                	mv	a0,s9
ffffffffc0206a8c:	fc3e                	sd	a5,56(sp)
          r = b->left;
ffffffffc0206a8e:	f81a                	sd	t1,48(sp)
ffffffffc0206a90:	f446                	sd	a7,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206a92:	d82ff0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          b->left = l;
ffffffffc0206a96:	7342                	ld	t1,48(sp)
          b->right = r;
ffffffffc0206a98:	78a2                	ld	a7,40(sp)
          if (l) l->parent = b;
ffffffffc0206a9a:	77e2                	ld	a5,56(sp)
          b->left = l;
ffffffffc0206a9c:	00a33423          	sd	a0,8(t1)
          b->right = r;
ffffffffc0206aa0:	01133823          	sd	a7,16(t1)
          if (l) l->parent = b;
ffffffffc0206aa4:	c119                	beqz	a0,ffffffffc0206aaa <stride_dequeue+0x89c>
ffffffffc0206aa6:	00653023          	sd	t1,0(a0)
          b->right = r;
ffffffffc0206aaa:	7702                	ld	a4,32(sp)
          b->left = l;
ffffffffc0206aac:	0067b423          	sd	t1,8(a5)
          if (l) l->parent = b;
ffffffffc0206ab0:	8cbe                	mv	s9,a5
          b->right = r;
ffffffffc0206ab2:	eb98                	sd	a4,16(a5)
          if (l) l->parent = b;
ffffffffc0206ab4:	00f33023          	sd	a5,0(t1)
          b->right = r;
ffffffffc0206ab8:	67e2                	ld	a5,24(sp)
          b->left = l;
ffffffffc0206aba:	019d3423          	sd	s9,8(s10)
          b->right = r;
ffffffffc0206abe:	00fd3823          	sd	a5,16(s10)
          if (l) l->parent = b;
ffffffffc0206ac2:	01acb023          	sd	s10,0(s9)
ffffffffc0206ac6:	8cea                	mv	s9,s10
          b->right = r;
ffffffffc0206ac8:	67c2                	ld	a5,16(sp)
          b->left = l;
ffffffffc0206aca:	019c3423          	sd	s9,8(s8)
          b->right = r;
ffffffffc0206ace:	00fc3823          	sd	a5,16(s8)
          if (l) l->parent = b;
ffffffffc0206ad2:	018cb023          	sd	s8,0(s9)
          a->right = r;
ffffffffc0206ad6:	67a2                	ld	a5,8(sp)
          a->left = l;
ffffffffc0206ad8:	01893423          	sd	s8,8(s2)
          a->right = r;
ffffffffc0206adc:	00f93823          	sd	a5,16(s2)
          if (l) l->parent = a;
ffffffffc0206ae0:	012c3023          	sd	s2,0(s8)
ffffffffc0206ae4:	88fff06f          	j	ffffffffc0206372 <stride_dequeue+0x164>
          r = a->left;
ffffffffc0206ae8:	008c3783          	ld	a5,8(s8)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0206aec:	010c3c83          	ld	s9,16(s8)
          r = a->left;
ffffffffc0206af0:	e43e                	sd	a5,8(sp)
     if (a == NULL) return b;
ffffffffc0206af2:	0c0c8863          	beqz	s9,ffffffffc0206bc2 <stride_dequeue+0x9b4>
     if (comp(a, b) == -1)
ffffffffc0206af6:	85a6                	mv	a1,s1
ffffffffc0206af8:	8566                	mv	a0,s9
ffffffffc0206afa:	cbeff0ef          	jal	ra,ffffffffc0205fb8 <proc_stride_comp_f>
ffffffffc0206afe:	0ba50ce3          	beq	a0,s10,ffffffffc02073b6 <stride_dequeue+0x11a8>
          r = b->left;
ffffffffc0206b02:	649c                	ld	a5,8(s1)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206b04:	0104bd03          	ld	s10,16(s1)
          r = b->left;
ffffffffc0206b08:	e83e                	sd	a5,16(sp)
     else if (b == NULL) return a;
ffffffffc0206b0a:	000d1463          	bnez	s10,ffffffffc0206b12 <stride_dequeue+0x904>
ffffffffc0206b0e:	24c0106f          	j	ffffffffc0207d5a <stride_dequeue+0x1b4c>
     if (comp(a, b) == -1)
ffffffffc0206b12:	85ea                	mv	a1,s10
ffffffffc0206b14:	8566                	mv	a0,s9
ffffffffc0206b16:	ca2ff0ef          	jal	ra,ffffffffc0205fb8 <proc_stride_comp_f>
ffffffffc0206b1a:	537d                	li	t1,-1
ffffffffc0206b1c:	00651463          	bne	a0,t1,ffffffffc0206b24 <stride_dequeue+0x916>
ffffffffc0206b20:	6f90006f          	j	ffffffffc0207a18 <stride_dequeue+0x180a>
          r = b->left;
ffffffffc0206b24:	008d3783          	ld	a5,8(s10)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206b28:	010d3703          	ld	a4,16(s10)
          r = b->left;
ffffffffc0206b2c:	ec3e                	sd	a5,24(sp)
     else if (b == NULL) return a;
ffffffffc0206b2e:	cf2d                	beqz	a4,ffffffffc0206ba8 <stride_dequeue+0x99a>
     if (comp(a, b) == -1)
ffffffffc0206b30:	85ba                	mv	a1,a4
ffffffffc0206b32:	8566                	mv	a0,s9
ffffffffc0206b34:	f03a                	sd	a4,32(sp)
ffffffffc0206b36:	c82ff0ef          	jal	ra,ffffffffc0205fb8 <proc_stride_comp_f>
ffffffffc0206b3a:	537d                	li	t1,-1
ffffffffc0206b3c:	7702                	ld	a4,32(sp)
ffffffffc0206b3e:	00651463          	bne	a0,t1,ffffffffc0206b46 <stride_dequeue+0x938>
ffffffffc0206b42:	6aa0106f          	j	ffffffffc02081ec <stride_dequeue+0x1fde>
          r = b->left;
ffffffffc0206b46:	671c                	ld	a5,8(a4)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206b48:	01073883          	ld	a7,16(a4) # 18010 <_binary_obj___user_matrix_out_size+0xc5a8>
          r = b->left;
ffffffffc0206b4c:	f03e                	sd	a5,32(sp)
     else if (b == NULL) return a;
ffffffffc0206b4e:	04088663          	beqz	a7,ffffffffc0206b9a <stride_dequeue+0x98c>
     if (comp(a, b) == -1)
ffffffffc0206b52:	85c6                	mv	a1,a7
ffffffffc0206b54:	8566                	mv	a0,s9
ffffffffc0206b56:	f83a                	sd	a4,48(sp)
ffffffffc0206b58:	f446                	sd	a7,40(sp)
ffffffffc0206b5a:	c5eff0ef          	jal	ra,ffffffffc0205fb8 <proc_stride_comp_f>
ffffffffc0206b5e:	537d                	li	t1,-1
ffffffffc0206b60:	78a2                	ld	a7,40(sp)
ffffffffc0206b62:	7742                	ld	a4,48(sp)
ffffffffc0206b64:	00651463          	bne	a0,t1,ffffffffc0206b6c <stride_dequeue+0x95e>
ffffffffc0206b68:	4090106f          	j	ffffffffc0208770 <stride_dequeue+0x2562>
          r = b->left;
ffffffffc0206b6c:	0088b303          	ld	t1,8(a7) # 2008 <_binary_obj___user_faultread_out_size-0x78f8>
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206b70:	0108b583          	ld	a1,16(a7)
ffffffffc0206b74:	8566                	mv	a0,s9
ffffffffc0206b76:	fc3a                	sd	a4,56(sp)
          r = b->left;
ffffffffc0206b78:	f846                	sd	a7,48(sp)
ffffffffc0206b7a:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206b7c:	c98ff0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          b->left = l;
ffffffffc0206b80:	78c2                	ld	a7,48(sp)
          b->right = r;
ffffffffc0206b82:	7322                	ld	t1,40(sp)
          if (l) l->parent = b;
ffffffffc0206b84:	7762                	ld	a4,56(sp)
          b->left = l;
ffffffffc0206b86:	00a8b423          	sd	a0,8(a7)
          b->right = r;
ffffffffc0206b8a:	0068b823          	sd	t1,16(a7)
          if (l) l->parent = b;
ffffffffc0206b8e:	e119                	bnez	a0,ffffffffc0206b94 <stride_dequeue+0x986>
ffffffffc0206b90:	55b0106f          	j	ffffffffc02088ea <stride_dequeue+0x26dc>
ffffffffc0206b94:	01153023          	sd	a7,0(a0)
ffffffffc0206b98:	8cc6                	mv	s9,a7
          b->right = r;
ffffffffc0206b9a:	7782                	ld	a5,32(sp)
          b->left = l;
ffffffffc0206b9c:	01973423          	sd	s9,8(a4)
          b->right = r;
ffffffffc0206ba0:	eb1c                	sd	a5,16(a4)
          if (l) l->parent = b;
ffffffffc0206ba2:	00ecb023          	sd	a4,0(s9)
ffffffffc0206ba6:	8cba                	mv	s9,a4
          b->right = r;
ffffffffc0206ba8:	67e2                	ld	a5,24(sp)
          b->left = l;
ffffffffc0206baa:	019d3423          	sd	s9,8(s10)
          b->right = r;
ffffffffc0206bae:	00fd3823          	sd	a5,16(s10)
          if (l) l->parent = b;
ffffffffc0206bb2:	01acb023          	sd	s10,0(s9)
          b->right = r;
ffffffffc0206bb6:	67c2                	ld	a5,16(sp)
          b->left = l;
ffffffffc0206bb8:	01a4b423          	sd	s10,8(s1)
          b->right = r;
ffffffffc0206bbc:	e89c                	sd	a5,16(s1)
          if (l) l->parent = b;
ffffffffc0206bbe:	009d3023          	sd	s1,0(s10)
          a->right = r;
ffffffffc0206bc2:	67a2                	ld	a5,8(sp)
          a->left = l;
ffffffffc0206bc4:	009c3423          	sd	s1,8(s8)
          a->right = r;
ffffffffc0206bc8:	00fc3823          	sd	a5,16(s8)
          if (l) l->parent = a;
ffffffffc0206bcc:	0184b023          	sd	s8,0(s1)
ffffffffc0206bd0:	84e2                	mv	s1,s8
ffffffffc0206bd2:	bead                	j	ffffffffc020674c <stride_dequeue+0x53e>
          r = a->left;
ffffffffc0206bd4:	008db783          	ld	a5,8(s11)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0206bd8:	010dbb03          	ld	s6,16(s11)
          r = a->left;
ffffffffc0206bdc:	e83e                	sd	a5,16(sp)
     if (a == NULL) return b;
ffffffffc0206bde:	0a0b0663          	beqz	s6,ffffffffc0206c8a <stride_dequeue+0xa7c>
     if (comp(a, b) == -1)
ffffffffc0206be2:	85e6                	mv	a1,s9
ffffffffc0206be4:	855a                	mv	a0,s6
ffffffffc0206be6:	bd2ff0ef          	jal	ra,ffffffffc0205fb8 <proc_stride_comp_f>
ffffffffc0206bea:	58fd                	li	a7,-1
ffffffffc0206bec:	231502e3          	beq	a0,a7,ffffffffc0207610 <stride_dequeue+0x1402>
          r = b->left;
ffffffffc0206bf0:	008cb783          	ld	a5,8(s9)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206bf4:	010cb803          	ld	a6,16(s9)
          r = b->left;
ffffffffc0206bf8:	ec3e                	sd	a5,24(sp)
     else if (b == NULL) return a;
ffffffffc0206bfa:	00081463          	bnez	a6,ffffffffc0206c02 <stride_dequeue+0x9f4>
ffffffffc0206bfe:	3e60106f          	j	ffffffffc0207fe4 <stride_dequeue+0x1dd6>
     if (comp(a, b) == -1)
ffffffffc0206c02:	85c2                	mv	a1,a6
ffffffffc0206c04:	855a                	mv	a0,s6
ffffffffc0206c06:	f042                	sd	a6,32(sp)
ffffffffc0206c08:	bb0ff0ef          	jal	ra,ffffffffc0205fb8 <proc_stride_comp_f>
ffffffffc0206c0c:	58fd                	li	a7,-1
ffffffffc0206c0e:	7802                	ld	a6,32(sp)
ffffffffc0206c10:	01151463          	bne	a0,a7,ffffffffc0206c18 <stride_dequeue+0xa0a>
ffffffffc0206c14:	7c30006f          	j	ffffffffc0207bd6 <stride_dequeue+0x19c8>
          r = b->left;
ffffffffc0206c18:	00883783          	ld	a5,8(a6)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206c1c:	01083303          	ld	t1,16(a6)
          r = b->left;
ffffffffc0206c20:	f03e                	sd	a5,32(sp)
     else if (b == NULL) return a;
ffffffffc0206c22:	04030663          	beqz	t1,ffffffffc0206c6e <stride_dequeue+0xa60>
     if (comp(a, b) == -1)
ffffffffc0206c26:	859a                	mv	a1,t1
ffffffffc0206c28:	855a                	mv	a0,s6
ffffffffc0206c2a:	f842                	sd	a6,48(sp)
ffffffffc0206c2c:	f41a                	sd	t1,40(sp)
ffffffffc0206c2e:	b8aff0ef          	jal	ra,ffffffffc0205fb8 <proc_stride_comp_f>
ffffffffc0206c32:	58fd                	li	a7,-1
ffffffffc0206c34:	7322                	ld	t1,40(sp)
ffffffffc0206c36:	7842                	ld	a6,48(sp)
ffffffffc0206c38:	01151463          	bne	a0,a7,ffffffffc0206c40 <stride_dequeue+0xa32>
ffffffffc0206c3c:	5d80106f          	j	ffffffffc0208214 <stride_dequeue+0x2006>
          r = b->left;
ffffffffc0206c40:	00833883          	ld	a7,8(t1)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206c44:	01033583          	ld	a1,16(t1)
ffffffffc0206c48:	855a                	mv	a0,s6
ffffffffc0206c4a:	fc42                	sd	a6,56(sp)
          r = b->left;
ffffffffc0206c4c:	f81a                	sd	t1,48(sp)
ffffffffc0206c4e:	f446                	sd	a7,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206c50:	bc4ff0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          b->left = l;
ffffffffc0206c54:	7342                	ld	t1,48(sp)
          b->right = r;
ffffffffc0206c56:	78a2                	ld	a7,40(sp)
          if (l) l->parent = b;
ffffffffc0206c58:	7862                	ld	a6,56(sp)
          b->left = l;
ffffffffc0206c5a:	00a33423          	sd	a0,8(t1)
          b->right = r;
ffffffffc0206c5e:	01133823          	sd	a7,16(t1)
          if (l) l->parent = b;
ffffffffc0206c62:	e119                	bnez	a0,ffffffffc0206c68 <stride_dequeue+0xa5a>
ffffffffc0206c64:	7fa0106f          	j	ffffffffc020845e <stride_dequeue+0x2250>
ffffffffc0206c68:	00653023          	sd	t1,0(a0)
ffffffffc0206c6c:	8b1a                	mv	s6,t1
          b->right = r;
ffffffffc0206c6e:	7782                	ld	a5,32(sp)
          b->left = l;
ffffffffc0206c70:	01683423          	sd	s6,8(a6)
          b->right = r;
ffffffffc0206c74:	00f83823          	sd	a5,16(a6)
          if (l) l->parent = b;
ffffffffc0206c78:	010b3023          	sd	a6,0(s6)
          b->right = r;
ffffffffc0206c7c:	67e2                	ld	a5,24(sp)
          b->left = l;
ffffffffc0206c7e:	010cb423          	sd	a6,8(s9)
          b->right = r;
ffffffffc0206c82:	00fcb823          	sd	a5,16(s9)
          if (l) l->parent = b;
ffffffffc0206c86:	01983023          	sd	s9,0(a6)
          a->right = r;
ffffffffc0206c8a:	67c2                	ld	a5,16(sp)
          a->left = l;
ffffffffc0206c8c:	019db423          	sd	s9,8(s11)
          a->right = r;
ffffffffc0206c90:	00fdb823          	sd	a5,16(s11)
          if (l) l->parent = a;
ffffffffc0206c94:	01bcb023          	sd	s11,0(s9)
ffffffffc0206c98:	85dff06f          	j	ffffffffc02064f4 <stride_dequeue+0x2e6>
          r = a->left;
ffffffffc0206c9c:	008cb783          	ld	a5,8(s9)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0206ca0:	010cbd03          	ld	s10,16(s9)
          r = a->left;
ffffffffc0206ca4:	e83e                	sd	a5,16(sp)
     if (a == NULL) return b;
ffffffffc0206ca6:	0a0d0663          	beqz	s10,ffffffffc0206d52 <stride_dequeue+0xb44>
     if (comp(a, b) == -1)
ffffffffc0206caa:	85e2                	mv	a1,s8
ffffffffc0206cac:	856a                	mv	a0,s10
ffffffffc0206cae:	b0aff0ef          	jal	ra,ffffffffc0205fb8 <proc_stride_comp_f>
ffffffffc0206cb2:	58fd                	li	a7,-1
ffffffffc0206cb4:	0b150fe3          	beq	a0,a7,ffffffffc0207572 <stride_dequeue+0x1364>
          r = b->left;
ffffffffc0206cb8:	008c3783          	ld	a5,8(s8)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206cbc:	010c3803          	ld	a6,16(s8)
          r = b->left;
ffffffffc0206cc0:	ec3e                	sd	a5,24(sp)
     else if (b == NULL) return a;
ffffffffc0206cc2:	00081463          	bnez	a6,ffffffffc0206cca <stride_dequeue+0xabc>
ffffffffc0206cc6:	3240106f          	j	ffffffffc0207fea <stride_dequeue+0x1ddc>
     if (comp(a, b) == -1)
ffffffffc0206cca:	85c2                	mv	a1,a6
ffffffffc0206ccc:	856a                	mv	a0,s10
ffffffffc0206cce:	f042                	sd	a6,32(sp)
ffffffffc0206cd0:	ae8ff0ef          	jal	ra,ffffffffc0205fb8 <proc_stride_comp_f>
ffffffffc0206cd4:	58fd                	li	a7,-1
ffffffffc0206cd6:	7802                	ld	a6,32(sp)
ffffffffc0206cd8:	01151463          	bne	a0,a7,ffffffffc0206ce0 <stride_dequeue+0xad2>
ffffffffc0206cdc:	7b70006f          	j	ffffffffc0207c92 <stride_dequeue+0x1a84>
          r = b->left;
ffffffffc0206ce0:	00883783          	ld	a5,8(a6)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206ce4:	01083303          	ld	t1,16(a6)
          r = b->left;
ffffffffc0206ce8:	f03e                	sd	a5,32(sp)
     else if (b == NULL) return a;
ffffffffc0206cea:	04030663          	beqz	t1,ffffffffc0206d36 <stride_dequeue+0xb28>
     if (comp(a, b) == -1)
ffffffffc0206cee:	859a                	mv	a1,t1
ffffffffc0206cf0:	856a                	mv	a0,s10
ffffffffc0206cf2:	f842                	sd	a6,48(sp)
ffffffffc0206cf4:	f41a                	sd	t1,40(sp)
ffffffffc0206cf6:	ac2ff0ef          	jal	ra,ffffffffc0205fb8 <proc_stride_comp_f>
ffffffffc0206cfa:	58fd                	li	a7,-1
ffffffffc0206cfc:	7322                	ld	t1,40(sp)
ffffffffc0206cfe:	7842                	ld	a6,48(sp)
ffffffffc0206d00:	01151463          	bne	a0,a7,ffffffffc0206d08 <stride_dequeue+0xafa>
ffffffffc0206d04:	4420106f          	j	ffffffffc0208146 <stride_dequeue+0x1f38>
          r = b->left;
ffffffffc0206d08:	00833883          	ld	a7,8(t1)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206d0c:	01033583          	ld	a1,16(t1)
ffffffffc0206d10:	856a                	mv	a0,s10
ffffffffc0206d12:	fc42                	sd	a6,56(sp)
          r = b->left;
ffffffffc0206d14:	f81a                	sd	t1,48(sp)
ffffffffc0206d16:	f446                	sd	a7,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206d18:	afcff0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          b->left = l;
ffffffffc0206d1c:	7342                	ld	t1,48(sp)
          b->right = r;
ffffffffc0206d1e:	78a2                	ld	a7,40(sp)
          if (l) l->parent = b;
ffffffffc0206d20:	7862                	ld	a6,56(sp)
          b->left = l;
ffffffffc0206d22:	00a33423          	sd	a0,8(t1)
          b->right = r;
ffffffffc0206d26:	01133823          	sd	a7,16(t1)
          if (l) l->parent = b;
ffffffffc0206d2a:	e119                	bnez	a0,ffffffffc0206d30 <stride_dequeue+0xb22>
ffffffffc0206d2c:	7f60106f          	j	ffffffffc0208522 <stride_dequeue+0x2314>
ffffffffc0206d30:	00653023          	sd	t1,0(a0)
ffffffffc0206d34:	8d1a                	mv	s10,t1
          b->right = r;
ffffffffc0206d36:	7782                	ld	a5,32(sp)
          b->left = l;
ffffffffc0206d38:	01a83423          	sd	s10,8(a6)
          b->right = r;
ffffffffc0206d3c:	00f83823          	sd	a5,16(a6)
          if (l) l->parent = b;
ffffffffc0206d40:	010d3023          	sd	a6,0(s10)
          b->right = r;
ffffffffc0206d44:	67e2                	ld	a5,24(sp)
          b->left = l;
ffffffffc0206d46:	010c3423          	sd	a6,8(s8)
          b->right = r;
ffffffffc0206d4a:	00fc3823          	sd	a5,16(s8)
          if (l) l->parent = b;
ffffffffc0206d4e:	01883023          	sd	s8,0(a6)
          a->right = r;
ffffffffc0206d52:	67c2                	ld	a5,16(sp)
          a->left = l;
ffffffffc0206d54:	018cb423          	sd	s8,8(s9)
          a->right = r;
ffffffffc0206d58:	00fcb823          	sd	a5,16(s9)
          if (l) l->parent = a;
ffffffffc0206d5c:	019c3023          	sd	s9,0(s8)
ffffffffc0206d60:	8c66                	mv	s8,s9
ffffffffc0206d62:	bb95                	j	ffffffffc0206ad6 <stride_dequeue+0x8c8>
          r = a->left;
ffffffffc0206d64:	008c3783          	ld	a5,8(s8)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0206d68:	010c3d03          	ld	s10,16(s8)
          r = a->left;
ffffffffc0206d6c:	e83e                	sd	a5,16(sp)
     if (a == NULL) return b;
ffffffffc0206d6e:	0a0d0463          	beqz	s10,ffffffffc0206e16 <stride_dequeue+0xc08>
     if (comp(a, b) == -1)
ffffffffc0206d72:	85e6                	mv	a1,s9
ffffffffc0206d74:	856a                	mv	a0,s10
ffffffffc0206d76:	a42ff0ef          	jal	ra,ffffffffc0205fb8 <proc_stride_comp_f>
ffffffffc0206d7a:	58fd                	li	a7,-1
ffffffffc0206d7c:	6b150d63          	beq	a0,a7,ffffffffc0207436 <stride_dequeue+0x1228>
          r = b->left;
ffffffffc0206d80:	008cb783          	ld	a5,8(s9)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206d84:	010cb803          	ld	a6,16(s9)
          r = b->left;
ffffffffc0206d88:	ec3e                	sd	a5,24(sp)
     else if (b == NULL) return a;
ffffffffc0206d8a:	00081463          	bnez	a6,ffffffffc0206d92 <stride_dequeue+0xb84>
ffffffffc0206d8e:	2620106f          	j	ffffffffc0207ff0 <stride_dequeue+0x1de2>
     if (comp(a, b) == -1)
ffffffffc0206d92:	85c2                	mv	a1,a6
ffffffffc0206d94:	856a                	mv	a0,s10
ffffffffc0206d96:	f042                	sd	a6,32(sp)
ffffffffc0206d98:	a20ff0ef          	jal	ra,ffffffffc0205fb8 <proc_stride_comp_f>
ffffffffc0206d9c:	58fd                	li	a7,-1
ffffffffc0206d9e:	7802                	ld	a6,32(sp)
ffffffffc0206da0:	57150de3          	beq	a0,a7,ffffffffc0207b1a <stride_dequeue+0x190c>
          r = b->left;
ffffffffc0206da4:	00883783          	ld	a5,8(a6)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206da8:	01083303          	ld	t1,16(a6)
          r = b->left;
ffffffffc0206dac:	f03e                	sd	a5,32(sp)
     else if (b == NULL) return a;
ffffffffc0206dae:	04030663          	beqz	t1,ffffffffc0206dfa <stride_dequeue+0xbec>
     if (comp(a, b) == -1)
ffffffffc0206db2:	859a                	mv	a1,t1
ffffffffc0206db4:	856a                	mv	a0,s10
ffffffffc0206db6:	f842                	sd	a6,48(sp)
ffffffffc0206db8:	f41a                	sd	t1,40(sp)
ffffffffc0206dba:	9feff0ef          	jal	ra,ffffffffc0205fb8 <proc_stride_comp_f>
ffffffffc0206dbe:	58fd                	li	a7,-1
ffffffffc0206dc0:	7322                	ld	t1,40(sp)
ffffffffc0206dc2:	7842                	ld	a6,48(sp)
ffffffffc0206dc4:	01151463          	bne	a0,a7,ffffffffc0206dcc <stride_dequeue+0xbbe>
ffffffffc0206dc8:	3fa0106f          	j	ffffffffc02081c2 <stride_dequeue+0x1fb4>
          r = b->left;
ffffffffc0206dcc:	00833883          	ld	a7,8(t1)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206dd0:	01033583          	ld	a1,16(t1)
ffffffffc0206dd4:	856a                	mv	a0,s10
ffffffffc0206dd6:	fc42                	sd	a6,56(sp)
          r = b->left;
ffffffffc0206dd8:	f81a                	sd	t1,48(sp)
ffffffffc0206dda:	f446                	sd	a7,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206ddc:	a38ff0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          b->left = l;
ffffffffc0206de0:	7342                	ld	t1,48(sp)
          b->right = r;
ffffffffc0206de2:	78a2                	ld	a7,40(sp)
          if (l) l->parent = b;
ffffffffc0206de4:	7862                	ld	a6,56(sp)
          b->left = l;
ffffffffc0206de6:	00a33423          	sd	a0,8(t1)
          b->right = r;
ffffffffc0206dea:	01133823          	sd	a7,16(t1)
          if (l) l->parent = b;
ffffffffc0206dee:	e119                	bnez	a0,ffffffffc0206df4 <stride_dequeue+0xbe6>
ffffffffc0206df0:	6fa0106f          	j	ffffffffc02084ea <stride_dequeue+0x22dc>
ffffffffc0206df4:	00653023          	sd	t1,0(a0)
ffffffffc0206df8:	8d1a                	mv	s10,t1
          b->right = r;
ffffffffc0206dfa:	7782                	ld	a5,32(sp)
          b->left = l;
ffffffffc0206dfc:	01a83423          	sd	s10,8(a6)
          b->right = r;
ffffffffc0206e00:	00f83823          	sd	a5,16(a6)
          if (l) l->parent = b;
ffffffffc0206e04:	010d3023          	sd	a6,0(s10)
          b->right = r;
ffffffffc0206e08:	67e2                	ld	a5,24(sp)
          b->left = l;
ffffffffc0206e0a:	010cb423          	sd	a6,8(s9)
          b->right = r;
ffffffffc0206e0e:	00fcb823          	sd	a5,16(s9)
          if (l) l->parent = b;
ffffffffc0206e12:	01983023          	sd	s9,0(a6)
          a->right = r;
ffffffffc0206e16:	67c2                	ld	a5,16(sp)
          a->left = l;
ffffffffc0206e18:	019c3423          	sd	s9,8(s8)
          a->right = r;
ffffffffc0206e1c:	00fc3823          	sd	a5,16(s8)
          if (l) l->parent = a;
ffffffffc0206e20:	018cb023          	sd	s8,0(s9)
ffffffffc0206e24:	805ff06f          	j	ffffffffc0206628 <stride_dequeue+0x41a>
          r = a->left;
ffffffffc0206e28:	00893783          	ld	a5,8(s2)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0206e2c:	01093883          	ld	a7,16(s2)
ffffffffc0206e30:	f02a                	sd	a0,32(sp)
          r = a->left;
ffffffffc0206e32:	ec3e                	sd	a5,24(sp)
     if (a == NULL) return b;
ffffffffc0206e34:	06088963          	beqz	a7,ffffffffc0206ea6 <stride_dequeue+0xc98>
     if (comp(a, b) == -1)
ffffffffc0206e38:	8546                	mv	a0,a7
ffffffffc0206e3a:	85e6                	mv	a1,s9
ffffffffc0206e3c:	f446                	sd	a7,40(sp)
ffffffffc0206e3e:	97aff0ef          	jal	ra,ffffffffc0205fb8 <proc_stride_comp_f>
ffffffffc0206e42:	7802                	ld	a6,32(sp)
ffffffffc0206e44:	78a2                	ld	a7,40(sp)
ffffffffc0206e46:	19050ae3          	beq	a0,a6,ffffffffc02077da <stride_dequeue+0x15cc>
          r = b->left;
ffffffffc0206e4a:	008cb783          	ld	a5,8(s9)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206e4e:	010cb303          	ld	t1,16(s9)
ffffffffc0206e52:	f442                	sd	a6,40(sp)
          r = b->left;
ffffffffc0206e54:	f03e                	sd	a5,32(sp)
     else if (b == NULL) return a;
ffffffffc0206e56:	4a030fe3          	beqz	t1,ffffffffc0207b14 <stride_dequeue+0x1906>
     if (comp(a, b) == -1)
ffffffffc0206e5a:	859a                	mv	a1,t1
ffffffffc0206e5c:	8546                	mv	a0,a7
ffffffffc0206e5e:	fc1a                	sd	t1,56(sp)
ffffffffc0206e60:	f846                	sd	a7,48(sp)
ffffffffc0206e62:	956ff0ef          	jal	ra,ffffffffc0205fb8 <proc_stride_comp_f>
ffffffffc0206e66:	7822                	ld	a6,40(sp)
ffffffffc0206e68:	78c2                	ld	a7,48(sp)
ffffffffc0206e6a:	7362                	ld	t1,56(sp)
ffffffffc0206e6c:	01051463          	bne	a0,a6,ffffffffc0206e74 <stride_dequeue+0xc66>
ffffffffc0206e70:	1140106f          	j	ffffffffc0207f84 <stride_dequeue+0x1d76>
          r = b->left;
ffffffffc0206e74:	00833803          	ld	a6,8(t1)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206e78:	01033583          	ld	a1,16(t1)
ffffffffc0206e7c:	8546                	mv	a0,a7
          r = b->left;
ffffffffc0206e7e:	f81a                	sd	t1,48(sp)
ffffffffc0206e80:	f442                	sd	a6,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206e82:	992ff0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          b->left = l;
ffffffffc0206e86:	7342                	ld	t1,48(sp)
          b->right = r;
ffffffffc0206e88:	7822                	ld	a6,40(sp)
          b->left = l;
ffffffffc0206e8a:	00a33423          	sd	a0,8(t1)
          b->right = r;
ffffffffc0206e8e:	01033823          	sd	a6,16(t1)
          if (l) l->parent = b;
ffffffffc0206e92:	c119                	beqz	a0,ffffffffc0206e98 <stride_dequeue+0xc8a>
ffffffffc0206e94:	00653023          	sd	t1,0(a0)
          b->right = r;
ffffffffc0206e98:	7782                	ld	a5,32(sp)
          b->left = l;
ffffffffc0206e9a:	006cb423          	sd	t1,8(s9)
          b->right = r;
ffffffffc0206e9e:	00fcb823          	sd	a5,16(s9)
          if (l) l->parent = b;
ffffffffc0206ea2:	01933023          	sd	s9,0(t1)
          a->right = r;
ffffffffc0206ea6:	67e2                	ld	a5,24(sp)
          a->left = l;
ffffffffc0206ea8:	01993423          	sd	s9,8(s2)
          a->right = r;
ffffffffc0206eac:	00f93823          	sd	a5,16(s2)
          if (l) l->parent = a;
ffffffffc0206eb0:	012cb023          	sd	s2,0(s9)
ffffffffc0206eb4:	c9eff06f          	j	ffffffffc0206352 <stride_dequeue+0x144>
          r = a->left;
ffffffffc0206eb8:	008b3783          	ld	a5,8(s6)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0206ebc:	010b3c83          	ld	s9,16(s6)
          r = a->left;
ffffffffc0206ec0:	e83e                	sd	a5,16(sp)
     if (a == NULL) return b;
ffffffffc0206ec2:	0a0c8563          	beqz	s9,ffffffffc0206f6c <stride_dequeue+0xd5e>
     if (comp(a, b) == -1)
ffffffffc0206ec6:	85ea                	mv	a1,s10
ffffffffc0206ec8:	8566                	mv	a0,s9
ffffffffc0206eca:	8eeff0ef          	jal	ra,ffffffffc0205fb8 <proc_stride_comp_f>
ffffffffc0206ece:	537d                	li	t1,-1
ffffffffc0206ed0:	2e650ae3          	beq	a0,t1,ffffffffc02079c4 <stride_dequeue+0x17b6>
          r = b->left;
ffffffffc0206ed4:	008d3783          	ld	a5,8(s10)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206ed8:	010d3803          	ld	a6,16(s10)
          r = b->left;
ffffffffc0206edc:	ec3e                	sd	a5,24(sp)
     else if (b == NULL) return a;
ffffffffc0206ede:	08080063          	beqz	a6,ffffffffc0206f5e <stride_dequeue+0xd50>
     if (comp(a, b) == -1)
ffffffffc0206ee2:	85c2                	mv	a1,a6
ffffffffc0206ee4:	8566                	mv	a0,s9
ffffffffc0206ee6:	f042                	sd	a6,32(sp)
ffffffffc0206ee8:	8d0ff0ef          	jal	ra,ffffffffc0205fb8 <proc_stride_comp_f>
ffffffffc0206eec:	537d                	li	t1,-1
ffffffffc0206eee:	7802                	ld	a6,32(sp)
ffffffffc0206ef0:	00651463          	bne	a0,t1,ffffffffc0206ef8 <stride_dequeue+0xcea>
ffffffffc0206ef4:	2a60106f          	j	ffffffffc020819a <stride_dequeue+0x1f8c>
          r = b->left;
ffffffffc0206ef8:	00883783          	ld	a5,8(a6)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206efc:	01083883          	ld	a7,16(a6)
          r = b->left;
ffffffffc0206f00:	f03e                	sd	a5,32(sp)
     else if (b == NULL) return a;
ffffffffc0206f02:	04088663          	beqz	a7,ffffffffc0206f4e <stride_dequeue+0xd40>
     if (comp(a, b) == -1)
ffffffffc0206f06:	85c6                	mv	a1,a7
ffffffffc0206f08:	8566                	mv	a0,s9
ffffffffc0206f0a:	f842                	sd	a6,48(sp)
ffffffffc0206f0c:	f446                	sd	a7,40(sp)
ffffffffc0206f0e:	8aaff0ef          	jal	ra,ffffffffc0205fb8 <proc_stride_comp_f>
ffffffffc0206f12:	537d                	li	t1,-1
ffffffffc0206f14:	78a2                	ld	a7,40(sp)
ffffffffc0206f16:	7842                	ld	a6,48(sp)
ffffffffc0206f18:	00651463          	bne	a0,t1,ffffffffc0206f20 <stride_dequeue+0xd12>
ffffffffc0206f1c:	02b0106f          	j	ffffffffc0208746 <stride_dequeue+0x2538>
          r = b->left;
ffffffffc0206f20:	0088b303          	ld	t1,8(a7)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206f24:	0108b583          	ld	a1,16(a7)
ffffffffc0206f28:	8566                	mv	a0,s9
ffffffffc0206f2a:	fc42                	sd	a6,56(sp)
          r = b->left;
ffffffffc0206f2c:	f846                	sd	a7,48(sp)
ffffffffc0206f2e:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206f30:	8e4ff0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          b->left = l;
ffffffffc0206f34:	78c2                	ld	a7,48(sp)
          b->right = r;
ffffffffc0206f36:	7322                	ld	t1,40(sp)
          if (l) l->parent = b;
ffffffffc0206f38:	7862                	ld	a6,56(sp)
          b->left = l;
ffffffffc0206f3a:	00a8b423          	sd	a0,8(a7)
          b->right = r;
ffffffffc0206f3e:	0068b823          	sd	t1,16(a7)
          if (l) l->parent = b;
ffffffffc0206f42:	e119                	bnez	a0,ffffffffc0206f48 <stride_dequeue+0xd3a>
ffffffffc0206f44:	2130106f          	j	ffffffffc0208956 <stride_dequeue+0x2748>
ffffffffc0206f48:	01153023          	sd	a7,0(a0)
ffffffffc0206f4c:	8cc6                	mv	s9,a7
          b->right = r;
ffffffffc0206f4e:	7782                	ld	a5,32(sp)
          b->left = l;
ffffffffc0206f50:	01983423          	sd	s9,8(a6)
          b->right = r;
ffffffffc0206f54:	00f83823          	sd	a5,16(a6)
          if (l) l->parent = b;
ffffffffc0206f58:	010cb023          	sd	a6,0(s9)
ffffffffc0206f5c:	8cc2                	mv	s9,a6
          b->right = r;
ffffffffc0206f5e:	67e2                	ld	a5,24(sp)
          b->left = l;
ffffffffc0206f60:	019d3423          	sd	s9,8(s10)
          b->right = r;
ffffffffc0206f64:	00fd3823          	sd	a5,16(s10)
          if (l) l->parent = b;
ffffffffc0206f68:	01acb023          	sd	s10,0(s9)
          a->right = r;
ffffffffc0206f6c:	67c2                	ld	a5,16(sp)
          a->left = l;
ffffffffc0206f6e:	01ab3423          	sd	s10,8(s6)
          a->right = r;
ffffffffc0206f72:	00fb3823          	sd	a5,16(s6)
          if (l) l->parent = a;
ffffffffc0206f76:	016d3023          	sd	s6,0(s10)
ffffffffc0206f7a:	8d5a                	mv	s10,s6
ffffffffc0206f7c:	b0d1                	j	ffffffffc0206840 <stride_dequeue+0x632>
          r = a->left;
ffffffffc0206f7e:	008d3783          	ld	a5,8(s10)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0206f82:	010d3c83          	ld	s9,16(s10)
          r = a->left;
ffffffffc0206f86:	e83e                	sd	a5,16(sp)
     if (a == NULL) return b;
ffffffffc0206f88:	0a0c8563          	beqz	s9,ffffffffc0207032 <stride_dequeue+0xe24>
     if (comp(a, b) == -1)
ffffffffc0206f8c:	85ee                	mv	a1,s11
ffffffffc0206f8e:	8566                	mv	a0,s9
ffffffffc0206f90:	828ff0ef          	jal	ra,ffffffffc0205fb8 <proc_stride_comp_f>
ffffffffc0206f94:	537d                	li	t1,-1
ffffffffc0206f96:	2c650be3          	beq	a0,t1,ffffffffc0207a6c <stride_dequeue+0x185e>
          r = b->left;
ffffffffc0206f9a:	008db783          	ld	a5,8(s11)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206f9e:	010db803          	ld	a6,16(s11)
          r = b->left;
ffffffffc0206fa2:	ec3e                	sd	a5,24(sp)
     else if (b == NULL) return a;
ffffffffc0206fa4:	08080063          	beqz	a6,ffffffffc0207024 <stride_dequeue+0xe16>
     if (comp(a, b) == -1)
ffffffffc0206fa8:	85c2                	mv	a1,a6
ffffffffc0206faa:	8566                	mv	a0,s9
ffffffffc0206fac:	f042                	sd	a6,32(sp)
ffffffffc0206fae:	80aff0ef          	jal	ra,ffffffffc0205fb8 <proc_stride_comp_f>
ffffffffc0206fb2:	537d                	li	t1,-1
ffffffffc0206fb4:	7802                	ld	a6,32(sp)
ffffffffc0206fb6:	00651463          	bne	a0,t1,ffffffffc0206fbe <stride_dequeue+0xdb0>
ffffffffc0206fba:	3a40106f          	j	ffffffffc020835e <stride_dequeue+0x2150>
          r = b->left;
ffffffffc0206fbe:	00883783          	ld	a5,8(a6)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206fc2:	01083883          	ld	a7,16(a6)
          r = b->left;
ffffffffc0206fc6:	f03e                	sd	a5,32(sp)
     else if (b == NULL) return a;
ffffffffc0206fc8:	04088663          	beqz	a7,ffffffffc0207014 <stride_dequeue+0xe06>
     if (comp(a, b) == -1)
ffffffffc0206fcc:	85c6                	mv	a1,a7
ffffffffc0206fce:	8566                	mv	a0,s9
ffffffffc0206fd0:	f842                	sd	a6,48(sp)
ffffffffc0206fd2:	f446                	sd	a7,40(sp)
ffffffffc0206fd4:	fe5fe0ef          	jal	ra,ffffffffc0205fb8 <proc_stride_comp_f>
ffffffffc0206fd8:	537d                	li	t1,-1
ffffffffc0206fda:	78a2                	ld	a7,40(sp)
ffffffffc0206fdc:	7842                	ld	a6,48(sp)
ffffffffc0206fde:	00651463          	bne	a0,t1,ffffffffc0206fe6 <stride_dequeue+0xdd8>
ffffffffc0206fe2:	6da0106f          	j	ffffffffc02086bc <stride_dequeue+0x24ae>
          r = b->left;
ffffffffc0206fe6:	0088b303          	ld	t1,8(a7)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206fea:	0108b583          	ld	a1,16(a7)
ffffffffc0206fee:	8566                	mv	a0,s9
ffffffffc0206ff0:	fc42                	sd	a6,56(sp)
          r = b->left;
ffffffffc0206ff2:	f846                	sd	a7,48(sp)
ffffffffc0206ff4:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0206ff6:	81eff0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          b->left = l;
ffffffffc0206ffa:	78c2                	ld	a7,48(sp)
          b->right = r;
ffffffffc0206ffc:	7322                	ld	t1,40(sp)
          if (l) l->parent = b;
ffffffffc0206ffe:	7862                	ld	a6,56(sp)
          b->left = l;
ffffffffc0207000:	00a8b423          	sd	a0,8(a7)
          b->right = r;
ffffffffc0207004:	0068b823          	sd	t1,16(a7)
          if (l) l->parent = b;
ffffffffc0207008:	e119                	bnez	a0,ffffffffc020700e <stride_dequeue+0xe00>
ffffffffc020700a:	11d0106f          	j	ffffffffc0208926 <stride_dequeue+0x2718>
ffffffffc020700e:	01153023          	sd	a7,0(a0)
ffffffffc0207012:	8cc6                	mv	s9,a7
          b->right = r;
ffffffffc0207014:	7782                	ld	a5,32(sp)
          b->left = l;
ffffffffc0207016:	01983423          	sd	s9,8(a6)
          b->right = r;
ffffffffc020701a:	00f83823          	sd	a5,16(a6)
          if (l) l->parent = b;
ffffffffc020701e:	010cb023          	sd	a6,0(s9)
ffffffffc0207022:	8cc2                	mv	s9,a6
          b->right = r;
ffffffffc0207024:	67e2                	ld	a5,24(sp)
          b->left = l;
ffffffffc0207026:	019db423          	sd	s9,8(s11)
          b->right = r;
ffffffffc020702a:	00fdb823          	sd	a5,16(s11)
          if (l) l->parent = b;
ffffffffc020702e:	01bcb023          	sd	s11,0(s9)
          a->right = r;
ffffffffc0207032:	67c2                	ld	a5,16(sp)
          a->left = l;
ffffffffc0207034:	01bd3423          	sd	s11,8(s10)
          a->right = r;
ffffffffc0207038:	00fd3823          	sd	a5,16(s10)
          if (l) l->parent = a;
ffffffffc020703c:	01adb023          	sd	s10,0(s11)
ffffffffc0207040:	8dea                	mv	s11,s10
ffffffffc0207042:	b0fd                	j	ffffffffc0206930 <stride_dequeue+0x722>
          r = a->left;
ffffffffc0207044:	008c3783          	ld	a5,8(s8)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0207048:	010c3c83          	ld	s9,16(s8)
          r = a->left;
ffffffffc020704c:	e83e                	sd	a5,16(sp)
     if (a == NULL) return b;
ffffffffc020704e:	0a0c8563          	beqz	s9,ffffffffc02070f8 <stride_dequeue+0xeea>
     if (comp(a, b) == -1)
ffffffffc0207052:	85ea                	mv	a1,s10
ffffffffc0207054:	8566                	mv	a0,s9
ffffffffc0207056:	f63fe0ef          	jal	ra,ffffffffc0205fb8 <proc_stride_comp_f>
ffffffffc020705a:	537d                	li	t1,-1
ffffffffc020705c:	266502e3          	beq	a0,t1,ffffffffc0207ac0 <stride_dequeue+0x18b2>
          r = b->left;
ffffffffc0207060:	008d3783          	ld	a5,8(s10)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207064:	010d3803          	ld	a6,16(s10)
          r = b->left;
ffffffffc0207068:	ec3e                	sd	a5,24(sp)
     else if (b == NULL) return a;
ffffffffc020706a:	08080063          	beqz	a6,ffffffffc02070ea <stride_dequeue+0xedc>
     if (comp(a, b) == -1)
ffffffffc020706e:	85c2                	mv	a1,a6
ffffffffc0207070:	8566                	mv	a0,s9
ffffffffc0207072:	f042                	sd	a6,32(sp)
ffffffffc0207074:	f45fe0ef          	jal	ra,ffffffffc0205fb8 <proc_stride_comp_f>
ffffffffc0207078:	537d                	li	t1,-1
ffffffffc020707a:	7802                	ld	a6,32(sp)
ffffffffc020707c:	00651463          	bne	a0,t1,ffffffffc0207084 <stride_dequeue+0xe76>
ffffffffc0207080:	23c0106f          	j	ffffffffc02082bc <stride_dequeue+0x20ae>
          r = b->left;
ffffffffc0207084:	00883783          	ld	a5,8(a6)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207088:	01083883          	ld	a7,16(a6)
          r = b->left;
ffffffffc020708c:	f03e                	sd	a5,32(sp)
     else if (b == NULL) return a;
ffffffffc020708e:	04088663          	beqz	a7,ffffffffc02070da <stride_dequeue+0xecc>
     if (comp(a, b) == -1)
ffffffffc0207092:	85c6                	mv	a1,a7
ffffffffc0207094:	8566                	mv	a0,s9
ffffffffc0207096:	f842                	sd	a6,48(sp)
ffffffffc0207098:	f446                	sd	a7,40(sp)
ffffffffc020709a:	f1ffe0ef          	jal	ra,ffffffffc0205fb8 <proc_stride_comp_f>
ffffffffc020709e:	537d                	li	t1,-1
ffffffffc02070a0:	78a2                	ld	a7,40(sp)
ffffffffc02070a2:	7842                	ld	a6,48(sp)
ffffffffc02070a4:	00651463          	bne	a0,t1,ffffffffc02070ac <stride_dequeue+0xe9e>
ffffffffc02070a8:	50a0106f          	j	ffffffffc02085b2 <stride_dequeue+0x23a4>
          r = b->left;
ffffffffc02070ac:	0088b303          	ld	t1,8(a7)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02070b0:	0108b583          	ld	a1,16(a7)
ffffffffc02070b4:	8566                	mv	a0,s9
ffffffffc02070b6:	fc42                	sd	a6,56(sp)
          r = b->left;
ffffffffc02070b8:	f846                	sd	a7,48(sp)
ffffffffc02070ba:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02070bc:	f59fe0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          b->left = l;
ffffffffc02070c0:	78c2                	ld	a7,48(sp)
          b->right = r;
ffffffffc02070c2:	7322                	ld	t1,40(sp)
          if (l) l->parent = b;
ffffffffc02070c4:	7862                	ld	a6,56(sp)
          b->left = l;
ffffffffc02070c6:	00a8b423          	sd	a0,8(a7)
          b->right = r;
ffffffffc02070ca:	0068b823          	sd	t1,16(a7)
          if (l) l->parent = b;
ffffffffc02070ce:	e119                	bnez	a0,ffffffffc02070d4 <stride_dequeue+0xec6>
ffffffffc02070d0:	0330106f          	j	ffffffffc0208902 <stride_dequeue+0x26f4>
ffffffffc02070d4:	01153023          	sd	a7,0(a0)
ffffffffc02070d8:	8cc6                	mv	s9,a7
          b->right = r;
ffffffffc02070da:	7782                	ld	a5,32(sp)
          b->left = l;
ffffffffc02070dc:	01983423          	sd	s9,8(a6)
          b->right = r;
ffffffffc02070e0:	00f83823          	sd	a5,16(a6)
          if (l) l->parent = b;
ffffffffc02070e4:	010cb023          	sd	a6,0(s9)
ffffffffc02070e8:	8cc2                	mv	s9,a6
          b->right = r;
ffffffffc02070ea:	67e2                	ld	a5,24(sp)
          b->left = l;
ffffffffc02070ec:	019d3423          	sd	s9,8(s10)
          b->right = r;
ffffffffc02070f0:	00fd3823          	sd	a5,16(s10)
          if (l) l->parent = b;
ffffffffc02070f4:	01acb023          	sd	s10,0(s9)
          a->right = r;
ffffffffc02070f8:	67c2                	ld	a5,16(sp)
          a->left = l;
ffffffffc02070fa:	01ac3423          	sd	s10,8(s8)
          a->right = r;
ffffffffc02070fe:	00fc3823          	sd	a5,16(s8)
          if (l) l->parent = a;
ffffffffc0207102:	018d3023          	sd	s8,0(s10)
ffffffffc0207106:	e3aff06f          	j	ffffffffc0206740 <stride_dequeue+0x532>
          r = a->left;
ffffffffc020710a:	008db783          	ld	a5,8(s11)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc020710e:	010db883          	ld	a7,16(s11)
ffffffffc0207112:	f02a                	sd	a0,32(sp)
          r = a->left;
ffffffffc0207114:	ec3e                	sd	a5,24(sp)
     if (a == NULL) return b;
ffffffffc0207116:	06088c63          	beqz	a7,ffffffffc020718e <stride_dequeue+0xf80>
     if (comp(a, b) == -1)
ffffffffc020711a:	8546                	mv	a0,a7
ffffffffc020711c:	85da                	mv	a1,s6
ffffffffc020711e:	f446                	sd	a7,40(sp)
ffffffffc0207120:	e99fe0ef          	jal	ra,ffffffffc0205fb8 <proc_stride_comp_f>
ffffffffc0207124:	7802                	ld	a6,32(sp)
ffffffffc0207126:	78a2                	ld	a7,40(sp)
ffffffffc0207128:	4f0507e3          	beq	a0,a6,ffffffffc0207e16 <stride_dequeue+0x1c08>
          r = b->left;
ffffffffc020712c:	008b3783          	ld	a5,8(s6)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207130:	010b3303          	ld	t1,16(s6)
ffffffffc0207134:	f442                	sd	a6,40(sp)
          r = b->left;
ffffffffc0207136:	f03e                	sd	a5,32(sp)
     else if (b == NULL) return a;
ffffffffc0207138:	04030463          	beqz	t1,ffffffffc0207180 <stride_dequeue+0xf72>
     if (comp(a, b) == -1)
ffffffffc020713c:	859a                	mv	a1,t1
ffffffffc020713e:	8546                	mv	a0,a7
ffffffffc0207140:	fc1a                	sd	t1,56(sp)
ffffffffc0207142:	f846                	sd	a7,48(sp)
ffffffffc0207144:	e75fe0ef          	jal	ra,ffffffffc0205fb8 <proc_stride_comp_f>
ffffffffc0207148:	7822                	ld	a6,40(sp)
ffffffffc020714a:	78c2                	ld	a7,48(sp)
ffffffffc020714c:	7362                	ld	t1,56(sp)
ffffffffc020714e:	01051463          	bne	a0,a6,ffffffffc0207156 <stride_dequeue+0xf48>
ffffffffc0207152:	2340106f          	j	ffffffffc0208386 <stride_dequeue+0x2178>
          r = b->left;
ffffffffc0207156:	00833803          	ld	a6,8(t1)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc020715a:	01033583          	ld	a1,16(t1)
ffffffffc020715e:	8546                	mv	a0,a7
          r = b->left;
ffffffffc0207160:	f81a                	sd	t1,48(sp)
ffffffffc0207162:	f442                	sd	a6,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207164:	eb1fe0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          b->left = l;
ffffffffc0207168:	7342                	ld	t1,48(sp)
          b->right = r;
ffffffffc020716a:	7822                	ld	a6,40(sp)
          b->left = l;
ffffffffc020716c:	00a33423          	sd	a0,8(t1)
          b->right = r;
ffffffffc0207170:	01033823          	sd	a6,16(t1)
          if (l) l->parent = b;
ffffffffc0207174:	e119                	bnez	a0,ffffffffc020717a <stride_dequeue+0xf6c>
ffffffffc0207176:	2dc0106f          	j	ffffffffc0208452 <stride_dequeue+0x2244>
ffffffffc020717a:	00653023          	sd	t1,0(a0)
ffffffffc020717e:	889a                	mv	a7,t1
          b->right = r;
ffffffffc0207180:	7782                	ld	a5,32(sp)
          b->left = l;
ffffffffc0207182:	011b3423          	sd	a7,8(s6)
          b->right = r;
ffffffffc0207186:	00fb3823          	sd	a5,16(s6)
          if (l) l->parent = b;
ffffffffc020718a:	0168b023          	sd	s6,0(a7)
          a->right = r;
ffffffffc020718e:	67e2                	ld	a5,24(sp)
          a->left = l;
ffffffffc0207190:	016db423          	sd	s6,8(s11)
          a->right = r;
ffffffffc0207194:	00fdb823          	sd	a5,16(s11)
          if (l) l->parent = a;
ffffffffc0207198:	01bb3023          	sd	s11,0(s6)
ffffffffc020719c:	b48ff06f          	j	ffffffffc02064e4 <stride_dequeue+0x2d6>
          r = a->left;
ffffffffc02071a0:	008c3783          	ld	a5,8(s8)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02071a4:	010c3883          	ld	a7,16(s8)
ffffffffc02071a8:	f02a                	sd	a0,32(sp)
          r = a->left;
ffffffffc02071aa:	ec3e                	sd	a5,24(sp)
     if (a == NULL) return b;
ffffffffc02071ac:	06088c63          	beqz	a7,ffffffffc0207224 <stride_dequeue+0x1016>
     if (comp(a, b) == -1)
ffffffffc02071b0:	8546                	mv	a0,a7
ffffffffc02071b2:	85ea                	mv	a1,s10
ffffffffc02071b4:	f446                	sd	a7,40(sp)
ffffffffc02071b6:	e03fe0ef          	jal	ra,ffffffffc0205fb8 <proc_stride_comp_f>
ffffffffc02071ba:	7802                	ld	a6,32(sp)
ffffffffc02071bc:	78a2                	ld	a7,40(sp)
ffffffffc02071be:	4d0501e3          	beq	a0,a6,ffffffffc0207e80 <stride_dequeue+0x1c72>
          r = b->left;
ffffffffc02071c2:	008d3783          	ld	a5,8(s10)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02071c6:	010d3303          	ld	t1,16(s10)
ffffffffc02071ca:	f442                	sd	a6,40(sp)
          r = b->left;
ffffffffc02071cc:	f03e                	sd	a5,32(sp)
     else if (b == NULL) return a;
ffffffffc02071ce:	04030463          	beqz	t1,ffffffffc0207216 <stride_dequeue+0x1008>
     if (comp(a, b) == -1)
ffffffffc02071d2:	859a                	mv	a1,t1
ffffffffc02071d4:	8546                	mv	a0,a7
ffffffffc02071d6:	fc1a                	sd	t1,56(sp)
ffffffffc02071d8:	f846                	sd	a7,48(sp)
ffffffffc02071da:	ddffe0ef          	jal	ra,ffffffffc0205fb8 <proc_stride_comp_f>
ffffffffc02071de:	7822                	ld	a6,40(sp)
ffffffffc02071e0:	78c2                	ld	a7,48(sp)
ffffffffc02071e2:	7362                	ld	t1,56(sp)
ffffffffc02071e4:	01051463          	bne	a0,a6,ffffffffc02071ec <stride_dequeue+0xfde>
ffffffffc02071e8:	1c80106f          	j	ffffffffc02083b0 <stride_dequeue+0x21a2>
          r = b->left;
ffffffffc02071ec:	00833803          	ld	a6,8(t1)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02071f0:	01033583          	ld	a1,16(t1)
ffffffffc02071f4:	8546                	mv	a0,a7
          r = b->left;
ffffffffc02071f6:	f81a                	sd	t1,48(sp)
ffffffffc02071f8:	f442                	sd	a6,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02071fa:	e1bfe0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          b->left = l;
ffffffffc02071fe:	7342                	ld	t1,48(sp)
          b->right = r;
ffffffffc0207200:	7822                	ld	a6,40(sp)
          b->left = l;
ffffffffc0207202:	00a33423          	sd	a0,8(t1)
          b->right = r;
ffffffffc0207206:	01033823          	sd	a6,16(t1)
          if (l) l->parent = b;
ffffffffc020720a:	e119                	bnez	a0,ffffffffc0207210 <stride_dequeue+0x1002>
ffffffffc020720c:	24c0106f          	j	ffffffffc0208458 <stride_dequeue+0x224a>
ffffffffc0207210:	00653023          	sd	t1,0(a0)
ffffffffc0207214:	889a                	mv	a7,t1
          b->right = r;
ffffffffc0207216:	7782                	ld	a5,32(sp)
          b->left = l;
ffffffffc0207218:	011d3423          	sd	a7,8(s10)
          b->right = r;
ffffffffc020721c:	00fd3823          	sd	a5,16(s10)
          if (l) l->parent = b;
ffffffffc0207220:	01a8b023          	sd	s10,0(a7)
          a->right = r;
ffffffffc0207224:	67e2                	ld	a5,24(sp)
          a->left = l;
ffffffffc0207226:	01ac3423          	sd	s10,8(s8)
          a->right = r;
ffffffffc020722a:	00fc3823          	sd	a5,16(s8)
          if (l) l->parent = a;
ffffffffc020722e:	018d3023          	sd	s8,0(s10)
ffffffffc0207232:	be6ff06f          	j	ffffffffc0206618 <stride_dequeue+0x40a>
          r = a->left;
ffffffffc0207236:	008cb783          	ld	a5,8(s9)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc020723a:	010cb883          	ld	a7,16(s9)
ffffffffc020723e:	f02a                	sd	a0,32(sp)
          r = a->left;
ffffffffc0207240:	ec3e                	sd	a5,24(sp)
     if (a == NULL) return b;
ffffffffc0207242:	06088a63          	beqz	a7,ffffffffc02072b6 <stride_dequeue+0x10a8>
     if (comp(a, b) == -1)
ffffffffc0207246:	8546                	mv	a0,a7
ffffffffc0207248:	85ea                	mv	a1,s10
ffffffffc020724a:	f446                	sd	a7,40(sp)
ffffffffc020724c:	d6dfe0ef          	jal	ra,ffffffffc0205fb8 <proc_stride_comp_f>
ffffffffc0207250:	7802                	ld	a6,32(sp)
ffffffffc0207252:	78a2                	ld	a7,40(sp)
ffffffffc0207254:	1f0500e3          	beq	a0,a6,ffffffffc0207c34 <stride_dequeue+0x1a26>
          r = b->left;
ffffffffc0207258:	008d3783          	ld	a5,8(s10)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc020725c:	010d3303          	ld	t1,16(s10)
ffffffffc0207260:	f442                	sd	a6,40(sp)
          r = b->left;
ffffffffc0207262:	f03e                	sd	a5,32(sp)
     else if (b == NULL) return a;
ffffffffc0207264:	04030263          	beqz	t1,ffffffffc02072a8 <stride_dequeue+0x109a>
     if (comp(a, b) == -1)
ffffffffc0207268:	859a                	mv	a1,t1
ffffffffc020726a:	8546                	mv	a0,a7
ffffffffc020726c:	fc1a                	sd	t1,56(sp)
ffffffffc020726e:	f846                	sd	a7,48(sp)
ffffffffc0207270:	d49fe0ef          	jal	ra,ffffffffc0205fb8 <proc_stride_comp_f>
ffffffffc0207274:	7822                	ld	a6,40(sp)
ffffffffc0207276:	78c2                	ld	a7,48(sp)
ffffffffc0207278:	7362                	ld	t1,56(sp)
ffffffffc020727a:	5b0504e3          	beq	a0,a6,ffffffffc0208022 <stride_dequeue+0x1e14>
          r = b->left;
ffffffffc020727e:	00833803          	ld	a6,8(t1)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207282:	01033583          	ld	a1,16(t1)
ffffffffc0207286:	8546                	mv	a0,a7
          r = b->left;
ffffffffc0207288:	f81a                	sd	t1,48(sp)
ffffffffc020728a:	f442                	sd	a6,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc020728c:	d89fe0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          b->left = l;
ffffffffc0207290:	7342                	ld	t1,48(sp)
          b->right = r;
ffffffffc0207292:	7822                	ld	a6,40(sp)
          b->left = l;
ffffffffc0207294:	00a33423          	sd	a0,8(t1)
          b->right = r;
ffffffffc0207298:	01033823          	sd	a6,16(t1)
          if (l) l->parent = b;
ffffffffc020729c:	e119                	bnez	a0,ffffffffc02072a2 <stride_dequeue+0x1094>
ffffffffc020729e:	27e0106f          	j	ffffffffc020851c <stride_dequeue+0x230e>
ffffffffc02072a2:	00653023          	sd	t1,0(a0)
ffffffffc02072a6:	889a                	mv	a7,t1
          b->right = r;
ffffffffc02072a8:	7782                	ld	a5,32(sp)
          b->left = l;
ffffffffc02072aa:	011d3423          	sd	a7,8(s10)
          b->right = r;
ffffffffc02072ae:	00fd3823          	sd	a5,16(s10)
          if (l) l->parent = b;
ffffffffc02072b2:	01a8b023          	sd	s10,0(a7)
          a->right = r;
ffffffffc02072b6:	67e2                	ld	a5,24(sp)
          a->left = l;
ffffffffc02072b8:	01acb423          	sd	s10,8(s9)
          a->right = r;
ffffffffc02072bc:	00fcb823          	sd	a5,16(s9)
          if (l) l->parent = a;
ffffffffc02072c0:	019d3023          	sd	s9,0(s10)
ffffffffc02072c4:	805ff06f          	j	ffffffffc0206ac8 <stride_dequeue+0x8ba>
          r = a->left;
ffffffffc02072c8:	008cb783          	ld	a5,8(s9)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02072cc:	010cb883          	ld	a7,16(s9)
ffffffffc02072d0:	f02a                	sd	a0,32(sp)
          r = a->left;
ffffffffc02072d2:	ec3e                	sd	a5,24(sp)
     if (a == NULL) return b;
ffffffffc02072d4:	06088c63          	beqz	a7,ffffffffc020734c <stride_dequeue+0x113e>
     if (comp(a, b) == -1)
ffffffffc02072d8:	8546                	mv	a0,a7
ffffffffc02072da:	85ea                	mv	a1,s10
ffffffffc02072dc:	f446                	sd	a7,40(sp)
ffffffffc02072de:	cdbfe0ef          	jal	ra,ffffffffc0205fb8 <proc_stride_comp_f>
ffffffffc02072e2:	7802                	ld	a6,32(sp)
ffffffffc02072e4:	78a2                	ld	a7,40(sp)
ffffffffc02072e6:	090509e3          	beq	a0,a6,ffffffffc0207b78 <stride_dequeue+0x196a>
          r = b->left;
ffffffffc02072ea:	008d3783          	ld	a5,8(s10)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02072ee:	010d3303          	ld	t1,16(s10)
ffffffffc02072f2:	f442                	sd	a6,40(sp)
          r = b->left;
ffffffffc02072f4:	f03e                	sd	a5,32(sp)
     else if (b == NULL) return a;
ffffffffc02072f6:	04030463          	beqz	t1,ffffffffc020733e <stride_dequeue+0x1130>
     if (comp(a, b) == -1)
ffffffffc02072fa:	859a                	mv	a1,t1
ffffffffc02072fc:	8546                	mv	a0,a7
ffffffffc02072fe:	fc1a                	sd	t1,56(sp)
ffffffffc0207300:	f846                	sd	a7,48(sp)
ffffffffc0207302:	cb7fe0ef          	jal	ra,ffffffffc0205fb8 <proc_stride_comp_f>
ffffffffc0207306:	7822                	ld	a6,40(sp)
ffffffffc0207308:	78c2                	ld	a7,48(sp)
ffffffffc020730a:	7362                	ld	t1,56(sp)
ffffffffc020730c:	01051463          	bne	a0,a6,ffffffffc0207314 <stride_dequeue+0x1106>
ffffffffc0207310:	0f40106f          	j	ffffffffc0208404 <stride_dequeue+0x21f6>
          r = b->left;
ffffffffc0207314:	00833803          	ld	a6,8(t1)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207318:	01033583          	ld	a1,16(t1)
ffffffffc020731c:	8546                	mv	a0,a7
          r = b->left;
ffffffffc020731e:	f81a                	sd	t1,48(sp)
ffffffffc0207320:	f442                	sd	a6,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207322:	cf3fe0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          b->left = l;
ffffffffc0207326:	7342                	ld	t1,48(sp)
          b->right = r;
ffffffffc0207328:	7822                	ld	a6,40(sp)
          b->left = l;
ffffffffc020732a:	00a33423          	sd	a0,8(t1)
          b->right = r;
ffffffffc020732e:	01033823          	sd	a6,16(t1)
          if (l) l->parent = b;
ffffffffc0207332:	e119                	bnez	a0,ffffffffc0207338 <stride_dequeue+0x112a>
ffffffffc0207334:	1360106f          	j	ffffffffc020846a <stride_dequeue+0x225c>
ffffffffc0207338:	00653023          	sd	t1,0(a0)
ffffffffc020733c:	889a                	mv	a7,t1
          b->right = r;
ffffffffc020733e:	7782                	ld	a5,32(sp)
          b->left = l;
ffffffffc0207340:	011d3423          	sd	a7,8(s10)
          b->right = r;
ffffffffc0207344:	00fd3823          	sd	a5,16(s10)
          if (l) l->parent = b;
ffffffffc0207348:	01a8b023          	sd	s10,0(a7)
          a->right = r;
ffffffffc020734c:	67e2                	ld	a5,24(sp)
          a->left = l;
ffffffffc020734e:	01acb423          	sd	s10,8(s9)
          a->right = r;
ffffffffc0207352:	00fcb823          	sd	a5,16(s9)
          if (l) l->parent = a;
ffffffffc0207356:	019d3023          	sd	s9,0(s10)
ffffffffc020735a:	8d66                	mv	s10,s9
ffffffffc020735c:	e94ff06f          	j	ffffffffc02069f0 <stride_dequeue+0x7e2>
          r = a->left;
ffffffffc0207360:	00893703          	ld	a4,8(s2)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0207364:	01093883          	ld	a7,16(s2)
ffffffffc0207368:	f42a                	sd	a0,40(sp)
          r = a->left;
ffffffffc020736a:	f03a                	sd	a4,32(sp)
     if (a == NULL) return b;
ffffffffc020736c:	02088c63          	beqz	a7,ffffffffc02073a4 <stride_dequeue+0x1196>
     if (comp(a, b) == -1)
ffffffffc0207370:	85be                	mv	a1,a5
ffffffffc0207372:	8546                	mv	a0,a7
ffffffffc0207374:	fc3e                	sd	a5,56(sp)
ffffffffc0207376:	f846                	sd	a7,48(sp)
ffffffffc0207378:	c41fe0ef          	jal	ra,ffffffffc0205fb8 <proc_stride_comp_f>
ffffffffc020737c:	7322                	ld	t1,40(sp)
ffffffffc020737e:	78c2                	ld	a7,48(sp)
ffffffffc0207380:	77e2                	ld	a5,56(sp)
ffffffffc0207382:	3c650ce3          	beq	a0,t1,ffffffffc0207f5a <stride_dequeue+0x1d4c>
          r = b->left;
ffffffffc0207386:	0087b303          	ld	t1,8(a5)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc020738a:	6b8c                	ld	a1,16(a5)
ffffffffc020738c:	8546                	mv	a0,a7
          r = b->left;
ffffffffc020738e:	f83e                	sd	a5,48(sp)
ffffffffc0207390:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207392:	c83fe0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          b->left = l;
ffffffffc0207396:	77c2                	ld	a5,48(sp)
          b->right = r;
ffffffffc0207398:	7322                	ld	t1,40(sp)
          b->left = l;
ffffffffc020739a:	e788                	sd	a0,8(a5)
          b->right = r;
ffffffffc020739c:	0067b823          	sd	t1,16(a5)
          if (l) l->parent = b;
ffffffffc02073a0:	c111                	beqz	a0,ffffffffc02073a4 <stride_dequeue+0x1196>
ffffffffc02073a2:	e11c                	sd	a5,0(a0)
          a->right = r;
ffffffffc02073a4:	7702                	ld	a4,32(sp)
          a->left = l;
ffffffffc02073a6:	00f93423          	sd	a5,8(s2)
          a->right = r;
ffffffffc02073aa:	00e93823          	sd	a4,16(s2)
          if (l) l->parent = a;
ffffffffc02073ae:	0127b023          	sd	s2,0(a5)
ffffffffc02073b2:	f91fe06f          	j	ffffffffc0206342 <stride_dequeue+0x134>
          r = a->left;
ffffffffc02073b6:	008cb783          	ld	a5,8(s9)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02073ba:	010cbd03          	ld	s10,16(s9)
          r = a->left;
ffffffffc02073be:	e83e                	sd	a5,16(sp)
     if (a == NULL) return b;
ffffffffc02073c0:	520d08e3          	beqz	s10,ffffffffc02080f0 <stride_dequeue+0x1ee2>
     if (comp(a, b) == -1)
ffffffffc02073c4:	85a6                	mv	a1,s1
ffffffffc02073c6:	856a                	mv	a0,s10
ffffffffc02073c8:	bf1fe0ef          	jal	ra,ffffffffc0205fb8 <proc_stride_comp_f>
ffffffffc02073cc:	587d                	li	a6,-1
ffffffffc02073ce:	430507e3          	beq	a0,a6,ffffffffc0207ffc <stride_dequeue+0x1dee>
          r = b->left;
ffffffffc02073d2:	649c                	ld	a5,8(s1)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02073d4:	6890                	ld	a2,16(s1)
          r = b->left;
ffffffffc02073d6:	ec3e                	sd	a5,24(sp)
     else if (b == NULL) return a;
ffffffffc02073d8:	ce15                	beqz	a2,ffffffffc0207414 <stride_dequeue+0x1206>
     if (comp(a, b) == -1)
ffffffffc02073da:	85b2                	mv	a1,a2
ffffffffc02073dc:	856a                	mv	a0,s10
ffffffffc02073de:	f032                	sd	a2,32(sp)
ffffffffc02073e0:	bd9fe0ef          	jal	ra,ffffffffc0205fb8 <proc_stride_comp_f>
ffffffffc02073e4:	587d                	li	a6,-1
ffffffffc02073e6:	7602                	ld	a2,32(sp)
ffffffffc02073e8:	01051463          	bne	a0,a6,ffffffffc02073f0 <stride_dequeue+0x11e2>
ffffffffc02073ec:	0b00106f          	j	ffffffffc020849c <stride_dequeue+0x228e>
          r = b->left;
ffffffffc02073f0:	00863803          	ld	a6,8(a2)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02073f4:	6a0c                	ld	a1,16(a2)
ffffffffc02073f6:	856a                	mv	a0,s10
          r = b->left;
ffffffffc02073f8:	f432                	sd	a2,40(sp)
ffffffffc02073fa:	f042                	sd	a6,32(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02073fc:	c19fe0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          b->left = l;
ffffffffc0207400:	7622                	ld	a2,40(sp)
          b->right = r;
ffffffffc0207402:	7802                	ld	a6,32(sp)
          b->left = l;
ffffffffc0207404:	e608                	sd	a0,8(a2)
          b->right = r;
ffffffffc0207406:	01063823          	sd	a6,16(a2)
          if (l) l->parent = b;
ffffffffc020740a:	e119                	bnez	a0,ffffffffc0207410 <stride_dequeue+0x1202>
ffffffffc020740c:	1a00106f          	j	ffffffffc02085ac <stride_dequeue+0x239e>
ffffffffc0207410:	e110                	sd	a2,0(a0)
ffffffffc0207412:	8d32                	mv	s10,a2
          b->right = r;
ffffffffc0207414:	67e2                	ld	a5,24(sp)
          b->left = l;
ffffffffc0207416:	01a4b423          	sd	s10,8(s1)
          b->right = r;
ffffffffc020741a:	e89c                	sd	a5,16(s1)
          if (l) l->parent = b;
ffffffffc020741c:	009d3023          	sd	s1,0(s10)
ffffffffc0207420:	8d26                	mv	s10,s1
          a->right = r;
ffffffffc0207422:	67c2                	ld	a5,16(sp)
          a->left = l;
ffffffffc0207424:	01acb423          	sd	s10,8(s9)
          if (l) l->parent = a;
ffffffffc0207428:	84e6                	mv	s1,s9
          a->right = r;
ffffffffc020742a:	00fcb823          	sd	a5,16(s9)
          if (l) l->parent = a;
ffffffffc020742e:	019d3023          	sd	s9,0(s10)
ffffffffc0207432:	f90ff06f          	j	ffffffffc0206bc2 <stride_dequeue+0x9b4>
          r = a->left;
ffffffffc0207436:	008d3783          	ld	a5,8(s10)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc020743a:	010d3803          	ld	a6,16(s10)
ffffffffc020743e:	f02a                	sd	a0,32(sp)
          r = a->left;
ffffffffc0207440:	ec3e                	sd	a5,24(sp)
     if (a == NULL) return b;
ffffffffc0207442:	00081463          	bnez	a6,ffffffffc020744a <stride_dequeue+0x123c>
ffffffffc0207446:	7e90006f          	j	ffffffffc020842e <stride_dequeue+0x2220>
     if (comp(a, b) == -1)
ffffffffc020744a:	8542                	mv	a0,a6
ffffffffc020744c:	85e6                	mv	a1,s9
ffffffffc020744e:	f442                	sd	a6,40(sp)
ffffffffc0207450:	b69fe0ef          	jal	ra,ffffffffc0205fb8 <proc_stride_comp_f>
ffffffffc0207454:	7302                	ld	t1,32(sp)
ffffffffc0207456:	7822                	ld	a6,40(sp)
ffffffffc0207458:	00651463          	bne	a0,t1,ffffffffc0207460 <stride_dequeue+0x1252>
ffffffffc020745c:	6db0006f          	j	ffffffffc0208336 <stride_dequeue+0x2128>
          r = b->left;
ffffffffc0207460:	008cb783          	ld	a5,8(s9)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207464:	010cb883          	ld	a7,16(s9)
ffffffffc0207468:	fc1a                	sd	t1,56(sp)
          r = b->left;
ffffffffc020746a:	f03e                	sd	a5,32(sp)
     else if (b == NULL) return a;
ffffffffc020746c:	04088463          	beqz	a7,ffffffffc02074b4 <stride_dequeue+0x12a6>
     if (comp(a, b) == -1)
ffffffffc0207470:	85c6                	mv	a1,a7
ffffffffc0207472:	8542                	mv	a0,a6
ffffffffc0207474:	f846                	sd	a7,48(sp)
ffffffffc0207476:	f442                	sd	a6,40(sp)
ffffffffc0207478:	b41fe0ef          	jal	ra,ffffffffc0205fb8 <proc_stride_comp_f>
ffffffffc020747c:	7362                	ld	t1,56(sp)
ffffffffc020747e:	7822                	ld	a6,40(sp)
ffffffffc0207480:	78c2                	ld	a7,48(sp)
ffffffffc0207482:	00651463          	bne	a0,t1,ffffffffc020748a <stride_dequeue+0x127c>
ffffffffc0207486:	0ce0106f          	j	ffffffffc0208554 <stride_dequeue+0x2346>
          r = b->left;
ffffffffc020748a:	0088b303          	ld	t1,8(a7)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc020748e:	0108b583          	ld	a1,16(a7)
ffffffffc0207492:	8542                	mv	a0,a6
          r = b->left;
ffffffffc0207494:	f846                	sd	a7,48(sp)
ffffffffc0207496:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207498:	b7dfe0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          b->left = l;
ffffffffc020749c:	78c2                	ld	a7,48(sp)
          b->right = r;
ffffffffc020749e:	7322                	ld	t1,40(sp)
          b->left = l;
ffffffffc02074a0:	00a8b423          	sd	a0,8(a7)
          b->right = r;
ffffffffc02074a4:	0068b823          	sd	t1,16(a7)
          if (l) l->parent = b;
ffffffffc02074a8:	e119                	bnez	a0,ffffffffc02074ae <stride_dequeue+0x12a0>
ffffffffc02074aa:	4880106f          	j	ffffffffc0208932 <stride_dequeue+0x2724>
ffffffffc02074ae:	01153023          	sd	a7,0(a0)
ffffffffc02074b2:	8846                	mv	a6,a7
          b->right = r;
ffffffffc02074b4:	7782                	ld	a5,32(sp)
          b->left = l;
ffffffffc02074b6:	010cb423          	sd	a6,8(s9)
          b->right = r;
ffffffffc02074ba:	00fcb823          	sd	a5,16(s9)
          if (l) l->parent = b;
ffffffffc02074be:	01983023          	sd	s9,0(a6)
ffffffffc02074c2:	8866                	mv	a6,s9
          a->right = r;
ffffffffc02074c4:	67e2                	ld	a5,24(sp)
          a->left = l;
ffffffffc02074c6:	010d3423          	sd	a6,8(s10)
          if (l) l->parent = a;
ffffffffc02074ca:	8cea                	mv	s9,s10
          a->right = r;
ffffffffc02074cc:	00fd3823          	sd	a5,16(s10)
          if (l) l->parent = a;
ffffffffc02074d0:	01a83023          	sd	s10,0(a6)
ffffffffc02074d4:	b289                	j	ffffffffc0206e16 <stride_dequeue+0xc08>
          r = a->left;
ffffffffc02074d6:	008c3783          	ld	a5,8(s8)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02074da:	010c3803          	ld	a6,16(s8)
ffffffffc02074de:	f02a                	sd	a0,32(sp)
          r = a->left;
ffffffffc02074e0:	ec3e                	sd	a5,24(sp)
     if (a == NULL) return b;
ffffffffc02074e2:	00081463          	bnez	a6,ffffffffc02074ea <stride_dequeue+0x12dc>
ffffffffc02074e6:	75b0006f          	j	ffffffffc0208440 <stride_dequeue+0x2232>
     if (comp(a, b) == -1)
ffffffffc02074ea:	8542                	mv	a0,a6
ffffffffc02074ec:	85e6                	mv	a1,s9
ffffffffc02074ee:	f442                	sd	a6,40(sp)
ffffffffc02074f0:	ac9fe0ef          	jal	ra,ffffffffc0205fb8 <proc_stride_comp_f>
ffffffffc02074f4:	7302                	ld	t1,32(sp)
ffffffffc02074f6:	7822                	ld	a6,40(sp)
ffffffffc02074f8:	426503e3          	beq	a0,t1,ffffffffc020811e <stride_dequeue+0x1f10>
          r = b->left;
ffffffffc02074fc:	008cb783          	ld	a5,8(s9)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207500:	010cb883          	ld	a7,16(s9)
ffffffffc0207504:	fc1a                	sd	t1,56(sp)
          r = b->left;
ffffffffc0207506:	f03e                	sd	a5,32(sp)
     else if (b == NULL) return a;
ffffffffc0207508:	04088463          	beqz	a7,ffffffffc0207550 <stride_dequeue+0x1342>
     if (comp(a, b) == -1)
ffffffffc020750c:	85c6                	mv	a1,a7
ffffffffc020750e:	8542                	mv	a0,a6
ffffffffc0207510:	f846                	sd	a7,48(sp)
ffffffffc0207512:	f442                	sd	a6,40(sp)
ffffffffc0207514:	aa5fe0ef          	jal	ra,ffffffffc0205fb8 <proc_stride_comp_f>
ffffffffc0207518:	7362                	ld	t1,56(sp)
ffffffffc020751a:	7822                	ld	a6,40(sp)
ffffffffc020751c:	78c2                	ld	a7,48(sp)
ffffffffc020751e:	00651463          	bne	a0,t1,ffffffffc0207526 <stride_dequeue+0x1318>
ffffffffc0207522:	0e60106f          	j	ffffffffc0208608 <stride_dequeue+0x23fa>
          r = b->left;
ffffffffc0207526:	0088b303          	ld	t1,8(a7)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc020752a:	0108b583          	ld	a1,16(a7)
ffffffffc020752e:	8542                	mv	a0,a6
          r = b->left;
ffffffffc0207530:	f846                	sd	a7,48(sp)
ffffffffc0207532:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207534:	ae1fe0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          b->left = l;
ffffffffc0207538:	78c2                	ld	a7,48(sp)
          b->right = r;
ffffffffc020753a:	7322                	ld	t1,40(sp)
          b->left = l;
ffffffffc020753c:	00a8b423          	sd	a0,8(a7)
          b->right = r;
ffffffffc0207540:	0068b823          	sd	t1,16(a7)
          if (l) l->parent = b;
ffffffffc0207544:	e119                	bnez	a0,ffffffffc020754a <stride_dequeue+0x133c>
ffffffffc0207546:	3c80106f          	j	ffffffffc020890e <stride_dequeue+0x2700>
ffffffffc020754a:	01153023          	sd	a7,0(a0)
ffffffffc020754e:	8846                	mv	a6,a7
          b->right = r;
ffffffffc0207550:	7782                	ld	a5,32(sp)
          b->left = l;
ffffffffc0207552:	010cb423          	sd	a6,8(s9)
          b->right = r;
ffffffffc0207556:	00fcb823          	sd	a5,16(s9)
          if (l) l->parent = b;
ffffffffc020755a:	01983023          	sd	s9,0(a6)
ffffffffc020755e:	8866                	mv	a6,s9
          a->right = r;
ffffffffc0207560:	67e2                	ld	a5,24(sp)
          a->left = l;
ffffffffc0207562:	010c3423          	sd	a6,8(s8)
          a->right = r;
ffffffffc0207566:	00fc3823          	sd	a5,16(s8)
          if (l) l->parent = a;
ffffffffc020756a:	01883023          	sd	s8,0(a6)
ffffffffc020756e:	9c2ff06f          	j	ffffffffc0206730 <stride_dequeue+0x522>
          r = a->left;
ffffffffc0207572:	008d3783          	ld	a5,8(s10)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0207576:	010d3803          	ld	a6,16(s10)
ffffffffc020757a:	f02a                	sd	a0,32(sp)
          r = a->left;
ffffffffc020757c:	ec3e                	sd	a5,24(sp)
     if (a == NULL) return b;
ffffffffc020757e:	00081463          	bnez	a6,ffffffffc0207586 <stride_dequeue+0x1378>
ffffffffc0207582:	6b30006f          	j	ffffffffc0208434 <stride_dequeue+0x2226>
     if (comp(a, b) == -1)
ffffffffc0207586:	8542                	mv	a0,a6
ffffffffc0207588:	85e2                	mv	a1,s8
ffffffffc020758a:	f442                	sd	a6,40(sp)
ffffffffc020758c:	a2dfe0ef          	jal	ra,ffffffffc0205fb8 <proc_stride_comp_f>
ffffffffc0207590:	7302                	ld	t1,32(sp)
ffffffffc0207592:	7822                	ld	a6,40(sp)
ffffffffc0207594:	546508e3          	beq	a0,t1,ffffffffc02082e4 <stride_dequeue+0x20d6>
          r = b->left;
ffffffffc0207598:	008c3783          	ld	a5,8(s8)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc020759c:	010c3883          	ld	a7,16(s8)
ffffffffc02075a0:	fc1a                	sd	t1,56(sp)
          r = b->left;
ffffffffc02075a2:	f03e                	sd	a5,32(sp)
     else if (b == NULL) return a;
ffffffffc02075a4:	04088463          	beqz	a7,ffffffffc02075ec <stride_dequeue+0x13de>
     if (comp(a, b) == -1)
ffffffffc02075a8:	85c6                	mv	a1,a7
ffffffffc02075aa:	8542                	mv	a0,a6
ffffffffc02075ac:	f846                	sd	a7,48(sp)
ffffffffc02075ae:	f442                	sd	a6,40(sp)
ffffffffc02075b0:	a09fe0ef          	jal	ra,ffffffffc0205fb8 <proc_stride_comp_f>
ffffffffc02075b4:	7362                	ld	t1,56(sp)
ffffffffc02075b6:	7822                	ld	a6,40(sp)
ffffffffc02075b8:	78c2                	ld	a7,48(sp)
ffffffffc02075ba:	00651463          	bne	a0,t1,ffffffffc02075c2 <stride_dequeue+0x13b4>
ffffffffc02075be:	1dc0106f          	j	ffffffffc020879a <stride_dequeue+0x258c>
          r = b->left;
ffffffffc02075c2:	0088b303          	ld	t1,8(a7)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02075c6:	0108b583          	ld	a1,16(a7)
ffffffffc02075ca:	8542                	mv	a0,a6
          r = b->left;
ffffffffc02075cc:	f846                	sd	a7,48(sp)
ffffffffc02075ce:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02075d0:	a45fe0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          b->left = l;
ffffffffc02075d4:	78c2                	ld	a7,48(sp)
          b->right = r;
ffffffffc02075d6:	7322                	ld	t1,40(sp)
          b->left = l;
ffffffffc02075d8:	00a8b423          	sd	a0,8(a7)
          b->right = r;
ffffffffc02075dc:	0068b823          	sd	t1,16(a7)
          if (l) l->parent = b;
ffffffffc02075e0:	e119                	bnez	a0,ffffffffc02075e6 <stride_dequeue+0x13d8>
ffffffffc02075e2:	30e0106f          	j	ffffffffc02088f0 <stride_dequeue+0x26e2>
ffffffffc02075e6:	01153023          	sd	a7,0(a0)
ffffffffc02075ea:	8846                	mv	a6,a7
          b->right = r;
ffffffffc02075ec:	7782                	ld	a5,32(sp)
          b->left = l;
ffffffffc02075ee:	010c3423          	sd	a6,8(s8)
          b->right = r;
ffffffffc02075f2:	00fc3823          	sd	a5,16(s8)
          if (l) l->parent = b;
ffffffffc02075f6:	01883023          	sd	s8,0(a6)
ffffffffc02075fa:	8862                	mv	a6,s8
          a->right = r;
ffffffffc02075fc:	67e2                	ld	a5,24(sp)
          a->left = l;
ffffffffc02075fe:	010d3423          	sd	a6,8(s10)
          if (l) l->parent = a;
ffffffffc0207602:	8c6a                	mv	s8,s10
          a->right = r;
ffffffffc0207604:	00fd3823          	sd	a5,16(s10)
          if (l) l->parent = a;
ffffffffc0207608:	01a83023          	sd	s10,0(a6)
ffffffffc020760c:	f46ff06f          	j	ffffffffc0206d52 <stride_dequeue+0xb44>
          r = a->left;
ffffffffc0207610:	008b3783          	ld	a5,8(s6)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0207614:	010b3803          	ld	a6,16(s6)
ffffffffc0207618:	f02a                	sd	a0,32(sp)
          r = a->left;
ffffffffc020761a:	ec3e                	sd	a5,24(sp)
     if (a == NULL) return b;
ffffffffc020761c:	620808e3          	beqz	a6,ffffffffc020844c <stride_dequeue+0x223e>
     if (comp(a, b) == -1)
ffffffffc0207620:	8542                	mv	a0,a6
ffffffffc0207622:	85e6                	mv	a1,s9
ffffffffc0207624:	f442                	sd	a6,40(sp)
ffffffffc0207626:	993fe0ef          	jal	ra,ffffffffc0205fb8 <proc_stride_comp_f>
ffffffffc020762a:	7302                	ld	t1,32(sp)
ffffffffc020762c:	7822                	ld	a6,40(sp)
ffffffffc020762e:	28650de3          	beq	a0,t1,ffffffffc02080c8 <stride_dequeue+0x1eba>
          r = b->left;
ffffffffc0207632:	008cb783          	ld	a5,8(s9)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207636:	010cb883          	ld	a7,16(s9)
ffffffffc020763a:	fc1a                	sd	t1,56(sp)
          r = b->left;
ffffffffc020763c:	f03e                	sd	a5,32(sp)
     else if (b == NULL) return a;
ffffffffc020763e:	04088463          	beqz	a7,ffffffffc0207686 <stride_dequeue+0x1478>
     if (comp(a, b) == -1)
ffffffffc0207642:	85c6                	mv	a1,a7
ffffffffc0207644:	8542                	mv	a0,a6
ffffffffc0207646:	f846                	sd	a7,48(sp)
ffffffffc0207648:	f442                	sd	a6,40(sp)
ffffffffc020764a:	96ffe0ef          	jal	ra,ffffffffc0205fb8 <proc_stride_comp_f>
ffffffffc020764e:	7362                	ld	t1,56(sp)
ffffffffc0207650:	7822                	ld	a6,40(sp)
ffffffffc0207652:	78c2                	ld	a7,48(sp)
ffffffffc0207654:	00651463          	bne	a0,t1,ffffffffc020765c <stride_dequeue+0x144e>
ffffffffc0207658:	1c80106f          	j	ffffffffc0208820 <stride_dequeue+0x2612>
          r = b->left;
ffffffffc020765c:	0088b303          	ld	t1,8(a7)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207660:	0108b583          	ld	a1,16(a7)
ffffffffc0207664:	8542                	mv	a0,a6
          r = b->left;
ffffffffc0207666:	f846                	sd	a7,48(sp)
ffffffffc0207668:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc020766a:	9abfe0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          b->left = l;
ffffffffc020766e:	78c2                	ld	a7,48(sp)
          b->right = r;
ffffffffc0207670:	7322                	ld	t1,40(sp)
          b->left = l;
ffffffffc0207672:	00a8b423          	sd	a0,8(a7)
          b->right = r;
ffffffffc0207676:	0068b823          	sd	t1,16(a7)
          if (l) l->parent = b;
ffffffffc020767a:	e119                	bnez	a0,ffffffffc0207680 <stride_dequeue+0x1472>
ffffffffc020767c:	2560106f          	j	ffffffffc02088d2 <stride_dequeue+0x26c4>
ffffffffc0207680:	01153023          	sd	a7,0(a0)
ffffffffc0207684:	8846                	mv	a6,a7
          b->right = r;
ffffffffc0207686:	7782                	ld	a5,32(sp)
          b->left = l;
ffffffffc0207688:	010cb423          	sd	a6,8(s9)
          b->right = r;
ffffffffc020768c:	00fcb823          	sd	a5,16(s9)
          if (l) l->parent = b;
ffffffffc0207690:	01983023          	sd	s9,0(a6)
ffffffffc0207694:	8866                	mv	a6,s9
          a->right = r;
ffffffffc0207696:	67e2                	ld	a5,24(sp)
          a->left = l;
ffffffffc0207698:	010b3423          	sd	a6,8(s6)
          if (l) l->parent = a;
ffffffffc020769c:	8cda                	mv	s9,s6
          a->right = r;
ffffffffc020769e:	00fb3823          	sd	a5,16(s6)
          if (l) l->parent = a;
ffffffffc02076a2:	01683023          	sd	s6,0(a6)
ffffffffc02076a6:	de4ff06f          	j	ffffffffc0206c8a <stride_dequeue+0xa7c>
          r = a->left;
ffffffffc02076aa:	008b3783          	ld	a5,8(s6)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02076ae:	010b3803          	ld	a6,16(s6)
ffffffffc02076b2:	f02a                	sd	a0,32(sp)
          r = a->left;
ffffffffc02076b4:	ec3e                	sd	a5,24(sp)
     if (a == NULL) return b;
ffffffffc02076b6:	580808e3          	beqz	a6,ffffffffc0208446 <stride_dequeue+0x2238>
     if (comp(a, b) == -1)
ffffffffc02076ba:	8542                	mv	a0,a6
ffffffffc02076bc:	85e6                	mv	a1,s9
ffffffffc02076be:	f442                	sd	a6,40(sp)
ffffffffc02076c0:	8f9fe0ef          	jal	ra,ffffffffc0205fb8 <proc_stride_comp_f>
ffffffffc02076c4:	7302                	ld	t1,32(sp)
ffffffffc02076c6:	7822                	ld	a6,40(sp)
ffffffffc02076c8:	226507e3          	beq	a0,t1,ffffffffc02080f6 <stride_dequeue+0x1ee8>
          r = b->left;
ffffffffc02076cc:	008cb783          	ld	a5,8(s9)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02076d0:	010cb883          	ld	a7,16(s9)
ffffffffc02076d4:	fc1a                	sd	t1,56(sp)
          r = b->left;
ffffffffc02076d6:	f03e                	sd	a5,32(sp)
     else if (b == NULL) return a;
ffffffffc02076d8:	04088463          	beqz	a7,ffffffffc0207720 <stride_dequeue+0x1512>
     if (comp(a, b) == -1)
ffffffffc02076dc:	85c6                	mv	a1,a7
ffffffffc02076de:	8542                	mv	a0,a6
ffffffffc02076e0:	f846                	sd	a7,48(sp)
ffffffffc02076e2:	f442                	sd	a6,40(sp)
ffffffffc02076e4:	8d5fe0ef          	jal	ra,ffffffffc0205fb8 <proc_stride_comp_f>
ffffffffc02076e8:	7362                	ld	t1,56(sp)
ffffffffc02076ea:	7822                	ld	a6,40(sp)
ffffffffc02076ec:	78c2                	ld	a7,48(sp)
ffffffffc02076ee:	00651463          	bne	a0,t1,ffffffffc02076f6 <stride_dequeue+0x14e8>
ffffffffc02076f2:	0d40106f          	j	ffffffffc02087c6 <stride_dequeue+0x25b8>
          r = b->left;
ffffffffc02076f6:	0088b303          	ld	t1,8(a7)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02076fa:	0108b583          	ld	a1,16(a7)
ffffffffc02076fe:	8542                	mv	a0,a6
          r = b->left;
ffffffffc0207700:	f846                	sd	a7,48(sp)
ffffffffc0207702:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207704:	911fe0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          b->left = l;
ffffffffc0207708:	78c2                	ld	a7,48(sp)
          b->right = r;
ffffffffc020770a:	7322                	ld	t1,40(sp)
          b->left = l;
ffffffffc020770c:	00a8b423          	sd	a0,8(a7)
          b->right = r;
ffffffffc0207710:	0068b823          	sd	t1,16(a7)
          if (l) l->parent = b;
ffffffffc0207714:	e119                	bnez	a0,ffffffffc020771a <stride_dequeue+0x150c>
ffffffffc0207716:	2040106f          	j	ffffffffc020891a <stride_dequeue+0x270c>
ffffffffc020771a:	01153023          	sd	a7,0(a0)
ffffffffc020771e:	8846                	mv	a6,a7
          b->right = r;
ffffffffc0207720:	7782                	ld	a5,32(sp)
          b->left = l;
ffffffffc0207722:	010cb423          	sd	a6,8(s9)
          b->right = r;
ffffffffc0207726:	00fcb823          	sd	a5,16(s9)
          if (l) l->parent = b;
ffffffffc020772a:	01983023          	sd	s9,0(a6)
ffffffffc020772e:	8866                	mv	a6,s9
          a->right = r;
ffffffffc0207730:	67e2                	ld	a5,24(sp)
          a->left = l;
ffffffffc0207732:	010b3423          	sd	a6,8(s6)
          a->right = r;
ffffffffc0207736:	00fb3823          	sd	a5,16(s6)
          if (l) l->parent = a;
ffffffffc020773a:	01683023          	sd	s6,0(a6)
ffffffffc020773e:	8f4ff06f          	j	ffffffffc0206832 <stride_dequeue+0x624>
          r = a->left;
ffffffffc0207742:	008d3783          	ld	a5,8(s10)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0207746:	010d3803          	ld	a6,16(s10)
ffffffffc020774a:	f02a                	sd	a0,32(sp)
          r = a->left;
ffffffffc020774c:	ec3e                	sd	a5,24(sp)
     if (a == NULL) return b;
ffffffffc020774e:	4e0806e3          	beqz	a6,ffffffffc020843a <stride_dequeue+0x222c>
     if (comp(a, b) == -1)
ffffffffc0207752:	8542                	mv	a0,a6
ffffffffc0207754:	85e6                	mv	a1,s9
ffffffffc0207756:	f442                	sd	a6,40(sp)
ffffffffc0207758:	861fe0ef          	jal	ra,ffffffffc0205fb8 <proc_stride_comp_f>
ffffffffc020775c:	7302                	ld	t1,32(sp)
ffffffffc020775e:	7822                	ld	a6,40(sp)
ffffffffc0207760:	10650be3          	beq	a0,t1,ffffffffc0208076 <stride_dequeue+0x1e68>
          r = b->left;
ffffffffc0207764:	008cb783          	ld	a5,8(s9)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207768:	010cb883          	ld	a7,16(s9)
ffffffffc020776c:	fc1a                	sd	t1,56(sp)
          r = b->left;
ffffffffc020776e:	f03e                	sd	a5,32(sp)
     else if (b == NULL) return a;
ffffffffc0207770:	04088463          	beqz	a7,ffffffffc02077b8 <stride_dequeue+0x15aa>
     if (comp(a, b) == -1)
ffffffffc0207774:	85c6                	mv	a1,a7
ffffffffc0207776:	8542                	mv	a0,a6
ffffffffc0207778:	f846                	sd	a7,48(sp)
ffffffffc020777a:	f442                	sd	a6,40(sp)
ffffffffc020777c:	83dfe0ef          	jal	ra,ffffffffc0205fb8 <proc_stride_comp_f>
ffffffffc0207780:	7362                	ld	t1,56(sp)
ffffffffc0207782:	7822                	ld	a6,40(sp)
ffffffffc0207784:	78c2                	ld	a7,48(sp)
ffffffffc0207786:	00651463          	bne	a0,t1,ffffffffc020778e <stride_dequeue+0x1580>
ffffffffc020778a:	0c20106f          	j	ffffffffc020884c <stride_dequeue+0x263e>
          r = b->left;
ffffffffc020778e:	0088b303          	ld	t1,8(a7)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207792:	0108b583          	ld	a1,16(a7)
ffffffffc0207796:	8542                	mv	a0,a6
          r = b->left;
ffffffffc0207798:	f846                	sd	a7,48(sp)
ffffffffc020779a:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc020779c:	879fe0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          b->left = l;
ffffffffc02077a0:	78c2                	ld	a7,48(sp)
          b->right = r;
ffffffffc02077a2:	7322                	ld	t1,40(sp)
          b->left = l;
ffffffffc02077a4:	00a8b423          	sd	a0,8(a7)
          b->right = r;
ffffffffc02077a8:	0068b823          	sd	t1,16(a7)
          if (l) l->parent = b;
ffffffffc02077ac:	e119                	bnez	a0,ffffffffc02077b2 <stride_dequeue+0x15a4>
ffffffffc02077ae:	1c00106f          	j	ffffffffc020896e <stride_dequeue+0x2760>
ffffffffc02077b2:	01153023          	sd	a7,0(a0)
ffffffffc02077b6:	8846                	mv	a6,a7
          b->right = r;
ffffffffc02077b8:	7782                	ld	a5,32(sp)
          b->left = l;
ffffffffc02077ba:	010cb423          	sd	a6,8(s9)
          b->right = r;
ffffffffc02077be:	00fcb823          	sd	a5,16(s9)
          if (l) l->parent = b;
ffffffffc02077c2:	01983023          	sd	s9,0(a6)
ffffffffc02077c6:	8866                	mv	a6,s9
          a->right = r;
ffffffffc02077c8:	67e2                	ld	a5,24(sp)
          a->left = l;
ffffffffc02077ca:	010d3423          	sd	a6,8(s10)
          a->right = r;
ffffffffc02077ce:	00fd3823          	sd	a5,16(s10)
          if (l) l->parent = a;
ffffffffc02077d2:	01a83023          	sd	s10,0(a6)
ffffffffc02077d6:	94cff06f          	j	ffffffffc0206922 <stride_dequeue+0x714>
          r = a->left;
ffffffffc02077da:	0088b783          	ld	a5,8(a7)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02077de:	0108b803          	ld	a6,16(a7)
ffffffffc02077e2:	f42a                	sd	a0,40(sp)
          r = a->left;
ffffffffc02077e4:	f03e                	sd	a5,32(sp)
     if (a == NULL) return b;
ffffffffc02077e6:	02080f63          	beqz	a6,ffffffffc0207824 <stride_dequeue+0x1616>
     if (comp(a, b) == -1)
ffffffffc02077ea:	8542                	mv	a0,a6
ffffffffc02077ec:	85e6                	mv	a1,s9
ffffffffc02077ee:	fc46                	sd	a7,56(sp)
ffffffffc02077f0:	f842                	sd	a6,48(sp)
ffffffffc02077f2:	fc6fe0ef          	jal	ra,ffffffffc0205fb8 <proc_stride_comp_f>
ffffffffc02077f6:	7322                	ld	t1,40(sp)
ffffffffc02077f8:	7842                	ld	a6,48(sp)
ffffffffc02077fa:	78e2                	ld	a7,56(sp)
ffffffffc02077fc:	046507e3          	beq	a0,t1,ffffffffc020804a <stride_dequeue+0x1e3c>
          r = b->left;
ffffffffc0207800:	008cb303          	ld	t1,8(s9)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207804:	010cb583          	ld	a1,16(s9)
ffffffffc0207808:	8542                	mv	a0,a6
ffffffffc020780a:	f846                	sd	a7,48(sp)
          r = b->left;
ffffffffc020780c:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc020780e:	807fe0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          b->right = r;
ffffffffc0207812:	7322                	ld	t1,40(sp)
          b->left = l;
ffffffffc0207814:	00acb423          	sd	a0,8(s9)
          if (l) l->parent = b;
ffffffffc0207818:	78c2                	ld	a7,48(sp)
          b->right = r;
ffffffffc020781a:	006cb823          	sd	t1,16(s9)
          if (l) l->parent = b;
ffffffffc020781e:	c119                	beqz	a0,ffffffffc0207824 <stride_dequeue+0x1616>
ffffffffc0207820:	01953023          	sd	s9,0(a0)
          a->right = r;
ffffffffc0207824:	7782                	ld	a5,32(sp)
          a->left = l;
ffffffffc0207826:	0198b423          	sd	s9,8(a7)
          a->right = r;
ffffffffc020782a:	00f8b823          	sd	a5,16(a7)
          if (l) l->parent = a;
ffffffffc020782e:	011cb023          	sd	a7,0(s9)
ffffffffc0207832:	8cc6                	mv	s9,a7
ffffffffc0207834:	e72ff06f          	j	ffffffffc0206ea6 <stride_dequeue+0xc98>
          r = a->left;
ffffffffc0207838:	008cb783          	ld	a5,8(s9)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc020783c:	010cb883          	ld	a7,16(s9)
ffffffffc0207840:	f42a                	sd	a0,40(sp)
          r = a->left;
ffffffffc0207842:	f03e                	sd	a5,32(sp)
     if (a == NULL) return b;
ffffffffc0207844:	02088f63          	beqz	a7,ffffffffc0207882 <stride_dequeue+0x1674>
     if (comp(a, b) == -1)
ffffffffc0207848:	85c2                	mv	a1,a6
ffffffffc020784a:	8546                	mv	a0,a7
ffffffffc020784c:	fc42                	sd	a6,56(sp)
ffffffffc020784e:	f846                	sd	a7,48(sp)
ffffffffc0207850:	f68fe0ef          	jal	ra,ffffffffc0205fb8 <proc_stride_comp_f>
ffffffffc0207854:	7322                	ld	t1,40(sp)
ffffffffc0207856:	78c2                	ld	a7,48(sp)
ffffffffc0207858:	7862                	ld	a6,56(sp)
ffffffffc020785a:	22650ce3          	beq	a0,t1,ffffffffc0208292 <stride_dequeue+0x2084>
          r = b->left;
ffffffffc020785e:	00883303          	ld	t1,8(a6)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207862:	01083583          	ld	a1,16(a6)
ffffffffc0207866:	8546                	mv	a0,a7
          r = b->left;
ffffffffc0207868:	f842                	sd	a6,48(sp)
ffffffffc020786a:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc020786c:	fa8fe0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          b->left = l;
ffffffffc0207870:	7842                	ld	a6,48(sp)
          b->right = r;
ffffffffc0207872:	7322                	ld	t1,40(sp)
          b->left = l;
ffffffffc0207874:	00a83423          	sd	a0,8(a6)
          b->right = r;
ffffffffc0207878:	00683823          	sd	t1,16(a6)
          if (l) l->parent = b;
ffffffffc020787c:	c119                	beqz	a0,ffffffffc0207882 <stride_dequeue+0x1674>
ffffffffc020787e:	01053023          	sd	a6,0(a0)
          a->right = r;
ffffffffc0207882:	7782                	ld	a5,32(sp)
          a->left = l;
ffffffffc0207884:	010cb423          	sd	a6,8(s9)
          a->right = r;
ffffffffc0207888:	00fcb823          	sd	a5,16(s9)
          if (l) l->parent = a;
ffffffffc020788c:	01983023          	sd	s9,0(a6)
ffffffffc0207890:	952ff06f          	j	ffffffffc02069e2 <stride_dequeue+0x7d4>
          r = a->left;
ffffffffc0207894:	008db703          	ld	a4,8(s11)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0207898:	010db883          	ld	a7,16(s11)
ffffffffc020789c:	f42a                	sd	a0,40(sp)
          r = a->left;
ffffffffc020789e:	f03a                	sd	a4,32(sp)
     if (a == NULL) return b;
ffffffffc02078a0:	02088c63          	beqz	a7,ffffffffc02078d8 <stride_dequeue+0x16ca>
     if (comp(a, b) == -1)
ffffffffc02078a4:	85be                	mv	a1,a5
ffffffffc02078a6:	8546                	mv	a0,a7
ffffffffc02078a8:	fc3e                	sd	a5,56(sp)
ffffffffc02078aa:	f846                	sd	a7,48(sp)
ffffffffc02078ac:	f0cfe0ef          	jal	ra,ffffffffc0205fb8 <proc_stride_comp_f>
ffffffffc02078b0:	7322                	ld	t1,40(sp)
ffffffffc02078b2:	78c2                	ld	a7,48(sp)
ffffffffc02078b4:	77e2                	ld	a5,56(sp)
ffffffffc02078b6:	1a6509e3          	beq	a0,t1,ffffffffc0208268 <stride_dequeue+0x205a>
          r = b->left;
ffffffffc02078ba:	0087b303          	ld	t1,8(a5)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02078be:	6b8c                	ld	a1,16(a5)
ffffffffc02078c0:	8546                	mv	a0,a7
          r = b->left;
ffffffffc02078c2:	f83e                	sd	a5,48(sp)
ffffffffc02078c4:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02078c6:	f4efe0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          b->left = l;
ffffffffc02078ca:	77c2                	ld	a5,48(sp)
          b->right = r;
ffffffffc02078cc:	7322                	ld	t1,40(sp)
          b->left = l;
ffffffffc02078ce:	e788                	sd	a0,8(a5)
          b->right = r;
ffffffffc02078d0:	0067b823          	sd	t1,16(a5)
          if (l) l->parent = b;
ffffffffc02078d4:	c111                	beqz	a0,ffffffffc02078d8 <stride_dequeue+0x16ca>
ffffffffc02078d6:	e11c                	sd	a5,0(a0)
          a->right = r;
ffffffffc02078d8:	7702                	ld	a4,32(sp)
          a->left = l;
ffffffffc02078da:	00fdb423          	sd	a5,8(s11)
          a->right = r;
ffffffffc02078de:	00edb823          	sd	a4,16(s11)
          if (l) l->parent = a;
ffffffffc02078e2:	01b7b023          	sd	s11,0(a5)
ffffffffc02078e6:	beffe06f          	j	ffffffffc02064d4 <stride_dequeue+0x2c6>
          r = a->left;
ffffffffc02078ea:	008c3703          	ld	a4,8(s8)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02078ee:	010c3883          	ld	a7,16(s8)
ffffffffc02078f2:	f42a                	sd	a0,40(sp)
          r = a->left;
ffffffffc02078f4:	f03a                	sd	a4,32(sp)
     if (a == NULL) return b;
ffffffffc02078f6:	02088c63          	beqz	a7,ffffffffc020792e <stride_dequeue+0x1720>
     if (comp(a, b) == -1)
ffffffffc02078fa:	85be                	mv	a1,a5
ffffffffc02078fc:	8546                	mv	a0,a7
ffffffffc02078fe:	fc3e                	sd	a5,56(sp)
ffffffffc0207900:	f846                	sd	a7,48(sp)
ffffffffc0207902:	eb6fe0ef          	jal	ra,ffffffffc0205fb8 <proc_stride_comp_f>
ffffffffc0207906:	7322                	ld	t1,40(sp)
ffffffffc0207908:	78c2                	ld	a7,48(sp)
ffffffffc020790a:	77e2                	ld	a5,56(sp)
ffffffffc020790c:	126509e3          	beq	a0,t1,ffffffffc020823e <stride_dequeue+0x2030>
          r = b->left;
ffffffffc0207910:	0087b303          	ld	t1,8(a5)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207914:	6b8c                	ld	a1,16(a5)
ffffffffc0207916:	8546                	mv	a0,a7
          r = b->left;
ffffffffc0207918:	f83e                	sd	a5,48(sp)
ffffffffc020791a:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc020791c:	ef8fe0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          b->left = l;
ffffffffc0207920:	77c2                	ld	a5,48(sp)
          b->right = r;
ffffffffc0207922:	7322                	ld	t1,40(sp)
          b->left = l;
ffffffffc0207924:	e788                	sd	a0,8(a5)
          b->right = r;
ffffffffc0207926:	0067b823          	sd	t1,16(a5)
          if (l) l->parent = b;
ffffffffc020792a:	c111                	beqz	a0,ffffffffc020792e <stride_dequeue+0x1720>
ffffffffc020792c:	e11c                	sd	a5,0(a0)
          a->right = r;
ffffffffc020792e:	7702                	ld	a4,32(sp)
          a->left = l;
ffffffffc0207930:	00fc3423          	sd	a5,8(s8)
          a->right = r;
ffffffffc0207934:	00ec3823          	sd	a4,16(s8)
          if (l) l->parent = a;
ffffffffc0207938:	0187b023          	sd	s8,0(a5)
ffffffffc020793c:	ccdfe06f          	j	ffffffffc0206608 <stride_dequeue+0x3fa>
          r = a->left;
ffffffffc0207940:	008cb703          	ld	a4,8(s9)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0207944:	010cb883          	ld	a7,16(s9)
ffffffffc0207948:	f42a                	sd	a0,40(sp)
          r = a->left;
ffffffffc020794a:	f03a                	sd	a4,32(sp)
     if (a == NULL) return b;
ffffffffc020794c:	02088c63          	beqz	a7,ffffffffc0207984 <stride_dequeue+0x1776>
     if (comp(a, b) == -1)
ffffffffc0207950:	85be                	mv	a1,a5
ffffffffc0207952:	8546                	mv	a0,a7
ffffffffc0207954:	fc3e                	sd	a5,56(sp)
ffffffffc0207956:	f846                	sd	a7,48(sp)
ffffffffc0207958:	e60fe0ef          	jal	ra,ffffffffc0205fb8 <proc_stride_comp_f>
ffffffffc020795c:	7322                	ld	t1,40(sp)
ffffffffc020795e:	78c2                	ld	a7,48(sp)
ffffffffc0207960:	77e2                	ld	a5,56(sp)
ffffffffc0207962:	006507e3          	beq	a0,t1,ffffffffc0208170 <stride_dequeue+0x1f62>
          r = b->left;
ffffffffc0207966:	0087b303          	ld	t1,8(a5)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc020796a:	6b8c                	ld	a1,16(a5)
ffffffffc020796c:	8546                	mv	a0,a7
          r = b->left;
ffffffffc020796e:	f83e                	sd	a5,48(sp)
ffffffffc0207970:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207972:	ea2fe0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          b->left = l;
ffffffffc0207976:	77c2                	ld	a5,48(sp)
          b->right = r;
ffffffffc0207978:	7322                	ld	t1,40(sp)
          b->left = l;
ffffffffc020797a:	e788                	sd	a0,8(a5)
          b->right = r;
ffffffffc020797c:	0067b823          	sd	t1,16(a5)
          if (l) l->parent = b;
ffffffffc0207980:	c111                	beqz	a0,ffffffffc0207984 <stride_dequeue+0x1776>
ffffffffc0207982:	e11c                	sd	a5,0(a0)
          a->right = r;
ffffffffc0207984:	7702                	ld	a4,32(sp)
          a->left = l;
ffffffffc0207986:	00fcb423          	sd	a5,8(s9)
          a->right = r;
ffffffffc020798a:	00ecb823          	sd	a4,16(s9)
          if (l) l->parent = a;
ffffffffc020798e:	0197b023          	sd	s9,0(a5)
ffffffffc0207992:	926ff06f          	j	ffffffffc0206ab8 <stride_dequeue+0x8aa>
          r = a->left;
ffffffffc0207996:	00893883          	ld	a7,8(s2)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc020799a:	01093503          	ld	a0,16(s2)
ffffffffc020799e:	859a                	mv	a1,t1
          r = a->left;
ffffffffc02079a0:	f446                	sd	a7,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02079a2:	e72fe0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->right = r;
ffffffffc02079a6:	78a2                	ld	a7,40(sp)
          a->left = l;
ffffffffc02079a8:	00a93423          	sd	a0,8(s2)
          if (l) l->parent = a;
ffffffffc02079ac:	834a                	mv	t1,s2
          a->right = r;
ffffffffc02079ae:	01193823          	sd	a7,16(s2)
          if (l) l->parent = a;
ffffffffc02079b2:	77c2                	ld	a5,48(sp)
ffffffffc02079b4:	c119                	beqz	a0,ffffffffc02079ba <stride_dequeue+0x17ac>
ffffffffc02079b6:	97bfe06f          	j	ffffffffc0206330 <stride_dequeue+0x122>
ffffffffc02079ba:	97bfe06f          	j	ffffffffc0206334 <stride_dequeue+0x126>
     else if (b == NULL) return a;
ffffffffc02079be:	834a                	mv	t1,s2
ffffffffc02079c0:	975fe06f          	j	ffffffffc0206334 <stride_dequeue+0x126>
          r = a->left;
ffffffffc02079c4:	008cb703          	ld	a4,8(s9)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02079c8:	010cb783          	ld	a5,16(s9)
ffffffffc02079cc:	f42a                	sd	a0,40(sp)
          r = a->left;
ffffffffc02079ce:	ec3a                	sd	a4,24(sp)
     if (a == NULL) return b;
ffffffffc02079d0:	cb95                	beqz	a5,ffffffffc0207a04 <stride_dequeue+0x17f6>
     if (comp(a, b) == -1)
ffffffffc02079d2:	853e                	mv	a0,a5
ffffffffc02079d4:	85ea                	mv	a1,s10
ffffffffc02079d6:	f03e                	sd	a5,32(sp)
ffffffffc02079d8:	de0fe0ef          	jal	ra,ffffffffc0205fb8 <proc_stride_comp_f>
ffffffffc02079dc:	7822                	ld	a6,40(sp)
ffffffffc02079de:	7782                	ld	a5,32(sp)
ffffffffc02079e0:	310508e3          	beq	a0,a6,ffffffffc02084f0 <stride_dequeue+0x22e2>
          r = b->left;
ffffffffc02079e4:	008d3803          	ld	a6,8(s10)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02079e8:	010d3583          	ld	a1,16(s10)
ffffffffc02079ec:	853e                	mv	a0,a5
          r = b->left;
ffffffffc02079ee:	f042                	sd	a6,32(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc02079f0:	e24fe0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          b->right = r;
ffffffffc02079f4:	7802                	ld	a6,32(sp)
          b->left = l;
ffffffffc02079f6:	00ad3423          	sd	a0,8(s10)
          b->right = r;
ffffffffc02079fa:	010d3823          	sd	a6,16(s10)
          if (l) l->parent = b;
ffffffffc02079fe:	c119                	beqz	a0,ffffffffc0207a04 <stride_dequeue+0x17f6>
ffffffffc0207a00:	01a53023          	sd	s10,0(a0)
          a->right = r;
ffffffffc0207a04:	67e2                	ld	a5,24(sp)
          a->left = l;
ffffffffc0207a06:	01acb423          	sd	s10,8(s9)
          a->right = r;
ffffffffc0207a0a:	00fcb823          	sd	a5,16(s9)
          if (l) l->parent = a;
ffffffffc0207a0e:	019d3023          	sd	s9,0(s10)
ffffffffc0207a12:	8d66                	mv	s10,s9
ffffffffc0207a14:	d58ff06f          	j	ffffffffc0206f6c <stride_dequeue+0xd5e>
          r = a->left;
ffffffffc0207a18:	008cb703          	ld	a4,8(s9)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0207a1c:	010cb783          	ld	a5,16(s9)
ffffffffc0207a20:	f42a                	sd	a0,40(sp)
          r = a->left;
ffffffffc0207a22:	ec3a                	sd	a4,24(sp)
     if (a == NULL) return b;
ffffffffc0207a24:	cb95                	beqz	a5,ffffffffc0207a58 <stride_dequeue+0x184a>
     if (comp(a, b) == -1)
ffffffffc0207a26:	853e                	mv	a0,a5
ffffffffc0207a28:	85ea                	mv	a1,s10
ffffffffc0207a2a:	f03e                	sd	a5,32(sp)
ffffffffc0207a2c:	d8cfe0ef          	jal	ra,ffffffffc0205fb8 <proc_stride_comp_f>
ffffffffc0207a30:	7822                	ld	a6,40(sp)
ffffffffc0207a32:	7782                	ld	a5,32(sp)
ffffffffc0207a34:	23050ee3          	beq	a0,a6,ffffffffc0208470 <stride_dequeue+0x2262>
          r = b->left;
ffffffffc0207a38:	008d3803          	ld	a6,8(s10)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207a3c:	010d3583          	ld	a1,16(s10)
ffffffffc0207a40:	853e                	mv	a0,a5
          r = b->left;
ffffffffc0207a42:	f042                	sd	a6,32(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207a44:	dd0fe0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          b->right = r;
ffffffffc0207a48:	7802                	ld	a6,32(sp)
          b->left = l;
ffffffffc0207a4a:	00ad3423          	sd	a0,8(s10)
          b->right = r;
ffffffffc0207a4e:	010d3823          	sd	a6,16(s10)
          if (l) l->parent = b;
ffffffffc0207a52:	c119                	beqz	a0,ffffffffc0207a58 <stride_dequeue+0x184a>
ffffffffc0207a54:	01a53023          	sd	s10,0(a0)
          a->right = r;
ffffffffc0207a58:	67e2                	ld	a5,24(sp)
          a->left = l;
ffffffffc0207a5a:	01acb423          	sd	s10,8(s9)
          a->right = r;
ffffffffc0207a5e:	00fcb823          	sd	a5,16(s9)
          if (l) l->parent = a;
ffffffffc0207a62:	019d3023          	sd	s9,0(s10)
ffffffffc0207a66:	8d66                	mv	s10,s9
ffffffffc0207a68:	94eff06f          	j	ffffffffc0206bb6 <stride_dequeue+0x9a8>
          r = a->left;
ffffffffc0207a6c:	008cb703          	ld	a4,8(s9)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0207a70:	010cb783          	ld	a5,16(s9)
ffffffffc0207a74:	f42a                	sd	a0,40(sp)
          r = a->left;
ffffffffc0207a76:	ec3a                	sd	a4,24(sp)
     if (a == NULL) return b;
ffffffffc0207a78:	cb95                	beqz	a5,ffffffffc0207aac <stride_dequeue+0x189e>
     if (comp(a, b) == -1)
ffffffffc0207a7a:	853e                	mv	a0,a5
ffffffffc0207a7c:	85ee                	mv	a1,s11
ffffffffc0207a7e:	f03e                	sd	a5,32(sp)
ffffffffc0207a80:	d38fe0ef          	jal	ra,ffffffffc0205fb8 <proc_stride_comp_f>
ffffffffc0207a84:	7822                	ld	a6,40(sp)
ffffffffc0207a86:	7782                	ld	a5,32(sp)
ffffffffc0207a88:	23050ee3          	beq	a0,a6,ffffffffc02084c4 <stride_dequeue+0x22b6>
          r = b->left;
ffffffffc0207a8c:	008db803          	ld	a6,8(s11)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207a90:	010db583          	ld	a1,16(s11)
ffffffffc0207a94:	853e                	mv	a0,a5
          r = b->left;
ffffffffc0207a96:	f042                	sd	a6,32(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207a98:	d7cfe0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          b->right = r;
ffffffffc0207a9c:	7802                	ld	a6,32(sp)
          b->left = l;
ffffffffc0207a9e:	00adb423          	sd	a0,8(s11)
          b->right = r;
ffffffffc0207aa2:	010db823          	sd	a6,16(s11)
          if (l) l->parent = b;
ffffffffc0207aa6:	c119                	beqz	a0,ffffffffc0207aac <stride_dequeue+0x189e>
ffffffffc0207aa8:	01b53023          	sd	s11,0(a0)
          a->right = r;
ffffffffc0207aac:	67e2                	ld	a5,24(sp)
          a->left = l;
ffffffffc0207aae:	01bcb423          	sd	s11,8(s9)
          a->right = r;
ffffffffc0207ab2:	00fcb823          	sd	a5,16(s9)
          if (l) l->parent = a;
ffffffffc0207ab6:	019db023          	sd	s9,0(s11)
ffffffffc0207aba:	8de6                	mv	s11,s9
ffffffffc0207abc:	d76ff06f          	j	ffffffffc0207032 <stride_dequeue+0xe24>
          r = a->left;
ffffffffc0207ac0:	008cb703          	ld	a4,8(s9)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0207ac4:	010cb783          	ld	a5,16(s9)
ffffffffc0207ac8:	f42a                	sd	a0,40(sp)
          r = a->left;
ffffffffc0207aca:	ec3a                	sd	a4,24(sp)
     if (a == NULL) return b;
ffffffffc0207acc:	cb95                	beqz	a5,ffffffffc0207b00 <stride_dequeue+0x18f2>
     if (comp(a, b) == -1)
ffffffffc0207ace:	853e                	mv	a0,a5
ffffffffc0207ad0:	85ea                	mv	a1,s10
ffffffffc0207ad2:	f03e                	sd	a5,32(sp)
ffffffffc0207ad4:	ce4fe0ef          	jal	ra,ffffffffc0205fb8 <proc_stride_comp_f>
ffffffffc0207ad8:	7822                	ld	a6,40(sp)
ffffffffc0207ada:	7782                	ld	a5,32(sp)
ffffffffc0207adc:	250506e3          	beq	a0,a6,ffffffffc0208528 <stride_dequeue+0x231a>
          r = b->left;
ffffffffc0207ae0:	008d3803          	ld	a6,8(s10)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207ae4:	010d3583          	ld	a1,16(s10)
ffffffffc0207ae8:	853e                	mv	a0,a5
          r = b->left;
ffffffffc0207aea:	f042                	sd	a6,32(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207aec:	d28fe0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          b->right = r;
ffffffffc0207af0:	7802                	ld	a6,32(sp)
          b->left = l;
ffffffffc0207af2:	00ad3423          	sd	a0,8(s10)
          b->right = r;
ffffffffc0207af6:	010d3823          	sd	a6,16(s10)
          if (l) l->parent = b;
ffffffffc0207afa:	c119                	beqz	a0,ffffffffc0207b00 <stride_dequeue+0x18f2>
ffffffffc0207afc:	01a53023          	sd	s10,0(a0)
          a->right = r;
ffffffffc0207b00:	67e2                	ld	a5,24(sp)
          a->left = l;
ffffffffc0207b02:	01acb423          	sd	s10,8(s9)
          a->right = r;
ffffffffc0207b06:	00fcb823          	sd	a5,16(s9)
          if (l) l->parent = a;
ffffffffc0207b0a:	019d3023          	sd	s9,0(s10)
ffffffffc0207b0e:	8d66                	mv	s10,s9
ffffffffc0207b10:	de8ff06f          	j	ffffffffc02070f8 <stride_dequeue+0xeea>
ffffffffc0207b14:	8346                	mv	t1,a7
ffffffffc0207b16:	b82ff06f          	j	ffffffffc0206e98 <stride_dequeue+0xc8a>
          r = a->left;
ffffffffc0207b1a:	008d3783          	ld	a5,8(s10)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0207b1e:	010d3883          	ld	a7,16(s10)
ffffffffc0207b22:	fc2a                	sd	a0,56(sp)
          r = a->left;
ffffffffc0207b24:	f03e                	sd	a5,32(sp)
     if (a == NULL) return b;
ffffffffc0207b26:	02088f63          	beqz	a7,ffffffffc0207b64 <stride_dequeue+0x1956>
     if (comp(a, b) == -1)
ffffffffc0207b2a:	85c2                	mv	a1,a6
ffffffffc0207b2c:	8546                	mv	a0,a7
ffffffffc0207b2e:	f842                	sd	a6,48(sp)
ffffffffc0207b30:	f446                	sd	a7,40(sp)
ffffffffc0207b32:	c86fe0ef          	jal	ra,ffffffffc0205fb8 <proc_stride_comp_f>
ffffffffc0207b36:	7362                	ld	t1,56(sp)
ffffffffc0207b38:	78a2                	ld	a7,40(sp)
ffffffffc0207b3a:	7842                	ld	a6,48(sp)
ffffffffc0207b3c:	326504e3          	beq	a0,t1,ffffffffc0208664 <stride_dequeue+0x2456>
          r = b->left;
ffffffffc0207b40:	00883303          	ld	t1,8(a6)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207b44:	01083583          	ld	a1,16(a6)
ffffffffc0207b48:	8546                	mv	a0,a7
          r = b->left;
ffffffffc0207b4a:	f842                	sd	a6,48(sp)
ffffffffc0207b4c:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207b4e:	cc6fe0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          b->left = l;
ffffffffc0207b52:	7842                	ld	a6,48(sp)
          b->right = r;
ffffffffc0207b54:	7322                	ld	t1,40(sp)
          b->left = l;
ffffffffc0207b56:	00a83423          	sd	a0,8(a6)
          b->right = r;
ffffffffc0207b5a:	00683823          	sd	t1,16(a6)
          if (l) l->parent = b;
ffffffffc0207b5e:	c119                	beqz	a0,ffffffffc0207b64 <stride_dequeue+0x1956>
ffffffffc0207b60:	01053023          	sd	a6,0(a0)
          a->right = r;
ffffffffc0207b64:	7782                	ld	a5,32(sp)
          a->left = l;
ffffffffc0207b66:	010d3423          	sd	a6,8(s10)
          a->right = r;
ffffffffc0207b6a:	00fd3823          	sd	a5,16(s10)
          if (l) l->parent = a;
ffffffffc0207b6e:	01a83023          	sd	s10,0(a6)
ffffffffc0207b72:	886a                	mv	a6,s10
ffffffffc0207b74:	a94ff06f          	j	ffffffffc0206e08 <stride_dequeue+0xbfa>
          r = a->left;
ffffffffc0207b78:	0088b783          	ld	a5,8(a7)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0207b7c:	0108b803          	ld	a6,16(a7)
ffffffffc0207b80:	fc2a                	sd	a0,56(sp)
          r = a->left;
ffffffffc0207b82:	f03e                	sd	a5,32(sp)
     if (a == NULL) return b;
ffffffffc0207b84:	02080f63          	beqz	a6,ffffffffc0207bc2 <stride_dequeue+0x19b4>
     if (comp(a, b) == -1)
ffffffffc0207b88:	8542                	mv	a0,a6
ffffffffc0207b8a:	85ea                	mv	a1,s10
ffffffffc0207b8c:	f846                	sd	a7,48(sp)
ffffffffc0207b8e:	f442                	sd	a6,40(sp)
ffffffffc0207b90:	c28fe0ef          	jal	ra,ffffffffc0205fb8 <proc_stride_comp_f>
ffffffffc0207b94:	7362                	ld	t1,56(sp)
ffffffffc0207b96:	7822                	ld	a6,40(sp)
ffffffffc0207b98:	78c2                	ld	a7,48(sp)
ffffffffc0207b9a:	44650ce3          	beq	a0,t1,ffffffffc02087f2 <stride_dequeue+0x25e4>
          r = b->left;
ffffffffc0207b9e:	008d3303          	ld	t1,8(s10)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207ba2:	010d3583          	ld	a1,16(s10)
ffffffffc0207ba6:	8542                	mv	a0,a6
ffffffffc0207ba8:	f846                	sd	a7,48(sp)
          r = b->left;
ffffffffc0207baa:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207bac:	c68fe0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          b->right = r;
ffffffffc0207bb0:	7322                	ld	t1,40(sp)
          b->left = l;
ffffffffc0207bb2:	00ad3423          	sd	a0,8(s10)
          if (l) l->parent = b;
ffffffffc0207bb6:	78c2                	ld	a7,48(sp)
          b->right = r;
ffffffffc0207bb8:	006d3823          	sd	t1,16(s10)
          if (l) l->parent = b;
ffffffffc0207bbc:	c119                	beqz	a0,ffffffffc0207bc2 <stride_dequeue+0x19b4>
ffffffffc0207bbe:	01a53023          	sd	s10,0(a0)
          a->right = r;
ffffffffc0207bc2:	7782                	ld	a5,32(sp)
          a->left = l;
ffffffffc0207bc4:	01a8b423          	sd	s10,8(a7)
          a->right = r;
ffffffffc0207bc8:	00f8b823          	sd	a5,16(a7)
          if (l) l->parent = a;
ffffffffc0207bcc:	011d3023          	sd	a7,0(s10)
ffffffffc0207bd0:	8d46                	mv	s10,a7
ffffffffc0207bd2:	f7aff06f          	j	ffffffffc020734c <stride_dequeue+0x113e>
          r = a->left;
ffffffffc0207bd6:	008b3783          	ld	a5,8(s6)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0207bda:	010b3883          	ld	a7,16(s6)
ffffffffc0207bde:	fc2a                	sd	a0,56(sp)
          r = a->left;
ffffffffc0207be0:	f03e                	sd	a5,32(sp)
     if (a == NULL) return b;
ffffffffc0207be2:	02088f63          	beqz	a7,ffffffffc0207c20 <stride_dequeue+0x1a12>
     if (comp(a, b) == -1)
ffffffffc0207be6:	85c2                	mv	a1,a6
ffffffffc0207be8:	8546                	mv	a0,a7
ffffffffc0207bea:	f842                	sd	a6,48(sp)
ffffffffc0207bec:	f446                	sd	a7,40(sp)
ffffffffc0207bee:	bcafe0ef          	jal	ra,ffffffffc0205fb8 <proc_stride_comp_f>
ffffffffc0207bf2:	7362                	ld	t1,56(sp)
ffffffffc0207bf4:	78a2                	ld	a7,40(sp)
ffffffffc0207bf6:	7842                	ld	a6,48(sp)
ffffffffc0207bf8:	486500e3          	beq	a0,t1,ffffffffc0208878 <stride_dequeue+0x266a>
          r = b->left;
ffffffffc0207bfc:	00883303          	ld	t1,8(a6)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207c00:	01083583          	ld	a1,16(a6)
ffffffffc0207c04:	8546                	mv	a0,a7
          r = b->left;
ffffffffc0207c06:	f842                	sd	a6,48(sp)
ffffffffc0207c08:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207c0a:	c0afe0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          b->left = l;
ffffffffc0207c0e:	7842                	ld	a6,48(sp)
          b->right = r;
ffffffffc0207c10:	7322                	ld	t1,40(sp)
          b->left = l;
ffffffffc0207c12:	00a83423          	sd	a0,8(a6)
          b->right = r;
ffffffffc0207c16:	00683823          	sd	t1,16(a6)
          if (l) l->parent = b;
ffffffffc0207c1a:	c119                	beqz	a0,ffffffffc0207c20 <stride_dequeue+0x1a12>
ffffffffc0207c1c:	01053023          	sd	a6,0(a0)
          a->right = r;
ffffffffc0207c20:	7782                	ld	a5,32(sp)
          a->left = l;
ffffffffc0207c22:	010b3423          	sd	a6,8(s6)
          a->right = r;
ffffffffc0207c26:	00fb3823          	sd	a5,16(s6)
          if (l) l->parent = a;
ffffffffc0207c2a:	01683023          	sd	s6,0(a6)
ffffffffc0207c2e:	885a                	mv	a6,s6
ffffffffc0207c30:	84cff06f          	j	ffffffffc0206c7c <stride_dequeue+0xa6e>
          r = a->left;
ffffffffc0207c34:	0088b783          	ld	a5,8(a7)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0207c38:	0108b803          	ld	a6,16(a7)
ffffffffc0207c3c:	fc2a                	sd	a0,56(sp)
          r = a->left;
ffffffffc0207c3e:	f03e                	sd	a5,32(sp)
     if (a == NULL) return b;
ffffffffc0207c40:	02080f63          	beqz	a6,ffffffffc0207c7e <stride_dequeue+0x1a70>
     if (comp(a, b) == -1)
ffffffffc0207c44:	8542                	mv	a0,a6
ffffffffc0207c46:	85ea                	mv	a1,s10
ffffffffc0207c48:	f846                	sd	a7,48(sp)
ffffffffc0207c4a:	f442                	sd	a6,40(sp)
ffffffffc0207c4c:	b6cfe0ef          	jal	ra,ffffffffc0205fb8 <proc_stride_comp_f>
ffffffffc0207c50:	7362                	ld	t1,56(sp)
ffffffffc0207c52:	7822                	ld	a6,40(sp)
ffffffffc0207c54:	78c2                	ld	a7,48(sp)
ffffffffc0207c56:	1c650fe3          	beq	a0,t1,ffffffffc0208634 <stride_dequeue+0x2426>
          r = b->left;
ffffffffc0207c5a:	008d3303          	ld	t1,8(s10)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207c5e:	010d3583          	ld	a1,16(s10)
ffffffffc0207c62:	8542                	mv	a0,a6
ffffffffc0207c64:	f846                	sd	a7,48(sp)
          r = b->left;
ffffffffc0207c66:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207c68:	bacfe0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          b->right = r;
ffffffffc0207c6c:	7322                	ld	t1,40(sp)
          b->left = l;
ffffffffc0207c6e:	00ad3423          	sd	a0,8(s10)
          if (l) l->parent = b;
ffffffffc0207c72:	78c2                	ld	a7,48(sp)
          b->right = r;
ffffffffc0207c74:	006d3823          	sd	t1,16(s10)
          if (l) l->parent = b;
ffffffffc0207c78:	c119                	beqz	a0,ffffffffc0207c7e <stride_dequeue+0x1a70>
ffffffffc0207c7a:	01a53023          	sd	s10,0(a0)
          a->right = r;
ffffffffc0207c7e:	7782                	ld	a5,32(sp)
          a->left = l;
ffffffffc0207c80:	01a8b423          	sd	s10,8(a7)
          a->right = r;
ffffffffc0207c84:	00f8b823          	sd	a5,16(a7)
          if (l) l->parent = a;
ffffffffc0207c88:	011d3023          	sd	a7,0(s10)
ffffffffc0207c8c:	8d46                	mv	s10,a7
ffffffffc0207c8e:	e28ff06f          	j	ffffffffc02072b6 <stride_dequeue+0x10a8>
          r = a->left;
ffffffffc0207c92:	008d3783          	ld	a5,8(s10)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0207c96:	010d3883          	ld	a7,16(s10)
ffffffffc0207c9a:	fc2a                	sd	a0,56(sp)
          r = a->left;
ffffffffc0207c9c:	f03e                	sd	a5,32(sp)
     if (a == NULL) return b;
ffffffffc0207c9e:	02088f63          	beqz	a7,ffffffffc0207cdc <stride_dequeue+0x1ace>
     if (comp(a, b) == -1)
ffffffffc0207ca2:	85c2                	mv	a1,a6
ffffffffc0207ca4:	8546                	mv	a0,a7
ffffffffc0207ca6:	f842                	sd	a6,48(sp)
ffffffffc0207ca8:	f446                	sd	a7,40(sp)
ffffffffc0207caa:	b0efe0ef          	jal	ra,ffffffffc0205fb8 <proc_stride_comp_f>
ffffffffc0207cae:	7362                	ld	t1,56(sp)
ffffffffc0207cb0:	78a2                	ld	a7,40(sp)
ffffffffc0207cb2:	7842                	ld	a6,48(sp)
ffffffffc0207cb4:	3e6507e3          	beq	a0,t1,ffffffffc02088a2 <stride_dequeue+0x2694>
          r = b->left;
ffffffffc0207cb8:	00883303          	ld	t1,8(a6)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207cbc:	01083583          	ld	a1,16(a6)
ffffffffc0207cc0:	8546                	mv	a0,a7
          r = b->left;
ffffffffc0207cc2:	f842                	sd	a6,48(sp)
ffffffffc0207cc4:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207cc6:	b4efe0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          b->left = l;
ffffffffc0207cca:	7842                	ld	a6,48(sp)
          b->right = r;
ffffffffc0207ccc:	7322                	ld	t1,40(sp)
          b->left = l;
ffffffffc0207cce:	00a83423          	sd	a0,8(a6)
          b->right = r;
ffffffffc0207cd2:	00683823          	sd	t1,16(a6)
          if (l) l->parent = b;
ffffffffc0207cd6:	c119                	beqz	a0,ffffffffc0207cdc <stride_dequeue+0x1ace>
ffffffffc0207cd8:	01053023          	sd	a6,0(a0)
          a->right = r;
ffffffffc0207cdc:	7782                	ld	a5,32(sp)
          a->left = l;
ffffffffc0207cde:	010d3423          	sd	a6,8(s10)
          a->right = r;
ffffffffc0207ce2:	00fd3823          	sd	a5,16(s10)
          if (l) l->parent = a;
ffffffffc0207ce6:	01a83023          	sd	s10,0(a6)
ffffffffc0207cea:	886a                	mv	a6,s10
ffffffffc0207cec:	858ff06f          	j	ffffffffc0206d44 <stride_dequeue+0xb36>
          r = a->left;
ffffffffc0207cf0:	008b3783          	ld	a5,8(s6)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0207cf4:	010b3883          	ld	a7,16(s6)
ffffffffc0207cf8:	fc2a                	sd	a0,56(sp)
          r = a->left;
ffffffffc0207cfa:	f03e                	sd	a5,32(sp)
     if (a == NULL) return b;
ffffffffc0207cfc:	02088f63          	beqz	a7,ffffffffc0207d3a <stride_dequeue+0x1b2c>
     if (comp(a, b) == -1)
ffffffffc0207d00:	85c2                	mv	a1,a6
ffffffffc0207d02:	8546                	mv	a0,a7
ffffffffc0207d04:	f842                	sd	a6,48(sp)
ffffffffc0207d06:	f446                	sd	a7,40(sp)
ffffffffc0207d08:	ab0fe0ef          	jal	ra,ffffffffc0205fb8 <proc_stride_comp_f>
ffffffffc0207d0c:	7362                	ld	t1,56(sp)
ffffffffc0207d0e:	78a2                	ld	a7,40(sp)
ffffffffc0207d10:	7842                	ld	a6,48(sp)
ffffffffc0207d12:	16650fe3          	beq	a0,t1,ffffffffc0208690 <stride_dequeue+0x2482>
          r = b->left;
ffffffffc0207d16:	00883303          	ld	t1,8(a6)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207d1a:	01083583          	ld	a1,16(a6)
ffffffffc0207d1e:	8546                	mv	a0,a7
          r = b->left;
ffffffffc0207d20:	f842                	sd	a6,48(sp)
ffffffffc0207d22:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207d24:	af0fe0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          b->left = l;
ffffffffc0207d28:	7842                	ld	a6,48(sp)
          b->right = r;
ffffffffc0207d2a:	7322                	ld	t1,40(sp)
          b->left = l;
ffffffffc0207d2c:	00a83423          	sd	a0,8(a6)
          b->right = r;
ffffffffc0207d30:	00683823          	sd	t1,16(a6)
          if (l) l->parent = b;
ffffffffc0207d34:	c119                	beqz	a0,ffffffffc0207d3a <stride_dequeue+0x1b2c>
ffffffffc0207d36:	01053023          	sd	a6,0(a0)
          a->right = r;
ffffffffc0207d3a:	7782                	ld	a5,32(sp)
          a->left = l;
ffffffffc0207d3c:	010b3423          	sd	a6,8(s6)
          a->right = r;
ffffffffc0207d40:	00fb3823          	sd	a5,16(s6)
          if (l) l->parent = a;
ffffffffc0207d44:	01683023          	sd	s6,0(a6)
ffffffffc0207d48:	885a                	mv	a6,s6
ffffffffc0207d4a:	ad9fe06f          	j	ffffffffc0206822 <stride_dequeue+0x614>
ffffffffc0207d4e:	836e                	mv	t1,s11
ffffffffc0207d50:	f76fe06f          	j	ffffffffc02064c6 <stride_dequeue+0x2b8>
ffffffffc0207d54:	8362                	mv	t1,s8
ffffffffc0207d56:	8a5fe06f          	j	ffffffffc02065fa <stride_dequeue+0x3ec>
     else if (b == NULL) return a;
ffffffffc0207d5a:	8d66                	mv	s10,s9
ffffffffc0207d5c:	e5bfe06f          	j	ffffffffc0206bb6 <stride_dequeue+0x9a8>
          r = a->left;
ffffffffc0207d60:	008d3783          	ld	a5,8(s10)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0207d64:	010d3883          	ld	a7,16(s10)
ffffffffc0207d68:	fc2a                	sd	a0,56(sp)
          r = a->left;
ffffffffc0207d6a:	f03e                	sd	a5,32(sp)
     if (a == NULL) return b;
ffffffffc0207d6c:	02088f63          	beqz	a7,ffffffffc0207daa <stride_dequeue+0x1b9c>
     if (comp(a, b) == -1)
ffffffffc0207d70:	85c2                	mv	a1,a6
ffffffffc0207d72:	8546                	mv	a0,a7
ffffffffc0207d74:	f842                	sd	a6,48(sp)
ffffffffc0207d76:	f446                	sd	a7,40(sp)
ffffffffc0207d78:	a40fe0ef          	jal	ra,ffffffffc0205fb8 <proc_stride_comp_f>
ffffffffc0207d7c:	7362                	ld	t1,56(sp)
ffffffffc0207d7e:	78a2                	ld	a7,40(sp)
ffffffffc0207d80:	7842                	ld	a6,48(sp)
ffffffffc0207d82:	04650de3          	beq	a0,t1,ffffffffc02085dc <stride_dequeue+0x23ce>
          r = b->left;
ffffffffc0207d86:	00883303          	ld	t1,8(a6)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207d8a:	01083583          	ld	a1,16(a6)
ffffffffc0207d8e:	8546                	mv	a0,a7
          r = b->left;
ffffffffc0207d90:	f842                	sd	a6,48(sp)
ffffffffc0207d92:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207d94:	a80fe0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          b->left = l;
ffffffffc0207d98:	7842                	ld	a6,48(sp)
          b->right = r;
ffffffffc0207d9a:	7322                	ld	t1,40(sp)
          b->left = l;
ffffffffc0207d9c:	00a83423          	sd	a0,8(a6)
          b->right = r;
ffffffffc0207da0:	00683823          	sd	t1,16(a6)
          if (l) l->parent = b;
ffffffffc0207da4:	c119                	beqz	a0,ffffffffc0207daa <stride_dequeue+0x1b9c>
ffffffffc0207da6:	01053023          	sd	a6,0(a0)
          a->right = r;
ffffffffc0207daa:	7782                	ld	a5,32(sp)
          a->left = l;
ffffffffc0207dac:	010d3423          	sd	a6,8(s10)
          a->right = r;
ffffffffc0207db0:	00fd3823          	sd	a5,16(s10)
          if (l) l->parent = a;
ffffffffc0207db4:	01a83023          	sd	s10,0(a6)
ffffffffc0207db8:	886a                	mv	a6,s10
ffffffffc0207dba:	b59fe06f          	j	ffffffffc0206912 <stride_dequeue+0x704>
          r = a->left;
ffffffffc0207dbe:	008c3703          	ld	a4,8(s8)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0207dc2:	010c3883          	ld	a7,16(s8)
ffffffffc0207dc6:	fc2a                	sd	a0,56(sp)
          r = a->left;
ffffffffc0207dc8:	f03a                	sd	a4,32(sp)
     if (a == NULL) return b;
ffffffffc0207dca:	02088c63          	beqz	a7,ffffffffc0207e02 <stride_dequeue+0x1bf4>
     if (comp(a, b) == -1)
ffffffffc0207dce:	85be                	mv	a1,a5
ffffffffc0207dd0:	8546                	mv	a0,a7
ffffffffc0207dd2:	f83e                	sd	a5,48(sp)
ffffffffc0207dd4:	f446                	sd	a7,40(sp)
ffffffffc0207dd6:	9e2fe0ef          	jal	ra,ffffffffc0205fb8 <proc_stride_comp_f>
ffffffffc0207dda:	7362                	ld	t1,56(sp)
ffffffffc0207ddc:	78a2                	ld	a7,40(sp)
ffffffffc0207dde:	77c2                	ld	a5,48(sp)
ffffffffc0207de0:	7a650063          	beq	a0,t1,ffffffffc0208580 <stride_dequeue+0x2372>
          r = b->left;
ffffffffc0207de4:	0087b303          	ld	t1,8(a5)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207de8:	6b8c                	ld	a1,16(a5)
ffffffffc0207dea:	8546                	mv	a0,a7
          r = b->left;
ffffffffc0207dec:	f83e                	sd	a5,48(sp)
ffffffffc0207dee:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207df0:	a24fe0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          b->left = l;
ffffffffc0207df4:	77c2                	ld	a5,48(sp)
          b->right = r;
ffffffffc0207df6:	7322                	ld	t1,40(sp)
          b->left = l;
ffffffffc0207df8:	e788                	sd	a0,8(a5)
          b->right = r;
ffffffffc0207dfa:	0067b823          	sd	t1,16(a5)
          if (l) l->parent = b;
ffffffffc0207dfe:	c111                	beqz	a0,ffffffffc0207e02 <stride_dequeue+0x1bf4>
ffffffffc0207e00:	e11c                	sd	a5,0(a0)
          a->right = r;
ffffffffc0207e02:	7702                	ld	a4,32(sp)
          a->left = l;
ffffffffc0207e04:	00fc3423          	sd	a5,8(s8)
          a->right = r;
ffffffffc0207e08:	00ec3823          	sd	a4,16(s8)
          if (l) l->parent = a;
ffffffffc0207e0c:	0187b023          	sd	s8,0(a5)
ffffffffc0207e10:	87e2                	mv	a5,s8
ffffffffc0207e12:	90ffe06f          	j	ffffffffc0206720 <stride_dequeue+0x512>
          r = a->left;
ffffffffc0207e16:	0088b783          	ld	a5,8(a7)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0207e1a:	0108b803          	ld	a6,16(a7)
ffffffffc0207e1e:	fc2a                	sd	a0,56(sp)
          r = a->left;
ffffffffc0207e20:	f03e                	sd	a5,32(sp)
     if (a == NULL) return b;
ffffffffc0207e22:	02080f63          	beqz	a6,ffffffffc0207e60 <stride_dequeue+0x1c52>
     if (comp(a, b) == -1)
ffffffffc0207e26:	8542                	mv	a0,a6
ffffffffc0207e28:	85da                	mv	a1,s6
ffffffffc0207e2a:	f846                	sd	a7,48(sp)
ffffffffc0207e2c:	f442                	sd	a6,40(sp)
ffffffffc0207e2e:	98afe0ef          	jal	ra,ffffffffc0205fb8 <proc_stride_comp_f>
ffffffffc0207e32:	7362                	ld	t1,56(sp)
ffffffffc0207e34:	7822                	ld	a6,40(sp)
ffffffffc0207e36:	78c2                	ld	a7,48(sp)
ffffffffc0207e38:	0c650fe3          	beq	a0,t1,ffffffffc0208716 <stride_dequeue+0x2508>
          r = b->left;
ffffffffc0207e3c:	008b3303          	ld	t1,8(s6)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207e40:	010b3583          	ld	a1,16(s6)
ffffffffc0207e44:	8542                	mv	a0,a6
ffffffffc0207e46:	f846                	sd	a7,48(sp)
          r = b->left;
ffffffffc0207e48:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207e4a:	9cafe0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          b->right = r;
ffffffffc0207e4e:	7322                	ld	t1,40(sp)
          b->left = l;
ffffffffc0207e50:	00ab3423          	sd	a0,8(s6)
          if (l) l->parent = b;
ffffffffc0207e54:	78c2                	ld	a7,48(sp)
          b->right = r;
ffffffffc0207e56:	006b3823          	sd	t1,16(s6)
          if (l) l->parent = b;
ffffffffc0207e5a:	c119                	beqz	a0,ffffffffc0207e60 <stride_dequeue+0x1c52>
ffffffffc0207e5c:	01653023          	sd	s6,0(a0)
          a->right = r;
ffffffffc0207e60:	7782                	ld	a5,32(sp)
          a->left = l;
ffffffffc0207e62:	0168b423          	sd	s6,8(a7)
          a->right = r;
ffffffffc0207e66:	00f8b823          	sd	a5,16(a7)
          if (l) l->parent = a;
ffffffffc0207e6a:	011b3023          	sd	a7,0(s6)
ffffffffc0207e6e:	8b46                	mv	s6,a7
ffffffffc0207e70:	b1eff06f          	j	ffffffffc020718e <stride_dequeue+0xf80>
ffffffffc0207e74:	8366                	mv	t1,s9
ffffffffc0207e76:	b5dfe06f          	j	ffffffffc02069d2 <stride_dequeue+0x7c4>
ffffffffc0207e7a:	8366                	mv	t1,s9
ffffffffc0207e7c:	c2ffe06f          	j	ffffffffc0206aaa <stride_dequeue+0x89c>
          r = a->left;
ffffffffc0207e80:	0088b783          	ld	a5,8(a7)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0207e84:	0108b803          	ld	a6,16(a7)
ffffffffc0207e88:	fc2a                	sd	a0,56(sp)
          r = a->left;
ffffffffc0207e8a:	f03e                	sd	a5,32(sp)
     if (a == NULL) return b;
ffffffffc0207e8c:	02080f63          	beqz	a6,ffffffffc0207eca <stride_dequeue+0x1cbc>
     if (comp(a, b) == -1)
ffffffffc0207e90:	8542                	mv	a0,a6
ffffffffc0207e92:	85ea                	mv	a1,s10
ffffffffc0207e94:	f846                	sd	a7,48(sp)
ffffffffc0207e96:	f442                	sd	a6,40(sp)
ffffffffc0207e98:	920fe0ef          	jal	ra,ffffffffc0205fb8 <proc_stride_comp_f>
ffffffffc0207e9c:	7362                	ld	t1,56(sp)
ffffffffc0207e9e:	7822                	ld	a6,40(sp)
ffffffffc0207ea0:	78c2                	ld	a7,48(sp)
ffffffffc0207ea2:	046502e3          	beq	a0,t1,ffffffffc02086e6 <stride_dequeue+0x24d8>
          r = b->left;
ffffffffc0207ea6:	008d3303          	ld	t1,8(s10)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207eaa:	010d3583          	ld	a1,16(s10)
ffffffffc0207eae:	8542                	mv	a0,a6
ffffffffc0207eb0:	f846                	sd	a7,48(sp)
          r = b->left;
ffffffffc0207eb2:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a, b->right, comp);
ffffffffc0207eb4:	960fe0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          b->right = r;
ffffffffc0207eb8:	7322                	ld	t1,40(sp)
          b->left = l;
ffffffffc0207eba:	00ad3423          	sd	a0,8(s10)
          if (l) l->parent = b;
ffffffffc0207ebe:	78c2                	ld	a7,48(sp)
          b->right = r;
ffffffffc0207ec0:	006d3823          	sd	t1,16(s10)
          if (l) l->parent = b;
ffffffffc0207ec4:	c119                	beqz	a0,ffffffffc0207eca <stride_dequeue+0x1cbc>
ffffffffc0207ec6:	01a53023          	sd	s10,0(a0)
          a->right = r;
ffffffffc0207eca:	7782                	ld	a5,32(sp)
          a->left = l;
ffffffffc0207ecc:	01a8b423          	sd	s10,8(a7)
          a->right = r;
ffffffffc0207ed0:	00f8b823          	sd	a5,16(a7)
          if (l) l->parent = a;
ffffffffc0207ed4:	011d3023          	sd	a7,0(s10)
ffffffffc0207ed8:	8d46                	mv	s10,a7
ffffffffc0207eda:	b4aff06f          	j	ffffffffc0207224 <stride_dequeue+0x1016>
          r = a->left;
ffffffffc0207ede:	008db883          	ld	a7,8(s11)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0207ee2:	010db503          	ld	a0,16(s11)
ffffffffc0207ee6:	859a                	mv	a1,t1
          r = a->left;
ffffffffc0207ee8:	f446                	sd	a7,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0207eea:	92afe0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->right = r;
ffffffffc0207eee:	78a2                	ld	a7,40(sp)
          a->left = l;
ffffffffc0207ef0:	00adb423          	sd	a0,8(s11)
          if (l) l->parent = a;
ffffffffc0207ef4:	77c2                	ld	a5,48(sp)
          a->right = r;
ffffffffc0207ef6:	011db823          	sd	a7,16(s11)
          if (l) l->parent = a;
ffffffffc0207efa:	e4050ae3          	beqz	a0,ffffffffc0207d4e <stride_dequeue+0x1b40>
ffffffffc0207efe:	01b53023          	sd	s11,0(a0)
ffffffffc0207f02:	836e                	mv	t1,s11
ffffffffc0207f04:	dc2fe06f          	j	ffffffffc02064c6 <stride_dequeue+0x2b8>
          r = a->left;
ffffffffc0207f08:	008c3883          	ld	a7,8(s8)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0207f0c:	010c3503          	ld	a0,16(s8)
ffffffffc0207f10:	859a                	mv	a1,t1
          r = a->left;
ffffffffc0207f12:	f446                	sd	a7,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0207f14:	900fe0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->right = r;
ffffffffc0207f18:	78a2                	ld	a7,40(sp)
          a->left = l;
ffffffffc0207f1a:	00ac3423          	sd	a0,8(s8)
          if (l) l->parent = a;
ffffffffc0207f1e:	77c2                	ld	a5,48(sp)
          a->right = r;
ffffffffc0207f20:	011c3823          	sd	a7,16(s8)
          if (l) l->parent = a;
ffffffffc0207f24:	e20508e3          	beqz	a0,ffffffffc0207d54 <stride_dequeue+0x1b46>
ffffffffc0207f28:	01853023          	sd	s8,0(a0)
ffffffffc0207f2c:	8362                	mv	t1,s8
ffffffffc0207f2e:	eccfe06f          	j	ffffffffc02065fa <stride_dequeue+0x3ec>
          r = a->left;
ffffffffc0207f32:	008cb883          	ld	a7,8(s9)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0207f36:	010cb503          	ld	a0,16(s9)
ffffffffc0207f3a:	859a                	mv	a1,t1
          r = a->left;
ffffffffc0207f3c:	f446                	sd	a7,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0207f3e:	8d6fe0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->right = r;
ffffffffc0207f42:	78a2                	ld	a7,40(sp)
          a->left = l;
ffffffffc0207f44:	00acb423          	sd	a0,8(s9)
          if (l) l->parent = a;
ffffffffc0207f48:	7842                	ld	a6,48(sp)
          a->right = r;
ffffffffc0207f4a:	011cb823          	sd	a7,16(s9)
          if (l) l->parent = a;
ffffffffc0207f4e:	d11d                	beqz	a0,ffffffffc0207e74 <stride_dequeue+0x1c66>
ffffffffc0207f50:	01953023          	sd	s9,0(a0)
ffffffffc0207f54:	8366                	mv	t1,s9
ffffffffc0207f56:	a7dfe06f          	j	ffffffffc02069d2 <stride_dequeue+0x7c4>
          r = a->left;
ffffffffc0207f5a:	0088b303          	ld	t1,8(a7)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0207f5e:	0108b503          	ld	a0,16(a7)
ffffffffc0207f62:	85be                	mv	a1,a5
          r = a->left;
ffffffffc0207f64:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0207f66:	8aefe0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->left = l;
ffffffffc0207f6a:	78c2                	ld	a7,48(sp)
          a->right = r;
ffffffffc0207f6c:	7322                	ld	t1,40(sp)
          a->left = l;
ffffffffc0207f6e:	00a8b423          	sd	a0,8(a7)
          a->right = r;
ffffffffc0207f72:	0068b823          	sd	t1,16(a7)
          if (l) l->parent = a;
ffffffffc0207f76:	5c050c63          	beqz	a0,ffffffffc020854e <stride_dequeue+0x2340>
ffffffffc0207f7a:	01153023          	sd	a7,0(a0)
ffffffffc0207f7e:	87c6                	mv	a5,a7
ffffffffc0207f80:	c24ff06f          	j	ffffffffc02073a4 <stride_dequeue+0x1196>
          r = a->left;
ffffffffc0207f84:	0088b803          	ld	a6,8(a7)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0207f88:	0108b503          	ld	a0,16(a7)
ffffffffc0207f8c:	859a                	mv	a1,t1
          r = a->left;
ffffffffc0207f8e:	f442                	sd	a6,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0207f90:	884fe0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->left = l;
ffffffffc0207f94:	78c2                	ld	a7,48(sp)
          a->right = r;
ffffffffc0207f96:	7822                	ld	a6,40(sp)
          a->left = l;
ffffffffc0207f98:	00a8b423          	sd	a0,8(a7)
          a->right = r;
ffffffffc0207f9c:	0108b823          	sd	a6,16(a7)
          if (l) l->parent = a;
ffffffffc0207fa0:	b6050ae3          	beqz	a0,ffffffffc0207b14 <stride_dequeue+0x1906>
ffffffffc0207fa4:	01153023          	sd	a7,0(a0)
ffffffffc0207fa8:	8346                	mv	t1,a7
ffffffffc0207faa:	eeffe06f          	j	ffffffffc0206e98 <stride_dequeue+0xc8a>
          r = a->left;
ffffffffc0207fae:	008cb883          	ld	a7,8(s9)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0207fb2:	010cb503          	ld	a0,16(s9)
ffffffffc0207fb6:	859a                	mv	a1,t1
          r = a->left;
ffffffffc0207fb8:	f446                	sd	a7,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0207fba:	85afe0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->right = r;
ffffffffc0207fbe:	78a2                	ld	a7,40(sp)
          a->left = l;
ffffffffc0207fc0:	00acb423          	sd	a0,8(s9)
          if (l) l->parent = a;
ffffffffc0207fc4:	77c2                	ld	a5,48(sp)
          a->right = r;
ffffffffc0207fc6:	011cb823          	sd	a7,16(s9)
          if (l) l->parent = a;
ffffffffc0207fca:	ea0508e3          	beqz	a0,ffffffffc0207e7a <stride_dequeue+0x1c6c>
ffffffffc0207fce:	01953023          	sd	s9,0(a0)
ffffffffc0207fd2:	8366                	mv	t1,s9
ffffffffc0207fd4:	ad7fe06f          	j	ffffffffc0206aaa <stride_dequeue+0x89c>
     else if (b == NULL) return a;
ffffffffc0207fd8:	87e2                	mv	a5,s8
ffffffffc0207fda:	f46fe06f          	j	ffffffffc0206720 <stride_dequeue+0x512>
ffffffffc0207fde:	885a                	mv	a6,s6
ffffffffc0207fe0:	843fe06f          	j	ffffffffc0206822 <stride_dequeue+0x614>
ffffffffc0207fe4:	885a                	mv	a6,s6
ffffffffc0207fe6:	c97fe06f          	j	ffffffffc0206c7c <stride_dequeue+0xa6e>
ffffffffc0207fea:	886a                	mv	a6,s10
ffffffffc0207fec:	d59fe06f          	j	ffffffffc0206d44 <stride_dequeue+0xb36>
ffffffffc0207ff0:	886a                	mv	a6,s10
ffffffffc0207ff2:	e17fe06f          	j	ffffffffc0206e08 <stride_dequeue+0xbfa>
ffffffffc0207ff6:	886a                	mv	a6,s10
ffffffffc0207ff8:	91bfe06f          	j	ffffffffc0206912 <stride_dequeue+0x704>
          r = a->left;
ffffffffc0207ffc:	008d3783          	ld	a5,8(s10)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208000:	010d3503          	ld	a0,16(s10)
ffffffffc0208004:	85a6                	mv	a1,s1
          r = a->left;
ffffffffc0208006:	ec3e                	sd	a5,24(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208008:	80cfe0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->right = r;
ffffffffc020800c:	67e2                	ld	a5,24(sp)
          a->left = l;
ffffffffc020800e:	00ad3423          	sd	a0,8(s10)
          a->right = r;
ffffffffc0208012:	00fd3823          	sd	a5,16(s10)
          if (l) l->parent = a;
ffffffffc0208016:	c0050663          	beqz	a0,ffffffffc0207422 <stride_dequeue+0x1214>
ffffffffc020801a:	01a53023          	sd	s10,0(a0)
ffffffffc020801e:	c04ff06f          	j	ffffffffc0207422 <stride_dequeue+0x1214>
          r = a->left;
ffffffffc0208022:	0088b803          	ld	a6,8(a7)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208026:	0108b503          	ld	a0,16(a7)
ffffffffc020802a:	859a                	mv	a1,t1
          r = a->left;
ffffffffc020802c:	f442                	sd	a6,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc020802e:	fe7fd0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->left = l;
ffffffffc0208032:	78c2                	ld	a7,48(sp)
          a->right = r;
ffffffffc0208034:	7822                	ld	a6,40(sp)
          a->left = l;
ffffffffc0208036:	00a8b423          	sd	a0,8(a7)
          a->right = r;
ffffffffc020803a:	0108b823          	sd	a6,16(a7)
          if (l) l->parent = a;
ffffffffc020803e:	a6050563          	beqz	a0,ffffffffc02072a8 <stride_dequeue+0x109a>
ffffffffc0208042:	01153023          	sd	a7,0(a0)
ffffffffc0208046:	a62ff06f          	j	ffffffffc02072a8 <stride_dequeue+0x109a>
          r = a->left;
ffffffffc020804a:	00883303          	ld	t1,8(a6)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc020804e:	01083503          	ld	a0,16(a6)
ffffffffc0208052:	85e6                	mv	a1,s9
          r = a->left;
ffffffffc0208054:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208056:	fbffd0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->left = l;
ffffffffc020805a:	7842                	ld	a6,48(sp)
          a->right = r;
ffffffffc020805c:	7322                	ld	t1,40(sp)
          if (l) l->parent = a;
ffffffffc020805e:	78e2                	ld	a7,56(sp)
          a->left = l;
ffffffffc0208060:	00a83423          	sd	a0,8(a6)
          a->right = r;
ffffffffc0208064:	00683823          	sd	t1,16(a6)
          if (l) l->parent = a;
ffffffffc0208068:	0a0500e3          	beqz	a0,ffffffffc0208908 <stride_dequeue+0x26fa>
ffffffffc020806c:	01053023          	sd	a6,0(a0)
ffffffffc0208070:	8cc2                	mv	s9,a6
ffffffffc0208072:	fb2ff06f          	j	ffffffffc0207824 <stride_dequeue+0x1616>
          r = a->left;
ffffffffc0208076:	00883783          	ld	a5,8(a6)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc020807a:	01083503          	ld	a0,16(a6)
ffffffffc020807e:	85e6                	mv	a1,s9
          r = a->left;
ffffffffc0208080:	f03e                	sd	a5,32(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208082:	f93fd0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->left = l;
ffffffffc0208086:	7822                	ld	a6,40(sp)
          a->right = r;
ffffffffc0208088:	7782                	ld	a5,32(sp)
          a->left = l;
ffffffffc020808a:	00a83423          	sd	a0,8(a6)
          a->right = r;
ffffffffc020808e:	00f83823          	sd	a5,16(a6)
          if (l) l->parent = a;
ffffffffc0208092:	f2050b63          	beqz	a0,ffffffffc02077c8 <stride_dequeue+0x15ba>
ffffffffc0208096:	01053023          	sd	a6,0(a0)
ffffffffc020809a:	f2eff06f          	j	ffffffffc02077c8 <stride_dequeue+0x15ba>
          r = a->left;
ffffffffc020809e:	008b3883          	ld	a7,8(s6)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02080a2:	010b3503          	ld	a0,16(s6)
ffffffffc02080a6:	859a                	mv	a1,t1
          r = a->left;
ffffffffc02080a8:	f446                	sd	a7,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02080aa:	f6bfd0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->right = r;
ffffffffc02080ae:	78a2                	ld	a7,40(sp)
          a->left = l;
ffffffffc02080b0:	00ab3423          	sd	a0,8(s6)
          if (l) l->parent = a;
ffffffffc02080b4:	7842                	ld	a6,48(sp)
          a->right = r;
ffffffffc02080b6:	011b3823          	sd	a7,16(s6)
          if (l) l->parent = a;
ffffffffc02080ba:	e119                	bnez	a0,ffffffffc02080c0 <stride_dequeue+0x1eb2>
ffffffffc02080bc:	f58fe06f          	j	ffffffffc0206814 <stride_dequeue+0x606>
ffffffffc02080c0:	01653023          	sd	s6,0(a0)
ffffffffc02080c4:	f50fe06f          	j	ffffffffc0206814 <stride_dequeue+0x606>
          r = a->left;
ffffffffc02080c8:	00883783          	ld	a5,8(a6)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02080cc:	01083503          	ld	a0,16(a6)
ffffffffc02080d0:	85e6                	mv	a1,s9
          r = a->left;
ffffffffc02080d2:	f03e                	sd	a5,32(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02080d4:	f41fd0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->left = l;
ffffffffc02080d8:	7822                	ld	a6,40(sp)
          a->right = r;
ffffffffc02080da:	7782                	ld	a5,32(sp)
          a->left = l;
ffffffffc02080dc:	00a83423          	sd	a0,8(a6)
          a->right = r;
ffffffffc02080e0:	00f83823          	sd	a5,16(a6)
          if (l) l->parent = a;
ffffffffc02080e4:	da050963          	beqz	a0,ffffffffc0207696 <stride_dequeue+0x1488>
ffffffffc02080e8:	01053023          	sd	a6,0(a0)
ffffffffc02080ec:	daaff06f          	j	ffffffffc0207696 <stride_dequeue+0x1488>
     if (a == NULL) return b;
ffffffffc02080f0:	8d26                	mv	s10,s1
ffffffffc02080f2:	b30ff06f          	j	ffffffffc0207422 <stride_dequeue+0x1214>
          r = a->left;
ffffffffc02080f6:	00883783          	ld	a5,8(a6)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02080fa:	01083503          	ld	a0,16(a6)
ffffffffc02080fe:	85e6                	mv	a1,s9
          r = a->left;
ffffffffc0208100:	f03e                	sd	a5,32(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208102:	f13fd0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->left = l;
ffffffffc0208106:	7822                	ld	a6,40(sp)
          a->right = r;
ffffffffc0208108:	7782                	ld	a5,32(sp)
          a->left = l;
ffffffffc020810a:	00a83423          	sd	a0,8(a6)
          a->right = r;
ffffffffc020810e:	00f83823          	sd	a5,16(a6)
          if (l) l->parent = a;
ffffffffc0208112:	e0050f63          	beqz	a0,ffffffffc0207730 <stride_dequeue+0x1522>
ffffffffc0208116:	01053023          	sd	a6,0(a0)
ffffffffc020811a:	e16ff06f          	j	ffffffffc0207730 <stride_dequeue+0x1522>
          r = a->left;
ffffffffc020811e:	00883783          	ld	a5,8(a6)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208122:	01083503          	ld	a0,16(a6)
ffffffffc0208126:	85e6                	mv	a1,s9
          r = a->left;
ffffffffc0208128:	f03e                	sd	a5,32(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc020812a:	eebfd0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->left = l;
ffffffffc020812e:	7822                	ld	a6,40(sp)
          a->right = r;
ffffffffc0208130:	7782                	ld	a5,32(sp)
          a->left = l;
ffffffffc0208132:	00a83423          	sd	a0,8(a6)
          a->right = r;
ffffffffc0208136:	00f83823          	sd	a5,16(a6)
          if (l) l->parent = a;
ffffffffc020813a:	c2050363          	beqz	a0,ffffffffc0207560 <stride_dequeue+0x1352>
ffffffffc020813e:	01053023          	sd	a6,0(a0)
ffffffffc0208142:	c1eff06f          	j	ffffffffc0207560 <stride_dequeue+0x1352>
          r = a->left;
ffffffffc0208146:	008d3883          	ld	a7,8(s10)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc020814a:	010d3503          	ld	a0,16(s10)
ffffffffc020814e:	859a                	mv	a1,t1
          r = a->left;
ffffffffc0208150:	f446                	sd	a7,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208152:	ec3fd0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->right = r;
ffffffffc0208156:	78a2                	ld	a7,40(sp)
          a->left = l;
ffffffffc0208158:	00ad3423          	sd	a0,8(s10)
          if (l) l->parent = a;
ffffffffc020815c:	7842                	ld	a6,48(sp)
          a->right = r;
ffffffffc020815e:	011d3823          	sd	a7,16(s10)
          if (l) l->parent = a;
ffffffffc0208162:	e119                	bnez	a0,ffffffffc0208168 <stride_dequeue+0x1f5a>
ffffffffc0208164:	bd3fe06f          	j	ffffffffc0206d36 <stride_dequeue+0xb28>
ffffffffc0208168:	01a53023          	sd	s10,0(a0)
ffffffffc020816c:	bcbfe06f          	j	ffffffffc0206d36 <stride_dequeue+0xb28>
          r = a->left;
ffffffffc0208170:	0088b303          	ld	t1,8(a7)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208174:	0108b503          	ld	a0,16(a7)
ffffffffc0208178:	85be                	mv	a1,a5
          r = a->left;
ffffffffc020817a:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc020817c:	e99fd0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->left = l;
ffffffffc0208180:	78c2                	ld	a7,48(sp)
          a->right = r;
ffffffffc0208182:	7322                	ld	t1,40(sp)
          a->left = l;
ffffffffc0208184:	00a8b423          	sd	a0,8(a7)
          a->right = r;
ffffffffc0208188:	0068b823          	sd	t1,16(a7)
          if (l) l->parent = a;
ffffffffc020818c:	7c050b63          	beqz	a0,ffffffffc0208962 <stride_dequeue+0x2754>
ffffffffc0208190:	01153023          	sd	a7,0(a0)
ffffffffc0208194:	87c6                	mv	a5,a7
ffffffffc0208196:	feeff06f          	j	ffffffffc0207984 <stride_dequeue+0x1776>
          r = a->left;
ffffffffc020819a:	008cb783          	ld	a5,8(s9)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc020819e:	010cb503          	ld	a0,16(s9)
ffffffffc02081a2:	85c2                	mv	a1,a6
          r = a->left;
ffffffffc02081a4:	f03e                	sd	a5,32(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02081a6:	e6ffd0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->right = r;
ffffffffc02081aa:	7782                	ld	a5,32(sp)
          a->left = l;
ffffffffc02081ac:	00acb423          	sd	a0,8(s9)
          a->right = r;
ffffffffc02081b0:	00fcb823          	sd	a5,16(s9)
          if (l) l->parent = a;
ffffffffc02081b4:	e119                	bnez	a0,ffffffffc02081ba <stride_dequeue+0x1fac>
ffffffffc02081b6:	da9fe06f          	j	ffffffffc0206f5e <stride_dequeue+0xd50>
ffffffffc02081ba:	01953023          	sd	s9,0(a0)
ffffffffc02081be:	da1fe06f          	j	ffffffffc0206f5e <stride_dequeue+0xd50>
          r = a->left;
ffffffffc02081c2:	008d3883          	ld	a7,8(s10)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02081c6:	010d3503          	ld	a0,16(s10)
ffffffffc02081ca:	859a                	mv	a1,t1
          r = a->left;
ffffffffc02081cc:	f446                	sd	a7,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02081ce:	e47fd0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->right = r;
ffffffffc02081d2:	78a2                	ld	a7,40(sp)
          a->left = l;
ffffffffc02081d4:	00ad3423          	sd	a0,8(s10)
          if (l) l->parent = a;
ffffffffc02081d8:	7842                	ld	a6,48(sp)
          a->right = r;
ffffffffc02081da:	011d3823          	sd	a7,16(s10)
          if (l) l->parent = a;
ffffffffc02081de:	e119                	bnez	a0,ffffffffc02081e4 <stride_dequeue+0x1fd6>
ffffffffc02081e0:	c1bfe06f          	j	ffffffffc0206dfa <stride_dequeue+0xbec>
ffffffffc02081e4:	01a53023          	sd	s10,0(a0)
ffffffffc02081e8:	c13fe06f          	j	ffffffffc0206dfa <stride_dequeue+0xbec>
          r = a->left;
ffffffffc02081ec:	008cb783          	ld	a5,8(s9)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02081f0:	010cb503          	ld	a0,16(s9)
ffffffffc02081f4:	85ba                	mv	a1,a4
          r = a->left;
ffffffffc02081f6:	f03e                	sd	a5,32(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02081f8:	e1dfd0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->right = r;
ffffffffc02081fc:	7782                	ld	a5,32(sp)
          a->left = l;
ffffffffc02081fe:	00acb423          	sd	a0,8(s9)
          a->right = r;
ffffffffc0208202:	00fcb823          	sd	a5,16(s9)
          if (l) l->parent = a;
ffffffffc0208206:	e119                	bnez	a0,ffffffffc020820c <stride_dequeue+0x1ffe>
ffffffffc0208208:	9a1fe06f          	j	ffffffffc0206ba8 <stride_dequeue+0x99a>
ffffffffc020820c:	01953023          	sd	s9,0(a0)
ffffffffc0208210:	999fe06f          	j	ffffffffc0206ba8 <stride_dequeue+0x99a>
          r = a->left;
ffffffffc0208214:	008b3883          	ld	a7,8(s6)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208218:	010b3503          	ld	a0,16(s6)
ffffffffc020821c:	859a                	mv	a1,t1
          r = a->left;
ffffffffc020821e:	f446                	sd	a7,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208220:	df5fd0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->right = r;
ffffffffc0208224:	78a2                	ld	a7,40(sp)
          a->left = l;
ffffffffc0208226:	00ab3423          	sd	a0,8(s6)
          if (l) l->parent = a;
ffffffffc020822a:	7842                	ld	a6,48(sp)
          a->right = r;
ffffffffc020822c:	011b3823          	sd	a7,16(s6)
          if (l) l->parent = a;
ffffffffc0208230:	e119                	bnez	a0,ffffffffc0208236 <stride_dequeue+0x2028>
ffffffffc0208232:	a3dfe06f          	j	ffffffffc0206c6e <stride_dequeue+0xa60>
ffffffffc0208236:	01653023          	sd	s6,0(a0)
ffffffffc020823a:	a35fe06f          	j	ffffffffc0206c6e <stride_dequeue+0xa60>
          r = a->left;
ffffffffc020823e:	0088b303          	ld	t1,8(a7)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208242:	0108b503          	ld	a0,16(a7)
ffffffffc0208246:	85be                	mv	a1,a5
          r = a->left;
ffffffffc0208248:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc020824a:	dcbfd0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->left = l;
ffffffffc020824e:	78c2                	ld	a7,48(sp)
          a->right = r;
ffffffffc0208250:	7322                	ld	t1,40(sp)
          a->left = l;
ffffffffc0208252:	00a8b423          	sd	a0,8(a7)
          a->right = r;
ffffffffc0208256:	0068b823          	sd	t1,16(a7)
          if (l) l->parent = a;
ffffffffc020825a:	6e050863          	beqz	a0,ffffffffc020894a <stride_dequeue+0x273c>
ffffffffc020825e:	01153023          	sd	a7,0(a0)
ffffffffc0208262:	87c6                	mv	a5,a7
ffffffffc0208264:	ecaff06f          	j	ffffffffc020792e <stride_dequeue+0x1720>
          r = a->left;
ffffffffc0208268:	0088b303          	ld	t1,8(a7)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc020826c:	0108b503          	ld	a0,16(a7)
ffffffffc0208270:	85be                	mv	a1,a5
          r = a->left;
ffffffffc0208272:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208274:	da1fd0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->left = l;
ffffffffc0208278:	78c2                	ld	a7,48(sp)
          a->right = r;
ffffffffc020827a:	7322                	ld	t1,40(sp)
          a->left = l;
ffffffffc020827c:	00a8b423          	sd	a0,8(a7)
          a->right = r;
ffffffffc0208280:	0068b823          	sd	t1,16(a7)
          if (l) l->parent = a;
ffffffffc0208284:	6a050a63          	beqz	a0,ffffffffc0208938 <stride_dequeue+0x272a>
ffffffffc0208288:	01153023          	sd	a7,0(a0)
ffffffffc020828c:	87c6                	mv	a5,a7
ffffffffc020828e:	e4aff06f          	j	ffffffffc02078d8 <stride_dequeue+0x16ca>
          r = a->left;
ffffffffc0208292:	0088b303          	ld	t1,8(a7)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208296:	0108b503          	ld	a0,16(a7)
ffffffffc020829a:	85c2                	mv	a1,a6
          r = a->left;
ffffffffc020829c:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc020829e:	d77fd0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->left = l;
ffffffffc02082a2:	78c2                	ld	a7,48(sp)
          a->right = r;
ffffffffc02082a4:	7322                	ld	t1,40(sp)
          a->left = l;
ffffffffc02082a6:	00a8b423          	sd	a0,8(a7)
          a->right = r;
ffffffffc02082aa:	0068b823          	sd	t1,16(a7)
          if (l) l->parent = a;
ffffffffc02082ae:	68050863          	beqz	a0,ffffffffc020893e <stride_dequeue+0x2730>
ffffffffc02082b2:	01153023          	sd	a7,0(a0)
ffffffffc02082b6:	8846                	mv	a6,a7
ffffffffc02082b8:	dcaff06f          	j	ffffffffc0207882 <stride_dequeue+0x1674>
          r = a->left;
ffffffffc02082bc:	008cb783          	ld	a5,8(s9)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02082c0:	010cb503          	ld	a0,16(s9)
ffffffffc02082c4:	85c2                	mv	a1,a6
          r = a->left;
ffffffffc02082c6:	f03e                	sd	a5,32(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02082c8:	d4dfd0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->right = r;
ffffffffc02082cc:	7782                	ld	a5,32(sp)
          a->left = l;
ffffffffc02082ce:	00acb423          	sd	a0,8(s9)
          a->right = r;
ffffffffc02082d2:	00fcb823          	sd	a5,16(s9)
          if (l) l->parent = a;
ffffffffc02082d6:	e119                	bnez	a0,ffffffffc02082dc <stride_dequeue+0x20ce>
ffffffffc02082d8:	e13fe06f          	j	ffffffffc02070ea <stride_dequeue+0xedc>
ffffffffc02082dc:	01953023          	sd	s9,0(a0)
ffffffffc02082e0:	e0bfe06f          	j	ffffffffc02070ea <stride_dequeue+0xedc>
          r = a->left;
ffffffffc02082e4:	00883783          	ld	a5,8(a6)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02082e8:	01083503          	ld	a0,16(a6)
ffffffffc02082ec:	85e2                	mv	a1,s8
          r = a->left;
ffffffffc02082ee:	f03e                	sd	a5,32(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02082f0:	d25fd0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->left = l;
ffffffffc02082f4:	7822                	ld	a6,40(sp)
          a->right = r;
ffffffffc02082f6:	7782                	ld	a5,32(sp)
          a->left = l;
ffffffffc02082f8:	00a83423          	sd	a0,8(a6)
          a->right = r;
ffffffffc02082fc:	00f83823          	sd	a5,16(a6)
          if (l) l->parent = a;
ffffffffc0208300:	ae050e63          	beqz	a0,ffffffffc02075fc <stride_dequeue+0x13ee>
ffffffffc0208304:	01053023          	sd	a6,0(a0)
ffffffffc0208308:	af4ff06f          	j	ffffffffc02075fc <stride_dequeue+0x13ee>
          r = a->left;
ffffffffc020830c:	008c3883          	ld	a7,8(s8)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208310:	010c3503          	ld	a0,16(s8)
ffffffffc0208314:	859a                	mv	a1,t1
          r = a->left;
ffffffffc0208316:	f446                	sd	a7,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208318:	cfdfd0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->right = r;
ffffffffc020831c:	78a2                	ld	a7,40(sp)
          a->left = l;
ffffffffc020831e:	00ac3423          	sd	a0,8(s8)
          if (l) l->parent = a;
ffffffffc0208322:	77c2                	ld	a5,48(sp)
          a->right = r;
ffffffffc0208324:	011c3823          	sd	a7,16(s8)
          if (l) l->parent = a;
ffffffffc0208328:	e119                	bnez	a0,ffffffffc020832e <stride_dequeue+0x2120>
ffffffffc020832a:	beafe06f          	j	ffffffffc0206714 <stride_dequeue+0x506>
ffffffffc020832e:	01853023          	sd	s8,0(a0)
ffffffffc0208332:	be2fe06f          	j	ffffffffc0206714 <stride_dequeue+0x506>
          r = a->left;
ffffffffc0208336:	00883783          	ld	a5,8(a6)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc020833a:	01083503          	ld	a0,16(a6)
ffffffffc020833e:	85e6                	mv	a1,s9
          r = a->left;
ffffffffc0208340:	f03e                	sd	a5,32(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208342:	cd3fd0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->left = l;
ffffffffc0208346:	7822                	ld	a6,40(sp)
          a->right = r;
ffffffffc0208348:	7782                	ld	a5,32(sp)
          a->left = l;
ffffffffc020834a:	00a83423          	sd	a0,8(a6)
          a->right = r;
ffffffffc020834e:	00f83823          	sd	a5,16(a6)
          if (l) l->parent = a;
ffffffffc0208352:	96050963          	beqz	a0,ffffffffc02074c4 <stride_dequeue+0x12b6>
ffffffffc0208356:	01053023          	sd	a6,0(a0)
ffffffffc020835a:	96aff06f          	j	ffffffffc02074c4 <stride_dequeue+0x12b6>
          r = a->left;
ffffffffc020835e:	008cb783          	ld	a5,8(s9)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208362:	010cb503          	ld	a0,16(s9)
ffffffffc0208366:	85c2                	mv	a1,a6
          r = a->left;
ffffffffc0208368:	f03e                	sd	a5,32(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc020836a:	cabfd0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->right = r;
ffffffffc020836e:	7782                	ld	a5,32(sp)
          a->left = l;
ffffffffc0208370:	00acb423          	sd	a0,8(s9)
          a->right = r;
ffffffffc0208374:	00fcb823          	sd	a5,16(s9)
          if (l) l->parent = a;
ffffffffc0208378:	e119                	bnez	a0,ffffffffc020837e <stride_dequeue+0x2170>
ffffffffc020837a:	cabfe06f          	j	ffffffffc0207024 <stride_dequeue+0xe16>
ffffffffc020837e:	01953023          	sd	s9,0(a0)
ffffffffc0208382:	ca3fe06f          	j	ffffffffc0207024 <stride_dequeue+0xe16>
          r = a->left;
ffffffffc0208386:	0088b803          	ld	a6,8(a7)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc020838a:	0108b503          	ld	a0,16(a7)
ffffffffc020838e:	859a                	mv	a1,t1
          r = a->left;
ffffffffc0208390:	f442                	sd	a6,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208392:	c83fd0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->left = l;
ffffffffc0208396:	78c2                	ld	a7,48(sp)
          a->right = r;
ffffffffc0208398:	7822                	ld	a6,40(sp)
          a->left = l;
ffffffffc020839a:	00a8b423          	sd	a0,8(a7)
          a->right = r;
ffffffffc020839e:	0108b823          	sd	a6,16(a7)
          if (l) l->parent = a;
ffffffffc02083a2:	e119                	bnez	a0,ffffffffc02083a8 <stride_dequeue+0x219a>
ffffffffc02083a4:	dddfe06f          	j	ffffffffc0207180 <stride_dequeue+0xf72>
ffffffffc02083a8:	01153023          	sd	a7,0(a0)
ffffffffc02083ac:	dd5fe06f          	j	ffffffffc0207180 <stride_dequeue+0xf72>
          r = a->left;
ffffffffc02083b0:	0088b803          	ld	a6,8(a7)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02083b4:	0108b503          	ld	a0,16(a7)
ffffffffc02083b8:	859a                	mv	a1,t1
          r = a->left;
ffffffffc02083ba:	f442                	sd	a6,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02083bc:	c59fd0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->left = l;
ffffffffc02083c0:	78c2                	ld	a7,48(sp)
          a->right = r;
ffffffffc02083c2:	7822                	ld	a6,40(sp)
          a->left = l;
ffffffffc02083c4:	00a8b423          	sd	a0,8(a7)
          a->right = r;
ffffffffc02083c8:	0108b823          	sd	a6,16(a7)
          if (l) l->parent = a;
ffffffffc02083cc:	e119                	bnez	a0,ffffffffc02083d2 <stride_dequeue+0x21c4>
ffffffffc02083ce:	e49fe06f          	j	ffffffffc0207216 <stride_dequeue+0x1008>
ffffffffc02083d2:	01153023          	sd	a7,0(a0)
ffffffffc02083d6:	e41fe06f          	j	ffffffffc0207216 <stride_dequeue+0x1008>
          r = a->left;
ffffffffc02083da:	008d3883          	ld	a7,8(s10)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02083de:	010d3503          	ld	a0,16(s10)
ffffffffc02083e2:	859a                	mv	a1,t1
          r = a->left;
ffffffffc02083e4:	f446                	sd	a7,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02083e6:	c2ffd0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->right = r;
ffffffffc02083ea:	78a2                	ld	a7,40(sp)
          a->left = l;
ffffffffc02083ec:	00ad3423          	sd	a0,8(s10)
          if (l) l->parent = a;
ffffffffc02083f0:	7842                	ld	a6,48(sp)
          a->right = r;
ffffffffc02083f2:	011d3823          	sd	a7,16(s10)
          if (l) l->parent = a;
ffffffffc02083f6:	e119                	bnez	a0,ffffffffc02083fc <stride_dequeue+0x21ee>
ffffffffc02083f8:	d0cfe06f          	j	ffffffffc0206904 <stride_dequeue+0x6f6>
ffffffffc02083fc:	01a53023          	sd	s10,0(a0)
ffffffffc0208400:	d04fe06f          	j	ffffffffc0206904 <stride_dequeue+0x6f6>
          r = a->left;
ffffffffc0208404:	0088b803          	ld	a6,8(a7)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208408:	0108b503          	ld	a0,16(a7)
ffffffffc020840c:	859a                	mv	a1,t1
          r = a->left;
ffffffffc020840e:	f442                	sd	a6,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208410:	c05fd0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->left = l;
ffffffffc0208414:	78c2                	ld	a7,48(sp)
          a->right = r;
ffffffffc0208416:	7822                	ld	a6,40(sp)
          a->left = l;
ffffffffc0208418:	00a8b423          	sd	a0,8(a7)
          a->right = r;
ffffffffc020841c:	0108b823          	sd	a6,16(a7)
          if (l) l->parent = a;
ffffffffc0208420:	e119                	bnez	a0,ffffffffc0208426 <stride_dequeue+0x2218>
ffffffffc0208422:	f1dfe06f          	j	ffffffffc020733e <stride_dequeue+0x1130>
ffffffffc0208426:	01153023          	sd	a7,0(a0)
ffffffffc020842a:	f15fe06f          	j	ffffffffc020733e <stride_dequeue+0x1130>
     if (a == NULL) return b;
ffffffffc020842e:	8866                	mv	a6,s9
ffffffffc0208430:	894ff06f          	j	ffffffffc02074c4 <stride_dequeue+0x12b6>
ffffffffc0208434:	8862                	mv	a6,s8
ffffffffc0208436:	9c6ff06f          	j	ffffffffc02075fc <stride_dequeue+0x13ee>
ffffffffc020843a:	8866                	mv	a6,s9
ffffffffc020843c:	b8cff06f          	j	ffffffffc02077c8 <stride_dequeue+0x15ba>
ffffffffc0208440:	8866                	mv	a6,s9
ffffffffc0208442:	91eff06f          	j	ffffffffc0207560 <stride_dequeue+0x1352>
ffffffffc0208446:	8866                	mv	a6,s9
ffffffffc0208448:	ae8ff06f          	j	ffffffffc0207730 <stride_dequeue+0x1522>
ffffffffc020844c:	8866                	mv	a6,s9
ffffffffc020844e:	a48ff06f          	j	ffffffffc0207696 <stride_dequeue+0x1488>
          if (l) l->parent = b;
ffffffffc0208452:	889a                	mv	a7,t1
ffffffffc0208454:	d2dfe06f          	j	ffffffffc0207180 <stride_dequeue+0xf72>
ffffffffc0208458:	889a                	mv	a7,t1
ffffffffc020845a:	dbdfe06f          	j	ffffffffc0207216 <stride_dequeue+0x1008>
ffffffffc020845e:	8b1a                	mv	s6,t1
ffffffffc0208460:	80ffe06f          	j	ffffffffc0206c6e <stride_dequeue+0xa60>
ffffffffc0208464:	8d1a                	mv	s10,t1
ffffffffc0208466:	c9efe06f          	j	ffffffffc0206904 <stride_dequeue+0x6f6>
ffffffffc020846a:	889a                	mv	a7,t1
ffffffffc020846c:	ed3fe06f          	j	ffffffffc020733e <stride_dequeue+0x1130>
          r = a->left;
ffffffffc0208470:	0087b803          	ld	a6,8(a5)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208474:	6b88                	ld	a0,16(a5)
ffffffffc0208476:	85ea                	mv	a1,s10
          r = a->left;
ffffffffc0208478:	f43e                	sd	a5,40(sp)
ffffffffc020847a:	f042                	sd	a6,32(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc020847c:	b99fd0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->left = l;
ffffffffc0208480:	77a2                	ld	a5,40(sp)
          a->right = r;
ffffffffc0208482:	7802                	ld	a6,32(sp)
          a->left = l;
ffffffffc0208484:	e788                	sd	a0,8(a5)
          a->right = r;
ffffffffc0208486:	0107b823          	sd	a6,16(a5)
          if (l) l->parent = a;
ffffffffc020848a:	4c050363          	beqz	a0,ffffffffc0208950 <stride_dequeue+0x2742>
ffffffffc020848e:	e11c                	sd	a5,0(a0)
ffffffffc0208490:	8d3e                	mv	s10,a5
ffffffffc0208492:	dc6ff06f          	j	ffffffffc0207a58 <stride_dequeue+0x184a>
          if (l) l->parent = b;
ffffffffc0208496:	8c1a                	mv	s8,t1
ffffffffc0208498:	a7cfe06f          	j	ffffffffc0206714 <stride_dequeue+0x506>
          r = a->left;
ffffffffc020849c:	008d3803          	ld	a6,8(s10)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02084a0:	010d3503          	ld	a0,16(s10)
ffffffffc02084a4:	85b2                	mv	a1,a2
          r = a->left;
ffffffffc02084a6:	f042                	sd	a6,32(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02084a8:	b6dfd0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->right = r;
ffffffffc02084ac:	7802                	ld	a6,32(sp)
          a->left = l;
ffffffffc02084ae:	00ad3423          	sd	a0,8(s10)
          a->right = r;
ffffffffc02084b2:	010d3823          	sd	a6,16(s10)
          if (l) l->parent = a;
ffffffffc02084b6:	e119                	bnez	a0,ffffffffc02084bc <stride_dequeue+0x22ae>
ffffffffc02084b8:	f5dfe06f          	j	ffffffffc0207414 <stride_dequeue+0x1206>
ffffffffc02084bc:	01a53023          	sd	s10,0(a0)
ffffffffc02084c0:	f55fe06f          	j	ffffffffc0207414 <stride_dequeue+0x1206>
          r = a->left;
ffffffffc02084c4:	0087b803          	ld	a6,8(a5)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02084c8:	6b88                	ld	a0,16(a5)
ffffffffc02084ca:	85ee                	mv	a1,s11
          r = a->left;
ffffffffc02084cc:	f43e                	sd	a5,40(sp)
ffffffffc02084ce:	f042                	sd	a6,32(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02084d0:	b45fd0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->left = l;
ffffffffc02084d4:	77a2                	ld	a5,40(sp)
          a->right = r;
ffffffffc02084d6:	7802                	ld	a6,32(sp)
          a->left = l;
ffffffffc02084d8:	e788                	sd	a0,8(a5)
          a->right = r;
ffffffffc02084da:	0107b823          	sd	a6,16(a5)
          if (l) l->parent = a;
ffffffffc02084de:	3e050763          	beqz	a0,ffffffffc02088cc <stride_dequeue+0x26be>
ffffffffc02084e2:	e11c                	sd	a5,0(a0)
ffffffffc02084e4:	8dbe                	mv	s11,a5
ffffffffc02084e6:	dc6ff06f          	j	ffffffffc0207aac <stride_dequeue+0x189e>
          if (l) l->parent = b;
ffffffffc02084ea:	8d1a                	mv	s10,t1
ffffffffc02084ec:	90ffe06f          	j	ffffffffc0206dfa <stride_dequeue+0xbec>
          r = a->left;
ffffffffc02084f0:	0087b803          	ld	a6,8(a5)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02084f4:	6b88                	ld	a0,16(a5)
ffffffffc02084f6:	85ea                	mv	a1,s10
          r = a->left;
ffffffffc02084f8:	f43e                	sd	a5,40(sp)
ffffffffc02084fa:	f042                	sd	a6,32(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02084fc:	b19fd0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->left = l;
ffffffffc0208500:	77a2                	ld	a5,40(sp)
          a->right = r;
ffffffffc0208502:	7802                	ld	a6,32(sp)
          a->left = l;
ffffffffc0208504:	e788                	sd	a0,8(a5)
          a->right = r;
ffffffffc0208506:	0107b823          	sd	a6,16(a5)
          if (l) l->parent = a;
ffffffffc020850a:	40050b63          	beqz	a0,ffffffffc0208920 <stride_dequeue+0x2712>
ffffffffc020850e:	e11c                	sd	a5,0(a0)
ffffffffc0208510:	8d3e                	mv	s10,a5
ffffffffc0208512:	cf2ff06f          	j	ffffffffc0207a04 <stride_dequeue+0x17f6>
          if (l) l->parent = b;
ffffffffc0208516:	8b1a                	mv	s6,t1
ffffffffc0208518:	afcfe06f          	j	ffffffffc0206814 <stride_dequeue+0x606>
ffffffffc020851c:	889a                	mv	a7,t1
ffffffffc020851e:	d8bfe06f          	j	ffffffffc02072a8 <stride_dequeue+0x109a>
ffffffffc0208522:	8d1a                	mv	s10,t1
ffffffffc0208524:	813fe06f          	j	ffffffffc0206d36 <stride_dequeue+0xb28>
          r = a->left;
ffffffffc0208528:	0087b803          	ld	a6,8(a5)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc020852c:	6b88                	ld	a0,16(a5)
ffffffffc020852e:	85ea                	mv	a1,s10
          r = a->left;
ffffffffc0208530:	f43e                	sd	a5,40(sp)
ffffffffc0208532:	f042                	sd	a6,32(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208534:	ae1fd0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->left = l;
ffffffffc0208538:	77a2                	ld	a5,40(sp)
          a->right = r;
ffffffffc020853a:	7802                	ld	a6,32(sp)
          a->left = l;
ffffffffc020853c:	e788                	sd	a0,8(a5)
          a->right = r;
ffffffffc020853e:	0107b823          	sd	a6,16(a5)
          if (l) l->parent = a;
ffffffffc0208542:	42050363          	beqz	a0,ffffffffc0208968 <stride_dequeue+0x275a>
ffffffffc0208546:	e11c                	sd	a5,0(a0)
ffffffffc0208548:	8d3e                	mv	s10,a5
ffffffffc020854a:	db6ff06f          	j	ffffffffc0207b00 <stride_dequeue+0x18f2>
ffffffffc020854e:	87c6                	mv	a5,a7
ffffffffc0208550:	e55fe06f          	j	ffffffffc02073a4 <stride_dequeue+0x1196>
          r = a->left;
ffffffffc0208554:	00883303          	ld	t1,8(a6)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208558:	01083503          	ld	a0,16(a6)
ffffffffc020855c:	85c6                	mv	a1,a7
          r = a->left;
ffffffffc020855e:	f842                	sd	a6,48(sp)
ffffffffc0208560:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208562:	ab3fd0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->left = l;
ffffffffc0208566:	7842                	ld	a6,48(sp)
          a->right = r;
ffffffffc0208568:	7322                	ld	t1,40(sp)
          a->left = l;
ffffffffc020856a:	00a83423          	sd	a0,8(a6)
          a->right = r;
ffffffffc020856e:	00683823          	sd	t1,16(a6)
          if (l) l->parent = a;
ffffffffc0208572:	e119                	bnez	a0,ffffffffc0208578 <stride_dequeue+0x236a>
ffffffffc0208574:	f41fe06f          	j	ffffffffc02074b4 <stride_dequeue+0x12a6>
ffffffffc0208578:	01053023          	sd	a6,0(a0)
ffffffffc020857c:	f39fe06f          	j	ffffffffc02074b4 <stride_dequeue+0x12a6>
          r = a->left;
ffffffffc0208580:	0088b303          	ld	t1,8(a7)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208584:	0108b503          	ld	a0,16(a7)
ffffffffc0208588:	85be                	mv	a1,a5
          r = a->left;
ffffffffc020858a:	f846                	sd	a7,48(sp)
ffffffffc020858c:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc020858e:	a87fd0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->left = l;
ffffffffc0208592:	78c2                	ld	a7,48(sp)
          a->right = r;
ffffffffc0208594:	7322                	ld	t1,40(sp)
          a->left = l;
ffffffffc0208596:	00a8b423          	sd	a0,8(a7)
          a->right = r;
ffffffffc020859a:	0068b823          	sd	t1,16(a7)
          if (l) l->parent = a;
ffffffffc020859e:	3a050363          	beqz	a0,ffffffffc0208944 <stride_dequeue+0x2736>
ffffffffc02085a2:	01153023          	sd	a7,0(a0)
ffffffffc02085a6:	87c6                	mv	a5,a7
ffffffffc02085a8:	85bff06f          	j	ffffffffc0207e02 <stride_dequeue+0x1bf4>
          if (l) l->parent = b;
ffffffffc02085ac:	8d32                	mv	s10,a2
ffffffffc02085ae:	e67fe06f          	j	ffffffffc0207414 <stride_dequeue+0x1206>
          r = a->left;
ffffffffc02085b2:	008cb303          	ld	t1,8(s9)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02085b6:	010cb503          	ld	a0,16(s9)
ffffffffc02085ba:	85c6                	mv	a1,a7
          r = a->left;
ffffffffc02085bc:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02085be:	a57fd0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->right = r;
ffffffffc02085c2:	7322                	ld	t1,40(sp)
          a->left = l;
ffffffffc02085c4:	00acb423          	sd	a0,8(s9)
          if (l) l->parent = a;
ffffffffc02085c8:	7842                	ld	a6,48(sp)
          a->right = r;
ffffffffc02085ca:	006cb823          	sd	t1,16(s9)
          if (l) l->parent = a;
ffffffffc02085ce:	e119                	bnez	a0,ffffffffc02085d4 <stride_dequeue+0x23c6>
ffffffffc02085d0:	b0bfe06f          	j	ffffffffc02070da <stride_dequeue+0xecc>
ffffffffc02085d4:	01953023          	sd	s9,0(a0)
ffffffffc02085d8:	b03fe06f          	j	ffffffffc02070da <stride_dequeue+0xecc>
          r = a->left;
ffffffffc02085dc:	0088b303          	ld	t1,8(a7)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02085e0:	0108b503          	ld	a0,16(a7)
ffffffffc02085e4:	85c2                	mv	a1,a6
          r = a->left;
ffffffffc02085e6:	f846                	sd	a7,48(sp)
ffffffffc02085e8:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02085ea:	a2bfd0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->left = l;
ffffffffc02085ee:	78c2                	ld	a7,48(sp)
          a->right = r;
ffffffffc02085f0:	7322                	ld	t1,40(sp)
          a->left = l;
ffffffffc02085f2:	00a8b423          	sd	a0,8(a7)
          a->right = r;
ffffffffc02085f6:	0068b823          	sd	t1,16(a7)
          if (l) l->parent = a;
ffffffffc02085fa:	30050d63          	beqz	a0,ffffffffc0208914 <stride_dequeue+0x2706>
ffffffffc02085fe:	01153023          	sd	a7,0(a0)
ffffffffc0208602:	8846                	mv	a6,a7
ffffffffc0208604:	fa6ff06f          	j	ffffffffc0207daa <stride_dequeue+0x1b9c>
          r = a->left;
ffffffffc0208608:	00883303          	ld	t1,8(a6)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc020860c:	01083503          	ld	a0,16(a6)
ffffffffc0208610:	85c6                	mv	a1,a7
          r = a->left;
ffffffffc0208612:	f842                	sd	a6,48(sp)
ffffffffc0208614:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208616:	9fffd0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->left = l;
ffffffffc020861a:	7842                	ld	a6,48(sp)
          a->right = r;
ffffffffc020861c:	7322                	ld	t1,40(sp)
          a->left = l;
ffffffffc020861e:	00a83423          	sd	a0,8(a6)
          a->right = r;
ffffffffc0208622:	00683823          	sd	t1,16(a6)
          if (l) l->parent = a;
ffffffffc0208626:	e119                	bnez	a0,ffffffffc020862c <stride_dequeue+0x241e>
ffffffffc0208628:	f29fe06f          	j	ffffffffc0207550 <stride_dequeue+0x1342>
ffffffffc020862c:	01053023          	sd	a6,0(a0)
ffffffffc0208630:	f21fe06f          	j	ffffffffc0207550 <stride_dequeue+0x1342>
          r = a->left;
ffffffffc0208634:	00883303          	ld	t1,8(a6)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208638:	01083503          	ld	a0,16(a6)
ffffffffc020863c:	85ea                	mv	a1,s10
ffffffffc020863e:	fc46                	sd	a7,56(sp)
          r = a->left;
ffffffffc0208640:	f842                	sd	a6,48(sp)
ffffffffc0208642:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208644:	9d1fd0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->left = l;
ffffffffc0208648:	7842                	ld	a6,48(sp)
          a->right = r;
ffffffffc020864a:	7322                	ld	t1,40(sp)
          if (l) l->parent = a;
ffffffffc020864c:	78e2                	ld	a7,56(sp)
          a->left = l;
ffffffffc020864e:	00a83423          	sd	a0,8(a6)
          a->right = r;
ffffffffc0208652:	00683823          	sd	t1,16(a6)
          if (l) l->parent = a;
ffffffffc0208656:	2a050063          	beqz	a0,ffffffffc02088f6 <stride_dequeue+0x26e8>
ffffffffc020865a:	01053023          	sd	a6,0(a0)
ffffffffc020865e:	8d42                	mv	s10,a6
ffffffffc0208660:	e1eff06f          	j	ffffffffc0207c7e <stride_dequeue+0x1a70>
          r = a->left;
ffffffffc0208664:	0088b303          	ld	t1,8(a7)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208668:	0108b503          	ld	a0,16(a7)
ffffffffc020866c:	85c2                	mv	a1,a6
          r = a->left;
ffffffffc020866e:	f846                	sd	a7,48(sp)
ffffffffc0208670:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208672:	9a3fd0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->left = l;
ffffffffc0208676:	78c2                	ld	a7,48(sp)
          a->right = r;
ffffffffc0208678:	7322                	ld	t1,40(sp)
          a->left = l;
ffffffffc020867a:	00a8b423          	sd	a0,8(a7)
          a->right = r;
ffffffffc020867e:	0068b823          	sd	t1,16(a7)
          if (l) l->parent = a;
ffffffffc0208682:	26050d63          	beqz	a0,ffffffffc02088fc <stride_dequeue+0x26ee>
ffffffffc0208686:	01153023          	sd	a7,0(a0)
ffffffffc020868a:	8846                	mv	a6,a7
ffffffffc020868c:	cd8ff06f          	j	ffffffffc0207b64 <stride_dequeue+0x1956>
          r = a->left;
ffffffffc0208690:	0088b303          	ld	t1,8(a7)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208694:	0108b503          	ld	a0,16(a7)
ffffffffc0208698:	85c2                	mv	a1,a6
          r = a->left;
ffffffffc020869a:	f846                	sd	a7,48(sp)
ffffffffc020869c:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc020869e:	977fd0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->left = l;
ffffffffc02086a2:	78c2                	ld	a7,48(sp)
          a->right = r;
ffffffffc02086a4:	7322                	ld	t1,40(sp)
          a->left = l;
ffffffffc02086a6:	00a8b423          	sd	a0,8(a7)
          a->right = r;
ffffffffc02086aa:	0068b823          	sd	t1,16(a7)
          if (l) l->parent = a;
ffffffffc02086ae:	26050f63          	beqz	a0,ffffffffc020892c <stride_dequeue+0x271e>
ffffffffc02086b2:	01153023          	sd	a7,0(a0)
ffffffffc02086b6:	8846                	mv	a6,a7
ffffffffc02086b8:	e82ff06f          	j	ffffffffc0207d3a <stride_dequeue+0x1b2c>
          r = a->left;
ffffffffc02086bc:	008cb303          	ld	t1,8(s9)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02086c0:	010cb503          	ld	a0,16(s9)
ffffffffc02086c4:	85c6                	mv	a1,a7
          r = a->left;
ffffffffc02086c6:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02086c8:	94dfd0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->right = r;
ffffffffc02086cc:	7322                	ld	t1,40(sp)
          a->left = l;
ffffffffc02086ce:	00acb423          	sd	a0,8(s9)
          if (l) l->parent = a;
ffffffffc02086d2:	7842                	ld	a6,48(sp)
          a->right = r;
ffffffffc02086d4:	006cb823          	sd	t1,16(s9)
          if (l) l->parent = a;
ffffffffc02086d8:	e119                	bnez	a0,ffffffffc02086de <stride_dequeue+0x24d0>
ffffffffc02086da:	93bfe06f          	j	ffffffffc0207014 <stride_dequeue+0xe06>
ffffffffc02086de:	01953023          	sd	s9,0(a0)
ffffffffc02086e2:	933fe06f          	j	ffffffffc0207014 <stride_dequeue+0xe06>
          r = a->left;
ffffffffc02086e6:	00883303          	ld	t1,8(a6)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02086ea:	01083503          	ld	a0,16(a6)
ffffffffc02086ee:	85ea                	mv	a1,s10
ffffffffc02086f0:	fc46                	sd	a7,56(sp)
          r = a->left;
ffffffffc02086f2:	f842                	sd	a6,48(sp)
ffffffffc02086f4:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02086f6:	91ffd0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->left = l;
ffffffffc02086fa:	7842                	ld	a6,48(sp)
          a->right = r;
ffffffffc02086fc:	7322                	ld	t1,40(sp)
          if (l) l->parent = a;
ffffffffc02086fe:	78e2                	ld	a7,56(sp)
          a->left = l;
ffffffffc0208700:	00a83423          	sd	a0,8(a6)
          a->right = r;
ffffffffc0208704:	00683823          	sd	t1,16(a6)
          if (l) l->parent = a;
ffffffffc0208708:	1c050b63          	beqz	a0,ffffffffc02088de <stride_dequeue+0x26d0>
ffffffffc020870c:	01053023          	sd	a6,0(a0)
ffffffffc0208710:	8d42                	mv	s10,a6
ffffffffc0208712:	fb8ff06f          	j	ffffffffc0207eca <stride_dequeue+0x1cbc>
          r = a->left;
ffffffffc0208716:	00883303          	ld	t1,8(a6)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc020871a:	01083503          	ld	a0,16(a6)
ffffffffc020871e:	85da                	mv	a1,s6
ffffffffc0208720:	fc46                	sd	a7,56(sp)
          r = a->left;
ffffffffc0208722:	f842                	sd	a6,48(sp)
ffffffffc0208724:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208726:	8effd0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->left = l;
ffffffffc020872a:	7842                	ld	a6,48(sp)
          a->right = r;
ffffffffc020872c:	7322                	ld	t1,40(sp)
          if (l) l->parent = a;
ffffffffc020872e:	78e2                	ld	a7,56(sp)
          a->left = l;
ffffffffc0208730:	00a83423          	sd	a0,8(a6)
          a->right = r;
ffffffffc0208734:	00683823          	sd	t1,16(a6)
          if (l) l->parent = a;
ffffffffc0208738:	22050263          	beqz	a0,ffffffffc020895c <stride_dequeue+0x274e>
ffffffffc020873c:	01053023          	sd	a6,0(a0)
ffffffffc0208740:	8b42                	mv	s6,a6
ffffffffc0208742:	f1eff06f          	j	ffffffffc0207e60 <stride_dequeue+0x1c52>
          r = a->left;
ffffffffc0208746:	008cb303          	ld	t1,8(s9)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc020874a:	010cb503          	ld	a0,16(s9)
ffffffffc020874e:	85c6                	mv	a1,a7
          r = a->left;
ffffffffc0208750:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208752:	8c3fd0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->right = r;
ffffffffc0208756:	7322                	ld	t1,40(sp)
          a->left = l;
ffffffffc0208758:	00acb423          	sd	a0,8(s9)
          if (l) l->parent = a;
ffffffffc020875c:	7842                	ld	a6,48(sp)
          a->right = r;
ffffffffc020875e:	006cb823          	sd	t1,16(s9)
          if (l) l->parent = a;
ffffffffc0208762:	e119                	bnez	a0,ffffffffc0208768 <stride_dequeue+0x255a>
ffffffffc0208764:	feafe06f          	j	ffffffffc0206f4e <stride_dequeue+0xd40>
ffffffffc0208768:	01953023          	sd	s9,0(a0)
ffffffffc020876c:	fe2fe06f          	j	ffffffffc0206f4e <stride_dequeue+0xd40>
          r = a->left;
ffffffffc0208770:	008cb303          	ld	t1,8(s9)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208774:	010cb503          	ld	a0,16(s9)
ffffffffc0208778:	85c6                	mv	a1,a7
          r = a->left;
ffffffffc020877a:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc020877c:	899fd0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->right = r;
ffffffffc0208780:	7322                	ld	t1,40(sp)
          a->left = l;
ffffffffc0208782:	00acb423          	sd	a0,8(s9)
          if (l) l->parent = a;
ffffffffc0208786:	7742                	ld	a4,48(sp)
          a->right = r;
ffffffffc0208788:	006cb823          	sd	t1,16(s9)
          if (l) l->parent = a;
ffffffffc020878c:	e119                	bnez	a0,ffffffffc0208792 <stride_dequeue+0x2584>
ffffffffc020878e:	c0cfe06f          	j	ffffffffc0206b9a <stride_dequeue+0x98c>
ffffffffc0208792:	01953023          	sd	s9,0(a0)
ffffffffc0208796:	c04fe06f          	j	ffffffffc0206b9a <stride_dequeue+0x98c>
          r = a->left;
ffffffffc020879a:	00883303          	ld	t1,8(a6)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc020879e:	01083503          	ld	a0,16(a6)
ffffffffc02087a2:	85c6                	mv	a1,a7
          r = a->left;
ffffffffc02087a4:	f842                	sd	a6,48(sp)
ffffffffc02087a6:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02087a8:	86dfd0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->left = l;
ffffffffc02087ac:	7842                	ld	a6,48(sp)
          a->right = r;
ffffffffc02087ae:	7322                	ld	t1,40(sp)
          a->left = l;
ffffffffc02087b0:	00a83423          	sd	a0,8(a6)
          a->right = r;
ffffffffc02087b4:	00683823          	sd	t1,16(a6)
          if (l) l->parent = a;
ffffffffc02087b8:	e119                	bnez	a0,ffffffffc02087be <stride_dequeue+0x25b0>
ffffffffc02087ba:	e33fe06f          	j	ffffffffc02075ec <stride_dequeue+0x13de>
ffffffffc02087be:	01053023          	sd	a6,0(a0)
ffffffffc02087c2:	e2bfe06f          	j	ffffffffc02075ec <stride_dequeue+0x13de>
          r = a->left;
ffffffffc02087c6:	00883303          	ld	t1,8(a6)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02087ca:	01083503          	ld	a0,16(a6)
ffffffffc02087ce:	85c6                	mv	a1,a7
          r = a->left;
ffffffffc02087d0:	f842                	sd	a6,48(sp)
ffffffffc02087d2:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02087d4:	841fd0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->left = l;
ffffffffc02087d8:	7842                	ld	a6,48(sp)
          a->right = r;
ffffffffc02087da:	7322                	ld	t1,40(sp)
          a->left = l;
ffffffffc02087dc:	00a83423          	sd	a0,8(a6)
          a->right = r;
ffffffffc02087e0:	00683823          	sd	t1,16(a6)
          if (l) l->parent = a;
ffffffffc02087e4:	e119                	bnez	a0,ffffffffc02087ea <stride_dequeue+0x25dc>
ffffffffc02087e6:	f3bfe06f          	j	ffffffffc0207720 <stride_dequeue+0x1512>
ffffffffc02087ea:	01053023          	sd	a6,0(a0)
ffffffffc02087ee:	f33fe06f          	j	ffffffffc0207720 <stride_dequeue+0x1512>
          r = a->left;
ffffffffc02087f2:	00883303          	ld	t1,8(a6)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02087f6:	01083503          	ld	a0,16(a6)
ffffffffc02087fa:	85ea                	mv	a1,s10
ffffffffc02087fc:	fc46                	sd	a7,56(sp)
          r = a->left;
ffffffffc02087fe:	f842                	sd	a6,48(sp)
ffffffffc0208800:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208802:	813fd0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->left = l;
ffffffffc0208806:	7842                	ld	a6,48(sp)
          a->right = r;
ffffffffc0208808:	7322                	ld	t1,40(sp)
          if (l) l->parent = a;
ffffffffc020880a:	78e2                	ld	a7,56(sp)
          a->left = l;
ffffffffc020880c:	00a83423          	sd	a0,8(a6)
          a->right = r;
ffffffffc0208810:	00683823          	sd	t1,16(a6)
          if (l) l->parent = a;
ffffffffc0208814:	c171                	beqz	a0,ffffffffc02088d8 <stride_dequeue+0x26ca>
ffffffffc0208816:	01053023          	sd	a6,0(a0)
ffffffffc020881a:	8d42                	mv	s10,a6
ffffffffc020881c:	ba6ff06f          	j	ffffffffc0207bc2 <stride_dequeue+0x19b4>
          r = a->left;
ffffffffc0208820:	00883303          	ld	t1,8(a6)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208824:	01083503          	ld	a0,16(a6)
ffffffffc0208828:	85c6                	mv	a1,a7
          r = a->left;
ffffffffc020882a:	f842                	sd	a6,48(sp)
ffffffffc020882c:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc020882e:	fe6fd0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->left = l;
ffffffffc0208832:	7842                	ld	a6,48(sp)
          a->right = r;
ffffffffc0208834:	7322                	ld	t1,40(sp)
          a->left = l;
ffffffffc0208836:	00a83423          	sd	a0,8(a6)
          a->right = r;
ffffffffc020883a:	00683823          	sd	t1,16(a6)
          if (l) l->parent = a;
ffffffffc020883e:	e119                	bnez	a0,ffffffffc0208844 <stride_dequeue+0x2636>
ffffffffc0208840:	e47fe06f          	j	ffffffffc0207686 <stride_dequeue+0x1478>
ffffffffc0208844:	01053023          	sd	a6,0(a0)
ffffffffc0208848:	e3ffe06f          	j	ffffffffc0207686 <stride_dequeue+0x1478>
          r = a->left;
ffffffffc020884c:	00883303          	ld	t1,8(a6)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208850:	01083503          	ld	a0,16(a6)
ffffffffc0208854:	85c6                	mv	a1,a7
          r = a->left;
ffffffffc0208856:	f842                	sd	a6,48(sp)
ffffffffc0208858:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc020885a:	fbafd0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->left = l;
ffffffffc020885e:	7842                	ld	a6,48(sp)
          a->right = r;
ffffffffc0208860:	7322                	ld	t1,40(sp)
          a->left = l;
ffffffffc0208862:	00a83423          	sd	a0,8(a6)
          a->right = r;
ffffffffc0208866:	00683823          	sd	t1,16(a6)
          if (l) l->parent = a;
ffffffffc020886a:	e119                	bnez	a0,ffffffffc0208870 <stride_dequeue+0x2662>
ffffffffc020886c:	f4dfe06f          	j	ffffffffc02077b8 <stride_dequeue+0x15aa>
ffffffffc0208870:	01053023          	sd	a6,0(a0)
ffffffffc0208874:	f45fe06f          	j	ffffffffc02077b8 <stride_dequeue+0x15aa>
          r = a->left;
ffffffffc0208878:	0088b303          	ld	t1,8(a7)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc020887c:	0108b503          	ld	a0,16(a7)
ffffffffc0208880:	85c2                	mv	a1,a6
          r = a->left;
ffffffffc0208882:	f846                	sd	a7,48(sp)
ffffffffc0208884:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc0208886:	f8efd0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->left = l;
ffffffffc020888a:	78c2                	ld	a7,48(sp)
          a->right = r;
ffffffffc020888c:	7322                	ld	t1,40(sp)
          a->left = l;
ffffffffc020888e:	00a8b423          	sd	a0,8(a7)
          a->right = r;
ffffffffc0208892:	0068b823          	sd	t1,16(a7)
          if (l) l->parent = a;
ffffffffc0208896:	cd79                	beqz	a0,ffffffffc0208974 <stride_dequeue+0x2766>
ffffffffc0208898:	01153023          	sd	a7,0(a0)
ffffffffc020889c:	8846                	mv	a6,a7
ffffffffc020889e:	b82ff06f          	j	ffffffffc0207c20 <stride_dequeue+0x1a12>
          r = a->left;
ffffffffc02088a2:	0088b303          	ld	t1,8(a7)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02088a6:	0108b503          	ld	a0,16(a7)
ffffffffc02088aa:	85c2                	mv	a1,a6
          r = a->left;
ffffffffc02088ac:	f846                	sd	a7,48(sp)
ffffffffc02088ae:	f41a                	sd	t1,40(sp)
          l = skew_heap_merge(a->right, b, comp);
ffffffffc02088b0:	f64fd0ef          	jal	ra,ffffffffc0206014 <skew_heap_merge.constprop.2>
          a->left = l;
ffffffffc02088b4:	78c2                	ld	a7,48(sp)
          a->right = r;
ffffffffc02088b6:	7322                	ld	t1,40(sp)
          a->left = l;
ffffffffc02088b8:	00a8b423          	sd	a0,8(a7)
          a->right = r;
ffffffffc02088bc:	0068b823          	sd	t1,16(a7)
          if (l) l->parent = a;
ffffffffc02088c0:	c115                	beqz	a0,ffffffffc02088e4 <stride_dequeue+0x26d6>
ffffffffc02088c2:	01153023          	sd	a7,0(a0)
ffffffffc02088c6:	8846                	mv	a6,a7
ffffffffc02088c8:	c14ff06f          	j	ffffffffc0207cdc <stride_dequeue+0x1ace>
ffffffffc02088cc:	8dbe                	mv	s11,a5
ffffffffc02088ce:	9deff06f          	j	ffffffffc0207aac <stride_dequeue+0x189e>
          if (l) l->parent = b;
ffffffffc02088d2:	8846                	mv	a6,a7
ffffffffc02088d4:	db3fe06f          	j	ffffffffc0207686 <stride_dequeue+0x1478>
          if (l) l->parent = a;
ffffffffc02088d8:	8d42                	mv	s10,a6
ffffffffc02088da:	ae8ff06f          	j	ffffffffc0207bc2 <stride_dequeue+0x19b4>
ffffffffc02088de:	8d42                	mv	s10,a6
ffffffffc02088e0:	deaff06f          	j	ffffffffc0207eca <stride_dequeue+0x1cbc>
ffffffffc02088e4:	8846                	mv	a6,a7
ffffffffc02088e6:	bf6ff06f          	j	ffffffffc0207cdc <stride_dequeue+0x1ace>
          if (l) l->parent = b;
ffffffffc02088ea:	8cc6                	mv	s9,a7
ffffffffc02088ec:	aaefe06f          	j	ffffffffc0206b9a <stride_dequeue+0x98c>
ffffffffc02088f0:	8846                	mv	a6,a7
ffffffffc02088f2:	cfbfe06f          	j	ffffffffc02075ec <stride_dequeue+0x13de>
          if (l) l->parent = a;
ffffffffc02088f6:	8d42                	mv	s10,a6
ffffffffc02088f8:	b86ff06f          	j	ffffffffc0207c7e <stride_dequeue+0x1a70>
ffffffffc02088fc:	8846                	mv	a6,a7
ffffffffc02088fe:	a66ff06f          	j	ffffffffc0207b64 <stride_dequeue+0x1956>
          if (l) l->parent = b;
ffffffffc0208902:	8cc6                	mv	s9,a7
ffffffffc0208904:	fd6fe06f          	j	ffffffffc02070da <stride_dequeue+0xecc>
          if (l) l->parent = a;
ffffffffc0208908:	8cc2                	mv	s9,a6
ffffffffc020890a:	f1bfe06f          	j	ffffffffc0207824 <stride_dequeue+0x1616>
          if (l) l->parent = b;
ffffffffc020890e:	8846                	mv	a6,a7
ffffffffc0208910:	c41fe06f          	j	ffffffffc0207550 <stride_dequeue+0x1342>
          if (l) l->parent = a;
ffffffffc0208914:	8846                	mv	a6,a7
ffffffffc0208916:	c94ff06f          	j	ffffffffc0207daa <stride_dequeue+0x1b9c>
          if (l) l->parent = b;
ffffffffc020891a:	8846                	mv	a6,a7
ffffffffc020891c:	e05fe06f          	j	ffffffffc0207720 <stride_dequeue+0x1512>
          if (l) l->parent = a;
ffffffffc0208920:	8d3e                	mv	s10,a5
ffffffffc0208922:	8e2ff06f          	j	ffffffffc0207a04 <stride_dequeue+0x17f6>
          if (l) l->parent = b;
ffffffffc0208926:	8cc6                	mv	s9,a7
ffffffffc0208928:	eecfe06f          	j	ffffffffc0207014 <stride_dequeue+0xe06>
          if (l) l->parent = a;
ffffffffc020892c:	8846                	mv	a6,a7
ffffffffc020892e:	c0cff06f          	j	ffffffffc0207d3a <stride_dequeue+0x1b2c>
          if (l) l->parent = b;
ffffffffc0208932:	8846                	mv	a6,a7
ffffffffc0208934:	b81fe06f          	j	ffffffffc02074b4 <stride_dequeue+0x12a6>
          if (l) l->parent = a;
ffffffffc0208938:	87c6                	mv	a5,a7
ffffffffc020893a:	f9ffe06f          	j	ffffffffc02078d8 <stride_dequeue+0x16ca>
ffffffffc020893e:	8846                	mv	a6,a7
ffffffffc0208940:	f43fe06f          	j	ffffffffc0207882 <stride_dequeue+0x1674>
ffffffffc0208944:	87c6                	mv	a5,a7
ffffffffc0208946:	cbcff06f          	j	ffffffffc0207e02 <stride_dequeue+0x1bf4>
ffffffffc020894a:	87c6                	mv	a5,a7
ffffffffc020894c:	fe3fe06f          	j	ffffffffc020792e <stride_dequeue+0x1720>
ffffffffc0208950:	8d3e                	mv	s10,a5
ffffffffc0208952:	906ff06f          	j	ffffffffc0207a58 <stride_dequeue+0x184a>
          if (l) l->parent = b;
ffffffffc0208956:	8cc6                	mv	s9,a7
ffffffffc0208958:	df6fe06f          	j	ffffffffc0206f4e <stride_dequeue+0xd40>
          if (l) l->parent = a;
ffffffffc020895c:	8b42                	mv	s6,a6
ffffffffc020895e:	d02ff06f          	j	ffffffffc0207e60 <stride_dequeue+0x1c52>
ffffffffc0208962:	87c6                	mv	a5,a7
ffffffffc0208964:	820ff06f          	j	ffffffffc0207984 <stride_dequeue+0x1776>
ffffffffc0208968:	8d3e                	mv	s10,a5
ffffffffc020896a:	996ff06f          	j	ffffffffc0207b00 <stride_dequeue+0x18f2>
          if (l) l->parent = b;
ffffffffc020896e:	8846                	mv	a6,a7
ffffffffc0208970:	e49fe06f          	j	ffffffffc02077b8 <stride_dequeue+0x15aa>
          if (l) l->parent = a;
ffffffffc0208974:	8846                	mv	a6,a7
ffffffffc0208976:	aaaff06f          	j	ffffffffc0207c20 <stride_dequeue+0x1a12>

ffffffffc020897a <sched_class_proc_tick>:
    return sched_class->pick_next(rq);
}

void
sched_class_proc_tick(struct proc_struct *proc) {
    if (proc != idleproc) {
ffffffffc020897a:	000c1797          	auipc	a5,0xc1
ffffffffc020897e:	90e78793          	addi	a5,a5,-1778 # ffffffffc02c9288 <idleproc>
ffffffffc0208982:	639c                	ld	a5,0(a5)
sched_class_proc_tick(struct proc_struct *proc) {
ffffffffc0208984:	85aa                	mv	a1,a0
    if (proc != idleproc) {
ffffffffc0208986:	00a78f63          	beq	a5,a0,ffffffffc02089a4 <sched_class_proc_tick+0x2a>
        sched_class->proc_tick(rq, proc);
ffffffffc020898a:	000c1797          	auipc	a5,0xc1
ffffffffc020898e:	91e78793          	addi	a5,a5,-1762 # ffffffffc02c92a8 <sched_class>
ffffffffc0208992:	639c                	ld	a5,0(a5)
ffffffffc0208994:	000c1717          	auipc	a4,0xc1
ffffffffc0208998:	90c70713          	addi	a4,a4,-1780 # ffffffffc02c92a0 <rq>
ffffffffc020899c:	6308                	ld	a0,0(a4)
ffffffffc020899e:	0287b303          	ld	t1,40(a5)
ffffffffc02089a2:	8302                	jr	t1
    }
    else {
        proc->need_resched = 1;
ffffffffc02089a4:	4705                	li	a4,1
ffffffffc02089a6:	ef98                	sd	a4,24(a5)
    }
}
ffffffffc02089a8:	8082                	ret

ffffffffc02089aa <sched_init>:

static struct run_queue __rq;

void
sched_init(void) {
ffffffffc02089aa:	1141                	addi	sp,sp,-16
    list_init(&timer_list);

    sched_class = &default_sched_class;
ffffffffc02089ac:	000b5697          	auipc	a3,0xb5
ffffffffc02089b0:	42c68693          	addi	a3,a3,1068 # ffffffffc02bddd8 <default_sched_class>
sched_init(void) {
ffffffffc02089b4:	e022                	sd	s0,0(sp)
ffffffffc02089b6:	e406                	sd	ra,8(sp)
ffffffffc02089b8:	000c1797          	auipc	a5,0xc1
ffffffffc02089bc:	88878793          	addi	a5,a5,-1912 # ffffffffc02c9240 <timer_list>

    rq = &__rq;
    rq->max_time_slice = MAX_TIME_SLICE;
    sched_class->init(rq);
ffffffffc02089c0:	6690                	ld	a2,8(a3)
    rq = &__rq;
ffffffffc02089c2:	000c1717          	auipc	a4,0xc1
ffffffffc02089c6:	85670713          	addi	a4,a4,-1962 # ffffffffc02c9218 <__rq>
ffffffffc02089ca:	e79c                	sd	a5,8(a5)
ffffffffc02089cc:	e39c                	sd	a5,0(a5)
    rq->max_time_slice = MAX_TIME_SLICE;
ffffffffc02089ce:	4795                	li	a5,5
    sched_class = &default_sched_class;
ffffffffc02089d0:	000c1417          	auipc	s0,0xc1
ffffffffc02089d4:	8d840413          	addi	s0,s0,-1832 # ffffffffc02c92a8 <sched_class>
    rq->max_time_slice = MAX_TIME_SLICE;
ffffffffc02089d8:	cb5c                	sw	a5,20(a4)
    sched_class->init(rq);
ffffffffc02089da:	853a                	mv	a0,a4
    sched_class = &default_sched_class;
ffffffffc02089dc:	e014                	sd	a3,0(s0)
    rq = &__rq;
ffffffffc02089de:	000c1797          	auipc	a5,0xc1
ffffffffc02089e2:	8ce7b123          	sd	a4,-1854(a5) # ffffffffc02c92a0 <rq>
    sched_class->init(rq);
ffffffffc02089e6:	9602                	jalr	a2

    cprintf("sched class: %s\n", sched_class->name);
ffffffffc02089e8:	601c                	ld	a5,0(s0)
}
ffffffffc02089ea:	6402                	ld	s0,0(sp)
ffffffffc02089ec:	60a2                	ld	ra,8(sp)
    cprintf("sched class: %s\n", sched_class->name);
ffffffffc02089ee:	638c                	ld	a1,0(a5)
ffffffffc02089f0:	00003517          	auipc	a0,0x3
ffffffffc02089f4:	9e850513          	addi	a0,a0,-1560 # ffffffffc020b3d8 <default_pmm_manager+0x1540>
}
ffffffffc02089f8:	0141                	addi	sp,sp,16
    cprintf("sched class: %s\n", sched_class->name);
ffffffffc02089fa:	f98f706f          	j	ffffffffc0200192 <cprintf>

ffffffffc02089fe <wakeup_proc>:

void
wakeup_proc(struct proc_struct *proc) {
    assert(proc->state != PROC_ZOMBIE);
ffffffffc02089fe:	4118                	lw	a4,0(a0)
wakeup_proc(struct proc_struct *proc) {
ffffffffc0208a00:	1101                	addi	sp,sp,-32
ffffffffc0208a02:	ec06                	sd	ra,24(sp)
ffffffffc0208a04:	e822                	sd	s0,16(sp)
ffffffffc0208a06:	e426                	sd	s1,8(sp)
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0208a08:	478d                	li	a5,3
ffffffffc0208a0a:	08f70763          	beq	a4,a5,ffffffffc0208a98 <wakeup_proc+0x9a>
ffffffffc0208a0e:	842a                	mv	s0,a0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0208a10:	100027f3          	csrr	a5,sstatus
ffffffffc0208a14:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0208a16:	4481                	li	s1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0208a18:	ebbd                	bnez	a5,ffffffffc0208a8e <wakeup_proc+0x90>
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        if (proc->state != PROC_RUNNABLE) {
ffffffffc0208a1a:	4789                	li	a5,2
ffffffffc0208a1c:	04f70c63          	beq	a4,a5,ffffffffc0208a74 <wakeup_proc+0x76>
            proc->state = PROC_RUNNABLE;
            proc->wait_state = 0;
            if (proc != current) {
ffffffffc0208a20:	000c1717          	auipc	a4,0xc1
ffffffffc0208a24:	86070713          	addi	a4,a4,-1952 # ffffffffc02c9280 <current>
ffffffffc0208a28:	6318                	ld	a4,0(a4)
            proc->wait_state = 0;
ffffffffc0208a2a:	0e042623          	sw	zero,236(s0)
            proc->state = PROC_RUNNABLE;
ffffffffc0208a2e:	c01c                	sw	a5,0(s0)
            if (proc != current) {
ffffffffc0208a30:	02870663          	beq	a4,s0,ffffffffc0208a5c <wakeup_proc+0x5e>
    if (proc != idleproc) {
ffffffffc0208a34:	000c1797          	auipc	a5,0xc1
ffffffffc0208a38:	85478793          	addi	a5,a5,-1964 # ffffffffc02c9288 <idleproc>
ffffffffc0208a3c:	639c                	ld	a5,0(a5)
ffffffffc0208a3e:	00f40f63          	beq	s0,a5,ffffffffc0208a5c <wakeup_proc+0x5e>
        sched_class->enqueue(rq, proc);
ffffffffc0208a42:	000c1797          	auipc	a5,0xc1
ffffffffc0208a46:	86678793          	addi	a5,a5,-1946 # ffffffffc02c92a8 <sched_class>
ffffffffc0208a4a:	639c                	ld	a5,0(a5)
ffffffffc0208a4c:	000c1717          	auipc	a4,0xc1
ffffffffc0208a50:	85470713          	addi	a4,a4,-1964 # ffffffffc02c92a0 <rq>
ffffffffc0208a54:	6308                	ld	a0,0(a4)
ffffffffc0208a56:	6b9c                	ld	a5,16(a5)
ffffffffc0208a58:	85a2                	mv	a1,s0
ffffffffc0208a5a:	9782                	jalr	a5
    if (flag) {
ffffffffc0208a5c:	e491                	bnez	s1,ffffffffc0208a68 <wakeup_proc+0x6a>
        else {
            warn("wakeup runnable process.\n");
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc0208a5e:	60e2                	ld	ra,24(sp)
ffffffffc0208a60:	6442                	ld	s0,16(sp)
ffffffffc0208a62:	64a2                	ld	s1,8(sp)
ffffffffc0208a64:	6105                	addi	sp,sp,32
ffffffffc0208a66:	8082                	ret
ffffffffc0208a68:	6442                	ld	s0,16(sp)
ffffffffc0208a6a:	60e2                	ld	ra,24(sp)
ffffffffc0208a6c:	64a2                	ld	s1,8(sp)
ffffffffc0208a6e:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0208a70:	bddf706f          	j	ffffffffc020064c <intr_enable>
            warn("wakeup runnable process.\n");
ffffffffc0208a74:	00003617          	auipc	a2,0x3
ffffffffc0208a78:	9b460613          	addi	a2,a2,-1612 # ffffffffc020b428 <default_pmm_manager+0x1590>
ffffffffc0208a7c:	04800593          	li	a1,72
ffffffffc0208a80:	00003517          	auipc	a0,0x3
ffffffffc0208a84:	99050513          	addi	a0,a0,-1648 # ffffffffc020b410 <default_pmm_manager+0x1578>
ffffffffc0208a88:	a6df70ef          	jal	ra,ffffffffc02004f4 <__warn>
ffffffffc0208a8c:	bfc1                	j	ffffffffc0208a5c <wakeup_proc+0x5e>
        intr_disable();
ffffffffc0208a8e:	bc5f70ef          	jal	ra,ffffffffc0200652 <intr_disable>
        return 1;
ffffffffc0208a92:	4018                	lw	a4,0(s0)
ffffffffc0208a94:	4485                	li	s1,1
ffffffffc0208a96:	b751                	j	ffffffffc0208a1a <wakeup_proc+0x1c>
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0208a98:	00003697          	auipc	a3,0x3
ffffffffc0208a9c:	95868693          	addi	a3,a3,-1704 # ffffffffc020b3f0 <default_pmm_manager+0x1558>
ffffffffc0208aa0:	00001617          	auipc	a2,0x1
ffffffffc0208aa4:	cb060613          	addi	a2,a2,-848 # ffffffffc0209750 <commands+0x4c0>
ffffffffc0208aa8:	03c00593          	li	a1,60
ffffffffc0208aac:	00003517          	auipc	a0,0x3
ffffffffc0208ab0:	96450513          	addi	a0,a0,-1692 # ffffffffc020b410 <default_pmm_manager+0x1578>
ffffffffc0208ab4:	9d5f70ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0208ab8 <schedule>:

void
schedule(void) {
ffffffffc0208ab8:	7179                	addi	sp,sp,-48
ffffffffc0208aba:	f406                	sd	ra,40(sp)
ffffffffc0208abc:	f022                	sd	s0,32(sp)
ffffffffc0208abe:	ec26                	sd	s1,24(sp)
ffffffffc0208ac0:	e84a                	sd	s2,16(sp)
ffffffffc0208ac2:	e44e                	sd	s3,8(sp)
ffffffffc0208ac4:	e052                	sd	s4,0(sp)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0208ac6:	100027f3          	csrr	a5,sstatus
ffffffffc0208aca:	8b89                	andi	a5,a5,2
ffffffffc0208acc:	4a01                	li	s4,0
ffffffffc0208ace:	e7d5                	bnez	a5,ffffffffc0208b7a <schedule+0xc2>
    bool intr_flag;
    struct proc_struct *next;
    local_intr_save(intr_flag);
    {
        current->need_resched = 0;
ffffffffc0208ad0:	000c0497          	auipc	s1,0xc0
ffffffffc0208ad4:	7b048493          	addi	s1,s1,1968 # ffffffffc02c9280 <current>
ffffffffc0208ad8:	608c                	ld	a1,0(s1)
ffffffffc0208ada:	000c0997          	auipc	s3,0xc0
ffffffffc0208ade:	7ce98993          	addi	s3,s3,1998 # ffffffffc02c92a8 <sched_class>
ffffffffc0208ae2:	000c0917          	auipc	s2,0xc0
ffffffffc0208ae6:	7be90913          	addi	s2,s2,1982 # ffffffffc02c92a0 <rq>
        if (current->state == PROC_RUNNABLE) {
ffffffffc0208aea:	4194                	lw	a3,0(a1)
        current->need_resched = 0;
ffffffffc0208aec:	0005bc23          	sd	zero,24(a1)
        if (current->state == PROC_RUNNABLE) {
ffffffffc0208af0:	4709                	li	a4,2
ffffffffc0208af2:	0009b783          	ld	a5,0(s3)
ffffffffc0208af6:	00093503          	ld	a0,0(s2)
ffffffffc0208afa:	04e68063          	beq	a3,a4,ffffffffc0208b3a <schedule+0x82>
    return sched_class->pick_next(rq);
ffffffffc0208afe:	739c                	ld	a5,32(a5)
ffffffffc0208b00:	9782                	jalr	a5
ffffffffc0208b02:	842a                	mv	s0,a0
            sched_class_enqueue(current);
        }
        if ((next = sched_class_pick_next()) != NULL) {
ffffffffc0208b04:	cd21                	beqz	a0,ffffffffc0208b5c <schedule+0xa4>
    sched_class->dequeue(rq, proc);
ffffffffc0208b06:	0009b783          	ld	a5,0(s3)
ffffffffc0208b0a:	00093503          	ld	a0,0(s2)
ffffffffc0208b0e:	85a2                	mv	a1,s0
ffffffffc0208b10:	6f9c                	ld	a5,24(a5)
ffffffffc0208b12:	9782                	jalr	a5
            sched_class_dequeue(next);
        }
        if (next == NULL) {
            next = idleproc;
        }
        next->runs ++;
ffffffffc0208b14:	441c                	lw	a5,8(s0)
        if (next != current) {
ffffffffc0208b16:	6098                	ld	a4,0(s1)
        next->runs ++;
ffffffffc0208b18:	2785                	addiw	a5,a5,1
ffffffffc0208b1a:	c41c                	sw	a5,8(s0)
        if (next != current) {
ffffffffc0208b1c:	00870563          	beq	a4,s0,ffffffffc0208b26 <schedule+0x6e>
            proc_run(next);
ffffffffc0208b20:	8522                	mv	a0,s0
ffffffffc0208b22:	be0fc0ef          	jal	ra,ffffffffc0204f02 <proc_run>
    if (flag) {
ffffffffc0208b26:	040a1163          	bnez	s4,ffffffffc0208b68 <schedule+0xb0>
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc0208b2a:	70a2                	ld	ra,40(sp)
ffffffffc0208b2c:	7402                	ld	s0,32(sp)
ffffffffc0208b2e:	64e2                	ld	s1,24(sp)
ffffffffc0208b30:	6942                	ld	s2,16(sp)
ffffffffc0208b32:	69a2                	ld	s3,8(sp)
ffffffffc0208b34:	6a02                	ld	s4,0(sp)
ffffffffc0208b36:	6145                	addi	sp,sp,48
ffffffffc0208b38:	8082                	ret
    if (proc != idleproc) {
ffffffffc0208b3a:	000c0717          	auipc	a4,0xc0
ffffffffc0208b3e:	74e70713          	addi	a4,a4,1870 # ffffffffc02c9288 <idleproc>
ffffffffc0208b42:	6318                	ld	a4,0(a4)
ffffffffc0208b44:	fae58de3          	beq	a1,a4,ffffffffc0208afe <schedule+0x46>
        sched_class->enqueue(rq, proc);
ffffffffc0208b48:	6b9c                	ld	a5,16(a5)
ffffffffc0208b4a:	9782                	jalr	a5
ffffffffc0208b4c:	0009b783          	ld	a5,0(s3)
ffffffffc0208b50:	00093503          	ld	a0,0(s2)
    return sched_class->pick_next(rq);
ffffffffc0208b54:	739c                	ld	a5,32(a5)
ffffffffc0208b56:	9782                	jalr	a5
ffffffffc0208b58:	842a                	mv	s0,a0
        if ((next = sched_class_pick_next()) != NULL) {
ffffffffc0208b5a:	f555                	bnez	a0,ffffffffc0208b06 <schedule+0x4e>
            next = idleproc;
ffffffffc0208b5c:	000c0797          	auipc	a5,0xc0
ffffffffc0208b60:	72c78793          	addi	a5,a5,1836 # ffffffffc02c9288 <idleproc>
ffffffffc0208b64:	6380                	ld	s0,0(a5)
ffffffffc0208b66:	b77d                	j	ffffffffc0208b14 <schedule+0x5c>
}
ffffffffc0208b68:	7402                	ld	s0,32(sp)
ffffffffc0208b6a:	70a2                	ld	ra,40(sp)
ffffffffc0208b6c:	64e2                	ld	s1,24(sp)
ffffffffc0208b6e:	6942                	ld	s2,16(sp)
ffffffffc0208b70:	69a2                	ld	s3,8(sp)
ffffffffc0208b72:	6a02                	ld	s4,0(sp)
ffffffffc0208b74:	6145                	addi	sp,sp,48
        intr_enable();
ffffffffc0208b76:	ad7f706f          	j	ffffffffc020064c <intr_enable>
        intr_disable();
ffffffffc0208b7a:	ad9f70ef          	jal	ra,ffffffffc0200652 <intr_disable>
        return 1;
ffffffffc0208b7e:	4a05                	li	s4,1
ffffffffc0208b80:	bf81                	j	ffffffffc0208ad0 <schedule+0x18>

ffffffffc0208b82 <sys_getpid>:
    return do_kill(pid);
}

static int
sys_getpid(uint64_t arg[]) {
    return current->pid;
ffffffffc0208b82:	000c0797          	auipc	a5,0xc0
ffffffffc0208b86:	6fe78793          	addi	a5,a5,1790 # ffffffffc02c9280 <current>
ffffffffc0208b8a:	639c                	ld	a5,0(a5)
}
ffffffffc0208b8c:	43c8                	lw	a0,4(a5)
ffffffffc0208b8e:	8082                	ret

ffffffffc0208b90 <sys_pgdir>:

static int
sys_pgdir(uint64_t arg[]) {
    //print_pgdir();
    return 0;
}
ffffffffc0208b90:	4501                	li	a0,0
ffffffffc0208b92:	8082                	ret

ffffffffc0208b94 <sys_gettime>:
static int sys_gettime(uint64_t arg[]){
    return (int)ticks*10;
ffffffffc0208b94:	000c0797          	auipc	a5,0xc0
ffffffffc0208b98:	71c78793          	addi	a5,a5,1820 # ffffffffc02c92b0 <ticks>
ffffffffc0208b9c:	639c                	ld	a5,0(a5)
ffffffffc0208b9e:	0027951b          	slliw	a0,a5,0x2
ffffffffc0208ba2:	9d3d                	addw	a0,a0,a5
}
ffffffffc0208ba4:	0015151b          	slliw	a0,a0,0x1
ffffffffc0208ba8:	8082                	ret

ffffffffc0208baa <sys_lab6_set_priority>:
static int sys_lab6_set_priority(uint64_t arg[]){
    uint64_t priority = (uint64_t)arg[0];
    lab6_set_priority(priority);
ffffffffc0208baa:	4108                	lw	a0,0(a0)
static int sys_lab6_set_priority(uint64_t arg[]){
ffffffffc0208bac:	1141                	addi	sp,sp,-16
ffffffffc0208bae:	e406                	sd	ra,8(sp)
    lab6_set_priority(priority);
ffffffffc0208bb0:	b62fd0ef          	jal	ra,ffffffffc0205f12 <lab6_set_priority>
    return 0;
}
ffffffffc0208bb4:	60a2                	ld	ra,8(sp)
ffffffffc0208bb6:	4501                	li	a0,0
ffffffffc0208bb8:	0141                	addi	sp,sp,16
ffffffffc0208bba:	8082                	ret

ffffffffc0208bbc <sys_putc>:
    cputchar(c);
ffffffffc0208bbc:	4108                	lw	a0,0(a0)
sys_putc(uint64_t arg[]) {
ffffffffc0208bbe:	1141                	addi	sp,sp,-16
ffffffffc0208bc0:	e406                	sd	ra,8(sp)
    cputchar(c);
ffffffffc0208bc2:	e04f70ef          	jal	ra,ffffffffc02001c6 <cputchar>
}
ffffffffc0208bc6:	60a2                	ld	ra,8(sp)
ffffffffc0208bc8:	4501                	li	a0,0
ffffffffc0208bca:	0141                	addi	sp,sp,16
ffffffffc0208bcc:	8082                	ret

ffffffffc0208bce <sys_kill>:
    return do_kill(pid);
ffffffffc0208bce:	4108                	lw	a0,0(a0)
ffffffffc0208bd0:	994fd06f          	j	ffffffffc0205d64 <do_kill>

ffffffffc0208bd4 <sys_yield>:
    return do_yield();
ffffffffc0208bd4:	93efd06f          	j	ffffffffc0205d12 <do_yield>

ffffffffc0208bd8 <sys_exec>:
    return do_execve(name, len, binary, size);
ffffffffc0208bd8:	6d14                	ld	a3,24(a0)
ffffffffc0208bda:	6910                	ld	a2,16(a0)
ffffffffc0208bdc:	650c                	ld	a1,8(a0)
ffffffffc0208bde:	6108                	ld	a0,0(a0)
ffffffffc0208be0:	c35fc06f          	j	ffffffffc0205814 <do_execve>

ffffffffc0208be4 <sys_wait>:
    return do_wait(pid, store);
ffffffffc0208be4:	650c                	ld	a1,8(a0)
ffffffffc0208be6:	4108                	lw	a0,0(a0)
ffffffffc0208be8:	93cfd06f          	j	ffffffffc0205d24 <do_wait>

ffffffffc0208bec <sys_fork>:
    struct trapframe *tf = current->tf;
ffffffffc0208bec:	000c0797          	auipc	a5,0xc0
ffffffffc0208bf0:	69478793          	addi	a5,a5,1684 # ffffffffc02c9280 <current>
ffffffffc0208bf4:	639c                	ld	a5,0(a5)
    return do_fork(0, stack, tf);
ffffffffc0208bf6:	4501                	li	a0,0
    struct trapframe *tf = current->tf;
ffffffffc0208bf8:	73d0                	ld	a2,160(a5)
    return do_fork(0, stack, tf);
ffffffffc0208bfa:	6a0c                	ld	a1,16(a2)
ffffffffc0208bfc:	bcefc06f          	j	ffffffffc0204fca <do_fork>

ffffffffc0208c00 <sys_exit>:
    return do_exit(error_code);
ffffffffc0208c00:	4108                	lw	a0,0(a0)
ffffffffc0208c02:	ff4fc06f          	j	ffffffffc02053f6 <do_exit>

ffffffffc0208c06 <syscall>:
};

#define NUM_SYSCALLS        ((sizeof(syscalls)) / (sizeof(syscalls[0])))

void
syscall(void) {
ffffffffc0208c06:	715d                	addi	sp,sp,-80
ffffffffc0208c08:	fc26                	sd	s1,56(sp)
    struct trapframe *tf = current->tf;
ffffffffc0208c0a:	000c0497          	auipc	s1,0xc0
ffffffffc0208c0e:	67648493          	addi	s1,s1,1654 # ffffffffc02c9280 <current>
ffffffffc0208c12:	6098                	ld	a4,0(s1)
syscall(void) {
ffffffffc0208c14:	e0a2                	sd	s0,64(sp)
ffffffffc0208c16:	f84a                	sd	s2,48(sp)
    struct trapframe *tf = current->tf;
ffffffffc0208c18:	7340                	ld	s0,160(a4)
syscall(void) {
ffffffffc0208c1a:	e486                	sd	ra,72(sp)
    uint64_t arg[5];
    int num = tf->gpr.a0;
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc0208c1c:	0ff00793          	li	a5,255
    int num = tf->gpr.a0;
ffffffffc0208c20:	05042903          	lw	s2,80(s0)
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc0208c24:	0327ee63          	bltu	a5,s2,ffffffffc0208c60 <syscall+0x5a>
        if (syscalls[num] != NULL) {
ffffffffc0208c28:	00391713          	slli	a4,s2,0x3
ffffffffc0208c2c:	00003797          	auipc	a5,0x3
ffffffffc0208c30:	86478793          	addi	a5,a5,-1948 # ffffffffc020b490 <syscalls>
ffffffffc0208c34:	97ba                	add	a5,a5,a4
ffffffffc0208c36:	639c                	ld	a5,0(a5)
ffffffffc0208c38:	c785                	beqz	a5,ffffffffc0208c60 <syscall+0x5a>
            arg[0] = tf->gpr.a1;
ffffffffc0208c3a:	6c28                	ld	a0,88(s0)
            arg[1] = tf->gpr.a2;
ffffffffc0208c3c:	702c                	ld	a1,96(s0)
            arg[2] = tf->gpr.a3;
ffffffffc0208c3e:	7430                	ld	a2,104(s0)
            arg[3] = tf->gpr.a4;
ffffffffc0208c40:	7834                	ld	a3,112(s0)
            arg[4] = tf->gpr.a5;
ffffffffc0208c42:	7c38                	ld	a4,120(s0)
            arg[0] = tf->gpr.a1;
ffffffffc0208c44:	e42a                	sd	a0,8(sp)
            arg[1] = tf->gpr.a2;
ffffffffc0208c46:	e82e                	sd	a1,16(sp)
            arg[2] = tf->gpr.a3;
ffffffffc0208c48:	ec32                	sd	a2,24(sp)
            arg[3] = tf->gpr.a4;
ffffffffc0208c4a:	f036                	sd	a3,32(sp)
            arg[4] = tf->gpr.a5;
ffffffffc0208c4c:	f43a                	sd	a4,40(sp)
            tf->gpr.a0 = syscalls[num](arg);
ffffffffc0208c4e:	0028                	addi	a0,sp,8
ffffffffc0208c50:	9782                	jalr	a5
ffffffffc0208c52:	e828                	sd	a0,80(s0)
        }
    }
    print_trapframe(tf);
    panic("undefined syscall %d, pid = %d, name = %s.\n",
            num, current->pid, current->name);
}
ffffffffc0208c54:	60a6                	ld	ra,72(sp)
ffffffffc0208c56:	6406                	ld	s0,64(sp)
ffffffffc0208c58:	74e2                	ld	s1,56(sp)
ffffffffc0208c5a:	7942                	ld	s2,48(sp)
ffffffffc0208c5c:	6161                	addi	sp,sp,80
ffffffffc0208c5e:	8082                	ret
    print_trapframe(tf);
ffffffffc0208c60:	8522                	mv	a0,s0
ffffffffc0208c62:	be1f70ef          	jal	ra,ffffffffc0200842 <print_trapframe>
    panic("undefined syscall %d, pid = %d, name = %s.\n",
ffffffffc0208c66:	609c                	ld	a5,0(s1)
ffffffffc0208c68:	86ca                	mv	a3,s2
ffffffffc0208c6a:	00002617          	auipc	a2,0x2
ffffffffc0208c6e:	7de60613          	addi	a2,a2,2014 # ffffffffc020b448 <default_pmm_manager+0x15b0>
ffffffffc0208c72:	43d8                	lw	a4,4(a5)
ffffffffc0208c74:	06d00593          	li	a1,109
ffffffffc0208c78:	0b478793          	addi	a5,a5,180
ffffffffc0208c7c:	00002517          	auipc	a0,0x2
ffffffffc0208c80:	7fc50513          	addi	a0,a0,2044 # ffffffffc020b478 <default_pmm_manager+0x15e0>
ffffffffc0208c84:	805f70ef          	jal	ra,ffffffffc0200488 <__panic>

ffffffffc0208c88 <hash32>:
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
ffffffffc0208c88:	9e3707b7          	lui	a5,0x9e370
ffffffffc0208c8c:	2785                	addiw	a5,a5,1
ffffffffc0208c8e:	02f5053b          	mulw	a0,a0,a5
    return (hash >> (32 - bits));
ffffffffc0208c92:	02000793          	li	a5,32
ffffffffc0208c96:	40b785bb          	subw	a1,a5,a1
}
ffffffffc0208c9a:	00b5553b          	srlw	a0,a0,a1
ffffffffc0208c9e:	8082                	ret

ffffffffc0208ca0 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0208ca0:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0208ca4:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0208ca6:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0208caa:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0208cac:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0208cb0:	f022                	sd	s0,32(sp)
ffffffffc0208cb2:	ec26                	sd	s1,24(sp)
ffffffffc0208cb4:	e84a                	sd	s2,16(sp)
ffffffffc0208cb6:	f406                	sd	ra,40(sp)
ffffffffc0208cb8:	e44e                	sd	s3,8(sp)
ffffffffc0208cba:	84aa                	mv	s1,a0
ffffffffc0208cbc:	892e                	mv	s2,a1
ffffffffc0208cbe:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0208cc2:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
ffffffffc0208cc4:	03067e63          	bleu	a6,a2,ffffffffc0208d00 <printnum+0x60>
ffffffffc0208cc8:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0208cca:	00805763          	blez	s0,ffffffffc0208cd8 <printnum+0x38>
ffffffffc0208cce:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0208cd0:	85ca                	mv	a1,s2
ffffffffc0208cd2:	854e                	mv	a0,s3
ffffffffc0208cd4:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0208cd6:	fc65                	bnez	s0,ffffffffc0208cce <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0208cd8:	1a02                	slli	s4,s4,0x20
ffffffffc0208cda:	020a5a13          	srli	s4,s4,0x20
ffffffffc0208cde:	00003797          	auipc	a5,0x3
ffffffffc0208ce2:	1d278793          	addi	a5,a5,466 # ffffffffc020beb0 <error_string+0xc8>
ffffffffc0208ce6:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
ffffffffc0208ce8:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0208cea:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0208cee:	70a2                	ld	ra,40(sp)
ffffffffc0208cf0:	69a2                	ld	s3,8(sp)
ffffffffc0208cf2:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0208cf4:	85ca                	mv	a1,s2
ffffffffc0208cf6:	8326                	mv	t1,s1
}
ffffffffc0208cf8:	6942                	ld	s2,16(sp)
ffffffffc0208cfa:	64e2                	ld	s1,24(sp)
ffffffffc0208cfc:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0208cfe:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0208d00:	03065633          	divu	a2,a2,a6
ffffffffc0208d04:	8722                	mv	a4,s0
ffffffffc0208d06:	f9bff0ef          	jal	ra,ffffffffc0208ca0 <printnum>
ffffffffc0208d0a:	b7f9                	j	ffffffffc0208cd8 <printnum+0x38>

ffffffffc0208d0c <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0208d0c:	7119                	addi	sp,sp,-128
ffffffffc0208d0e:	f4a6                	sd	s1,104(sp)
ffffffffc0208d10:	f0ca                	sd	s2,96(sp)
ffffffffc0208d12:	e8d2                	sd	s4,80(sp)
ffffffffc0208d14:	e4d6                	sd	s5,72(sp)
ffffffffc0208d16:	e0da                	sd	s6,64(sp)
ffffffffc0208d18:	fc5e                	sd	s7,56(sp)
ffffffffc0208d1a:	f862                	sd	s8,48(sp)
ffffffffc0208d1c:	f06a                	sd	s10,32(sp)
ffffffffc0208d1e:	fc86                	sd	ra,120(sp)
ffffffffc0208d20:	f8a2                	sd	s0,112(sp)
ffffffffc0208d22:	ecce                	sd	s3,88(sp)
ffffffffc0208d24:	f466                	sd	s9,40(sp)
ffffffffc0208d26:	ec6e                	sd	s11,24(sp)
ffffffffc0208d28:	892a                	mv	s2,a0
ffffffffc0208d2a:	84ae                	mv	s1,a1
ffffffffc0208d2c:	8d32                	mv	s10,a2
ffffffffc0208d2e:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0208d30:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0208d32:	00003a17          	auipc	s4,0x3
ffffffffc0208d36:	f5ea0a13          	addi	s4,s4,-162 # ffffffffc020bc90 <syscalls+0x800>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0208d3a:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0208d3e:	00003c17          	auipc	s8,0x3
ffffffffc0208d42:	0aac0c13          	addi	s8,s8,170 # ffffffffc020bde8 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0208d46:	000d4503          	lbu	a0,0(s10)
ffffffffc0208d4a:	02500793          	li	a5,37
ffffffffc0208d4e:	001d0413          	addi	s0,s10,1
ffffffffc0208d52:	00f50e63          	beq	a0,a5,ffffffffc0208d6e <vprintfmt+0x62>
            if (ch == '\0') {
ffffffffc0208d56:	c521                	beqz	a0,ffffffffc0208d9e <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0208d58:	02500993          	li	s3,37
ffffffffc0208d5c:	a011                	j	ffffffffc0208d60 <vprintfmt+0x54>
            if (ch == '\0') {
ffffffffc0208d5e:	c121                	beqz	a0,ffffffffc0208d9e <vprintfmt+0x92>
            putch(ch, putdat);
ffffffffc0208d60:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0208d62:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0208d64:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0208d66:	fff44503          	lbu	a0,-1(s0)
ffffffffc0208d6a:	ff351ae3          	bne	a0,s3,ffffffffc0208d5e <vprintfmt+0x52>
ffffffffc0208d6e:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0208d72:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0208d76:	4981                	li	s3,0
ffffffffc0208d78:	4801                	li	a6,0
        width = precision = -1;
ffffffffc0208d7a:	5cfd                	li	s9,-1
ffffffffc0208d7c:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0208d7e:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
ffffffffc0208d82:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0208d84:	fdd6069b          	addiw	a3,a2,-35
ffffffffc0208d88:	0ff6f693          	andi	a3,a3,255
ffffffffc0208d8c:	00140d13          	addi	s10,s0,1
ffffffffc0208d90:	20d5e563          	bltu	a1,a3,ffffffffc0208f9a <vprintfmt+0x28e>
ffffffffc0208d94:	068a                	slli	a3,a3,0x2
ffffffffc0208d96:	96d2                	add	a3,a3,s4
ffffffffc0208d98:	4294                	lw	a3,0(a3)
ffffffffc0208d9a:	96d2                	add	a3,a3,s4
ffffffffc0208d9c:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0208d9e:	70e6                	ld	ra,120(sp)
ffffffffc0208da0:	7446                	ld	s0,112(sp)
ffffffffc0208da2:	74a6                	ld	s1,104(sp)
ffffffffc0208da4:	7906                	ld	s2,96(sp)
ffffffffc0208da6:	69e6                	ld	s3,88(sp)
ffffffffc0208da8:	6a46                	ld	s4,80(sp)
ffffffffc0208daa:	6aa6                	ld	s5,72(sp)
ffffffffc0208dac:	6b06                	ld	s6,64(sp)
ffffffffc0208dae:	7be2                	ld	s7,56(sp)
ffffffffc0208db0:	7c42                	ld	s8,48(sp)
ffffffffc0208db2:	7ca2                	ld	s9,40(sp)
ffffffffc0208db4:	7d02                	ld	s10,32(sp)
ffffffffc0208db6:	6de2                	ld	s11,24(sp)
ffffffffc0208db8:	6109                	addi	sp,sp,128
ffffffffc0208dba:	8082                	ret
    if (lflag >= 2) {
ffffffffc0208dbc:	4705                	li	a4,1
ffffffffc0208dbe:	008a8593          	addi	a1,s5,8
ffffffffc0208dc2:	01074463          	blt	a4,a6,ffffffffc0208dca <vprintfmt+0xbe>
    else if (lflag) {
ffffffffc0208dc6:	26080363          	beqz	a6,ffffffffc020902c <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
ffffffffc0208dca:	000ab603          	ld	a2,0(s5)
ffffffffc0208dce:	46c1                	li	a3,16
ffffffffc0208dd0:	8aae                	mv	s5,a1
ffffffffc0208dd2:	a06d                	j	ffffffffc0208e7c <vprintfmt+0x170>
            goto reswitch;
ffffffffc0208dd4:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0208dd8:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0208dda:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0208ddc:	b765                	j	ffffffffc0208d84 <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
ffffffffc0208dde:	000aa503          	lw	a0,0(s5)
ffffffffc0208de2:	85a6                	mv	a1,s1
ffffffffc0208de4:	0aa1                	addi	s5,s5,8
ffffffffc0208de6:	9902                	jalr	s2
            break;
ffffffffc0208de8:	bfb9                	j	ffffffffc0208d46 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0208dea:	4705                	li	a4,1
ffffffffc0208dec:	008a8993          	addi	s3,s5,8
ffffffffc0208df0:	01074463          	blt	a4,a6,ffffffffc0208df8 <vprintfmt+0xec>
    else if (lflag) {
ffffffffc0208df4:	22080463          	beqz	a6,ffffffffc020901c <vprintfmt+0x310>
        return va_arg(*ap, long);
ffffffffc0208df8:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
ffffffffc0208dfc:	24044463          	bltz	s0,ffffffffc0209044 <vprintfmt+0x338>
            num = getint(&ap, lflag);
ffffffffc0208e00:	8622                	mv	a2,s0
ffffffffc0208e02:	8ace                	mv	s5,s3
ffffffffc0208e04:	46a9                	li	a3,10
ffffffffc0208e06:	a89d                	j	ffffffffc0208e7c <vprintfmt+0x170>
            err = va_arg(ap, int);
ffffffffc0208e08:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0208e0c:	4761                	li	a4,24
            err = va_arg(ap, int);
ffffffffc0208e0e:	0aa1                	addi	s5,s5,8
            if (err < 0) {
ffffffffc0208e10:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0208e14:	8fb5                	xor	a5,a5,a3
ffffffffc0208e16:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0208e1a:	1ad74363          	blt	a4,a3,ffffffffc0208fc0 <vprintfmt+0x2b4>
ffffffffc0208e1e:	00369793          	slli	a5,a3,0x3
ffffffffc0208e22:	97e2                	add	a5,a5,s8
ffffffffc0208e24:	639c                	ld	a5,0(a5)
ffffffffc0208e26:	18078d63          	beqz	a5,ffffffffc0208fc0 <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
ffffffffc0208e2a:	86be                	mv	a3,a5
ffffffffc0208e2c:	00000617          	auipc	a2,0x0
ffffffffc0208e30:	35c60613          	addi	a2,a2,860 # ffffffffc0209188 <etext+0x28>
ffffffffc0208e34:	85a6                	mv	a1,s1
ffffffffc0208e36:	854a                	mv	a0,s2
ffffffffc0208e38:	240000ef          	jal	ra,ffffffffc0209078 <printfmt>
ffffffffc0208e3c:	b729                	j	ffffffffc0208d46 <vprintfmt+0x3a>
            lflag ++;
ffffffffc0208e3e:	00144603          	lbu	a2,1(s0)
ffffffffc0208e42:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0208e44:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0208e46:	bf3d                	j	ffffffffc0208d84 <vprintfmt+0x78>
    if (lflag >= 2) {
ffffffffc0208e48:	4705                	li	a4,1
ffffffffc0208e4a:	008a8593          	addi	a1,s5,8
ffffffffc0208e4e:	01074463          	blt	a4,a6,ffffffffc0208e56 <vprintfmt+0x14a>
    else if (lflag) {
ffffffffc0208e52:	1e080263          	beqz	a6,ffffffffc0209036 <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
ffffffffc0208e56:	000ab603          	ld	a2,0(s5)
ffffffffc0208e5a:	46a1                	li	a3,8
ffffffffc0208e5c:	8aae                	mv	s5,a1
ffffffffc0208e5e:	a839                	j	ffffffffc0208e7c <vprintfmt+0x170>
            putch('0', putdat);
ffffffffc0208e60:	03000513          	li	a0,48
ffffffffc0208e64:	85a6                	mv	a1,s1
ffffffffc0208e66:	e03e                	sd	a5,0(sp)
ffffffffc0208e68:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0208e6a:	85a6                	mv	a1,s1
ffffffffc0208e6c:	07800513          	li	a0,120
ffffffffc0208e70:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0208e72:	0aa1                	addi	s5,s5,8
ffffffffc0208e74:	ff8ab603          	ld	a2,-8(s5)
            goto number;
ffffffffc0208e78:	6782                	ld	a5,0(sp)
ffffffffc0208e7a:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0208e7c:	876e                	mv	a4,s11
ffffffffc0208e7e:	85a6                	mv	a1,s1
ffffffffc0208e80:	854a                	mv	a0,s2
ffffffffc0208e82:	e1fff0ef          	jal	ra,ffffffffc0208ca0 <printnum>
            break;
ffffffffc0208e86:	b5c1                	j	ffffffffc0208d46 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0208e88:	000ab603          	ld	a2,0(s5)
ffffffffc0208e8c:	0aa1                	addi	s5,s5,8
ffffffffc0208e8e:	1c060663          	beqz	a2,ffffffffc020905a <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
ffffffffc0208e92:	00160413          	addi	s0,a2,1
ffffffffc0208e96:	17b05c63          	blez	s11,ffffffffc020900e <vprintfmt+0x302>
ffffffffc0208e9a:	02d00593          	li	a1,45
ffffffffc0208e9e:	14b79263          	bne	a5,a1,ffffffffc0208fe2 <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0208ea2:	00064783          	lbu	a5,0(a2)
ffffffffc0208ea6:	0007851b          	sext.w	a0,a5
ffffffffc0208eaa:	c905                	beqz	a0,ffffffffc0208eda <vprintfmt+0x1ce>
ffffffffc0208eac:	000cc563          	bltz	s9,ffffffffc0208eb6 <vprintfmt+0x1aa>
ffffffffc0208eb0:	3cfd                	addiw	s9,s9,-1
ffffffffc0208eb2:	036c8263          	beq	s9,s6,ffffffffc0208ed6 <vprintfmt+0x1ca>
                    putch('?', putdat);
ffffffffc0208eb6:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0208eb8:	18098463          	beqz	s3,ffffffffc0209040 <vprintfmt+0x334>
ffffffffc0208ebc:	3781                	addiw	a5,a5,-32
ffffffffc0208ebe:	18fbf163          	bleu	a5,s7,ffffffffc0209040 <vprintfmt+0x334>
                    putch('?', putdat);
ffffffffc0208ec2:	03f00513          	li	a0,63
ffffffffc0208ec6:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0208ec8:	0405                	addi	s0,s0,1
ffffffffc0208eca:	fff44783          	lbu	a5,-1(s0)
ffffffffc0208ece:	3dfd                	addiw	s11,s11,-1
ffffffffc0208ed0:	0007851b          	sext.w	a0,a5
ffffffffc0208ed4:	fd61                	bnez	a0,ffffffffc0208eac <vprintfmt+0x1a0>
            for (; width > 0; width --) {
ffffffffc0208ed6:	e7b058e3          	blez	s11,ffffffffc0208d46 <vprintfmt+0x3a>
ffffffffc0208eda:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0208edc:	85a6                	mv	a1,s1
ffffffffc0208ede:	02000513          	li	a0,32
ffffffffc0208ee2:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0208ee4:	e60d81e3          	beqz	s11,ffffffffc0208d46 <vprintfmt+0x3a>
ffffffffc0208ee8:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0208eea:	85a6                	mv	a1,s1
ffffffffc0208eec:	02000513          	li	a0,32
ffffffffc0208ef0:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0208ef2:	fe0d94e3          	bnez	s11,ffffffffc0208eda <vprintfmt+0x1ce>
ffffffffc0208ef6:	bd81                	j	ffffffffc0208d46 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0208ef8:	4705                	li	a4,1
ffffffffc0208efa:	008a8593          	addi	a1,s5,8
ffffffffc0208efe:	01074463          	blt	a4,a6,ffffffffc0208f06 <vprintfmt+0x1fa>
    else if (lflag) {
ffffffffc0208f02:	12080063          	beqz	a6,ffffffffc0209022 <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
ffffffffc0208f06:	000ab603          	ld	a2,0(s5)
ffffffffc0208f0a:	46a9                	li	a3,10
ffffffffc0208f0c:	8aae                	mv	s5,a1
ffffffffc0208f0e:	b7bd                	j	ffffffffc0208e7c <vprintfmt+0x170>
ffffffffc0208f10:	00144603          	lbu	a2,1(s0)
            padc = '-';
ffffffffc0208f14:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0208f18:	846a                	mv	s0,s10
ffffffffc0208f1a:	b5ad                	j	ffffffffc0208d84 <vprintfmt+0x78>
            putch(ch, putdat);
ffffffffc0208f1c:	85a6                	mv	a1,s1
ffffffffc0208f1e:	02500513          	li	a0,37
ffffffffc0208f22:	9902                	jalr	s2
            break;
ffffffffc0208f24:	b50d                	j	ffffffffc0208d46 <vprintfmt+0x3a>
            precision = va_arg(ap, int);
ffffffffc0208f26:	000aac83          	lw	s9,0(s5)
            goto process_precision;
ffffffffc0208f2a:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0208f2e:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0208f30:	846a                	mv	s0,s10
            if (width < 0)
ffffffffc0208f32:	e40dd9e3          	bgez	s11,ffffffffc0208d84 <vprintfmt+0x78>
                width = precision, precision = -1;
ffffffffc0208f36:	8de6                	mv	s11,s9
ffffffffc0208f38:	5cfd                	li	s9,-1
ffffffffc0208f3a:	b5a9                	j	ffffffffc0208d84 <vprintfmt+0x78>
            goto reswitch;
ffffffffc0208f3c:	00144603          	lbu	a2,1(s0)
            padc = '0';
ffffffffc0208f40:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0208f44:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0208f46:	bd3d                	j	ffffffffc0208d84 <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
ffffffffc0208f48:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
ffffffffc0208f4c:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0208f50:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0208f52:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0208f56:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0208f5a:	fcd56ce3          	bltu	a0,a3,ffffffffc0208f32 <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
ffffffffc0208f5e:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0208f60:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
ffffffffc0208f64:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0208f68:	0196873b          	addw	a4,a3,s9
ffffffffc0208f6c:	0017171b          	slliw	a4,a4,0x1
ffffffffc0208f70:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
ffffffffc0208f74:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
ffffffffc0208f78:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc0208f7c:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0208f80:	fcd57fe3          	bleu	a3,a0,ffffffffc0208f5e <vprintfmt+0x252>
ffffffffc0208f84:	b77d                	j	ffffffffc0208f32 <vprintfmt+0x226>
            if (width < 0)
ffffffffc0208f86:	fffdc693          	not	a3,s11
ffffffffc0208f8a:	96fd                	srai	a3,a3,0x3f
ffffffffc0208f8c:	00ddfdb3          	and	s11,s11,a3
ffffffffc0208f90:	00144603          	lbu	a2,1(s0)
ffffffffc0208f94:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0208f96:	846a                	mv	s0,s10
ffffffffc0208f98:	b3f5                	j	ffffffffc0208d84 <vprintfmt+0x78>
            putch('%', putdat);
ffffffffc0208f9a:	85a6                	mv	a1,s1
ffffffffc0208f9c:	02500513          	li	a0,37
ffffffffc0208fa0:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0208fa2:	fff44703          	lbu	a4,-1(s0)
ffffffffc0208fa6:	02500793          	li	a5,37
ffffffffc0208faa:	8d22                	mv	s10,s0
ffffffffc0208fac:	d8f70de3          	beq	a4,a5,ffffffffc0208d46 <vprintfmt+0x3a>
ffffffffc0208fb0:	02500713          	li	a4,37
ffffffffc0208fb4:	1d7d                	addi	s10,s10,-1
ffffffffc0208fb6:	fffd4783          	lbu	a5,-1(s10)
ffffffffc0208fba:	fee79de3          	bne	a5,a4,ffffffffc0208fb4 <vprintfmt+0x2a8>
ffffffffc0208fbe:	b361                	j	ffffffffc0208d46 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0208fc0:	00003617          	auipc	a2,0x3
ffffffffc0208fc4:	fd060613          	addi	a2,a2,-48 # ffffffffc020bf90 <error_string+0x1a8>
ffffffffc0208fc8:	85a6                	mv	a1,s1
ffffffffc0208fca:	854a                	mv	a0,s2
ffffffffc0208fcc:	0ac000ef          	jal	ra,ffffffffc0209078 <printfmt>
ffffffffc0208fd0:	bb9d                	j	ffffffffc0208d46 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0208fd2:	00003617          	auipc	a2,0x3
ffffffffc0208fd6:	fb660613          	addi	a2,a2,-74 # ffffffffc020bf88 <error_string+0x1a0>
            if (width > 0 && padc != '-') {
ffffffffc0208fda:	00003417          	auipc	s0,0x3
ffffffffc0208fde:	faf40413          	addi	s0,s0,-81 # ffffffffc020bf89 <error_string+0x1a1>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0208fe2:	8532                	mv	a0,a2
ffffffffc0208fe4:	85e6                	mv	a1,s9
ffffffffc0208fe6:	e032                	sd	a2,0(sp)
ffffffffc0208fe8:	e43e                	sd	a5,8(sp)
ffffffffc0208fea:	0cc000ef          	jal	ra,ffffffffc02090b6 <strnlen>
ffffffffc0208fee:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0208ff2:	6602                	ld	a2,0(sp)
ffffffffc0208ff4:	01b05d63          	blez	s11,ffffffffc020900e <vprintfmt+0x302>
ffffffffc0208ff8:	67a2                	ld	a5,8(sp)
ffffffffc0208ffa:	2781                	sext.w	a5,a5
ffffffffc0208ffc:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
ffffffffc0208ffe:	6522                	ld	a0,8(sp)
ffffffffc0209000:	85a6                	mv	a1,s1
ffffffffc0209002:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0209004:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0209006:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0209008:	6602                	ld	a2,0(sp)
ffffffffc020900a:	fe0d9ae3          	bnez	s11,ffffffffc0208ffe <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020900e:	00064783          	lbu	a5,0(a2)
ffffffffc0209012:	0007851b          	sext.w	a0,a5
ffffffffc0209016:	e8051be3          	bnez	a0,ffffffffc0208eac <vprintfmt+0x1a0>
ffffffffc020901a:	b335                	j	ffffffffc0208d46 <vprintfmt+0x3a>
        return va_arg(*ap, int);
ffffffffc020901c:	000aa403          	lw	s0,0(s5)
ffffffffc0209020:	bbf1                	j	ffffffffc0208dfc <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
ffffffffc0209022:	000ae603          	lwu	a2,0(s5)
ffffffffc0209026:	46a9                	li	a3,10
ffffffffc0209028:	8aae                	mv	s5,a1
ffffffffc020902a:	bd89                	j	ffffffffc0208e7c <vprintfmt+0x170>
ffffffffc020902c:	000ae603          	lwu	a2,0(s5)
ffffffffc0209030:	46c1                	li	a3,16
ffffffffc0209032:	8aae                	mv	s5,a1
ffffffffc0209034:	b5a1                	j	ffffffffc0208e7c <vprintfmt+0x170>
ffffffffc0209036:	000ae603          	lwu	a2,0(s5)
ffffffffc020903a:	46a1                	li	a3,8
ffffffffc020903c:	8aae                	mv	s5,a1
ffffffffc020903e:	bd3d                	j	ffffffffc0208e7c <vprintfmt+0x170>
                    putch(ch, putdat);
ffffffffc0209040:	9902                	jalr	s2
ffffffffc0209042:	b559                	j	ffffffffc0208ec8 <vprintfmt+0x1bc>
                putch('-', putdat);
ffffffffc0209044:	85a6                	mv	a1,s1
ffffffffc0209046:	02d00513          	li	a0,45
ffffffffc020904a:	e03e                	sd	a5,0(sp)
ffffffffc020904c:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc020904e:	8ace                	mv	s5,s3
ffffffffc0209050:	40800633          	neg	a2,s0
ffffffffc0209054:	46a9                	li	a3,10
ffffffffc0209056:	6782                	ld	a5,0(sp)
ffffffffc0209058:	b515                	j	ffffffffc0208e7c <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
ffffffffc020905a:	01b05663          	blez	s11,ffffffffc0209066 <vprintfmt+0x35a>
ffffffffc020905e:	02d00693          	li	a3,45
ffffffffc0209062:	f6d798e3          	bne	a5,a3,ffffffffc0208fd2 <vprintfmt+0x2c6>
ffffffffc0209066:	00003417          	auipc	s0,0x3
ffffffffc020906a:	f2340413          	addi	s0,s0,-221 # ffffffffc020bf89 <error_string+0x1a1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020906e:	02800513          	li	a0,40
ffffffffc0209072:	02800793          	li	a5,40
ffffffffc0209076:	bd1d                	j	ffffffffc0208eac <vprintfmt+0x1a0>

ffffffffc0209078 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0209078:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc020907a:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020907e:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0209080:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0209082:	ec06                	sd	ra,24(sp)
ffffffffc0209084:	f83a                	sd	a4,48(sp)
ffffffffc0209086:	fc3e                	sd	a5,56(sp)
ffffffffc0209088:	e0c2                	sd	a6,64(sp)
ffffffffc020908a:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc020908c:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc020908e:	c7fff0ef          	jal	ra,ffffffffc0208d0c <vprintfmt>
}
ffffffffc0209092:	60e2                	ld	ra,24(sp)
ffffffffc0209094:	6161                	addi	sp,sp,80
ffffffffc0209096:	8082                	ret

ffffffffc0209098 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc0209098:	00054783          	lbu	a5,0(a0)
ffffffffc020909c:	cb91                	beqz	a5,ffffffffc02090b0 <strlen+0x18>
    size_t cnt = 0;
ffffffffc020909e:	4781                	li	a5,0
        cnt ++;
ffffffffc02090a0:	0785                	addi	a5,a5,1
    while (*s ++ != '\0') {
ffffffffc02090a2:	00f50733          	add	a4,a0,a5
ffffffffc02090a6:	00074703          	lbu	a4,0(a4)
ffffffffc02090aa:	fb7d                	bnez	a4,ffffffffc02090a0 <strlen+0x8>
    }
    return cnt;
}
ffffffffc02090ac:	853e                	mv	a0,a5
ffffffffc02090ae:	8082                	ret
    size_t cnt = 0;
ffffffffc02090b0:	4781                	li	a5,0
}
ffffffffc02090b2:	853e                	mv	a0,a5
ffffffffc02090b4:	8082                	ret

ffffffffc02090b6 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
ffffffffc02090b6:	c185                	beqz	a1,ffffffffc02090d6 <strnlen+0x20>
ffffffffc02090b8:	00054783          	lbu	a5,0(a0)
ffffffffc02090bc:	cf89                	beqz	a5,ffffffffc02090d6 <strnlen+0x20>
    size_t cnt = 0;
ffffffffc02090be:	4781                	li	a5,0
ffffffffc02090c0:	a021                	j	ffffffffc02090c8 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
ffffffffc02090c2:	00074703          	lbu	a4,0(a4)
ffffffffc02090c6:	c711                	beqz	a4,ffffffffc02090d2 <strnlen+0x1c>
        cnt ++;
ffffffffc02090c8:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc02090ca:	00f50733          	add	a4,a0,a5
ffffffffc02090ce:	fef59ae3          	bne	a1,a5,ffffffffc02090c2 <strnlen+0xc>
    }
    return cnt;
}
ffffffffc02090d2:	853e                	mv	a0,a5
ffffffffc02090d4:	8082                	ret
    size_t cnt = 0;
ffffffffc02090d6:	4781                	li	a5,0
}
ffffffffc02090d8:	853e                	mv	a0,a5
ffffffffc02090da:	8082                	ret

ffffffffc02090dc <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc02090dc:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc02090de:	0585                	addi	a1,a1,1
ffffffffc02090e0:	fff5c703          	lbu	a4,-1(a1)
ffffffffc02090e4:	0785                	addi	a5,a5,1
ffffffffc02090e6:	fee78fa3          	sb	a4,-1(a5)
ffffffffc02090ea:	fb75                	bnez	a4,ffffffffc02090de <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc02090ec:	8082                	ret

ffffffffc02090ee <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02090ee:	00054783          	lbu	a5,0(a0)
ffffffffc02090f2:	0005c703          	lbu	a4,0(a1)
ffffffffc02090f6:	cb91                	beqz	a5,ffffffffc020910a <strcmp+0x1c>
ffffffffc02090f8:	00e79c63          	bne	a5,a4,ffffffffc0209110 <strcmp+0x22>
        s1 ++, s2 ++;
ffffffffc02090fc:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02090fe:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
ffffffffc0209102:	0585                	addi	a1,a1,1
ffffffffc0209104:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0209108:	fbe5                	bnez	a5,ffffffffc02090f8 <strcmp+0xa>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020910a:	4501                	li	a0,0
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc020910c:	9d19                	subw	a0,a0,a4
ffffffffc020910e:	8082                	ret
ffffffffc0209110:	0007851b          	sext.w	a0,a5
ffffffffc0209114:	9d19                	subw	a0,a0,a4
ffffffffc0209116:	8082                	ret

ffffffffc0209118 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0209118:	00054783          	lbu	a5,0(a0)
ffffffffc020911c:	cb91                	beqz	a5,ffffffffc0209130 <strchr+0x18>
        if (*s == c) {
ffffffffc020911e:	00b79563          	bne	a5,a1,ffffffffc0209128 <strchr+0x10>
ffffffffc0209122:	a809                	j	ffffffffc0209134 <strchr+0x1c>
ffffffffc0209124:	00b78763          	beq	a5,a1,ffffffffc0209132 <strchr+0x1a>
            return (char *)s;
        }
        s ++;
ffffffffc0209128:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc020912a:	00054783          	lbu	a5,0(a0)
ffffffffc020912e:	fbfd                	bnez	a5,ffffffffc0209124 <strchr+0xc>
    }
    return NULL;
ffffffffc0209130:	4501                	li	a0,0
}
ffffffffc0209132:	8082                	ret
ffffffffc0209134:	8082                	ret

ffffffffc0209136 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0209136:	ca01                	beqz	a2,ffffffffc0209146 <memset+0x10>
ffffffffc0209138:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc020913a:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc020913c:	0785                	addi	a5,a5,1
ffffffffc020913e:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0209142:	fec79de3          	bne	a5,a2,ffffffffc020913c <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0209146:	8082                	ret

ffffffffc0209148 <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc0209148:	ca19                	beqz	a2,ffffffffc020915e <memcpy+0x16>
ffffffffc020914a:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc020914c:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc020914e:	0585                	addi	a1,a1,1
ffffffffc0209150:	fff5c703          	lbu	a4,-1(a1)
ffffffffc0209154:	0785                	addi	a5,a5,1
ffffffffc0209156:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc020915a:	fec59ae3          	bne	a1,a2,ffffffffc020914e <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc020915e:	8082                	ret
