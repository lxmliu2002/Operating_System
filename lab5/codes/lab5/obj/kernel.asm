
bin/kernel：     文件格式 elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c020b2b7          	lui	t0,0xc020b
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
ffffffffc0200028:	c020b137          	lui	sp,0xc020b

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
ffffffffc0200036:	000a1517          	auipc	a0,0xa1
ffffffffc020003a:	02250513          	addi	a0,a0,34 # ffffffffc02a1058 <edata>
ffffffffc020003e:	000ac617          	auipc	a2,0xac
ffffffffc0200042:	5a260613          	addi	a2,a2,1442 # ffffffffc02ac5e0 <end>
kern_init(void) {
ffffffffc0200046:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200048:	8e09                	sub	a2,a2,a0
ffffffffc020004a:	4581                	li	a1,0
kern_init(void) {
ffffffffc020004c:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004e:	714060ef          	jal	ra,ffffffffc0206762 <memset>
    cons_init();                // init the console
ffffffffc0200052:	536000ef          	jal	ra,ffffffffc0200588 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc0200056:	00006597          	auipc	a1,0x6
ffffffffc020005a:	73a58593          	addi	a1,a1,1850 # ffffffffc0206790 <etext+0x4>
ffffffffc020005e:	00006517          	auipc	a0,0x6
ffffffffc0200062:	75250513          	addi	a0,a0,1874 # ffffffffc02067b0 <etext+0x24>
ffffffffc0200066:	128000ef          	jal	ra,ffffffffc020018e <cprintf>

    print_kerninfo();
ffffffffc020006a:	1ac000ef          	jal	ra,ffffffffc0200216 <print_kerninfo>

    // grade_backtrace();

    pmm_init();                 // init physical memory management
ffffffffc020006e:	319020ef          	jal	ra,ffffffffc0202b86 <pmm_init>

    pic_init();                 // init interrupt controller
ffffffffc0200072:	5ee000ef          	jal	ra,ffffffffc0200660 <pic_init>
    idt_init();                 // init interrupt descriptor table
ffffffffc0200076:	5ec000ef          	jal	ra,ffffffffc0200662 <idt_init>

    vmm_init();                 // init virtual memory management
ffffffffc020007a:	66a040ef          	jal	ra,ffffffffc02046e4 <vmm_init>
    proc_init();                // init process table
ffffffffc020007e:	675050ef          	jal	ra,ffffffffc0205ef2 <proc_init>
    
    ide_init();                 // init ide devices
ffffffffc0200082:	57a000ef          	jal	ra,ffffffffc02005fc <ide_init>
    swap_init();                // init swap
ffffffffc0200086:	624030ef          	jal	ra,ffffffffc02036aa <swap_init>

    clock_init();               // init clock interrupt
ffffffffc020008a:	4a8000ef          	jal	ra,ffffffffc0200532 <clock_init>
    intr_enable();              // enable irq interrupt
ffffffffc020008e:	5c6000ef          	jal	ra,ffffffffc0200654 <intr_enable>
    
    cpu_idle();                 // run idle process
ffffffffc0200092:	7ad050ef          	jal	ra,ffffffffc020603e <cpu_idle>

ffffffffc0200096 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0200096:	715d                	addi	sp,sp,-80
ffffffffc0200098:	e486                	sd	ra,72(sp)
ffffffffc020009a:	e0a2                	sd	s0,64(sp)
ffffffffc020009c:	fc26                	sd	s1,56(sp)
ffffffffc020009e:	f84a                	sd	s2,48(sp)
ffffffffc02000a0:	f44e                	sd	s3,40(sp)
ffffffffc02000a2:	f052                	sd	s4,32(sp)
ffffffffc02000a4:	ec56                	sd	s5,24(sp)
ffffffffc02000a6:	e85a                	sd	s6,16(sp)
ffffffffc02000a8:	e45e                	sd	s7,8(sp)
    if (prompt != NULL) {
ffffffffc02000aa:	c901                	beqz	a0,ffffffffc02000ba <readline+0x24>
        cprintf("%s", prompt);
ffffffffc02000ac:	85aa                	mv	a1,a0
ffffffffc02000ae:	00006517          	auipc	a0,0x6
ffffffffc02000b2:	70a50513          	addi	a0,a0,1802 # ffffffffc02067b8 <etext+0x2c>
ffffffffc02000b6:	0d8000ef          	jal	ra,ffffffffc020018e <cprintf>
readline(const char *prompt) {
ffffffffc02000ba:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000bc:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc02000be:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc02000c0:	4aa9                	li	s5,10
ffffffffc02000c2:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc02000c4:	000a1b97          	auipc	s7,0xa1
ffffffffc02000c8:	f94b8b93          	addi	s7,s7,-108 # ffffffffc02a1058 <edata>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000cc:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc02000d0:	136000ef          	jal	ra,ffffffffc0200206 <getchar>
ffffffffc02000d4:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02000d6:	00054b63          	bltz	a0,ffffffffc02000ec <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000da:	00a95b63          	ble	a0,s2,ffffffffc02000f0 <readline+0x5a>
ffffffffc02000de:	029a5463          	ble	s1,s4,ffffffffc0200106 <readline+0x70>
        c = getchar();
ffffffffc02000e2:	124000ef          	jal	ra,ffffffffc0200206 <getchar>
ffffffffc02000e6:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02000e8:	fe0559e3          	bgez	a0,ffffffffc02000da <readline+0x44>
            return NULL;
ffffffffc02000ec:	4501                	li	a0,0
ffffffffc02000ee:	a099                	j	ffffffffc0200134 <readline+0x9e>
        else if (c == '\b' && i > 0) {
ffffffffc02000f0:	03341463          	bne	s0,s3,ffffffffc0200118 <readline+0x82>
ffffffffc02000f4:	e8b9                	bnez	s1,ffffffffc020014a <readline+0xb4>
        c = getchar();
ffffffffc02000f6:	110000ef          	jal	ra,ffffffffc0200206 <getchar>
ffffffffc02000fa:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02000fc:	fe0548e3          	bltz	a0,ffffffffc02000ec <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0200100:	fea958e3          	ble	a0,s2,ffffffffc02000f0 <readline+0x5a>
ffffffffc0200104:	4481                	li	s1,0
            cputchar(c);
ffffffffc0200106:	8522                	mv	a0,s0
ffffffffc0200108:	0ba000ef          	jal	ra,ffffffffc02001c2 <cputchar>
            buf[i ++] = c;
ffffffffc020010c:	009b87b3          	add	a5,s7,s1
ffffffffc0200110:	00878023          	sb	s0,0(a5)
ffffffffc0200114:	2485                	addiw	s1,s1,1
ffffffffc0200116:	bf6d                	j	ffffffffc02000d0 <readline+0x3a>
        else if (c == '\n' || c == '\r') {
ffffffffc0200118:	01540463          	beq	s0,s5,ffffffffc0200120 <readline+0x8a>
ffffffffc020011c:	fb641ae3          	bne	s0,s6,ffffffffc02000d0 <readline+0x3a>
            cputchar(c);
ffffffffc0200120:	8522                	mv	a0,s0
ffffffffc0200122:	0a0000ef          	jal	ra,ffffffffc02001c2 <cputchar>
            buf[i] = '\0';
ffffffffc0200126:	000a1517          	auipc	a0,0xa1
ffffffffc020012a:	f3250513          	addi	a0,a0,-206 # ffffffffc02a1058 <edata>
ffffffffc020012e:	94aa                	add	s1,s1,a0
ffffffffc0200130:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc0200134:	60a6                	ld	ra,72(sp)
ffffffffc0200136:	6406                	ld	s0,64(sp)
ffffffffc0200138:	74e2                	ld	s1,56(sp)
ffffffffc020013a:	7942                	ld	s2,48(sp)
ffffffffc020013c:	79a2                	ld	s3,40(sp)
ffffffffc020013e:	7a02                	ld	s4,32(sp)
ffffffffc0200140:	6ae2                	ld	s5,24(sp)
ffffffffc0200142:	6b42                	ld	s6,16(sp)
ffffffffc0200144:	6ba2                	ld	s7,8(sp)
ffffffffc0200146:	6161                	addi	sp,sp,80
ffffffffc0200148:	8082                	ret
            cputchar(c);
ffffffffc020014a:	4521                	li	a0,8
ffffffffc020014c:	076000ef          	jal	ra,ffffffffc02001c2 <cputchar>
            i --;
ffffffffc0200150:	34fd                	addiw	s1,s1,-1
ffffffffc0200152:	bfbd                	j	ffffffffc02000d0 <readline+0x3a>

ffffffffc0200154 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200154:	1141                	addi	sp,sp,-16
ffffffffc0200156:	e022                	sd	s0,0(sp)
ffffffffc0200158:	e406                	sd	ra,8(sp)
ffffffffc020015a:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc020015c:	42e000ef          	jal	ra,ffffffffc020058a <cons_putc>
    (*cnt) ++;
ffffffffc0200160:	401c                	lw	a5,0(s0)
}
ffffffffc0200162:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc0200164:	2785                	addiw	a5,a5,1
ffffffffc0200166:	c01c                	sw	a5,0(s0)
}
ffffffffc0200168:	6402                	ld	s0,0(sp)
ffffffffc020016a:	0141                	addi	sp,sp,16
ffffffffc020016c:	8082                	ret

ffffffffc020016e <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc020016e:	1101                	addi	sp,sp,-32
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200170:	86ae                	mv	a3,a1
ffffffffc0200172:	862a                	mv	a2,a0
ffffffffc0200174:	006c                	addi	a1,sp,12
ffffffffc0200176:	00000517          	auipc	a0,0x0
ffffffffc020017a:	fde50513          	addi	a0,a0,-34 # ffffffffc0200154 <cputch>
vcprintf(const char *fmt, va_list ap) {
ffffffffc020017e:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc0200180:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200182:	1b6060ef          	jal	ra,ffffffffc0206338 <vprintfmt>
    return cnt;
}
ffffffffc0200186:	60e2                	ld	ra,24(sp)
ffffffffc0200188:	4532                	lw	a0,12(sp)
ffffffffc020018a:	6105                	addi	sp,sp,32
ffffffffc020018c:	8082                	ret

ffffffffc020018e <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc020018e:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc0200190:	02810313          	addi	t1,sp,40 # ffffffffc020b028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc0200194:	f42e                	sd	a1,40(sp)
ffffffffc0200196:	f832                	sd	a2,48(sp)
ffffffffc0200198:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc020019a:	862a                	mv	a2,a0
ffffffffc020019c:	004c                	addi	a1,sp,4
ffffffffc020019e:	00000517          	auipc	a0,0x0
ffffffffc02001a2:	fb650513          	addi	a0,a0,-74 # ffffffffc0200154 <cputch>
ffffffffc02001a6:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
ffffffffc02001a8:	ec06                	sd	ra,24(sp)
ffffffffc02001aa:	e0ba                	sd	a4,64(sp)
ffffffffc02001ac:	e4be                	sd	a5,72(sp)
ffffffffc02001ae:	e8c2                	sd	a6,80(sp)
ffffffffc02001b0:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02001b2:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02001b4:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02001b6:	182060ef          	jal	ra,ffffffffc0206338 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02001ba:	60e2                	ld	ra,24(sp)
ffffffffc02001bc:	4512                	lw	a0,4(sp)
ffffffffc02001be:	6125                	addi	sp,sp,96
ffffffffc02001c0:	8082                	ret

ffffffffc02001c2 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02001c2:	3c80006f          	j	ffffffffc020058a <cons_putc>

ffffffffc02001c6 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc02001c6:	1101                	addi	sp,sp,-32
ffffffffc02001c8:	e822                	sd	s0,16(sp)
ffffffffc02001ca:	ec06                	sd	ra,24(sp)
ffffffffc02001cc:	e426                	sd	s1,8(sp)
ffffffffc02001ce:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc02001d0:	00054503          	lbu	a0,0(a0)
ffffffffc02001d4:	c51d                	beqz	a0,ffffffffc0200202 <cputs+0x3c>
ffffffffc02001d6:	0405                	addi	s0,s0,1
ffffffffc02001d8:	4485                	li	s1,1
ffffffffc02001da:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc02001dc:	3ae000ef          	jal	ra,ffffffffc020058a <cons_putc>
    (*cnt) ++;
ffffffffc02001e0:	008487bb          	addw	a5,s1,s0
    while ((c = *str ++) != '\0') {
ffffffffc02001e4:	0405                	addi	s0,s0,1
ffffffffc02001e6:	fff44503          	lbu	a0,-1(s0)
ffffffffc02001ea:	f96d                	bnez	a0,ffffffffc02001dc <cputs+0x16>
ffffffffc02001ec:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc02001f0:	4529                	li	a0,10
ffffffffc02001f2:	398000ef          	jal	ra,ffffffffc020058a <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc02001f6:	8522                	mv	a0,s0
ffffffffc02001f8:	60e2                	ld	ra,24(sp)
ffffffffc02001fa:	6442                	ld	s0,16(sp)
ffffffffc02001fc:	64a2                	ld	s1,8(sp)
ffffffffc02001fe:	6105                	addi	sp,sp,32
ffffffffc0200200:	8082                	ret
    while ((c = *str ++) != '\0') {
ffffffffc0200202:	4405                	li	s0,1
ffffffffc0200204:	b7f5                	j	ffffffffc02001f0 <cputs+0x2a>

ffffffffc0200206 <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc0200206:	1141                	addi	sp,sp,-16
ffffffffc0200208:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc020020a:	3b6000ef          	jal	ra,ffffffffc02005c0 <cons_getc>
ffffffffc020020e:	dd75                	beqz	a0,ffffffffc020020a <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200210:	60a2                	ld	ra,8(sp)
ffffffffc0200212:	0141                	addi	sp,sp,16
ffffffffc0200214:	8082                	ret

ffffffffc0200216 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc0200216:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc0200218:	00006517          	auipc	a0,0x6
ffffffffc020021c:	5d850513          	addi	a0,a0,1496 # ffffffffc02067f0 <etext+0x64>
void print_kerninfo(void) {
ffffffffc0200220:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200222:	f6dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc0200226:	00000597          	auipc	a1,0x0
ffffffffc020022a:	e1058593          	addi	a1,a1,-496 # ffffffffc0200036 <kern_init>
ffffffffc020022e:	00006517          	auipc	a0,0x6
ffffffffc0200232:	5e250513          	addi	a0,a0,1506 # ffffffffc0206810 <etext+0x84>
ffffffffc0200236:	f59ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc020023a:	00006597          	auipc	a1,0x6
ffffffffc020023e:	55258593          	addi	a1,a1,1362 # ffffffffc020678c <etext>
ffffffffc0200242:	00006517          	auipc	a0,0x6
ffffffffc0200246:	5ee50513          	addi	a0,a0,1518 # ffffffffc0206830 <etext+0xa4>
ffffffffc020024a:	f45ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc020024e:	000a1597          	auipc	a1,0xa1
ffffffffc0200252:	e0a58593          	addi	a1,a1,-502 # ffffffffc02a1058 <edata>
ffffffffc0200256:	00006517          	auipc	a0,0x6
ffffffffc020025a:	5fa50513          	addi	a0,a0,1530 # ffffffffc0206850 <etext+0xc4>
ffffffffc020025e:	f31ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc0200262:	000ac597          	auipc	a1,0xac
ffffffffc0200266:	37e58593          	addi	a1,a1,894 # ffffffffc02ac5e0 <end>
ffffffffc020026a:	00006517          	auipc	a0,0x6
ffffffffc020026e:	60650513          	addi	a0,a0,1542 # ffffffffc0206870 <etext+0xe4>
ffffffffc0200272:	f1dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc0200276:	000ac597          	auipc	a1,0xac
ffffffffc020027a:	76958593          	addi	a1,a1,1897 # ffffffffc02ac9df <end+0x3ff>
ffffffffc020027e:	00000797          	auipc	a5,0x0
ffffffffc0200282:	db878793          	addi	a5,a5,-584 # ffffffffc0200036 <kern_init>
ffffffffc0200286:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020028a:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc020028e:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200290:	3ff5f593          	andi	a1,a1,1023
ffffffffc0200294:	95be                	add	a1,a1,a5
ffffffffc0200296:	85a9                	srai	a1,a1,0xa
ffffffffc0200298:	00006517          	auipc	a0,0x6
ffffffffc020029c:	5f850513          	addi	a0,a0,1528 # ffffffffc0206890 <etext+0x104>
}
ffffffffc02002a0:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02002a2:	eedff06f          	j	ffffffffc020018e <cprintf>

ffffffffc02002a6 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc02002a6:	1141                	addi	sp,sp,-16
    panic("Not Implemented!");
ffffffffc02002a8:	00006617          	auipc	a2,0x6
ffffffffc02002ac:	51860613          	addi	a2,a2,1304 # ffffffffc02067c0 <etext+0x34>
ffffffffc02002b0:	04d00593          	li	a1,77
ffffffffc02002b4:	00006517          	auipc	a0,0x6
ffffffffc02002b8:	52450513          	addi	a0,a0,1316 # ffffffffc02067d8 <etext+0x4c>
void print_stackframe(void) {
ffffffffc02002bc:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc02002be:	1c6000ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc02002c2 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002c2:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02002c4:	00006617          	auipc	a2,0x6
ffffffffc02002c8:	6dc60613          	addi	a2,a2,1756 # ffffffffc02069a0 <commands+0xe0>
ffffffffc02002cc:	00006597          	auipc	a1,0x6
ffffffffc02002d0:	6f458593          	addi	a1,a1,1780 # ffffffffc02069c0 <commands+0x100>
ffffffffc02002d4:	00006517          	auipc	a0,0x6
ffffffffc02002d8:	6f450513          	addi	a0,a0,1780 # ffffffffc02069c8 <commands+0x108>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002dc:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02002de:	eb1ff0ef          	jal	ra,ffffffffc020018e <cprintf>
ffffffffc02002e2:	00006617          	auipc	a2,0x6
ffffffffc02002e6:	6f660613          	addi	a2,a2,1782 # ffffffffc02069d8 <commands+0x118>
ffffffffc02002ea:	00006597          	auipc	a1,0x6
ffffffffc02002ee:	71658593          	addi	a1,a1,1814 # ffffffffc0206a00 <commands+0x140>
ffffffffc02002f2:	00006517          	auipc	a0,0x6
ffffffffc02002f6:	6d650513          	addi	a0,a0,1750 # ffffffffc02069c8 <commands+0x108>
ffffffffc02002fa:	e95ff0ef          	jal	ra,ffffffffc020018e <cprintf>
ffffffffc02002fe:	00006617          	auipc	a2,0x6
ffffffffc0200302:	71260613          	addi	a2,a2,1810 # ffffffffc0206a10 <commands+0x150>
ffffffffc0200306:	00006597          	auipc	a1,0x6
ffffffffc020030a:	72a58593          	addi	a1,a1,1834 # ffffffffc0206a30 <commands+0x170>
ffffffffc020030e:	00006517          	auipc	a0,0x6
ffffffffc0200312:	6ba50513          	addi	a0,a0,1722 # ffffffffc02069c8 <commands+0x108>
ffffffffc0200316:	e79ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    }
    return 0;
}
ffffffffc020031a:	60a2                	ld	ra,8(sp)
ffffffffc020031c:	4501                	li	a0,0
ffffffffc020031e:	0141                	addi	sp,sp,16
ffffffffc0200320:	8082                	ret

ffffffffc0200322 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200322:	1141                	addi	sp,sp,-16
ffffffffc0200324:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc0200326:	ef1ff0ef          	jal	ra,ffffffffc0200216 <print_kerninfo>
    return 0;
}
ffffffffc020032a:	60a2                	ld	ra,8(sp)
ffffffffc020032c:	4501                	li	a0,0
ffffffffc020032e:	0141                	addi	sp,sp,16
ffffffffc0200330:	8082                	ret

ffffffffc0200332 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200332:	1141                	addi	sp,sp,-16
ffffffffc0200334:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc0200336:	f71ff0ef          	jal	ra,ffffffffc02002a6 <print_stackframe>
    return 0;
}
ffffffffc020033a:	60a2                	ld	ra,8(sp)
ffffffffc020033c:	4501                	li	a0,0
ffffffffc020033e:	0141                	addi	sp,sp,16
ffffffffc0200340:	8082                	ret

ffffffffc0200342 <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc0200342:	7115                	addi	sp,sp,-224
ffffffffc0200344:	e962                	sd	s8,144(sp)
ffffffffc0200346:	8c2a                	mv	s8,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200348:	00006517          	auipc	a0,0x6
ffffffffc020034c:	5c050513          	addi	a0,a0,1472 # ffffffffc0206908 <commands+0x48>
kmonitor(struct trapframe *tf) {
ffffffffc0200350:	ed86                	sd	ra,216(sp)
ffffffffc0200352:	e9a2                	sd	s0,208(sp)
ffffffffc0200354:	e5a6                	sd	s1,200(sp)
ffffffffc0200356:	e1ca                	sd	s2,192(sp)
ffffffffc0200358:	fd4e                	sd	s3,184(sp)
ffffffffc020035a:	f952                	sd	s4,176(sp)
ffffffffc020035c:	f556                	sd	s5,168(sp)
ffffffffc020035e:	f15a                	sd	s6,160(sp)
ffffffffc0200360:	ed5e                	sd	s7,152(sp)
ffffffffc0200362:	e566                	sd	s9,136(sp)
ffffffffc0200364:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200366:	e29ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc020036a:	00006517          	auipc	a0,0x6
ffffffffc020036e:	5c650513          	addi	a0,a0,1478 # ffffffffc0206930 <commands+0x70>
ffffffffc0200372:	e1dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    if (tf != NULL) {
ffffffffc0200376:	000c0563          	beqz	s8,ffffffffc0200380 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc020037a:	8562                	mv	a0,s8
ffffffffc020037c:	4ce000ef          	jal	ra,ffffffffc020084a <print_trapframe>
ffffffffc0200380:	00006c97          	auipc	s9,0x6
ffffffffc0200384:	540c8c93          	addi	s9,s9,1344 # ffffffffc02068c0 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200388:	00006997          	auipc	s3,0x6
ffffffffc020038c:	5d098993          	addi	s3,s3,1488 # ffffffffc0206958 <commands+0x98>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200390:	00006917          	auipc	s2,0x6
ffffffffc0200394:	5d090913          	addi	s2,s2,1488 # ffffffffc0206960 <commands+0xa0>
        if (argc == MAXARGS - 1) {
ffffffffc0200398:	4a3d                	li	s4,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc020039a:	00006b17          	auipc	s6,0x6
ffffffffc020039e:	5ceb0b13          	addi	s6,s6,1486 # ffffffffc0206968 <commands+0xa8>
    if (argc == 0) {
ffffffffc02003a2:	00006a97          	auipc	s5,0x6
ffffffffc02003a6:	61ea8a93          	addi	s5,s5,1566 # ffffffffc02069c0 <commands+0x100>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003aa:	4b8d                	li	s7,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02003ac:	854e                	mv	a0,s3
ffffffffc02003ae:	ce9ff0ef          	jal	ra,ffffffffc0200096 <readline>
ffffffffc02003b2:	842a                	mv	s0,a0
ffffffffc02003b4:	dd65                	beqz	a0,ffffffffc02003ac <kmonitor+0x6a>
ffffffffc02003b6:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02003ba:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003bc:	c999                	beqz	a1,ffffffffc02003d2 <kmonitor+0x90>
ffffffffc02003be:	854a                	mv	a0,s2
ffffffffc02003c0:	384060ef          	jal	ra,ffffffffc0206744 <strchr>
ffffffffc02003c4:	c925                	beqz	a0,ffffffffc0200434 <kmonitor+0xf2>
            *buf ++ = '\0';
ffffffffc02003c6:	00144583          	lbu	a1,1(s0)
ffffffffc02003ca:	00040023          	sb	zero,0(s0)
ffffffffc02003ce:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003d0:	f5fd                	bnez	a1,ffffffffc02003be <kmonitor+0x7c>
    if (argc == 0) {
ffffffffc02003d2:	dce9                	beqz	s1,ffffffffc02003ac <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003d4:	6582                	ld	a1,0(sp)
ffffffffc02003d6:	00006d17          	auipc	s10,0x6
ffffffffc02003da:	4ead0d13          	addi	s10,s10,1258 # ffffffffc02068c0 <commands>
    if (argc == 0) {
ffffffffc02003de:	8556                	mv	a0,s5
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003e0:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003e2:	0d61                	addi	s10,s10,24
ffffffffc02003e4:	336060ef          	jal	ra,ffffffffc020671a <strcmp>
ffffffffc02003e8:	c919                	beqz	a0,ffffffffc02003fe <kmonitor+0xbc>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003ea:	2405                	addiw	s0,s0,1
ffffffffc02003ec:	09740463          	beq	s0,s7,ffffffffc0200474 <kmonitor+0x132>
ffffffffc02003f0:	000d3503          	ld	a0,0(s10)
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003f4:	6582                	ld	a1,0(sp)
ffffffffc02003f6:	0d61                	addi	s10,s10,24
ffffffffc02003f8:	322060ef          	jal	ra,ffffffffc020671a <strcmp>
ffffffffc02003fc:	f57d                	bnez	a0,ffffffffc02003ea <kmonitor+0xa8>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc02003fe:	00141793          	slli	a5,s0,0x1
ffffffffc0200402:	97a2                	add	a5,a5,s0
ffffffffc0200404:	078e                	slli	a5,a5,0x3
ffffffffc0200406:	97e6                	add	a5,a5,s9
ffffffffc0200408:	6b9c                	ld	a5,16(a5)
ffffffffc020040a:	8662                	mv	a2,s8
ffffffffc020040c:	002c                	addi	a1,sp,8
ffffffffc020040e:	fff4851b          	addiw	a0,s1,-1
ffffffffc0200412:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc0200414:	f8055ce3          	bgez	a0,ffffffffc02003ac <kmonitor+0x6a>
}
ffffffffc0200418:	60ee                	ld	ra,216(sp)
ffffffffc020041a:	644e                	ld	s0,208(sp)
ffffffffc020041c:	64ae                	ld	s1,200(sp)
ffffffffc020041e:	690e                	ld	s2,192(sp)
ffffffffc0200420:	79ea                	ld	s3,184(sp)
ffffffffc0200422:	7a4a                	ld	s4,176(sp)
ffffffffc0200424:	7aaa                	ld	s5,168(sp)
ffffffffc0200426:	7b0a                	ld	s6,160(sp)
ffffffffc0200428:	6bea                	ld	s7,152(sp)
ffffffffc020042a:	6c4a                	ld	s8,144(sp)
ffffffffc020042c:	6caa                	ld	s9,136(sp)
ffffffffc020042e:	6d0a                	ld	s10,128(sp)
ffffffffc0200430:	612d                	addi	sp,sp,224
ffffffffc0200432:	8082                	ret
        if (*buf == '\0') {
ffffffffc0200434:	00044783          	lbu	a5,0(s0)
ffffffffc0200438:	dfc9                	beqz	a5,ffffffffc02003d2 <kmonitor+0x90>
        if (argc == MAXARGS - 1) {
ffffffffc020043a:	03448863          	beq	s1,s4,ffffffffc020046a <kmonitor+0x128>
        argv[argc ++] = buf;
ffffffffc020043e:	00349793          	slli	a5,s1,0x3
ffffffffc0200442:	0118                	addi	a4,sp,128
ffffffffc0200444:	97ba                	add	a5,a5,a4
ffffffffc0200446:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020044a:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc020044e:	2485                	addiw	s1,s1,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200450:	e591                	bnez	a1,ffffffffc020045c <kmonitor+0x11a>
ffffffffc0200452:	b749                	j	ffffffffc02003d4 <kmonitor+0x92>
            buf ++;
ffffffffc0200454:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200456:	00044583          	lbu	a1,0(s0)
ffffffffc020045a:	ddad                	beqz	a1,ffffffffc02003d4 <kmonitor+0x92>
ffffffffc020045c:	854a                	mv	a0,s2
ffffffffc020045e:	2e6060ef          	jal	ra,ffffffffc0206744 <strchr>
ffffffffc0200462:	d96d                	beqz	a0,ffffffffc0200454 <kmonitor+0x112>
ffffffffc0200464:	00044583          	lbu	a1,0(s0)
ffffffffc0200468:	bf91                	j	ffffffffc02003bc <kmonitor+0x7a>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc020046a:	45c1                	li	a1,16
ffffffffc020046c:	855a                	mv	a0,s6
ffffffffc020046e:	d21ff0ef          	jal	ra,ffffffffc020018e <cprintf>
ffffffffc0200472:	b7f1                	j	ffffffffc020043e <kmonitor+0xfc>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc0200474:	6582                	ld	a1,0(sp)
ffffffffc0200476:	00006517          	auipc	a0,0x6
ffffffffc020047a:	51250513          	addi	a0,a0,1298 # ffffffffc0206988 <commands+0xc8>
ffffffffc020047e:	d11ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    return 0;
ffffffffc0200482:	b72d                	j	ffffffffc02003ac <kmonitor+0x6a>

ffffffffc0200484 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc0200484:	000ac317          	auipc	t1,0xac
ffffffffc0200488:	fd430313          	addi	t1,t1,-44 # ffffffffc02ac458 <is_panic>
ffffffffc020048c:	00033303          	ld	t1,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc0200490:	715d                	addi	sp,sp,-80
ffffffffc0200492:	ec06                	sd	ra,24(sp)
ffffffffc0200494:	e822                	sd	s0,16(sp)
ffffffffc0200496:	f436                	sd	a3,40(sp)
ffffffffc0200498:	f83a                	sd	a4,48(sp)
ffffffffc020049a:	fc3e                	sd	a5,56(sp)
ffffffffc020049c:	e0c2                	sd	a6,64(sp)
ffffffffc020049e:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc02004a0:	02031c63          	bnez	t1,ffffffffc02004d8 <__panic+0x54>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc02004a4:	4785                	li	a5,1
ffffffffc02004a6:	8432                	mv	s0,a2
ffffffffc02004a8:	000ac717          	auipc	a4,0xac
ffffffffc02004ac:	faf73823          	sd	a5,-80(a4) # ffffffffc02ac458 <is_panic>

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02004b0:	862e                	mv	a2,a1
    va_start(ap, fmt);
ffffffffc02004b2:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02004b4:	85aa                	mv	a1,a0
ffffffffc02004b6:	00006517          	auipc	a0,0x6
ffffffffc02004ba:	58a50513          	addi	a0,a0,1418 # ffffffffc0206a40 <commands+0x180>
    va_start(ap, fmt);
ffffffffc02004be:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02004c0:	ccfff0ef          	jal	ra,ffffffffc020018e <cprintf>
    vcprintf(fmt, ap);
ffffffffc02004c4:	65a2                	ld	a1,8(sp)
ffffffffc02004c6:	8522                	mv	a0,s0
ffffffffc02004c8:	ca7ff0ef          	jal	ra,ffffffffc020016e <vcprintf>
    cprintf("\n");
ffffffffc02004cc:	00007517          	auipc	a0,0x7
ffffffffc02004d0:	5e450513          	addi	a0,a0,1508 # ffffffffc0207ab0 <default_pmm_manager+0x458>
ffffffffc02004d4:	cbbff0ef          	jal	ra,ffffffffc020018e <cprintf>
#endif
}

static inline void sbi_shutdown(void)
{
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc02004d8:	4501                	li	a0,0
ffffffffc02004da:	4581                	li	a1,0
ffffffffc02004dc:	4601                	li	a2,0
ffffffffc02004de:	48a1                	li	a7,8
ffffffffc02004e0:	00000073          	ecall
    va_end(ap);

panic_dead:
    // No debug monitor here
    sbi_shutdown();
    intr_disable();
ffffffffc02004e4:	176000ef          	jal	ra,ffffffffc020065a <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc02004e8:	4501                	li	a0,0
ffffffffc02004ea:	e59ff0ef          	jal	ra,ffffffffc0200342 <kmonitor>
ffffffffc02004ee:	bfed                	j	ffffffffc02004e8 <__panic+0x64>

ffffffffc02004f0 <__warn>:
    }
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
ffffffffc02004f0:	715d                	addi	sp,sp,-80
ffffffffc02004f2:	e822                	sd	s0,16(sp)
ffffffffc02004f4:	fc3e                	sd	a5,56(sp)
ffffffffc02004f6:	8432                	mv	s0,a2
    va_list ap;
    va_start(ap, fmt);
ffffffffc02004f8:	103c                	addi	a5,sp,40
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc02004fa:	862e                	mv	a2,a1
ffffffffc02004fc:	85aa                	mv	a1,a0
ffffffffc02004fe:	00006517          	auipc	a0,0x6
ffffffffc0200502:	56250513          	addi	a0,a0,1378 # ffffffffc0206a60 <commands+0x1a0>
__warn(const char *file, int line, const char *fmt, ...) {
ffffffffc0200506:	ec06                	sd	ra,24(sp)
ffffffffc0200508:	f436                	sd	a3,40(sp)
ffffffffc020050a:	f83a                	sd	a4,48(sp)
ffffffffc020050c:	e0c2                	sd	a6,64(sp)
ffffffffc020050e:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0200510:	e43e                	sd	a5,8(sp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc0200512:	c7dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    vcprintf(fmt, ap);
ffffffffc0200516:	65a2                	ld	a1,8(sp)
ffffffffc0200518:	8522                	mv	a0,s0
ffffffffc020051a:	c55ff0ef          	jal	ra,ffffffffc020016e <vcprintf>
    cprintf("\n");
ffffffffc020051e:	00007517          	auipc	a0,0x7
ffffffffc0200522:	59250513          	addi	a0,a0,1426 # ffffffffc0207ab0 <default_pmm_manager+0x458>
ffffffffc0200526:	c69ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    va_end(ap);
}
ffffffffc020052a:	60e2                	ld	ra,24(sp)
ffffffffc020052c:	6442                	ld	s0,16(sp)
ffffffffc020052e:	6161                	addi	sp,sp,80
ffffffffc0200530:	8082                	ret

ffffffffc0200532 <clock_init>:
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    timebase = 1e7 / 100;
ffffffffc0200532:	67e1                	lui	a5,0x18
ffffffffc0200534:	6a078793          	addi	a5,a5,1696 # 186a0 <_binary_obj___user_exit_out_size+0xdc20>
ffffffffc0200538:	000ac717          	auipc	a4,0xac
ffffffffc020053c:	f2f73423          	sd	a5,-216(a4) # ffffffffc02ac460 <timebase>
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200540:	c0102573          	rdtime	a0
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc0200544:	4581                	li	a1,0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200546:	953e                	add	a0,a0,a5
ffffffffc0200548:	4601                	li	a2,0
ffffffffc020054a:	4881                	li	a7,0
ffffffffc020054c:	00000073          	ecall
    set_csr(sie, MIP_STIP);
ffffffffc0200550:	02000793          	li	a5,32
ffffffffc0200554:	1047a7f3          	csrrs	a5,sie,a5
    cprintf("++ setup timer interrupts\n");
ffffffffc0200558:	00006517          	auipc	a0,0x6
ffffffffc020055c:	52850513          	addi	a0,a0,1320 # ffffffffc0206a80 <commands+0x1c0>
    ticks = 0;
ffffffffc0200560:	000ac797          	auipc	a5,0xac
ffffffffc0200564:	f407b823          	sd	zero,-176(a5) # ffffffffc02ac4b0 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc0200568:	c27ff06f          	j	ffffffffc020018e <cprintf>

ffffffffc020056c <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc020056c:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200570:	000ac797          	auipc	a5,0xac
ffffffffc0200574:	ef078793          	addi	a5,a5,-272 # ffffffffc02ac460 <timebase>
ffffffffc0200578:	639c                	ld	a5,0(a5)
ffffffffc020057a:	4581                	li	a1,0
ffffffffc020057c:	4601                	li	a2,0
ffffffffc020057e:	953e                	add	a0,a0,a5
ffffffffc0200580:	4881                	li	a7,0
ffffffffc0200582:	00000073          	ecall
ffffffffc0200586:	8082                	ret

ffffffffc0200588 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc0200588:	8082                	ret

ffffffffc020058a <cons_putc>:
#include <sched.h>
#include <riscv.h>
#include <assert.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020058a:	100027f3          	csrr	a5,sstatus
ffffffffc020058e:	8b89                	andi	a5,a5,2
ffffffffc0200590:	0ff57513          	andi	a0,a0,255
ffffffffc0200594:	e799                	bnez	a5,ffffffffc02005a2 <cons_putc+0x18>
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc0200596:	4581                	li	a1,0
ffffffffc0200598:	4601                	li	a2,0
ffffffffc020059a:	4885                	li	a7,1
ffffffffc020059c:	00000073          	ecall
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
ffffffffc02005a0:	8082                	ret

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc02005a2:	1101                	addi	sp,sp,-32
ffffffffc02005a4:	ec06                	sd	ra,24(sp)
ffffffffc02005a6:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02005a8:	0b2000ef          	jal	ra,ffffffffc020065a <intr_disable>
ffffffffc02005ac:	6522                	ld	a0,8(sp)
ffffffffc02005ae:	4581                	li	a1,0
ffffffffc02005b0:	4601                	li	a2,0
ffffffffc02005b2:	4885                	li	a7,1
ffffffffc02005b4:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc02005b8:	60e2                	ld	ra,24(sp)
ffffffffc02005ba:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc02005bc:	0980006f          	j	ffffffffc0200654 <intr_enable>

ffffffffc02005c0 <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02005c0:	100027f3          	csrr	a5,sstatus
ffffffffc02005c4:	8b89                	andi	a5,a5,2
ffffffffc02005c6:	eb89                	bnez	a5,ffffffffc02005d8 <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc02005c8:	4501                	li	a0,0
ffffffffc02005ca:	4581                	li	a1,0
ffffffffc02005cc:	4601                	li	a2,0
ffffffffc02005ce:	4889                	li	a7,2
ffffffffc02005d0:	00000073          	ecall
ffffffffc02005d4:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc02005d6:	8082                	ret
int cons_getc(void) {
ffffffffc02005d8:	1101                	addi	sp,sp,-32
ffffffffc02005da:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc02005dc:	07e000ef          	jal	ra,ffffffffc020065a <intr_disable>
ffffffffc02005e0:	4501                	li	a0,0
ffffffffc02005e2:	4581                	li	a1,0
ffffffffc02005e4:	4601                	li	a2,0
ffffffffc02005e6:	4889                	li	a7,2
ffffffffc02005e8:	00000073          	ecall
ffffffffc02005ec:	2501                	sext.w	a0,a0
ffffffffc02005ee:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc02005f0:	064000ef          	jal	ra,ffffffffc0200654 <intr_enable>
}
ffffffffc02005f4:	60e2                	ld	ra,24(sp)
ffffffffc02005f6:	6522                	ld	a0,8(sp)
ffffffffc02005f8:	6105                	addi	sp,sp,32
ffffffffc02005fa:	8082                	ret

ffffffffc02005fc <ide_init>:
#include <stdio.h>
#include <string.h>
#include <trap.h>
#include <riscv.h>

void ide_init(void) {}
ffffffffc02005fc:	8082                	ret

ffffffffc02005fe <ide_device_valid>:

#define MAX_IDE 2
#define MAX_DISK_NSECS 56
static char ide[MAX_DISK_NSECS * SECTSIZE];

bool ide_device_valid(unsigned short ideno) { return ideno < MAX_IDE; }
ffffffffc02005fe:	00253513          	sltiu	a0,a0,2
ffffffffc0200602:	8082                	ret

ffffffffc0200604 <ide_device_size>:

size_t ide_device_size(unsigned short ideno) { return MAX_DISK_NSECS; }
ffffffffc0200604:	03800513          	li	a0,56
ffffffffc0200608:	8082                	ret

ffffffffc020060a <ide_read_secs>:

int ide_read_secs(unsigned short ideno, uint32_t secno, void *dst,
                  size_t nsecs) {
    int iobase = secno * SECTSIZE;
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc020060a:	000a1797          	auipc	a5,0xa1
ffffffffc020060e:	e4e78793          	addi	a5,a5,-434 # ffffffffc02a1458 <ide>
ffffffffc0200612:	0095959b          	slliw	a1,a1,0x9
                  size_t nsecs) {
ffffffffc0200616:	1141                	addi	sp,sp,-16
ffffffffc0200618:	8532                	mv	a0,a2
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc020061a:	95be                	add	a1,a1,a5
ffffffffc020061c:	00969613          	slli	a2,a3,0x9
                  size_t nsecs) {
ffffffffc0200620:	e406                	sd	ra,8(sp)
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc0200622:	152060ef          	jal	ra,ffffffffc0206774 <memcpy>
    return 0;
}
ffffffffc0200626:	60a2                	ld	ra,8(sp)
ffffffffc0200628:	4501                	li	a0,0
ffffffffc020062a:	0141                	addi	sp,sp,16
ffffffffc020062c:	8082                	ret

ffffffffc020062e <ide_write_secs>:

int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
ffffffffc020062e:	8732                	mv	a4,a2
    int iobase = secno * SECTSIZE;
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200630:	0095979b          	slliw	a5,a1,0x9
ffffffffc0200634:	000a1517          	auipc	a0,0xa1
ffffffffc0200638:	e2450513          	addi	a0,a0,-476 # ffffffffc02a1458 <ide>
                   size_t nsecs) {
ffffffffc020063c:	1141                	addi	sp,sp,-16
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc020063e:	00969613          	slli	a2,a3,0x9
ffffffffc0200642:	85ba                	mv	a1,a4
ffffffffc0200644:	953e                	add	a0,a0,a5
                   size_t nsecs) {
ffffffffc0200646:	e406                	sd	ra,8(sp)
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200648:	12c060ef          	jal	ra,ffffffffc0206774 <memcpy>
    return 0;
}
ffffffffc020064c:	60a2                	ld	ra,8(sp)
ffffffffc020064e:	4501                	li	a0,0
ffffffffc0200650:	0141                	addi	sp,sp,16
ffffffffc0200652:	8082                	ret

ffffffffc0200654 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200654:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc0200658:	8082                	ret

ffffffffc020065a <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc020065a:	100177f3          	csrrci	a5,sstatus,2
ffffffffc020065e:	8082                	ret

ffffffffc0200660 <pic_init>:
#include <picirq.h>

void pic_enable(unsigned int irq) {}

/* pic_init - initialize the 8259A interrupt controllers */
void pic_init(void) {}
ffffffffc0200660:	8082                	ret

ffffffffc0200662 <idt_init>:
void
idt_init(void) {
    extern void __alltraps(void);
    /* Set sscratch register to 0, indicating to exception vector that we are
     * presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc0200662:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc0200666:	00000797          	auipc	a5,0x0
ffffffffc020066a:	67a78793          	addi	a5,a5,1658 # ffffffffc0200ce0 <__alltraps>
ffffffffc020066e:	10579073          	csrw	stvec,a5
    /* Allow kernel to access user memory */
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc0200672:	000407b7          	lui	a5,0x40
ffffffffc0200676:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc020067a:	8082                	ret

ffffffffc020067c <print_regs>:
    cprintf("  tval 0x%08x\n", tf->tval);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs* gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020067c:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs* gpr) {
ffffffffc020067e:	1141                	addi	sp,sp,-16
ffffffffc0200680:	e022                	sd	s0,0(sp)
ffffffffc0200682:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200684:	00006517          	auipc	a0,0x6
ffffffffc0200688:	74450513          	addi	a0,a0,1860 # ffffffffc0206dc8 <commands+0x508>
void print_regs(struct pushregs* gpr) {
ffffffffc020068c:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020068e:	b01ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc0200692:	640c                	ld	a1,8(s0)
ffffffffc0200694:	00006517          	auipc	a0,0x6
ffffffffc0200698:	74c50513          	addi	a0,a0,1868 # ffffffffc0206de0 <commands+0x520>
ffffffffc020069c:	af3ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02006a0:	680c                	ld	a1,16(s0)
ffffffffc02006a2:	00006517          	auipc	a0,0x6
ffffffffc02006a6:	75650513          	addi	a0,a0,1878 # ffffffffc0206df8 <commands+0x538>
ffffffffc02006aa:	ae5ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02006ae:	6c0c                	ld	a1,24(s0)
ffffffffc02006b0:	00006517          	auipc	a0,0x6
ffffffffc02006b4:	76050513          	addi	a0,a0,1888 # ffffffffc0206e10 <commands+0x550>
ffffffffc02006b8:	ad7ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02006bc:	700c                	ld	a1,32(s0)
ffffffffc02006be:	00006517          	auipc	a0,0x6
ffffffffc02006c2:	76a50513          	addi	a0,a0,1898 # ffffffffc0206e28 <commands+0x568>
ffffffffc02006c6:	ac9ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02006ca:	740c                	ld	a1,40(s0)
ffffffffc02006cc:	00006517          	auipc	a0,0x6
ffffffffc02006d0:	77450513          	addi	a0,a0,1908 # ffffffffc0206e40 <commands+0x580>
ffffffffc02006d4:	abbff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02006d8:	780c                	ld	a1,48(s0)
ffffffffc02006da:	00006517          	auipc	a0,0x6
ffffffffc02006de:	77e50513          	addi	a0,a0,1918 # ffffffffc0206e58 <commands+0x598>
ffffffffc02006e2:	aadff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02006e6:	7c0c                	ld	a1,56(s0)
ffffffffc02006e8:	00006517          	auipc	a0,0x6
ffffffffc02006ec:	78850513          	addi	a0,a0,1928 # ffffffffc0206e70 <commands+0x5b0>
ffffffffc02006f0:	a9fff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02006f4:	602c                	ld	a1,64(s0)
ffffffffc02006f6:	00006517          	auipc	a0,0x6
ffffffffc02006fa:	79250513          	addi	a0,a0,1938 # ffffffffc0206e88 <commands+0x5c8>
ffffffffc02006fe:	a91ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc0200702:	642c                	ld	a1,72(s0)
ffffffffc0200704:	00006517          	auipc	a0,0x6
ffffffffc0200708:	79c50513          	addi	a0,a0,1948 # ffffffffc0206ea0 <commands+0x5e0>
ffffffffc020070c:	a83ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200710:	682c                	ld	a1,80(s0)
ffffffffc0200712:	00006517          	auipc	a0,0x6
ffffffffc0200716:	7a650513          	addi	a0,a0,1958 # ffffffffc0206eb8 <commands+0x5f8>
ffffffffc020071a:	a75ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc020071e:	6c2c                	ld	a1,88(s0)
ffffffffc0200720:	00006517          	auipc	a0,0x6
ffffffffc0200724:	7b050513          	addi	a0,a0,1968 # ffffffffc0206ed0 <commands+0x610>
ffffffffc0200728:	a67ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc020072c:	702c                	ld	a1,96(s0)
ffffffffc020072e:	00006517          	auipc	a0,0x6
ffffffffc0200732:	7ba50513          	addi	a0,a0,1978 # ffffffffc0206ee8 <commands+0x628>
ffffffffc0200736:	a59ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc020073a:	742c                	ld	a1,104(s0)
ffffffffc020073c:	00006517          	auipc	a0,0x6
ffffffffc0200740:	7c450513          	addi	a0,a0,1988 # ffffffffc0206f00 <commands+0x640>
ffffffffc0200744:	a4bff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200748:	782c                	ld	a1,112(s0)
ffffffffc020074a:	00006517          	auipc	a0,0x6
ffffffffc020074e:	7ce50513          	addi	a0,a0,1998 # ffffffffc0206f18 <commands+0x658>
ffffffffc0200752:	a3dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200756:	7c2c                	ld	a1,120(s0)
ffffffffc0200758:	00006517          	auipc	a0,0x6
ffffffffc020075c:	7d850513          	addi	a0,a0,2008 # ffffffffc0206f30 <commands+0x670>
ffffffffc0200760:	a2fff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200764:	604c                	ld	a1,128(s0)
ffffffffc0200766:	00006517          	auipc	a0,0x6
ffffffffc020076a:	7e250513          	addi	a0,a0,2018 # ffffffffc0206f48 <commands+0x688>
ffffffffc020076e:	a21ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200772:	644c                	ld	a1,136(s0)
ffffffffc0200774:	00006517          	auipc	a0,0x6
ffffffffc0200778:	7ec50513          	addi	a0,a0,2028 # ffffffffc0206f60 <commands+0x6a0>
ffffffffc020077c:	a13ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200780:	684c                	ld	a1,144(s0)
ffffffffc0200782:	00006517          	auipc	a0,0x6
ffffffffc0200786:	7f650513          	addi	a0,a0,2038 # ffffffffc0206f78 <commands+0x6b8>
ffffffffc020078a:	a05ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc020078e:	6c4c                	ld	a1,152(s0)
ffffffffc0200790:	00007517          	auipc	a0,0x7
ffffffffc0200794:	80050513          	addi	a0,a0,-2048 # ffffffffc0206f90 <commands+0x6d0>
ffffffffc0200798:	9f7ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc020079c:	704c                	ld	a1,160(s0)
ffffffffc020079e:	00007517          	auipc	a0,0x7
ffffffffc02007a2:	80a50513          	addi	a0,a0,-2038 # ffffffffc0206fa8 <commands+0x6e8>
ffffffffc02007a6:	9e9ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02007aa:	744c                	ld	a1,168(s0)
ffffffffc02007ac:	00007517          	auipc	a0,0x7
ffffffffc02007b0:	81450513          	addi	a0,a0,-2028 # ffffffffc0206fc0 <commands+0x700>
ffffffffc02007b4:	9dbff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02007b8:	784c                	ld	a1,176(s0)
ffffffffc02007ba:	00007517          	auipc	a0,0x7
ffffffffc02007be:	81e50513          	addi	a0,a0,-2018 # ffffffffc0206fd8 <commands+0x718>
ffffffffc02007c2:	9cdff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02007c6:	7c4c                	ld	a1,184(s0)
ffffffffc02007c8:	00007517          	auipc	a0,0x7
ffffffffc02007cc:	82850513          	addi	a0,a0,-2008 # ffffffffc0206ff0 <commands+0x730>
ffffffffc02007d0:	9bfff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02007d4:	606c                	ld	a1,192(s0)
ffffffffc02007d6:	00007517          	auipc	a0,0x7
ffffffffc02007da:	83250513          	addi	a0,a0,-1998 # ffffffffc0207008 <commands+0x748>
ffffffffc02007de:	9b1ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02007e2:	646c                	ld	a1,200(s0)
ffffffffc02007e4:	00007517          	auipc	a0,0x7
ffffffffc02007e8:	83c50513          	addi	a0,a0,-1988 # ffffffffc0207020 <commands+0x760>
ffffffffc02007ec:	9a3ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02007f0:	686c                	ld	a1,208(s0)
ffffffffc02007f2:	00007517          	auipc	a0,0x7
ffffffffc02007f6:	84650513          	addi	a0,a0,-1978 # ffffffffc0207038 <commands+0x778>
ffffffffc02007fa:	995ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02007fe:	6c6c                	ld	a1,216(s0)
ffffffffc0200800:	00007517          	auipc	a0,0x7
ffffffffc0200804:	85050513          	addi	a0,a0,-1968 # ffffffffc0207050 <commands+0x790>
ffffffffc0200808:	987ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc020080c:	706c                	ld	a1,224(s0)
ffffffffc020080e:	00007517          	auipc	a0,0x7
ffffffffc0200812:	85a50513          	addi	a0,a0,-1958 # ffffffffc0207068 <commands+0x7a8>
ffffffffc0200816:	979ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc020081a:	746c                	ld	a1,232(s0)
ffffffffc020081c:	00007517          	auipc	a0,0x7
ffffffffc0200820:	86450513          	addi	a0,a0,-1948 # ffffffffc0207080 <commands+0x7c0>
ffffffffc0200824:	96bff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200828:	786c                	ld	a1,240(s0)
ffffffffc020082a:	00007517          	auipc	a0,0x7
ffffffffc020082e:	86e50513          	addi	a0,a0,-1938 # ffffffffc0207098 <commands+0x7d8>
ffffffffc0200832:	95dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200836:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200838:	6402                	ld	s0,0(sp)
ffffffffc020083a:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020083c:	00007517          	auipc	a0,0x7
ffffffffc0200840:	87450513          	addi	a0,a0,-1932 # ffffffffc02070b0 <commands+0x7f0>
}
ffffffffc0200844:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200846:	949ff06f          	j	ffffffffc020018e <cprintf>

ffffffffc020084a <print_trapframe>:
print_trapframe(struct trapframe *tf) {
ffffffffc020084a:	1141                	addi	sp,sp,-16
ffffffffc020084c:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020084e:	85aa                	mv	a1,a0
print_trapframe(struct trapframe *tf) {
ffffffffc0200850:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200852:	00007517          	auipc	a0,0x7
ffffffffc0200856:	87650513          	addi	a0,a0,-1930 # ffffffffc02070c8 <commands+0x808>
print_trapframe(struct trapframe *tf) {
ffffffffc020085a:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020085c:	933ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200860:	8522                	mv	a0,s0
ffffffffc0200862:	e1bff0ef          	jal	ra,ffffffffc020067c <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc0200866:	10043583          	ld	a1,256(s0)
ffffffffc020086a:	00007517          	auipc	a0,0x7
ffffffffc020086e:	87650513          	addi	a0,a0,-1930 # ffffffffc02070e0 <commands+0x820>
ffffffffc0200872:	91dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200876:	10843583          	ld	a1,264(s0)
ffffffffc020087a:	00007517          	auipc	a0,0x7
ffffffffc020087e:	87e50513          	addi	a0,a0,-1922 # ffffffffc02070f8 <commands+0x838>
ffffffffc0200882:	90dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  tval 0x%08x\n", tf->tval);
ffffffffc0200886:	11043583          	ld	a1,272(s0)
ffffffffc020088a:	00007517          	auipc	a0,0x7
ffffffffc020088e:	88650513          	addi	a0,a0,-1914 # ffffffffc0207110 <commands+0x850>
ffffffffc0200892:	8fdff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200896:	11843583          	ld	a1,280(s0)
}
ffffffffc020089a:	6402                	ld	s0,0(sp)
ffffffffc020089c:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020089e:	00007517          	auipc	a0,0x7
ffffffffc02008a2:	88250513          	addi	a0,a0,-1918 # ffffffffc0207120 <commands+0x860>
}
ffffffffc02008a6:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02008a8:	8e7ff06f          	j	ffffffffc020018e <cprintf>

ffffffffc02008ac <pgfault_handler>:
            trap_in_kernel(tf) ? 'K' : 'U',
            tf->cause == CAUSE_STORE_PAGE_FAULT ? 'W' : 'R');
}

static int
pgfault_handler(struct trapframe *tf) {
ffffffffc02008ac:	1101                	addi	sp,sp,-32
ffffffffc02008ae:	e426                	sd	s1,8(sp)
    extern struct mm_struct *check_mm_struct;
    if(check_mm_struct !=NULL) { //used for test check_swap
ffffffffc02008b0:	000ac497          	auipc	s1,0xac
ffffffffc02008b4:	d1848493          	addi	s1,s1,-744 # ffffffffc02ac5c8 <check_mm_struct>
ffffffffc02008b8:	609c                	ld	a5,0(s1)
pgfault_handler(struct trapframe *tf) {
ffffffffc02008ba:	e822                	sd	s0,16(sp)
ffffffffc02008bc:	ec06                	sd	ra,24(sp)
ffffffffc02008be:	842a                	mv	s0,a0
    if(check_mm_struct !=NULL) { //used for test check_swap
ffffffffc02008c0:	cbbd                	beqz	a5,ffffffffc0200936 <pgfault_handler+0x8a>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02008c2:	10053783          	ld	a5,256(a0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02008c6:	11053583          	ld	a1,272(a0)
ffffffffc02008ca:	04b00613          	li	a2,75
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02008ce:	1007f793          	andi	a5,a5,256
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02008d2:	cba1                	beqz	a5,ffffffffc0200922 <pgfault_handler+0x76>
ffffffffc02008d4:	11843703          	ld	a4,280(s0)
ffffffffc02008d8:	47bd                	li	a5,15
ffffffffc02008da:	05700693          	li	a3,87
ffffffffc02008de:	00f70463          	beq	a4,a5,ffffffffc02008e6 <pgfault_handler+0x3a>
ffffffffc02008e2:	05200693          	li	a3,82
ffffffffc02008e6:	00006517          	auipc	a0,0x6
ffffffffc02008ea:	46250513          	addi	a0,a0,1122 # ffffffffc0206d48 <commands+0x488>
ffffffffc02008ee:	8a1ff0ef          	jal	ra,ffffffffc020018e <cprintf>
            print_pgfault(tf);
        }
    struct mm_struct *mm;
    if (check_mm_struct != NULL) {
ffffffffc02008f2:	6088                	ld	a0,0(s1)
ffffffffc02008f4:	c129                	beqz	a0,ffffffffc0200936 <pgfault_handler+0x8a>
        assert(current == idleproc);
ffffffffc02008f6:	000ac797          	auipc	a5,0xac
ffffffffc02008fa:	b9a78793          	addi	a5,a5,-1126 # ffffffffc02ac490 <current>
ffffffffc02008fe:	6398                	ld	a4,0(a5)
ffffffffc0200900:	000ac797          	auipc	a5,0xac
ffffffffc0200904:	b9878793          	addi	a5,a5,-1128 # ffffffffc02ac498 <idleproc>
ffffffffc0200908:	639c                	ld	a5,0(a5)
ffffffffc020090a:	04f71763          	bne	a4,a5,ffffffffc0200958 <pgfault_handler+0xac>
            print_pgfault(tf);
            panic("unhandled page fault.\n");
        }
        mm = current->mm;
    }
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc020090e:	11043603          	ld	a2,272(s0)
ffffffffc0200912:	11843583          	ld	a1,280(s0)
}
ffffffffc0200916:	6442                	ld	s0,16(sp)
ffffffffc0200918:	60e2                	ld	ra,24(sp)
ffffffffc020091a:	64a2                	ld	s1,8(sp)
ffffffffc020091c:	6105                	addi	sp,sp,32
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc020091e:	30c0406f          	j	ffffffffc0204c2a <do_pgfault>
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc0200922:	11843703          	ld	a4,280(s0)
ffffffffc0200926:	47bd                	li	a5,15
ffffffffc0200928:	05500613          	li	a2,85
ffffffffc020092c:	05700693          	li	a3,87
ffffffffc0200930:	faf719e3          	bne	a4,a5,ffffffffc02008e2 <pgfault_handler+0x36>
ffffffffc0200934:	bf4d                	j	ffffffffc02008e6 <pgfault_handler+0x3a>
        if (current == NULL) {
ffffffffc0200936:	000ac797          	auipc	a5,0xac
ffffffffc020093a:	b5a78793          	addi	a5,a5,-1190 # ffffffffc02ac490 <current>
ffffffffc020093e:	639c                	ld	a5,0(a5)
ffffffffc0200940:	cf85                	beqz	a5,ffffffffc0200978 <pgfault_handler+0xcc>
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc0200942:	11043603          	ld	a2,272(s0)
ffffffffc0200946:	11843583          	ld	a1,280(s0)
}
ffffffffc020094a:	6442                	ld	s0,16(sp)
ffffffffc020094c:	60e2                	ld	ra,24(sp)
ffffffffc020094e:	64a2                	ld	s1,8(sp)
        mm = current->mm;
ffffffffc0200950:	7788                	ld	a0,40(a5)
}
ffffffffc0200952:	6105                	addi	sp,sp,32
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc0200954:	2d60406f          	j	ffffffffc0204c2a <do_pgfault>
        assert(current == idleproc);
ffffffffc0200958:	00006697          	auipc	a3,0x6
ffffffffc020095c:	41068693          	addi	a3,a3,1040 # ffffffffc0206d68 <commands+0x4a8>
ffffffffc0200960:	00006617          	auipc	a2,0x6
ffffffffc0200964:	42060613          	addi	a2,a2,1056 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0200968:	06b00593          	li	a1,107
ffffffffc020096c:	00006517          	auipc	a0,0x6
ffffffffc0200970:	42c50513          	addi	a0,a0,1068 # ffffffffc0206d98 <commands+0x4d8>
ffffffffc0200974:	b11ff0ef          	jal	ra,ffffffffc0200484 <__panic>
            print_trapframe(tf);
ffffffffc0200978:	8522                	mv	a0,s0
ffffffffc020097a:	ed1ff0ef          	jal	ra,ffffffffc020084a <print_trapframe>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc020097e:	10043783          	ld	a5,256(s0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc0200982:	11043583          	ld	a1,272(s0)
ffffffffc0200986:	04b00613          	li	a2,75
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc020098a:	1007f793          	andi	a5,a5,256
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc020098e:	e399                	bnez	a5,ffffffffc0200994 <pgfault_handler+0xe8>
ffffffffc0200990:	05500613          	li	a2,85
ffffffffc0200994:	11843703          	ld	a4,280(s0)
ffffffffc0200998:	47bd                	li	a5,15
ffffffffc020099a:	02f70663          	beq	a4,a5,ffffffffc02009c6 <pgfault_handler+0x11a>
ffffffffc020099e:	05200693          	li	a3,82
ffffffffc02009a2:	00006517          	auipc	a0,0x6
ffffffffc02009a6:	3a650513          	addi	a0,a0,934 # ffffffffc0206d48 <commands+0x488>
ffffffffc02009aa:	fe4ff0ef          	jal	ra,ffffffffc020018e <cprintf>
            panic("unhandled page fault.\n");
ffffffffc02009ae:	00006617          	auipc	a2,0x6
ffffffffc02009b2:	40260613          	addi	a2,a2,1026 # ffffffffc0206db0 <commands+0x4f0>
ffffffffc02009b6:	07200593          	li	a1,114
ffffffffc02009ba:	00006517          	auipc	a0,0x6
ffffffffc02009be:	3de50513          	addi	a0,a0,990 # ffffffffc0206d98 <commands+0x4d8>
ffffffffc02009c2:	ac3ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02009c6:	05700693          	li	a3,87
ffffffffc02009ca:	bfe1                	j	ffffffffc02009a2 <pgfault_handler+0xf6>

ffffffffc02009cc <interrupt_handler>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02009cc:	11853783          	ld	a5,280(a0)
ffffffffc02009d0:	577d                	li	a4,-1
ffffffffc02009d2:	8305                	srli	a4,a4,0x1
ffffffffc02009d4:	8ff9                	and	a5,a5,a4
    switch (cause) {
ffffffffc02009d6:	472d                	li	a4,11
ffffffffc02009d8:	08f76763          	bltu	a4,a5,ffffffffc0200a66 <interrupt_handler+0x9a>
ffffffffc02009dc:	00006717          	auipc	a4,0x6
ffffffffc02009e0:	0c070713          	addi	a4,a4,192 # ffffffffc0206a9c <commands+0x1dc>
ffffffffc02009e4:	078a                	slli	a5,a5,0x2
ffffffffc02009e6:	97ba                	add	a5,a5,a4
ffffffffc02009e8:	439c                	lw	a5,0(a5)
ffffffffc02009ea:	97ba                	add	a5,a5,a4
ffffffffc02009ec:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02009ee:	00006517          	auipc	a0,0x6
ffffffffc02009f2:	31a50513          	addi	a0,a0,794 # ffffffffc0206d08 <commands+0x448>
ffffffffc02009f6:	f98ff06f          	j	ffffffffc020018e <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02009fa:	00006517          	auipc	a0,0x6
ffffffffc02009fe:	2ee50513          	addi	a0,a0,750 # ffffffffc0206ce8 <commands+0x428>
ffffffffc0200a02:	f8cff06f          	j	ffffffffc020018e <cprintf>
            cprintf("User software interrupt\n");
ffffffffc0200a06:	00006517          	auipc	a0,0x6
ffffffffc0200a0a:	2a250513          	addi	a0,a0,674 # ffffffffc0206ca8 <commands+0x3e8>
ffffffffc0200a0e:	f80ff06f          	j	ffffffffc020018e <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc0200a12:	00006517          	auipc	a0,0x6
ffffffffc0200a16:	2b650513          	addi	a0,a0,694 # ffffffffc0206cc8 <commands+0x408>
ffffffffc0200a1a:	f74ff06f          	j	ffffffffc020018e <cprintf>
            break;
        case IRQ_U_EXT:
            cprintf("User software interrupt\n");
            break;
        case IRQ_S_EXT:
            cprintf("Supervisor external interrupt\n");
ffffffffc0200a1e:	00006517          	auipc	a0,0x6
ffffffffc0200a22:	30a50513          	addi	a0,a0,778 # ffffffffc0206d28 <commands+0x468>
ffffffffc0200a26:	f68ff06f          	j	ffffffffc020018e <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc0200a2a:	1141                	addi	sp,sp,-16
ffffffffc0200a2c:	e406                	sd	ra,8(sp)
            clock_set_next_event();
ffffffffc0200a2e:	b3fff0ef          	jal	ra,ffffffffc020056c <clock_set_next_event>
            if (++ticks % TICK_NUM == 0 && current) {
ffffffffc0200a32:	000ac797          	auipc	a5,0xac
ffffffffc0200a36:	a7e78793          	addi	a5,a5,-1410 # ffffffffc02ac4b0 <ticks>
ffffffffc0200a3a:	639c                	ld	a5,0(a5)
ffffffffc0200a3c:	06400713          	li	a4,100
ffffffffc0200a40:	0785                	addi	a5,a5,1
ffffffffc0200a42:	02e7f733          	remu	a4,a5,a4
ffffffffc0200a46:	000ac697          	auipc	a3,0xac
ffffffffc0200a4a:	a6f6b523          	sd	a5,-1430(a3) # ffffffffc02ac4b0 <ticks>
ffffffffc0200a4e:	eb09                	bnez	a4,ffffffffc0200a60 <interrupt_handler+0x94>
ffffffffc0200a50:	000ac797          	auipc	a5,0xac
ffffffffc0200a54:	a4078793          	addi	a5,a5,-1472 # ffffffffc02ac490 <current>
ffffffffc0200a58:	639c                	ld	a5,0(a5)
ffffffffc0200a5a:	c399                	beqz	a5,ffffffffc0200a60 <interrupt_handler+0x94>
                current->need_resched = 1;
ffffffffc0200a5c:	4705                	li	a4,1
ffffffffc0200a5e:	ef98                	sd	a4,24(a5)
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200a60:	60a2                	ld	ra,8(sp)
ffffffffc0200a62:	0141                	addi	sp,sp,16
ffffffffc0200a64:	8082                	ret
            print_trapframe(tf);
ffffffffc0200a66:	de5ff06f          	j	ffffffffc020084a <print_trapframe>

ffffffffc0200a6a <exception_handler>:
void kernel_execve_ret(struct trapframe *tf,uintptr_t kstacktop);
void exception_handler(struct trapframe *tf) {
    int ret;
    switch (tf->cause) {
ffffffffc0200a6a:	11853783          	ld	a5,280(a0)
ffffffffc0200a6e:	473d                	li	a4,15
ffffffffc0200a70:	1af76e63          	bltu	a4,a5,ffffffffc0200c2c <exception_handler+0x1c2>
ffffffffc0200a74:	00006717          	auipc	a4,0x6
ffffffffc0200a78:	05870713          	addi	a4,a4,88 # ffffffffc0206acc <commands+0x20c>
ffffffffc0200a7c:	078a                	slli	a5,a5,0x2
ffffffffc0200a7e:	97ba                	add	a5,a5,a4
ffffffffc0200a80:	439c                	lw	a5,0(a5)
void exception_handler(struct trapframe *tf) {
ffffffffc0200a82:	1101                	addi	sp,sp,-32
ffffffffc0200a84:	e822                	sd	s0,16(sp)
ffffffffc0200a86:	ec06                	sd	ra,24(sp)
ffffffffc0200a88:	e426                	sd	s1,8(sp)
    switch (tf->cause) {
ffffffffc0200a8a:	97ba                	add	a5,a5,a4
ffffffffc0200a8c:	842a                	mv	s0,a0
ffffffffc0200a8e:	8782                	jr	a5
            //cprintf("Environment call from U-mode\n");
            tf->epc += 4;
            syscall();
            break;
        case CAUSE_SUPERVISOR_ECALL:
            cprintf("Environment call from S-mode\n");
ffffffffc0200a90:	00006517          	auipc	a0,0x6
ffffffffc0200a94:	17050513          	addi	a0,a0,368 # ffffffffc0206c00 <commands+0x340>
ffffffffc0200a98:	ef6ff0ef          	jal	ra,ffffffffc020018e <cprintf>
            tf->epc += 4;
ffffffffc0200a9c:	10843783          	ld	a5,264(s0)
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200aa0:	60e2                	ld	ra,24(sp)
ffffffffc0200aa2:	64a2                	ld	s1,8(sp)
            tf->epc += 4;
ffffffffc0200aa4:	0791                	addi	a5,a5,4
ffffffffc0200aa6:	10f43423          	sd	a5,264(s0)
}
ffffffffc0200aaa:	6442                	ld	s0,16(sp)
ffffffffc0200aac:	6105                	addi	sp,sp,32
            syscall();
ffffffffc0200aae:	7860506f          	j	ffffffffc0206234 <syscall>
            cprintf("Environment call from H-mode\n");
ffffffffc0200ab2:	00006517          	auipc	a0,0x6
ffffffffc0200ab6:	16e50513          	addi	a0,a0,366 # ffffffffc0206c20 <commands+0x360>
}
ffffffffc0200aba:	6442                	ld	s0,16(sp)
ffffffffc0200abc:	60e2                	ld	ra,24(sp)
ffffffffc0200abe:	64a2                	ld	s1,8(sp)
ffffffffc0200ac0:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc0200ac2:	eccff06f          	j	ffffffffc020018e <cprintf>
            cprintf("Environment call from M-mode\n");
ffffffffc0200ac6:	00006517          	auipc	a0,0x6
ffffffffc0200aca:	17a50513          	addi	a0,a0,378 # ffffffffc0206c40 <commands+0x380>
ffffffffc0200ace:	b7f5                	j	ffffffffc0200aba <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc0200ad0:	00006517          	auipc	a0,0x6
ffffffffc0200ad4:	19050513          	addi	a0,a0,400 # ffffffffc0206c60 <commands+0x3a0>
ffffffffc0200ad8:	b7cd                	j	ffffffffc0200aba <exception_handler+0x50>
            cprintf("Load page fault\n");
ffffffffc0200ada:	00006517          	auipc	a0,0x6
ffffffffc0200ade:	19e50513          	addi	a0,a0,414 # ffffffffc0206c78 <commands+0x3b8>
ffffffffc0200ae2:	eacff0ef          	jal	ra,ffffffffc020018e <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200ae6:	8522                	mv	a0,s0
ffffffffc0200ae8:	dc5ff0ef          	jal	ra,ffffffffc02008ac <pgfault_handler>
ffffffffc0200aec:	84aa                	mv	s1,a0
ffffffffc0200aee:	14051163          	bnez	a0,ffffffffc0200c30 <exception_handler+0x1c6>
}
ffffffffc0200af2:	60e2                	ld	ra,24(sp)
ffffffffc0200af4:	6442                	ld	s0,16(sp)
ffffffffc0200af6:	64a2                	ld	s1,8(sp)
ffffffffc0200af8:	6105                	addi	sp,sp,32
ffffffffc0200afa:	8082                	ret
            cprintf("Store/AMO page fault\n");
ffffffffc0200afc:	00006517          	auipc	a0,0x6
ffffffffc0200b00:	19450513          	addi	a0,a0,404 # ffffffffc0206c90 <commands+0x3d0>
ffffffffc0200b04:	e8aff0ef          	jal	ra,ffffffffc020018e <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200b08:	8522                	mv	a0,s0
ffffffffc0200b0a:	da3ff0ef          	jal	ra,ffffffffc02008ac <pgfault_handler>
ffffffffc0200b0e:	84aa                	mv	s1,a0
ffffffffc0200b10:	d16d                	beqz	a0,ffffffffc0200af2 <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200b12:	8522                	mv	a0,s0
ffffffffc0200b14:	d37ff0ef          	jal	ra,ffffffffc020084a <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200b18:	86a6                	mv	a3,s1
ffffffffc0200b1a:	00006617          	auipc	a2,0x6
ffffffffc0200b1e:	09660613          	addi	a2,a2,150 # ffffffffc0206bb0 <commands+0x2f0>
ffffffffc0200b22:	0f800593          	li	a1,248
ffffffffc0200b26:	00006517          	auipc	a0,0x6
ffffffffc0200b2a:	27250513          	addi	a0,a0,626 # ffffffffc0206d98 <commands+0x4d8>
ffffffffc0200b2e:	957ff0ef          	jal	ra,ffffffffc0200484 <__panic>
            cprintf("Instruction address misaligned\n");
ffffffffc0200b32:	00006517          	auipc	a0,0x6
ffffffffc0200b36:	fde50513          	addi	a0,a0,-34 # ffffffffc0206b10 <commands+0x250>
ffffffffc0200b3a:	b741                	j	ffffffffc0200aba <exception_handler+0x50>
            cprintf("Instruction access fault\n");
ffffffffc0200b3c:	00006517          	auipc	a0,0x6
ffffffffc0200b40:	ff450513          	addi	a0,a0,-12 # ffffffffc0206b30 <commands+0x270>
ffffffffc0200b44:	bf9d                	j	ffffffffc0200aba <exception_handler+0x50>
            cprintf("Illegal instruction\n");
ffffffffc0200b46:	00006517          	auipc	a0,0x6
ffffffffc0200b4a:	00a50513          	addi	a0,a0,10 # ffffffffc0206b50 <commands+0x290>
ffffffffc0200b4e:	b7b5                	j	ffffffffc0200aba <exception_handler+0x50>
            cprintf("Breakpoint\n");
ffffffffc0200b50:	00006517          	auipc	a0,0x6
ffffffffc0200b54:	01850513          	addi	a0,a0,24 # ffffffffc0206b68 <commands+0x2a8>
ffffffffc0200b58:	e36ff0ef          	jal	ra,ffffffffc020018e <cprintf>
            if(tf->gpr.a7 == 10){
ffffffffc0200b5c:	6458                	ld	a4,136(s0)
ffffffffc0200b5e:	47a9                	li	a5,10
ffffffffc0200b60:	f8f719e3          	bne	a4,a5,ffffffffc0200af2 <exception_handler+0x88>
                tf->epc += 4;
ffffffffc0200b64:	10843783          	ld	a5,264(s0)
ffffffffc0200b68:	0791                	addi	a5,a5,4
ffffffffc0200b6a:	10f43423          	sd	a5,264(s0)
                syscall();
ffffffffc0200b6e:	6c6050ef          	jal	ra,ffffffffc0206234 <syscall>
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b72:	000ac797          	auipc	a5,0xac
ffffffffc0200b76:	91e78793          	addi	a5,a5,-1762 # ffffffffc02ac490 <current>
ffffffffc0200b7a:	639c                	ld	a5,0(a5)
ffffffffc0200b7c:	8522                	mv	a0,s0
}
ffffffffc0200b7e:	6442                	ld	s0,16(sp)
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b80:	6b9c                	ld	a5,16(a5)
}
ffffffffc0200b82:	60e2                	ld	ra,24(sp)
ffffffffc0200b84:	64a2                	ld	s1,8(sp)
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b86:	6589                	lui	a1,0x2
ffffffffc0200b88:	95be                	add	a1,a1,a5
}
ffffffffc0200b8a:	6105                	addi	sp,sp,32
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b8c:	2220006f          	j	ffffffffc0200dae <kernel_execve_ret>
            cprintf("Load address misaligned\n");
ffffffffc0200b90:	00006517          	auipc	a0,0x6
ffffffffc0200b94:	fe850513          	addi	a0,a0,-24 # ffffffffc0206b78 <commands+0x2b8>
ffffffffc0200b98:	b70d                	j	ffffffffc0200aba <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc0200b9a:	00006517          	auipc	a0,0x6
ffffffffc0200b9e:	ffe50513          	addi	a0,a0,-2 # ffffffffc0206b98 <commands+0x2d8>
ffffffffc0200ba2:	decff0ef          	jal	ra,ffffffffc020018e <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200ba6:	8522                	mv	a0,s0
ffffffffc0200ba8:	d05ff0ef          	jal	ra,ffffffffc02008ac <pgfault_handler>
ffffffffc0200bac:	84aa                	mv	s1,a0
ffffffffc0200bae:	d131                	beqz	a0,ffffffffc0200af2 <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200bb0:	8522                	mv	a0,s0
ffffffffc0200bb2:	c99ff0ef          	jal	ra,ffffffffc020084a <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200bb6:	86a6                	mv	a3,s1
ffffffffc0200bb8:	00006617          	auipc	a2,0x6
ffffffffc0200bbc:	ff860613          	addi	a2,a2,-8 # ffffffffc0206bb0 <commands+0x2f0>
ffffffffc0200bc0:	0cd00593          	li	a1,205
ffffffffc0200bc4:	00006517          	auipc	a0,0x6
ffffffffc0200bc8:	1d450513          	addi	a0,a0,468 # ffffffffc0206d98 <commands+0x4d8>
ffffffffc0200bcc:	8b9ff0ef          	jal	ra,ffffffffc0200484 <__panic>
            cprintf("Store/AMO access fault\n");
ffffffffc0200bd0:	00006517          	auipc	a0,0x6
ffffffffc0200bd4:	01850513          	addi	a0,a0,24 # ffffffffc0206be8 <commands+0x328>
ffffffffc0200bd8:	db6ff0ef          	jal	ra,ffffffffc020018e <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200bdc:	8522                	mv	a0,s0
ffffffffc0200bde:	ccfff0ef          	jal	ra,ffffffffc02008ac <pgfault_handler>
ffffffffc0200be2:	84aa                	mv	s1,a0
ffffffffc0200be4:	f00507e3          	beqz	a0,ffffffffc0200af2 <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200be8:	8522                	mv	a0,s0
ffffffffc0200bea:	c61ff0ef          	jal	ra,ffffffffc020084a <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200bee:	86a6                	mv	a3,s1
ffffffffc0200bf0:	00006617          	auipc	a2,0x6
ffffffffc0200bf4:	fc060613          	addi	a2,a2,-64 # ffffffffc0206bb0 <commands+0x2f0>
ffffffffc0200bf8:	0d700593          	li	a1,215
ffffffffc0200bfc:	00006517          	auipc	a0,0x6
ffffffffc0200c00:	19c50513          	addi	a0,a0,412 # ffffffffc0206d98 <commands+0x4d8>
ffffffffc0200c04:	881ff0ef          	jal	ra,ffffffffc0200484 <__panic>
}
ffffffffc0200c08:	6442                	ld	s0,16(sp)
ffffffffc0200c0a:	60e2                	ld	ra,24(sp)
ffffffffc0200c0c:	64a2                	ld	s1,8(sp)
ffffffffc0200c0e:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc0200c10:	c3bff06f          	j	ffffffffc020084a <print_trapframe>
            panic("AMO address misaligned\n");
ffffffffc0200c14:	00006617          	auipc	a2,0x6
ffffffffc0200c18:	fbc60613          	addi	a2,a2,-68 # ffffffffc0206bd0 <commands+0x310>
ffffffffc0200c1c:	0d100593          	li	a1,209
ffffffffc0200c20:	00006517          	auipc	a0,0x6
ffffffffc0200c24:	17850513          	addi	a0,a0,376 # ffffffffc0206d98 <commands+0x4d8>
ffffffffc0200c28:	85dff0ef          	jal	ra,ffffffffc0200484 <__panic>
            print_trapframe(tf);
ffffffffc0200c2c:	c1fff06f          	j	ffffffffc020084a <print_trapframe>
                print_trapframe(tf);
ffffffffc0200c30:	8522                	mv	a0,s0
ffffffffc0200c32:	c19ff0ef          	jal	ra,ffffffffc020084a <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200c36:	86a6                	mv	a3,s1
ffffffffc0200c38:	00006617          	auipc	a2,0x6
ffffffffc0200c3c:	f7860613          	addi	a2,a2,-136 # ffffffffc0206bb0 <commands+0x2f0>
ffffffffc0200c40:	0f100593          	li	a1,241
ffffffffc0200c44:	00006517          	auipc	a0,0x6
ffffffffc0200c48:	15450513          	addi	a0,a0,340 # ffffffffc0206d98 <commands+0x4d8>
ffffffffc0200c4c:	839ff0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0200c50 <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
ffffffffc0200c50:	1101                	addi	sp,sp,-32
ffffffffc0200c52:	e822                	sd	s0,16(sp)
    // dispatch based on what type of trap occurred
//    cputs("some trap");
    if (current == NULL) {
ffffffffc0200c54:	000ac417          	auipc	s0,0xac
ffffffffc0200c58:	83c40413          	addi	s0,s0,-1988 # ffffffffc02ac490 <current>
ffffffffc0200c5c:	6018                	ld	a4,0(s0)
trap(struct trapframe *tf) {
ffffffffc0200c5e:	ec06                	sd	ra,24(sp)
ffffffffc0200c60:	e426                	sd	s1,8(sp)
ffffffffc0200c62:	e04a                	sd	s2,0(sp)
ffffffffc0200c64:	11853683          	ld	a3,280(a0)
    if (current == NULL) {
ffffffffc0200c68:	cf1d                	beqz	a4,ffffffffc0200ca6 <trap+0x56>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200c6a:	10053483          	ld	s1,256(a0)
        trap_dispatch(tf);
    } else {
        struct trapframe *otf = current->tf;
ffffffffc0200c6e:	0a073903          	ld	s2,160(a4)
        current->tf = tf;
ffffffffc0200c72:	f348                	sd	a0,160(a4)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200c74:	1004f493          	andi	s1,s1,256
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200c78:	0206c463          	bltz	a3,ffffffffc0200ca0 <trap+0x50>
        exception_handler(tf);
ffffffffc0200c7c:	defff0ef          	jal	ra,ffffffffc0200a6a <exception_handler>

        bool in_kernel = trap_in_kernel(tf);

        trap_dispatch(tf);

        current->tf = otf;
ffffffffc0200c80:	601c                	ld	a5,0(s0)
ffffffffc0200c82:	0b27b023          	sd	s2,160(a5)
        if (!in_kernel) {
ffffffffc0200c86:	e499                	bnez	s1,ffffffffc0200c94 <trap+0x44>
            if (current->flags & PF_EXITING) {
ffffffffc0200c88:	0b07a703          	lw	a4,176(a5)
ffffffffc0200c8c:	8b05                	andi	a4,a4,1
ffffffffc0200c8e:	e339                	bnez	a4,ffffffffc0200cd4 <trap+0x84>
                do_exit(-E_KILLED);
            }
            if (current->need_resched) {
ffffffffc0200c90:	6f9c                	ld	a5,24(a5)
ffffffffc0200c92:	eb95                	bnez	a5,ffffffffc0200cc6 <trap+0x76>
                schedule();
            }
        }
    }
}
ffffffffc0200c94:	60e2                	ld	ra,24(sp)
ffffffffc0200c96:	6442                	ld	s0,16(sp)
ffffffffc0200c98:	64a2                	ld	s1,8(sp)
ffffffffc0200c9a:	6902                	ld	s2,0(sp)
ffffffffc0200c9c:	6105                	addi	sp,sp,32
ffffffffc0200c9e:	8082                	ret
        interrupt_handler(tf);
ffffffffc0200ca0:	d2dff0ef          	jal	ra,ffffffffc02009cc <interrupt_handler>
ffffffffc0200ca4:	bff1                	j	ffffffffc0200c80 <trap+0x30>
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200ca6:	0006c963          	bltz	a3,ffffffffc0200cb8 <trap+0x68>
}
ffffffffc0200caa:	6442                	ld	s0,16(sp)
ffffffffc0200cac:	60e2                	ld	ra,24(sp)
ffffffffc0200cae:	64a2                	ld	s1,8(sp)
ffffffffc0200cb0:	6902                	ld	s2,0(sp)
ffffffffc0200cb2:	6105                	addi	sp,sp,32
        exception_handler(tf);
ffffffffc0200cb4:	db7ff06f          	j	ffffffffc0200a6a <exception_handler>
}
ffffffffc0200cb8:	6442                	ld	s0,16(sp)
ffffffffc0200cba:	60e2                	ld	ra,24(sp)
ffffffffc0200cbc:	64a2                	ld	s1,8(sp)
ffffffffc0200cbe:	6902                	ld	s2,0(sp)
ffffffffc0200cc0:	6105                	addi	sp,sp,32
        interrupt_handler(tf);
ffffffffc0200cc2:	d0bff06f          	j	ffffffffc02009cc <interrupt_handler>
}
ffffffffc0200cc6:	6442                	ld	s0,16(sp)
ffffffffc0200cc8:	60e2                	ld	ra,24(sp)
ffffffffc0200cca:	64a2                	ld	s1,8(sp)
ffffffffc0200ccc:	6902                	ld	s2,0(sp)
ffffffffc0200cce:	6105                	addi	sp,sp,32
                schedule();
ffffffffc0200cd0:	46e0506f          	j	ffffffffc020613e <schedule>
                do_exit(-E_KILLED);
ffffffffc0200cd4:	555d                	li	a0,-9
ffffffffc0200cd6:	065040ef          	jal	ra,ffffffffc020553a <do_exit>
ffffffffc0200cda:	601c                	ld	a5,0(s0)
ffffffffc0200cdc:	bf55                	j	ffffffffc0200c90 <trap+0x40>
	...

ffffffffc0200ce0 <__alltraps>:
    LOAD x2, 2*REGBYTES(sp)
    .endm

    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0200ce0:	14011173          	csrrw	sp,sscratch,sp
ffffffffc0200ce4:	00011463          	bnez	sp,ffffffffc0200cec <__alltraps+0xc>
ffffffffc0200ce8:	14002173          	csrr	sp,sscratch
ffffffffc0200cec:	712d                	addi	sp,sp,-288
ffffffffc0200cee:	e002                	sd	zero,0(sp)
ffffffffc0200cf0:	e406                	sd	ra,8(sp)
ffffffffc0200cf2:	ec0e                	sd	gp,24(sp)
ffffffffc0200cf4:	f012                	sd	tp,32(sp)
ffffffffc0200cf6:	f416                	sd	t0,40(sp)
ffffffffc0200cf8:	f81a                	sd	t1,48(sp)
ffffffffc0200cfa:	fc1e                	sd	t2,56(sp)
ffffffffc0200cfc:	e0a2                	sd	s0,64(sp)
ffffffffc0200cfe:	e4a6                	sd	s1,72(sp)
ffffffffc0200d00:	e8aa                	sd	a0,80(sp)
ffffffffc0200d02:	ecae                	sd	a1,88(sp)
ffffffffc0200d04:	f0b2                	sd	a2,96(sp)
ffffffffc0200d06:	f4b6                	sd	a3,104(sp)
ffffffffc0200d08:	f8ba                	sd	a4,112(sp)
ffffffffc0200d0a:	fcbe                	sd	a5,120(sp)
ffffffffc0200d0c:	e142                	sd	a6,128(sp)
ffffffffc0200d0e:	e546                	sd	a7,136(sp)
ffffffffc0200d10:	e94a                	sd	s2,144(sp)
ffffffffc0200d12:	ed4e                	sd	s3,152(sp)
ffffffffc0200d14:	f152                	sd	s4,160(sp)
ffffffffc0200d16:	f556                	sd	s5,168(sp)
ffffffffc0200d18:	f95a                	sd	s6,176(sp)
ffffffffc0200d1a:	fd5e                	sd	s7,184(sp)
ffffffffc0200d1c:	e1e2                	sd	s8,192(sp)
ffffffffc0200d1e:	e5e6                	sd	s9,200(sp)
ffffffffc0200d20:	e9ea                	sd	s10,208(sp)
ffffffffc0200d22:	edee                	sd	s11,216(sp)
ffffffffc0200d24:	f1f2                	sd	t3,224(sp)
ffffffffc0200d26:	f5f6                	sd	t4,232(sp)
ffffffffc0200d28:	f9fa                	sd	t5,240(sp)
ffffffffc0200d2a:	fdfe                	sd	t6,248(sp)
ffffffffc0200d2c:	14001473          	csrrw	s0,sscratch,zero
ffffffffc0200d30:	100024f3          	csrr	s1,sstatus
ffffffffc0200d34:	14102973          	csrr	s2,sepc
ffffffffc0200d38:	143029f3          	csrr	s3,stval
ffffffffc0200d3c:	14202a73          	csrr	s4,scause
ffffffffc0200d40:	e822                	sd	s0,16(sp)
ffffffffc0200d42:	e226                	sd	s1,256(sp)
ffffffffc0200d44:	e64a                	sd	s2,264(sp)
ffffffffc0200d46:	ea4e                	sd	s3,272(sp)
ffffffffc0200d48:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200d4a:	850a                	mv	a0,sp
    jal trap
ffffffffc0200d4c:	f05ff0ef          	jal	ra,ffffffffc0200c50 <trap>

ffffffffc0200d50 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200d50:	6492                	ld	s1,256(sp)
ffffffffc0200d52:	6932                	ld	s2,264(sp)
ffffffffc0200d54:	1004f413          	andi	s0,s1,256
ffffffffc0200d58:	e401                	bnez	s0,ffffffffc0200d60 <__trapret+0x10>
ffffffffc0200d5a:	1200                	addi	s0,sp,288
ffffffffc0200d5c:	14041073          	csrw	sscratch,s0
ffffffffc0200d60:	10049073          	csrw	sstatus,s1
ffffffffc0200d64:	14191073          	csrw	sepc,s2
ffffffffc0200d68:	60a2                	ld	ra,8(sp)
ffffffffc0200d6a:	61e2                	ld	gp,24(sp)
ffffffffc0200d6c:	7202                	ld	tp,32(sp)
ffffffffc0200d6e:	72a2                	ld	t0,40(sp)
ffffffffc0200d70:	7342                	ld	t1,48(sp)
ffffffffc0200d72:	73e2                	ld	t2,56(sp)
ffffffffc0200d74:	6406                	ld	s0,64(sp)
ffffffffc0200d76:	64a6                	ld	s1,72(sp)
ffffffffc0200d78:	6546                	ld	a0,80(sp)
ffffffffc0200d7a:	65e6                	ld	a1,88(sp)
ffffffffc0200d7c:	7606                	ld	a2,96(sp)
ffffffffc0200d7e:	76a6                	ld	a3,104(sp)
ffffffffc0200d80:	7746                	ld	a4,112(sp)
ffffffffc0200d82:	77e6                	ld	a5,120(sp)
ffffffffc0200d84:	680a                	ld	a6,128(sp)
ffffffffc0200d86:	68aa                	ld	a7,136(sp)
ffffffffc0200d88:	694a                	ld	s2,144(sp)
ffffffffc0200d8a:	69ea                	ld	s3,152(sp)
ffffffffc0200d8c:	7a0a                	ld	s4,160(sp)
ffffffffc0200d8e:	7aaa                	ld	s5,168(sp)
ffffffffc0200d90:	7b4a                	ld	s6,176(sp)
ffffffffc0200d92:	7bea                	ld	s7,184(sp)
ffffffffc0200d94:	6c0e                	ld	s8,192(sp)
ffffffffc0200d96:	6cae                	ld	s9,200(sp)
ffffffffc0200d98:	6d4e                	ld	s10,208(sp)
ffffffffc0200d9a:	6dee                	ld	s11,216(sp)
ffffffffc0200d9c:	7e0e                	ld	t3,224(sp)
ffffffffc0200d9e:	7eae                	ld	t4,232(sp)
ffffffffc0200da0:	7f4e                	ld	t5,240(sp)
ffffffffc0200da2:	7fee                	ld	t6,248(sp)
ffffffffc0200da4:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc0200da6:	10200073          	sret

ffffffffc0200daa <forkrets>:
 
    .globl forkrets
forkrets:
    # set stack to this new process's trapframe
    move sp, a0
ffffffffc0200daa:	812a                	mv	sp,a0
    j __trapret
ffffffffc0200dac:	b755                	j	ffffffffc0200d50 <__trapret>

ffffffffc0200dae <kernel_execve_ret>:

    .global kernel_execve_ret
kernel_execve_ret:
    // adjust sp to beneath kstacktop of current process
    addi a1, a1, -36*REGBYTES
ffffffffc0200dae:	ee058593          	addi	a1,a1,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x7690>

    // copy from previous trapframe to new trapframe
    LOAD s1, 35*REGBYTES(a0)
ffffffffc0200db2:	11853483          	ld	s1,280(a0)
    STORE s1, 35*REGBYTES(a1)
ffffffffc0200db6:	1095bc23          	sd	s1,280(a1)
    LOAD s1, 34*REGBYTES(a0)
ffffffffc0200dba:	11053483          	ld	s1,272(a0)
    STORE s1, 34*REGBYTES(a1)
ffffffffc0200dbe:	1095b823          	sd	s1,272(a1)
    LOAD s1, 33*REGBYTES(a0)
ffffffffc0200dc2:	10853483          	ld	s1,264(a0)
    STORE s1, 33*REGBYTES(a1)
ffffffffc0200dc6:	1095b423          	sd	s1,264(a1)
    LOAD s1, 32*REGBYTES(a0)
ffffffffc0200dca:	10053483          	ld	s1,256(a0)
    STORE s1, 32*REGBYTES(a1)
ffffffffc0200dce:	1095b023          	sd	s1,256(a1)
    LOAD s1, 31*REGBYTES(a0)
ffffffffc0200dd2:	7d64                	ld	s1,248(a0)
    STORE s1, 31*REGBYTES(a1)
ffffffffc0200dd4:	fde4                	sd	s1,248(a1)
    LOAD s1, 30*REGBYTES(a0)
ffffffffc0200dd6:	7964                	ld	s1,240(a0)
    STORE s1, 30*REGBYTES(a1)
ffffffffc0200dd8:	f9e4                	sd	s1,240(a1)
    LOAD s1, 29*REGBYTES(a0)
ffffffffc0200dda:	7564                	ld	s1,232(a0)
    STORE s1, 29*REGBYTES(a1)
ffffffffc0200ddc:	f5e4                	sd	s1,232(a1)
    LOAD s1, 28*REGBYTES(a0)
ffffffffc0200dde:	7164                	ld	s1,224(a0)
    STORE s1, 28*REGBYTES(a1)
ffffffffc0200de0:	f1e4                	sd	s1,224(a1)
    LOAD s1, 27*REGBYTES(a0)
ffffffffc0200de2:	6d64                	ld	s1,216(a0)
    STORE s1, 27*REGBYTES(a1)
ffffffffc0200de4:	ede4                	sd	s1,216(a1)
    LOAD s1, 26*REGBYTES(a0)
ffffffffc0200de6:	6964                	ld	s1,208(a0)
    STORE s1, 26*REGBYTES(a1)
ffffffffc0200de8:	e9e4                	sd	s1,208(a1)
    LOAD s1, 25*REGBYTES(a0)
ffffffffc0200dea:	6564                	ld	s1,200(a0)
    STORE s1, 25*REGBYTES(a1)
ffffffffc0200dec:	e5e4                	sd	s1,200(a1)
    LOAD s1, 24*REGBYTES(a0)
ffffffffc0200dee:	6164                	ld	s1,192(a0)
    STORE s1, 24*REGBYTES(a1)
ffffffffc0200df0:	e1e4                	sd	s1,192(a1)
    LOAD s1, 23*REGBYTES(a0)
ffffffffc0200df2:	7d44                	ld	s1,184(a0)
    STORE s1, 23*REGBYTES(a1)
ffffffffc0200df4:	fdc4                	sd	s1,184(a1)
    LOAD s1, 22*REGBYTES(a0)
ffffffffc0200df6:	7944                	ld	s1,176(a0)
    STORE s1, 22*REGBYTES(a1)
ffffffffc0200df8:	f9c4                	sd	s1,176(a1)
    LOAD s1, 21*REGBYTES(a0)
ffffffffc0200dfa:	7544                	ld	s1,168(a0)
    STORE s1, 21*REGBYTES(a1)
ffffffffc0200dfc:	f5c4                	sd	s1,168(a1)
    LOAD s1, 20*REGBYTES(a0)
ffffffffc0200dfe:	7144                	ld	s1,160(a0)
    STORE s1, 20*REGBYTES(a1)
ffffffffc0200e00:	f1c4                	sd	s1,160(a1)
    LOAD s1, 19*REGBYTES(a0)
ffffffffc0200e02:	6d44                	ld	s1,152(a0)
    STORE s1, 19*REGBYTES(a1)
ffffffffc0200e04:	edc4                	sd	s1,152(a1)
    LOAD s1, 18*REGBYTES(a0)
ffffffffc0200e06:	6944                	ld	s1,144(a0)
    STORE s1, 18*REGBYTES(a1)
ffffffffc0200e08:	e9c4                	sd	s1,144(a1)
    LOAD s1, 17*REGBYTES(a0)
ffffffffc0200e0a:	6544                	ld	s1,136(a0)
    STORE s1, 17*REGBYTES(a1)
ffffffffc0200e0c:	e5c4                	sd	s1,136(a1)
    LOAD s1, 16*REGBYTES(a0)
ffffffffc0200e0e:	6144                	ld	s1,128(a0)
    STORE s1, 16*REGBYTES(a1)
ffffffffc0200e10:	e1c4                	sd	s1,128(a1)
    LOAD s1, 15*REGBYTES(a0)
ffffffffc0200e12:	7d24                	ld	s1,120(a0)
    STORE s1, 15*REGBYTES(a1)
ffffffffc0200e14:	fda4                	sd	s1,120(a1)
    LOAD s1, 14*REGBYTES(a0)
ffffffffc0200e16:	7924                	ld	s1,112(a0)
    STORE s1, 14*REGBYTES(a1)
ffffffffc0200e18:	f9a4                	sd	s1,112(a1)
    LOAD s1, 13*REGBYTES(a0)
ffffffffc0200e1a:	7524                	ld	s1,104(a0)
    STORE s1, 13*REGBYTES(a1)
ffffffffc0200e1c:	f5a4                	sd	s1,104(a1)
    LOAD s1, 12*REGBYTES(a0)
ffffffffc0200e1e:	7124                	ld	s1,96(a0)
    STORE s1, 12*REGBYTES(a1)
ffffffffc0200e20:	f1a4                	sd	s1,96(a1)
    LOAD s1, 11*REGBYTES(a0)
ffffffffc0200e22:	6d24                	ld	s1,88(a0)
    STORE s1, 11*REGBYTES(a1)
ffffffffc0200e24:	eda4                	sd	s1,88(a1)
    LOAD s1, 10*REGBYTES(a0)
ffffffffc0200e26:	6924                	ld	s1,80(a0)
    STORE s1, 10*REGBYTES(a1)
ffffffffc0200e28:	e9a4                	sd	s1,80(a1)
    LOAD s1, 9*REGBYTES(a0)
ffffffffc0200e2a:	6524                	ld	s1,72(a0)
    STORE s1, 9*REGBYTES(a1)
ffffffffc0200e2c:	e5a4                	sd	s1,72(a1)
    LOAD s1, 8*REGBYTES(a0)
ffffffffc0200e2e:	6124                	ld	s1,64(a0)
    STORE s1, 8*REGBYTES(a1)
ffffffffc0200e30:	e1a4                	sd	s1,64(a1)
    LOAD s1, 7*REGBYTES(a0)
ffffffffc0200e32:	7d04                	ld	s1,56(a0)
    STORE s1, 7*REGBYTES(a1)
ffffffffc0200e34:	fd84                	sd	s1,56(a1)
    LOAD s1, 6*REGBYTES(a0)
ffffffffc0200e36:	7904                	ld	s1,48(a0)
    STORE s1, 6*REGBYTES(a1)
ffffffffc0200e38:	f984                	sd	s1,48(a1)
    LOAD s1, 5*REGBYTES(a0)
ffffffffc0200e3a:	7504                	ld	s1,40(a0)
    STORE s1, 5*REGBYTES(a1)
ffffffffc0200e3c:	f584                	sd	s1,40(a1)
    LOAD s1, 4*REGBYTES(a0)
ffffffffc0200e3e:	7104                	ld	s1,32(a0)
    STORE s1, 4*REGBYTES(a1)
ffffffffc0200e40:	f184                	sd	s1,32(a1)
    LOAD s1, 3*REGBYTES(a0)
ffffffffc0200e42:	6d04                	ld	s1,24(a0)
    STORE s1, 3*REGBYTES(a1)
ffffffffc0200e44:	ed84                	sd	s1,24(a1)
    LOAD s1, 2*REGBYTES(a0)
ffffffffc0200e46:	6904                	ld	s1,16(a0)
    STORE s1, 2*REGBYTES(a1)
ffffffffc0200e48:	e984                	sd	s1,16(a1)
    LOAD s1, 1*REGBYTES(a0)
ffffffffc0200e4a:	6504                	ld	s1,8(a0)
    STORE s1, 1*REGBYTES(a1)
ffffffffc0200e4c:	e584                	sd	s1,8(a1)
    LOAD s1, 0*REGBYTES(a0)
ffffffffc0200e4e:	6104                	ld	s1,0(a0)
    STORE s1, 0*REGBYTES(a1)
ffffffffc0200e50:	e184                	sd	s1,0(a1)

    // acutually adjust sp
    move sp, a1
ffffffffc0200e52:	812e                	mv	sp,a1
ffffffffc0200e54:	bdf5                	j	ffffffffc0200d50 <__trapret>

ffffffffc0200e56 <cow_copy_range>:
        }
    }
    return 0;
}

int cow_copy_range(pde_t *to, pde_t *from, uintptr_t start, uintptr_t end) {
ffffffffc0200e56:	711d                	addi	sp,sp,-96
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0200e58:	00d667b3          	or	a5,a2,a3
int cow_copy_range(pde_t *to, pde_t *from, uintptr_t start, uintptr_t end) {
ffffffffc0200e5c:	ec86                	sd	ra,88(sp)
ffffffffc0200e5e:	e8a2                	sd	s0,80(sp)
ffffffffc0200e60:	e4a6                	sd	s1,72(sp)
ffffffffc0200e62:	e0ca                	sd	s2,64(sp)
ffffffffc0200e64:	fc4e                	sd	s3,56(sp)
ffffffffc0200e66:	f852                	sd	s4,48(sp)
ffffffffc0200e68:	f456                	sd	s5,40(sp)
ffffffffc0200e6a:	f05a                	sd	s6,32(sp)
ffffffffc0200e6c:	ec5e                	sd	s7,24(sp)
ffffffffc0200e6e:	e862                	sd	s8,16(sp)
ffffffffc0200e70:	e466                	sd	s9,8(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0200e72:	03479713          	slli	a4,a5,0x34
ffffffffc0200e76:	12071663          	bnez	a4,ffffffffc0200fa2 <cow_copy_range+0x14c>
    assert(USER_ACCESS(start, end));
ffffffffc0200e7a:	002007b7          	lui	a5,0x200
ffffffffc0200e7e:	8432                	mv	s0,a2
ffffffffc0200e80:	10f66163          	bltu	a2,a5,ffffffffc0200f82 <cow_copy_range+0x12c>
ffffffffc0200e84:	84b6                	mv	s1,a3
ffffffffc0200e86:	0ed67e63          	bleu	a3,a2,ffffffffc0200f82 <cow_copy_range+0x12c>
ffffffffc0200e8a:	4785                	li	a5,1
ffffffffc0200e8c:	07fe                	slli	a5,a5,0x1f
ffffffffc0200e8e:	0ed7ea63          	bltu	a5,a3,ffffffffc0200f82 <cow_copy_range+0x12c>
ffffffffc0200e92:	8baa                	mv	s7,a0
ffffffffc0200e94:	892e                	mv	s2,a1
            assert(page != NULL);
            int ret = 0;
            ret = page_insert(to, page, start, perm);
            assert(ret == 0);
        }
        start += PGSIZE;
ffffffffc0200e96:	6985                	lui	s3,0x1
    return page2ppn(page) << PGSHIFT;
}

static inline struct Page *
pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc0200e98:	000abb17          	auipc	s6,0xab
ffffffffc0200e9c:	5e0b0b13          	addi	s6,s6,1504 # ffffffffc02ac478 <npage>
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc0200ea0:	000aba97          	auipc	s5,0xab
ffffffffc0200ea4:	648a8a93          	addi	s5,s5,1608 # ffffffffc02ac4e8 <pages>
ffffffffc0200ea8:	00008a17          	auipc	s4,0x8
ffffffffc0200eac:	fe8a0a13          	addi	s4,s4,-24 # ffffffffc0208e90 <nbase>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc0200eb0:	00200cb7          	lui	s9,0x200
ffffffffc0200eb4:	ffe00c37          	lui	s8,0xffe00
        pte_t *ptep = get_pte(from, start, 0);
ffffffffc0200eb8:	4601                	li	a2,0
ffffffffc0200eba:	85a2                	mv	a1,s0
ffffffffc0200ebc:	854a                	mv	a0,s2
ffffffffc0200ebe:	5f4010ef          	jal	ra,ffffffffc02024b2 <get_pte>
        if (ptep == NULL) {
ffffffffc0200ec2:	cd2d                	beqz	a0,ffffffffc0200f3c <cow_copy_range+0xe6>
        if (*ptep & PTE_V) {
ffffffffc0200ec4:	6114                	ld	a3,0(a0)
ffffffffc0200ec6:	0016f793          	andi	a5,a3,1
ffffffffc0200eca:	e395                	bnez	a5,ffffffffc0200eee <cow_copy_range+0x98>
        start += PGSIZE;
ffffffffc0200ecc:	944e                	add	s0,s0,s3
    } while (start != 0 && start < end);
ffffffffc0200ece:	fe9465e3          	bltu	s0,s1,ffffffffc0200eb8 <cow_copy_range+0x62>
    return 0;
}
ffffffffc0200ed2:	60e6                	ld	ra,88(sp)
ffffffffc0200ed4:	6446                	ld	s0,80(sp)
ffffffffc0200ed6:	64a6                	ld	s1,72(sp)
ffffffffc0200ed8:	6906                	ld	s2,64(sp)
ffffffffc0200eda:	79e2                	ld	s3,56(sp)
ffffffffc0200edc:	7a42                	ld	s4,48(sp)
ffffffffc0200ede:	7aa2                	ld	s5,40(sp)
ffffffffc0200ee0:	7b02                	ld	s6,32(sp)
ffffffffc0200ee2:	6be2                	ld	s7,24(sp)
ffffffffc0200ee4:	6c42                	ld	s8,16(sp)
ffffffffc0200ee6:	6ca2                	ld	s9,8(sp)
ffffffffc0200ee8:	4501                	li	a0,0
ffffffffc0200eea:	6125                	addi	sp,sp,96
ffffffffc0200eec:	8082                	ret
            *ptep &= ~PTE_W;
ffffffffc0200eee:	ffb6f793          	andi	a5,a3,-5
ffffffffc0200ef2:	e11c                	sd	a5,0(a0)
    if (PPN(pa) >= npage) {
ffffffffc0200ef4:	000b3703          	ld	a4,0(s6)
static inline struct Page *
pte2page(pte_t pte) {
    if (!(pte & PTE_V)) {
        panic("pte2page called with invalid pte");
    }
    return pa2page(PTE_ADDR(pte));
ffffffffc0200ef8:	078a                	slli	a5,a5,0x2
ffffffffc0200efa:	83b1                	srli	a5,a5,0xc
            uint32_t perm = (*ptep & PTE_USER & ~PTE_W);
ffffffffc0200efc:	8aed                	andi	a3,a3,27
    if (PPN(pa) >= npage) {
ffffffffc0200efe:	06e7f663          	bleu	a4,a5,ffffffffc0200f6a <cow_copy_range+0x114>
    return &pages[PPN(pa) - nbase];
ffffffffc0200f02:	000a3703          	ld	a4,0(s4)
ffffffffc0200f06:	000ab583          	ld	a1,0(s5)
ffffffffc0200f0a:	8f99                	sub	a5,a5,a4
ffffffffc0200f0c:	079a                	slli	a5,a5,0x6
ffffffffc0200f0e:	95be                	add	a1,a1,a5
            assert(page != NULL);
ffffffffc0200f10:	cd8d                	beqz	a1,ffffffffc0200f4a <cow_copy_range+0xf4>
            ret = page_insert(to, page, start, perm);
ffffffffc0200f12:	8622                	mv	a2,s0
ffffffffc0200f14:	855e                	mv	a0,s7
ffffffffc0200f16:	3b3010ef          	jal	ra,ffffffffc0202ac8 <page_insert>
            assert(ret == 0);
ffffffffc0200f1a:	d94d                	beqz	a0,ffffffffc0200ecc <cow_copy_range+0x76>
ffffffffc0200f1c:	00006697          	auipc	a3,0x6
ffffffffc0200f20:	34c68693          	addi	a3,a3,844 # ffffffffc0207268 <commands+0x9a8>
ffffffffc0200f24:	00006617          	auipc	a2,0x6
ffffffffc0200f28:	e5c60613          	addi	a2,a2,-420 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0200f2c:	06b00593          	li	a1,107
ffffffffc0200f30:	00006517          	auipc	a0,0x6
ffffffffc0200f34:	2d050513          	addi	a0,a0,720 # ffffffffc0207200 <commands+0x940>
ffffffffc0200f38:	d4cff0ef          	jal	ra,ffffffffc0200484 <__panic>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc0200f3c:	9466                	add	s0,s0,s9
ffffffffc0200f3e:	01847433          	and	s0,s0,s8
    } while (start != 0 && start < end);
ffffffffc0200f42:	d841                	beqz	s0,ffffffffc0200ed2 <cow_copy_range+0x7c>
ffffffffc0200f44:	f6946ae3          	bltu	s0,s1,ffffffffc0200eb8 <cow_copy_range+0x62>
ffffffffc0200f48:	b769                	j	ffffffffc0200ed2 <cow_copy_range+0x7c>
            assert(page != NULL);
ffffffffc0200f4a:	00006697          	auipc	a3,0x6
ffffffffc0200f4e:	30e68693          	addi	a3,a3,782 # ffffffffc0207258 <commands+0x998>
ffffffffc0200f52:	00006617          	auipc	a2,0x6
ffffffffc0200f56:	e2e60613          	addi	a2,a2,-466 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0200f5a:	06800593          	li	a1,104
ffffffffc0200f5e:	00006517          	auipc	a0,0x6
ffffffffc0200f62:	2a250513          	addi	a0,a0,674 # ffffffffc0207200 <commands+0x940>
ffffffffc0200f66:	d1eff0ef          	jal	ra,ffffffffc0200484 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0200f6a:	00006617          	auipc	a2,0x6
ffffffffc0200f6e:	2be60613          	addi	a2,a2,702 # ffffffffc0207228 <commands+0x968>
ffffffffc0200f72:	06300593          	li	a1,99
ffffffffc0200f76:	00006517          	auipc	a0,0x6
ffffffffc0200f7a:	2d250513          	addi	a0,a0,722 # ffffffffc0207248 <commands+0x988>
ffffffffc0200f7e:	d06ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc0200f82:	00006697          	auipc	a3,0x6
ffffffffc0200f86:	28e68693          	addi	a3,a3,654 # ffffffffc0207210 <commands+0x950>
ffffffffc0200f8a:	00006617          	auipc	a2,0x6
ffffffffc0200f8e:	df660613          	addi	a2,a2,-522 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0200f92:	05d00593          	li	a1,93
ffffffffc0200f96:	00006517          	auipc	a0,0x6
ffffffffc0200f9a:	26a50513          	addi	a0,a0,618 # ffffffffc0207200 <commands+0x940>
ffffffffc0200f9e:	ce6ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0200fa2:	00006697          	auipc	a3,0x6
ffffffffc0200fa6:	22e68693          	addi	a3,a3,558 # ffffffffc02071d0 <commands+0x910>
ffffffffc0200faa:	00006617          	auipc	a2,0x6
ffffffffc0200fae:	dd660613          	addi	a2,a2,-554 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0200fb2:	05c00593          	li	a1,92
ffffffffc0200fb6:	00006517          	auipc	a0,0x6
ffffffffc0200fba:	24a50513          	addi	a0,a0,586 # ffffffffc0207200 <commands+0x940>
ffffffffc0200fbe:	cc6ff0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0200fc2 <cow_copy_mmap>:
cow_copy_mmap(struct mm_struct *to, struct mm_struct *from) {
ffffffffc0200fc2:	1101                	addi	sp,sp,-32
ffffffffc0200fc4:	ec06                	sd	ra,24(sp)
ffffffffc0200fc6:	e822                	sd	s0,16(sp)
ffffffffc0200fc8:	e426                	sd	s1,8(sp)
ffffffffc0200fca:	e04a                	sd	s2,0(sp)
    assert(to != NULL && from != NULL);
ffffffffc0200fcc:	cd31                	beqz	a0,ffffffffc0201028 <cow_copy_mmap+0x66>
ffffffffc0200fce:	892a                	mv	s2,a0
ffffffffc0200fd0:	84ae                	mv	s1,a1
    list_entry_t *list = &(from->mmap_list), *le = list;
ffffffffc0200fd2:	842e                	mv	s0,a1
    assert(to != NULL && from != NULL);
ffffffffc0200fd4:	e98d                	bnez	a1,ffffffffc0201006 <cow_copy_mmap+0x44>
ffffffffc0200fd6:	a889                	j	ffffffffc0201028 <cow_copy_mmap+0x66>
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
ffffffffc0200fd8:	ff842603          	lw	a2,-8(s0)
ffffffffc0200fdc:	ff043583          	ld	a1,-16(s0)
ffffffffc0200fe0:	fe843503          	ld	a0,-24(s0)
ffffffffc0200fe4:	44c030ef          	jal	ra,ffffffffc0204430 <vma_create>
        if (nvma == NULL) {
ffffffffc0200fe8:	c90d                	beqz	a0,ffffffffc020101a <cow_copy_mmap+0x58>
        insert_vma_struct(to, nvma);
ffffffffc0200fea:	85aa                	mv	a1,a0
ffffffffc0200fec:	854a                	mv	a0,s2
ffffffffc0200fee:	4ae030ef          	jal	ra,ffffffffc020449c <insert_vma_struct>
        if (cow_copy_range(to->pgdir, from->pgdir, vma->vm_start, vma->vm_end) != 0) {
ffffffffc0200ff2:	ff043683          	ld	a3,-16(s0)
ffffffffc0200ff6:	fe843603          	ld	a2,-24(s0)
ffffffffc0200ffa:	6c8c                	ld	a1,24(s1)
ffffffffc0200ffc:	01893503          	ld	a0,24(s2)
ffffffffc0201000:	e57ff0ef          	jal	ra,ffffffffc0200e56 <cow_copy_range>
ffffffffc0201004:	e919                	bnez	a0,ffffffffc020101a <cow_copy_mmap+0x58>
 * list_prev - get the previous entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_prev(list_entry_t *listelm) {
    return listelm->prev;
ffffffffc0201006:	6000                	ld	s0,0(s0)
    while ((le = list_prev(le)) != list) {
ffffffffc0201008:	fc8498e3          	bne	s1,s0,ffffffffc0200fd8 <cow_copy_mmap+0x16>
}
ffffffffc020100c:	60e2                	ld	ra,24(sp)
ffffffffc020100e:	6442                	ld	s0,16(sp)
ffffffffc0201010:	64a2                	ld	s1,8(sp)
ffffffffc0201012:	6902                	ld	s2,0(sp)
    return 0;
ffffffffc0201014:	4501                	li	a0,0
}
ffffffffc0201016:	6105                	addi	sp,sp,32
ffffffffc0201018:	8082                	ret
ffffffffc020101a:	60e2                	ld	ra,24(sp)
ffffffffc020101c:	6442                	ld	s0,16(sp)
ffffffffc020101e:	64a2                	ld	s1,8(sp)
ffffffffc0201020:	6902                	ld	s2,0(sp)
            return -E_NO_MEM;
ffffffffc0201022:	5571                	li	a0,-4
}
ffffffffc0201024:	6105                	addi	sp,sp,32
ffffffffc0201026:	8082                	ret
    assert(to != NULL && from != NULL);
ffffffffc0201028:	00006697          	auipc	a3,0x6
ffffffffc020102c:	18868693          	addi	a3,a3,392 # ffffffffc02071b0 <commands+0x8f0>
ffffffffc0201030:	00006617          	auipc	a2,0x6
ffffffffc0201034:	d5060613          	addi	a2,a2,-688 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0201038:	04a00593          	li	a1,74
ffffffffc020103c:	00006517          	auipc	a0,0x6
ffffffffc0201040:	1c450513          	addi	a0,a0,452 # ffffffffc0207200 <commands+0x940>
ffffffffc0201044:	c40ff0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0201048 <cow_copy_mm>:
    struct mm_struct *mm, *oldmm = current->mm;
ffffffffc0201048:	000ab797          	auipc	a5,0xab
ffffffffc020104c:	44878793          	addi	a5,a5,1096 # ffffffffc02ac490 <current>
ffffffffc0201050:	639c                	ld	a5,0(a5)
cow_copy_mm(struct proc_struct *proc) {
ffffffffc0201052:	715d                	addi	sp,sp,-80
ffffffffc0201054:	f84a                	sd	s2,48(sp)
    struct mm_struct *mm, *oldmm = current->mm;
ffffffffc0201056:	0287b903          	ld	s2,40(a5)
cow_copy_mm(struct proc_struct *proc) {
ffffffffc020105a:	e486                	sd	ra,72(sp)
ffffffffc020105c:	e0a2                	sd	s0,64(sp)
ffffffffc020105e:	fc26                	sd	s1,56(sp)
ffffffffc0201060:	f44e                	sd	s3,40(sp)
ffffffffc0201062:	f052                	sd	s4,32(sp)
ffffffffc0201064:	ec56                	sd	s5,24(sp)
ffffffffc0201066:	e85a                	sd	s6,16(sp)
ffffffffc0201068:	e45e                	sd	s7,8(sp)
ffffffffc020106a:	e062                	sd	s8,0(sp)
    if (oldmm == NULL) {
ffffffffc020106c:	0c090963          	beqz	s2,ffffffffc020113e <cow_copy_mm+0xf6>
ffffffffc0201070:	8a2a                	mv	s4,a0
    if ((mm = mm_create()) == NULL) {
ffffffffc0201072:	372030ef          	jal	ra,ffffffffc02043e4 <mm_create>
ffffffffc0201076:	89aa                	mv	s3,a0
ffffffffc0201078:	c179                	beqz	a0,ffffffffc020113e <cow_copy_mm+0xf6>
    if ((page = alloc_page()) == NULL) {
ffffffffc020107a:	4505                	li	a0,1
ffffffffc020107c:	328010ef          	jal	ra,ffffffffc02023a4 <alloc_pages>
ffffffffc0201080:	10050c63          	beqz	a0,ffffffffc0201198 <cow_copy_mm+0x150>
    return page - pages + nbase;
ffffffffc0201084:	000aba97          	auipc	s5,0xab
ffffffffc0201088:	464a8a93          	addi	s5,s5,1124 # ffffffffc02ac4e8 <pages>
ffffffffc020108c:	000ab683          	ld	a3,0(s5)
ffffffffc0201090:	00008b17          	auipc	s6,0x8
ffffffffc0201094:	e00b0b13          	addi	s6,s6,-512 # ffffffffc0208e90 <nbase>
ffffffffc0201098:	000b3483          	ld	s1,0(s6)
ffffffffc020109c:	40d506b3          	sub	a3,a0,a3
    return KADDR(page2pa(page));
ffffffffc02010a0:	000abb97          	auipc	s7,0xab
ffffffffc02010a4:	3d8b8b93          	addi	s7,s7,984 # ffffffffc02ac478 <npage>
    return page - pages + nbase;
ffffffffc02010a8:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc02010aa:	57fd                	li	a5,-1
ffffffffc02010ac:	000bb703          	ld	a4,0(s7)
    return page - pages + nbase;
ffffffffc02010b0:	96a6                	add	a3,a3,s1
    return KADDR(page2pa(page));
ffffffffc02010b2:	83b1                	srli	a5,a5,0xc
ffffffffc02010b4:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc02010b6:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02010b8:	0ee7f263          	bleu	a4,a5,ffffffffc020119c <cow_copy_mm+0x154>
ffffffffc02010bc:	000abc17          	auipc	s8,0xab
ffffffffc02010c0:	41cc0c13          	addi	s8,s8,1052 # ffffffffc02ac4d8 <va_pa_offset>
ffffffffc02010c4:	000c3483          	ld	s1,0(s8)
    memcpy(pgdir, boot_pgdir, PGSIZE);
ffffffffc02010c8:	000ab797          	auipc	a5,0xab
ffffffffc02010cc:	3a878793          	addi	a5,a5,936 # ffffffffc02ac470 <boot_pgdir>
ffffffffc02010d0:	638c                	ld	a1,0(a5)
ffffffffc02010d2:	94b6                	add	s1,s1,a3
ffffffffc02010d4:	6605                	lui	a2,0x1
ffffffffc02010d6:	8526                	mv	a0,s1
ffffffffc02010d8:	69c050ef          	jal	ra,ffffffffc0206774 <memcpy>
}

static inline void
lock_mm(struct mm_struct *mm) {
    if (mm != NULL) {
        lock(&(mm->mm_lock));
ffffffffc02010dc:	03890413          	addi	s0,s2,56
    mm->pgdir = pgdir;
ffffffffc02010e0:	0099bc23          	sd	s1,24(s3) # 1018 <_binary_obj___user_faultread_out_size-0x8558>
 * test_and_set_bit - Atomically set a bit and return its old value
 * @nr:     the bit to set
 * @addr:   the address to count from
 * */
static inline bool test_and_set_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02010e4:	4785                	li	a5,1
ffffffffc02010e6:	40f437af          	amoor.d	a5,a5,(s0)
ffffffffc02010ea:	8b85                	andi	a5,a5,1
    return !test_and_set_bit(0, lock);
}

static inline void
lock(lock_t *lock) {
    while (!try_lock(lock)) {
ffffffffc02010ec:	cb81                	beqz	a5,ffffffffc02010fc <cow_copy_mm+0xb4>
ffffffffc02010ee:	4485                	li	s1,1
        schedule();
ffffffffc02010f0:	04e050ef          	jal	ra,ffffffffc020613e <schedule>
ffffffffc02010f4:	409437af          	amoor.d	a5,s1,(s0)
ffffffffc02010f8:	8b85                	andi	a5,a5,1
    while (!try_lock(lock)) {
ffffffffc02010fa:	fbfd                	bnez	a5,ffffffffc02010f0 <cow_copy_mm+0xa8>
        ret = cow_copy_mmap(mm, oldmm);
ffffffffc02010fc:	85ca                	mv	a1,s2
ffffffffc02010fe:	854e                	mv	a0,s3
ffffffffc0201100:	ec3ff0ef          	jal	ra,ffffffffc0200fc2 <cow_copy_mmap>
ffffffffc0201104:	842a                	mv	s0,a0
 * test_and_clear_bit - Atomically clear a bit and return its old value
 * @nr:     the bit to clear
 * @addr:   the address to count from
 * */
static inline bool test_and_clear_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0201106:	57f9                	li	a5,-2
ffffffffc0201108:	03890713          	addi	a4,s2,56
ffffffffc020110c:	60f737af          	amoand.d	a5,a5,(a4)
ffffffffc0201110:	8b85                	andi	a5,a5,1
    }
}

static inline void
unlock(lock_t *lock) {
    if (!test_and_clear_bit(0, lock)) {
ffffffffc0201112:	0e078563          	beqz	a5,ffffffffc02011fc <cow_copy_mm+0x1b4>
    if (ret != 0) {
ffffffffc0201116:	e131                	bnez	a0,ffffffffc020115a <cow_copy_mm+0x112>
    mm->mm_count += 1;
ffffffffc0201118:	0309a783          	lw	a5,48(s3)
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc020111c:	0189b683          	ld	a3,24(s3)
ffffffffc0201120:	c0200737          	lui	a4,0xc0200
ffffffffc0201124:	2785                	addiw	a5,a5,1
ffffffffc0201126:	02f9a823          	sw	a5,48(s3)
    proc->mm = mm;
ffffffffc020112a:	033a3423          	sd	s3,40(s4)
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc020112e:	08e6ef63          	bltu	a3,a4,ffffffffc02011cc <cow_copy_mm+0x184>
ffffffffc0201132:	000c3783          	ld	a5,0(s8)
ffffffffc0201136:	8e9d                	sub	a3,a3,a5
ffffffffc0201138:	0ada3423          	sd	a3,168(s4)
    return 0;
ffffffffc020113c:	a011                	j	ffffffffc0201140 <cow_copy_mm+0xf8>
        return 0;
ffffffffc020113e:	4401                	li	s0,0
}
ffffffffc0201140:	8522                	mv	a0,s0
ffffffffc0201142:	60a6                	ld	ra,72(sp)
ffffffffc0201144:	6406                	ld	s0,64(sp)
ffffffffc0201146:	74e2                	ld	s1,56(sp)
ffffffffc0201148:	7942                	ld	s2,48(sp)
ffffffffc020114a:	79a2                	ld	s3,40(sp)
ffffffffc020114c:	7a02                	ld	s4,32(sp)
ffffffffc020114e:	6ae2                	ld	s5,24(sp)
ffffffffc0201150:	6b42                	ld	s6,16(sp)
ffffffffc0201152:	6ba2                	ld	s7,8(sp)
ffffffffc0201154:	6c02                	ld	s8,0(sp)
ffffffffc0201156:	6161                	addi	sp,sp,80
ffffffffc0201158:	8082                	ret
    exit_mmap(mm);
ffffffffc020115a:	854e                	mv	a0,s3
ffffffffc020115c:	512030ef          	jal	ra,ffffffffc020466e <exit_mmap>
    return pa2page(PADDR(kva));
ffffffffc0201160:	0189b683          	ld	a3,24(s3)
ffffffffc0201164:	c02007b7          	lui	a5,0xc0200
ffffffffc0201168:	06f6ee63          	bltu	a3,a5,ffffffffc02011e4 <cow_copy_mm+0x19c>
ffffffffc020116c:	000c3703          	ld	a4,0(s8)
    if (PPN(pa) >= npage) {
ffffffffc0201170:	000bb783          	ld	a5,0(s7)
    return pa2page(PADDR(kva));
ffffffffc0201174:	8e99                	sub	a3,a3,a4
    if (PPN(pa) >= npage) {
ffffffffc0201176:	82b1                	srli	a3,a3,0xc
ffffffffc0201178:	02f6fe63          	bleu	a5,a3,ffffffffc02011b4 <cow_copy_mm+0x16c>
    return &pages[PPN(pa) - nbase];
ffffffffc020117c:	000b3783          	ld	a5,0(s6)
ffffffffc0201180:	000ab503          	ld	a0,0(s5)
    free_page(kva2page(mm->pgdir));
ffffffffc0201184:	4585                	li	a1,1
ffffffffc0201186:	8e9d                	sub	a3,a3,a5
ffffffffc0201188:	069a                	slli	a3,a3,0x6
ffffffffc020118a:	9536                	add	a0,a0,a3
ffffffffc020118c:	2a0010ef          	jal	ra,ffffffffc020242c <free_pages>
    mm_destroy(mm);
ffffffffc0201190:	854e                	mv	a0,s3
ffffffffc0201192:	3d8030ef          	jal	ra,ffffffffc020456a <mm_destroy>
ffffffffc0201196:	b76d                	j	ffffffffc0201140 <cow_copy_mm+0xf8>
    int ret = 0;
ffffffffc0201198:	4401                	li	s0,0
ffffffffc020119a:	bfdd                	j	ffffffffc0201190 <cow_copy_mm+0x148>
    return KADDR(page2pa(page));
ffffffffc020119c:	00006617          	auipc	a2,0x6
ffffffffc02011a0:	f9c60613          	addi	a2,a2,-100 # ffffffffc0207138 <commands+0x878>
ffffffffc02011a4:	06a00593          	li	a1,106
ffffffffc02011a8:	00006517          	auipc	a0,0x6
ffffffffc02011ac:	0a050513          	addi	a0,a0,160 # ffffffffc0207248 <commands+0x988>
ffffffffc02011b0:	ad4ff0ef          	jal	ra,ffffffffc0200484 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02011b4:	00006617          	auipc	a2,0x6
ffffffffc02011b8:	07460613          	addi	a2,a2,116 # ffffffffc0207228 <commands+0x968>
ffffffffc02011bc:	06300593          	li	a1,99
ffffffffc02011c0:	00006517          	auipc	a0,0x6
ffffffffc02011c4:	08850513          	addi	a0,a0,136 # ffffffffc0207248 <commands+0x988>
ffffffffc02011c8:	abcff0ef          	jal	ra,ffffffffc0200484 <__panic>
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc02011cc:	00006617          	auipc	a2,0x6
ffffffffc02011d0:	fbc60613          	addi	a2,a2,-68 # ffffffffc0207188 <commands+0x8c8>
ffffffffc02011d4:	03d00593          	li	a1,61
ffffffffc02011d8:	00006517          	auipc	a0,0x6
ffffffffc02011dc:	02850513          	addi	a0,a0,40 # ffffffffc0207200 <commands+0x940>
ffffffffc02011e0:	aa4ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    return pa2page(PADDR(kva));
ffffffffc02011e4:	00006617          	auipc	a2,0x6
ffffffffc02011e8:	fa460613          	addi	a2,a2,-92 # ffffffffc0207188 <commands+0x8c8>
ffffffffc02011ec:	06f00593          	li	a1,111
ffffffffc02011f0:	00006517          	auipc	a0,0x6
ffffffffc02011f4:	05850513          	addi	a0,a0,88 # ffffffffc0207248 <commands+0x988>
ffffffffc02011f8:	a8cff0ef          	jal	ra,ffffffffc0200484 <__panic>
        panic("Unlock failed.\n");
ffffffffc02011fc:	00006617          	auipc	a2,0x6
ffffffffc0201200:	f6460613          	addi	a2,a2,-156 # ffffffffc0207160 <commands+0x8a0>
ffffffffc0201204:	03100593          	li	a1,49
ffffffffc0201208:	00006517          	auipc	a0,0x6
ffffffffc020120c:	f6850513          	addi	a0,a0,-152 # ffffffffc0207170 <commands+0x8b0>
ffffffffc0201210:	a74ff0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0201214 <cow_pgfault>:

int 
cow_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0201214:	715d                	addi	sp,sp,-80
    cprintf("COW page fault at 0x%x\n", addr);
ffffffffc0201216:	85b2                	mv	a1,a2
cow_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0201218:	f44e                	sd	s3,40(sp)
ffffffffc020121a:	89aa                	mv	s3,a0
    cprintf("COW page fault at 0x%x\n", addr);
ffffffffc020121c:	00006517          	auipc	a0,0x6
ffffffffc0201220:	05c50513          	addi	a0,a0,92 # ffffffffc0207278 <commands+0x9b8>
cow_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0201224:	e486                	sd	ra,72(sp)
ffffffffc0201226:	fc26                	sd	s1,56(sp)
ffffffffc0201228:	e0a2                	sd	s0,64(sp)
ffffffffc020122a:	84b2                	mv	s1,a2
ffffffffc020122c:	f84a                	sd	s2,48(sp)
ffffffffc020122e:	f052                	sd	s4,32(sp)
ffffffffc0201230:	ec56                	sd	s5,24(sp)
ffffffffc0201232:	e85a                	sd	s6,16(sp)
ffffffffc0201234:	e45e                	sd	s7,8(sp)
ffffffffc0201236:	e062                	sd	s8,0(sp)
    cprintf("COW page fault at 0x%x\n", addr);
ffffffffc0201238:	f57fe0ef          	jal	ra,ffffffffc020018e <cprintf>
    int ret = 0;
    pte_t *ptep = NULL;
    ptep = get_pte(mm->pgdir, addr, 0);
ffffffffc020123c:	0189b503          	ld	a0,24(s3)
ffffffffc0201240:	4601                	li	a2,0
ffffffffc0201242:	85a6                	mv	a1,s1
ffffffffc0201244:	26e010ef          	jal	ra,ffffffffc02024b2 <get_pte>
    uint32_t perm = (*ptep & PTE_USER) | PTE_W;
ffffffffc0201248:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc020124a:	0017f713          	andi	a4,a5,1
ffffffffc020124e:	14070163          	beqz	a4,ffffffffc0201390 <cow_pgfault+0x17c>
    if (PPN(pa) >= npage) {
ffffffffc0201252:	000abb97          	auipc	s7,0xab
ffffffffc0201256:	226b8b93          	addi	s7,s7,550 # ffffffffc02ac478 <npage>
ffffffffc020125a:	000bb703          	ld	a4,0(s7)
ffffffffc020125e:	01b7f913          	andi	s2,a5,27
    return pa2page(PTE_ADDR(pte));
ffffffffc0201262:	078a                	slli	a5,a5,0x2
ffffffffc0201264:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201266:	10e7f963          	bleu	a4,a5,ffffffffc0201378 <cow_pgfault+0x164>
    return &pages[PPN(pa) - nbase];
ffffffffc020126a:	00008717          	auipc	a4,0x8
ffffffffc020126e:	c2670713          	addi	a4,a4,-986 # ffffffffc0208e90 <nbase>
ffffffffc0201272:	00073a83          	ld	s5,0(a4)
ffffffffc0201276:	000abc17          	auipc	s8,0xab
ffffffffc020127a:	272c0c13          	addi	s8,s8,626 # ffffffffc02ac4e8 <pages>
ffffffffc020127e:	000c3403          	ld	s0,0(s8)
ffffffffc0201282:	415787b3          	sub	a5,a5,s5
ffffffffc0201286:	079a                	slli	a5,a5,0x6
ffffffffc0201288:	8a2a                	mv	s4,a0
    struct Page *page = pte2page(*ptep);
    struct Page *npage = alloc_page();
ffffffffc020128a:	4505                	li	a0,1
ffffffffc020128c:	943e                	add	s0,s0,a5
ffffffffc020128e:	116010ef          	jal	ra,ffffffffc02023a4 <alloc_pages>
ffffffffc0201292:	8b2a                	mv	s6,a0
    assert(page != NULL);
ffffffffc0201294:	c071                	beqz	s0,ffffffffc0201358 <cow_pgfault+0x144>
    assert(npage != NULL);
ffffffffc0201296:	c14d                	beqz	a0,ffffffffc0201338 <cow_pgfault+0x124>
    return page - pages + nbase;
ffffffffc0201298:	000c3783          	ld	a5,0(s8)
    return KADDR(page2pa(page));
ffffffffc020129c:	577d                	li	a4,-1
ffffffffc020129e:	000bb603          	ld	a2,0(s7)
    return page - pages + nbase;
ffffffffc02012a2:	40f406b3          	sub	a3,s0,a5
ffffffffc02012a6:	8699                	srai	a3,a3,0x6
ffffffffc02012a8:	96d6                	add	a3,a3,s5
    return KADDR(page2pa(page));
ffffffffc02012aa:	8331                	srli	a4,a4,0xc
ffffffffc02012ac:	00e6f5b3          	and	a1,a3,a4
    return page2ppn(page) << PGSHIFT;
ffffffffc02012b0:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02012b2:	06c5f763          	bleu	a2,a1,ffffffffc0201320 <cow_pgfault+0x10c>
    return page - pages + nbase;
ffffffffc02012b6:	40f507b3          	sub	a5,a0,a5
    return KADDR(page2pa(page));
ffffffffc02012ba:	000ab597          	auipc	a1,0xab
ffffffffc02012be:	21e58593          	addi	a1,a1,542 # ffffffffc02ac4d8 <va_pa_offset>
ffffffffc02012c2:	6188                	ld	a0,0(a1)
    return page - pages + nbase;
ffffffffc02012c4:	8799                	srai	a5,a5,0x6
ffffffffc02012c6:	9abe                	add	s5,s5,a5
    return KADDR(page2pa(page));
ffffffffc02012c8:	00eaf733          	and	a4,s5,a4
ffffffffc02012cc:	00a685b3          	add	a1,a3,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc02012d0:	0ab2                	slli	s5,s5,0xc
    return KADDR(page2pa(page));
ffffffffc02012d2:	04c77663          	bleu	a2,a4,ffffffffc020131e <cow_pgfault+0x10a>
    uintptr_t* src = page2kva(page);
    uintptr_t* dst = page2kva(npage);
    memcpy(dst, src, PGSIZE);
ffffffffc02012d6:	6605                	lui	a2,0x1
ffffffffc02012d8:	9556                	add	a0,a0,s5
ffffffffc02012da:	49a050ef          	jal	ra,ffffffffc0206774 <memcpy>
    uintptr_t start = ROUNDDOWN(addr, PGSIZE);
    *ptep = 0;
    ret = page_insert(mm->pgdir, npage, start, perm);
ffffffffc02012de:	0189b503          	ld	a0,24(s3)
ffffffffc02012e2:	00496913          	ori	s2,s2,4
ffffffffc02012e6:	767d                	lui	a2,0xfffff
ffffffffc02012e8:	86ca                	mv	a3,s2
ffffffffc02012ea:	8e65                	and	a2,a2,s1
ffffffffc02012ec:	85da                	mv	a1,s6
    *ptep = 0;
ffffffffc02012ee:	000a3023          	sd	zero,0(s4)
    ret = page_insert(mm->pgdir, npage, start, perm);
ffffffffc02012f2:	7d6010ef          	jal	ra,ffffffffc0202ac8 <page_insert>
ffffffffc02012f6:	842a                	mv	s0,a0
    ptep = get_pte(mm->pgdir, addr, 0);
ffffffffc02012f8:	0189b503          	ld	a0,24(s3)
ffffffffc02012fc:	85a6                	mv	a1,s1
ffffffffc02012fe:	4601                	li	a2,0
ffffffffc0201300:	1b2010ef          	jal	ra,ffffffffc02024b2 <get_pte>
    return ret;
ffffffffc0201304:	8522                	mv	a0,s0
ffffffffc0201306:	60a6                	ld	ra,72(sp)
ffffffffc0201308:	6406                	ld	s0,64(sp)
ffffffffc020130a:	74e2                	ld	s1,56(sp)
ffffffffc020130c:	7942                	ld	s2,48(sp)
ffffffffc020130e:	79a2                	ld	s3,40(sp)
ffffffffc0201310:	7a02                	ld	s4,32(sp)
ffffffffc0201312:	6ae2                	ld	s5,24(sp)
ffffffffc0201314:	6b42                	ld	s6,16(sp)
ffffffffc0201316:	6ba2                	ld	s7,8(sp)
ffffffffc0201318:	6c02                	ld	s8,0(sp)
ffffffffc020131a:	6161                	addi	sp,sp,80
ffffffffc020131c:	8082                	ret
ffffffffc020131e:	86d6                	mv	a3,s5
ffffffffc0201320:	00006617          	auipc	a2,0x6
ffffffffc0201324:	e1860613          	addi	a2,a2,-488 # ffffffffc0207138 <commands+0x878>
ffffffffc0201328:	06a00593          	li	a1,106
ffffffffc020132c:	00006517          	auipc	a0,0x6
ffffffffc0201330:	f1c50513          	addi	a0,a0,-228 # ffffffffc0207248 <commands+0x988>
ffffffffc0201334:	950ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(npage != NULL);
ffffffffc0201338:	00006697          	auipc	a3,0x6
ffffffffc020133c:	f8068693          	addi	a3,a3,-128 # ffffffffc02072b8 <commands+0x9f8>
ffffffffc0201340:	00006617          	auipc	a2,0x6
ffffffffc0201344:	a4060613          	addi	a2,a2,-1472 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0201348:	07c00593          	li	a1,124
ffffffffc020134c:	00006517          	auipc	a0,0x6
ffffffffc0201350:	eb450513          	addi	a0,a0,-332 # ffffffffc0207200 <commands+0x940>
ffffffffc0201354:	930ff0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page != NULL);
ffffffffc0201358:	00006697          	auipc	a3,0x6
ffffffffc020135c:	f0068693          	addi	a3,a3,-256 # ffffffffc0207258 <commands+0x998>
ffffffffc0201360:	00006617          	auipc	a2,0x6
ffffffffc0201364:	a2060613          	addi	a2,a2,-1504 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0201368:	07b00593          	li	a1,123
ffffffffc020136c:	00006517          	auipc	a0,0x6
ffffffffc0201370:	e9450513          	addi	a0,a0,-364 # ffffffffc0207200 <commands+0x940>
ffffffffc0201374:	910ff0ef          	jal	ra,ffffffffc0200484 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0201378:	00006617          	auipc	a2,0x6
ffffffffc020137c:	eb060613          	addi	a2,a2,-336 # ffffffffc0207228 <commands+0x968>
ffffffffc0201380:	06300593          	li	a1,99
ffffffffc0201384:	00006517          	auipc	a0,0x6
ffffffffc0201388:	ec450513          	addi	a0,a0,-316 # ffffffffc0207248 <commands+0x988>
ffffffffc020138c:	8f8ff0ef          	jal	ra,ffffffffc0200484 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0201390:	00006617          	auipc	a2,0x6
ffffffffc0201394:	f0060613          	addi	a2,a2,-256 # ffffffffc0207290 <commands+0x9d0>
ffffffffc0201398:	07500593          	li	a1,117
ffffffffc020139c:	00006517          	auipc	a0,0x6
ffffffffc02013a0:	eac50513          	addi	a0,a0,-340 # ffffffffc0207248 <commands+0x988>
ffffffffc02013a4:	8e0ff0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc02013a8 <default_init>:
    elm->prev = elm->next = elm;
ffffffffc02013a8:	000ab797          	auipc	a5,0xab
ffffffffc02013ac:	11078793          	addi	a5,a5,272 # ffffffffc02ac4b8 <free_area>
ffffffffc02013b0:	e79c                	sd	a5,8(a5)
ffffffffc02013b2:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc02013b4:	0007a823          	sw	zero,16(a5)
}
ffffffffc02013b8:	8082                	ret

ffffffffc02013ba <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc02013ba:	000ab517          	auipc	a0,0xab
ffffffffc02013be:	10e56503          	lwu	a0,270(a0) # ffffffffc02ac4c8 <free_area+0x10>
ffffffffc02013c2:	8082                	ret

ffffffffc02013c4 <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc02013c4:	715d                	addi	sp,sp,-80
ffffffffc02013c6:	f84a                	sd	s2,48(sp)
    return listelm->next;
ffffffffc02013c8:	000ab917          	auipc	s2,0xab
ffffffffc02013cc:	0f090913          	addi	s2,s2,240 # ffffffffc02ac4b8 <free_area>
ffffffffc02013d0:	00893783          	ld	a5,8(s2)
ffffffffc02013d4:	e486                	sd	ra,72(sp)
ffffffffc02013d6:	e0a2                	sd	s0,64(sp)
ffffffffc02013d8:	fc26                	sd	s1,56(sp)
ffffffffc02013da:	f44e                	sd	s3,40(sp)
ffffffffc02013dc:	f052                	sd	s4,32(sp)
ffffffffc02013de:	ec56                	sd	s5,24(sp)
ffffffffc02013e0:	e85a                	sd	s6,16(sp)
ffffffffc02013e2:	e45e                	sd	s7,8(sp)
ffffffffc02013e4:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc02013e6:	31278463          	beq	a5,s2,ffffffffc02016ee <default_check+0x32a>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02013ea:	ff07b703          	ld	a4,-16(a5)
ffffffffc02013ee:	8305                	srli	a4,a4,0x1
ffffffffc02013f0:	8b05                	andi	a4,a4,1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc02013f2:	30070263          	beqz	a4,ffffffffc02016f6 <default_check+0x332>
    int count = 0, total = 0;
ffffffffc02013f6:	4401                	li	s0,0
ffffffffc02013f8:	4481                	li	s1,0
ffffffffc02013fa:	a031                	j	ffffffffc0201406 <default_check+0x42>
ffffffffc02013fc:	ff07b703          	ld	a4,-16(a5)
        assert(PageProperty(p));
ffffffffc0201400:	8b09                	andi	a4,a4,2
ffffffffc0201402:	2e070a63          	beqz	a4,ffffffffc02016f6 <default_check+0x332>
        count ++, total += p->property;
ffffffffc0201406:	ff87a703          	lw	a4,-8(a5)
ffffffffc020140a:	679c                	ld	a5,8(a5)
ffffffffc020140c:	2485                	addiw	s1,s1,1
ffffffffc020140e:	9c39                	addw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201410:	ff2796e3          	bne	a5,s2,ffffffffc02013fc <default_check+0x38>
ffffffffc0201414:	89a2                	mv	s3,s0
    }
    assert(total == nr_free_pages());
ffffffffc0201416:	05c010ef          	jal	ra,ffffffffc0202472 <nr_free_pages>
ffffffffc020141a:	73351e63          	bne	a0,s3,ffffffffc0201b56 <default_check+0x792>
    assert((p0 = alloc_page()) != NULL);
ffffffffc020141e:	4505                	li	a0,1
ffffffffc0201420:	785000ef          	jal	ra,ffffffffc02023a4 <alloc_pages>
ffffffffc0201424:	8a2a                	mv	s4,a0
ffffffffc0201426:	46050863          	beqz	a0,ffffffffc0201896 <default_check+0x4d2>
    assert((p1 = alloc_page()) != NULL);
ffffffffc020142a:	4505                	li	a0,1
ffffffffc020142c:	779000ef          	jal	ra,ffffffffc02023a4 <alloc_pages>
ffffffffc0201430:	89aa                	mv	s3,a0
ffffffffc0201432:	74050263          	beqz	a0,ffffffffc0201b76 <default_check+0x7b2>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201436:	4505                	li	a0,1
ffffffffc0201438:	76d000ef          	jal	ra,ffffffffc02023a4 <alloc_pages>
ffffffffc020143c:	8aaa                	mv	s5,a0
ffffffffc020143e:	4c050c63          	beqz	a0,ffffffffc0201916 <default_check+0x552>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0201442:	2d3a0a63          	beq	s4,s3,ffffffffc0201716 <default_check+0x352>
ffffffffc0201446:	2caa0863          	beq	s4,a0,ffffffffc0201716 <default_check+0x352>
ffffffffc020144a:	2ca98663          	beq	s3,a0,ffffffffc0201716 <default_check+0x352>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc020144e:	000a2783          	lw	a5,0(s4)
ffffffffc0201452:	2e079263          	bnez	a5,ffffffffc0201736 <default_check+0x372>
ffffffffc0201456:	0009a783          	lw	a5,0(s3)
ffffffffc020145a:	2c079e63          	bnez	a5,ffffffffc0201736 <default_check+0x372>
ffffffffc020145e:	411c                	lw	a5,0(a0)
ffffffffc0201460:	2c079b63          	bnez	a5,ffffffffc0201736 <default_check+0x372>
    return page - pages + nbase;
ffffffffc0201464:	000ab797          	auipc	a5,0xab
ffffffffc0201468:	08478793          	addi	a5,a5,132 # ffffffffc02ac4e8 <pages>
ffffffffc020146c:	639c                	ld	a5,0(a5)
ffffffffc020146e:	00008717          	auipc	a4,0x8
ffffffffc0201472:	a2270713          	addi	a4,a4,-1502 # ffffffffc0208e90 <nbase>
ffffffffc0201476:	6310                	ld	a2,0(a4)
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0201478:	000ab717          	auipc	a4,0xab
ffffffffc020147c:	00070713          	mv	a4,a4
ffffffffc0201480:	6314                	ld	a3,0(a4)
ffffffffc0201482:	40fa0733          	sub	a4,s4,a5
ffffffffc0201486:	8719                	srai	a4,a4,0x6
ffffffffc0201488:	9732                	add	a4,a4,a2
ffffffffc020148a:	06b2                	slli	a3,a3,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc020148c:	0732                	slli	a4,a4,0xc
ffffffffc020148e:	2cd77463          	bleu	a3,a4,ffffffffc0201756 <default_check+0x392>
    return page - pages + nbase;
ffffffffc0201492:	40f98733          	sub	a4,s3,a5
ffffffffc0201496:	8719                	srai	a4,a4,0x6
ffffffffc0201498:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc020149a:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc020149c:	4ed77d63          	bleu	a3,a4,ffffffffc0201996 <default_check+0x5d2>
    return page - pages + nbase;
ffffffffc02014a0:	40f507b3          	sub	a5,a0,a5
ffffffffc02014a4:	8799                	srai	a5,a5,0x6
ffffffffc02014a6:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc02014a8:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc02014aa:	34d7f663          	bleu	a3,a5,ffffffffc02017f6 <default_check+0x432>
    assert(alloc_page() == NULL);
ffffffffc02014ae:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc02014b0:	00093c03          	ld	s8,0(s2)
ffffffffc02014b4:	00893b83          	ld	s7,8(s2)
    unsigned int nr_free_store = nr_free;
ffffffffc02014b8:	01092b03          	lw	s6,16(s2)
    elm->prev = elm->next = elm;
ffffffffc02014bc:	000ab797          	auipc	a5,0xab
ffffffffc02014c0:	0127b223          	sd	s2,4(a5) # ffffffffc02ac4c0 <free_area+0x8>
ffffffffc02014c4:	000ab797          	auipc	a5,0xab
ffffffffc02014c8:	ff27ba23          	sd	s2,-12(a5) # ffffffffc02ac4b8 <free_area>
    nr_free = 0;
ffffffffc02014cc:	000ab797          	auipc	a5,0xab
ffffffffc02014d0:	fe07ae23          	sw	zero,-4(a5) # ffffffffc02ac4c8 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc02014d4:	6d1000ef          	jal	ra,ffffffffc02023a4 <alloc_pages>
ffffffffc02014d8:	2e051f63          	bnez	a0,ffffffffc02017d6 <default_check+0x412>
    free_page(p0);
ffffffffc02014dc:	4585                	li	a1,1
ffffffffc02014de:	8552                	mv	a0,s4
ffffffffc02014e0:	74d000ef          	jal	ra,ffffffffc020242c <free_pages>
    free_page(p1);
ffffffffc02014e4:	4585                	li	a1,1
ffffffffc02014e6:	854e                	mv	a0,s3
ffffffffc02014e8:	745000ef          	jal	ra,ffffffffc020242c <free_pages>
    free_page(p2);
ffffffffc02014ec:	4585                	li	a1,1
ffffffffc02014ee:	8556                	mv	a0,s5
ffffffffc02014f0:	73d000ef          	jal	ra,ffffffffc020242c <free_pages>
    assert(nr_free == 3);
ffffffffc02014f4:	01092703          	lw	a4,16(s2)
ffffffffc02014f8:	478d                	li	a5,3
ffffffffc02014fa:	2af71e63          	bne	a4,a5,ffffffffc02017b6 <default_check+0x3f2>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02014fe:	4505                	li	a0,1
ffffffffc0201500:	6a5000ef          	jal	ra,ffffffffc02023a4 <alloc_pages>
ffffffffc0201504:	89aa                	mv	s3,a0
ffffffffc0201506:	28050863          	beqz	a0,ffffffffc0201796 <default_check+0x3d2>
    assert((p1 = alloc_page()) != NULL);
ffffffffc020150a:	4505                	li	a0,1
ffffffffc020150c:	699000ef          	jal	ra,ffffffffc02023a4 <alloc_pages>
ffffffffc0201510:	8aaa                	mv	s5,a0
ffffffffc0201512:	3e050263          	beqz	a0,ffffffffc02018f6 <default_check+0x532>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201516:	4505                	li	a0,1
ffffffffc0201518:	68d000ef          	jal	ra,ffffffffc02023a4 <alloc_pages>
ffffffffc020151c:	8a2a                	mv	s4,a0
ffffffffc020151e:	3a050c63          	beqz	a0,ffffffffc02018d6 <default_check+0x512>
    assert(alloc_page() == NULL);
ffffffffc0201522:	4505                	li	a0,1
ffffffffc0201524:	681000ef          	jal	ra,ffffffffc02023a4 <alloc_pages>
ffffffffc0201528:	38051763          	bnez	a0,ffffffffc02018b6 <default_check+0x4f2>
    free_page(p0);
ffffffffc020152c:	4585                	li	a1,1
ffffffffc020152e:	854e                	mv	a0,s3
ffffffffc0201530:	6fd000ef          	jal	ra,ffffffffc020242c <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0201534:	00893783          	ld	a5,8(s2)
ffffffffc0201538:	23278f63          	beq	a5,s2,ffffffffc0201776 <default_check+0x3b2>
    assert((p = alloc_page()) == p0);
ffffffffc020153c:	4505                	li	a0,1
ffffffffc020153e:	667000ef          	jal	ra,ffffffffc02023a4 <alloc_pages>
ffffffffc0201542:	32a99a63          	bne	s3,a0,ffffffffc0201876 <default_check+0x4b2>
    assert(alloc_page() == NULL);
ffffffffc0201546:	4505                	li	a0,1
ffffffffc0201548:	65d000ef          	jal	ra,ffffffffc02023a4 <alloc_pages>
ffffffffc020154c:	30051563          	bnez	a0,ffffffffc0201856 <default_check+0x492>
    assert(nr_free == 0);
ffffffffc0201550:	01092783          	lw	a5,16(s2)
ffffffffc0201554:	2e079163          	bnez	a5,ffffffffc0201836 <default_check+0x472>
    free_page(p);
ffffffffc0201558:	854e                	mv	a0,s3
ffffffffc020155a:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc020155c:	000ab797          	auipc	a5,0xab
ffffffffc0201560:	f587be23          	sd	s8,-164(a5) # ffffffffc02ac4b8 <free_area>
ffffffffc0201564:	000ab797          	auipc	a5,0xab
ffffffffc0201568:	f577be23          	sd	s7,-164(a5) # ffffffffc02ac4c0 <free_area+0x8>
    nr_free = nr_free_store;
ffffffffc020156c:	000ab797          	auipc	a5,0xab
ffffffffc0201570:	f567ae23          	sw	s6,-164(a5) # ffffffffc02ac4c8 <free_area+0x10>
    free_page(p);
ffffffffc0201574:	6b9000ef          	jal	ra,ffffffffc020242c <free_pages>
    free_page(p1);
ffffffffc0201578:	4585                	li	a1,1
ffffffffc020157a:	8556                	mv	a0,s5
ffffffffc020157c:	6b1000ef          	jal	ra,ffffffffc020242c <free_pages>
    free_page(p2);
ffffffffc0201580:	4585                	li	a1,1
ffffffffc0201582:	8552                	mv	a0,s4
ffffffffc0201584:	6a9000ef          	jal	ra,ffffffffc020242c <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0201588:	4515                	li	a0,5
ffffffffc020158a:	61b000ef          	jal	ra,ffffffffc02023a4 <alloc_pages>
ffffffffc020158e:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0201590:	28050363          	beqz	a0,ffffffffc0201816 <default_check+0x452>
ffffffffc0201594:	651c                	ld	a5,8(a0)
ffffffffc0201596:	8385                	srli	a5,a5,0x1
ffffffffc0201598:	8b85                	andi	a5,a5,1
    assert(!PageProperty(p0));
ffffffffc020159a:	54079e63          	bnez	a5,ffffffffc0201af6 <default_check+0x732>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc020159e:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc02015a0:	00093b03          	ld	s6,0(s2)
ffffffffc02015a4:	00893a83          	ld	s5,8(s2)
ffffffffc02015a8:	000ab797          	auipc	a5,0xab
ffffffffc02015ac:	f127b823          	sd	s2,-240(a5) # ffffffffc02ac4b8 <free_area>
ffffffffc02015b0:	000ab797          	auipc	a5,0xab
ffffffffc02015b4:	f127b823          	sd	s2,-240(a5) # ffffffffc02ac4c0 <free_area+0x8>
    assert(alloc_page() == NULL);
ffffffffc02015b8:	5ed000ef          	jal	ra,ffffffffc02023a4 <alloc_pages>
ffffffffc02015bc:	50051d63          	bnez	a0,ffffffffc0201ad6 <default_check+0x712>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc02015c0:	08098a13          	addi	s4,s3,128
ffffffffc02015c4:	8552                	mv	a0,s4
ffffffffc02015c6:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc02015c8:	01092b83          	lw	s7,16(s2)
    nr_free = 0;
ffffffffc02015cc:	000ab797          	auipc	a5,0xab
ffffffffc02015d0:	ee07ae23          	sw	zero,-260(a5) # ffffffffc02ac4c8 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc02015d4:	659000ef          	jal	ra,ffffffffc020242c <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc02015d8:	4511                	li	a0,4
ffffffffc02015da:	5cb000ef          	jal	ra,ffffffffc02023a4 <alloc_pages>
ffffffffc02015de:	4c051c63          	bnez	a0,ffffffffc0201ab6 <default_check+0x6f2>
ffffffffc02015e2:	0889b783          	ld	a5,136(s3)
ffffffffc02015e6:	8385                	srli	a5,a5,0x1
ffffffffc02015e8:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc02015ea:	4a078663          	beqz	a5,ffffffffc0201a96 <default_check+0x6d2>
ffffffffc02015ee:	0909a703          	lw	a4,144(s3)
ffffffffc02015f2:	478d                	li	a5,3
ffffffffc02015f4:	4af71163          	bne	a4,a5,ffffffffc0201a96 <default_check+0x6d2>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc02015f8:	450d                	li	a0,3
ffffffffc02015fa:	5ab000ef          	jal	ra,ffffffffc02023a4 <alloc_pages>
ffffffffc02015fe:	8c2a                	mv	s8,a0
ffffffffc0201600:	46050b63          	beqz	a0,ffffffffc0201a76 <default_check+0x6b2>
    assert(alloc_page() == NULL);
ffffffffc0201604:	4505                	li	a0,1
ffffffffc0201606:	59f000ef          	jal	ra,ffffffffc02023a4 <alloc_pages>
ffffffffc020160a:	44051663          	bnez	a0,ffffffffc0201a56 <default_check+0x692>
    assert(p0 + 2 == p1);
ffffffffc020160e:	438a1463          	bne	s4,s8,ffffffffc0201a36 <default_check+0x672>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc0201612:	4585                	li	a1,1
ffffffffc0201614:	854e                	mv	a0,s3
ffffffffc0201616:	617000ef          	jal	ra,ffffffffc020242c <free_pages>
    free_pages(p1, 3);
ffffffffc020161a:	458d                	li	a1,3
ffffffffc020161c:	8552                	mv	a0,s4
ffffffffc020161e:	60f000ef          	jal	ra,ffffffffc020242c <free_pages>
ffffffffc0201622:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc0201626:	04098c13          	addi	s8,s3,64
ffffffffc020162a:	8385                	srli	a5,a5,0x1
ffffffffc020162c:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc020162e:	3e078463          	beqz	a5,ffffffffc0201a16 <default_check+0x652>
ffffffffc0201632:	0109a703          	lw	a4,16(s3)
ffffffffc0201636:	4785                	li	a5,1
ffffffffc0201638:	3cf71f63          	bne	a4,a5,ffffffffc0201a16 <default_check+0x652>
ffffffffc020163c:	008a3783          	ld	a5,8(s4)
ffffffffc0201640:	8385                	srli	a5,a5,0x1
ffffffffc0201642:	8b85                	andi	a5,a5,1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0201644:	3a078963          	beqz	a5,ffffffffc02019f6 <default_check+0x632>
ffffffffc0201648:	010a2703          	lw	a4,16(s4)
ffffffffc020164c:	478d                	li	a5,3
ffffffffc020164e:	3af71463          	bne	a4,a5,ffffffffc02019f6 <default_check+0x632>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0201652:	4505                	li	a0,1
ffffffffc0201654:	551000ef          	jal	ra,ffffffffc02023a4 <alloc_pages>
ffffffffc0201658:	36a99f63          	bne	s3,a0,ffffffffc02019d6 <default_check+0x612>
    free_page(p0);
ffffffffc020165c:	4585                	li	a1,1
ffffffffc020165e:	5cf000ef          	jal	ra,ffffffffc020242c <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0201662:	4509                	li	a0,2
ffffffffc0201664:	541000ef          	jal	ra,ffffffffc02023a4 <alloc_pages>
ffffffffc0201668:	34aa1763          	bne	s4,a0,ffffffffc02019b6 <default_check+0x5f2>

    free_pages(p0, 2);
ffffffffc020166c:	4589                	li	a1,2
ffffffffc020166e:	5bf000ef          	jal	ra,ffffffffc020242c <free_pages>
    free_page(p2);
ffffffffc0201672:	4585                	li	a1,1
ffffffffc0201674:	8562                	mv	a0,s8
ffffffffc0201676:	5b7000ef          	jal	ra,ffffffffc020242c <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc020167a:	4515                	li	a0,5
ffffffffc020167c:	529000ef          	jal	ra,ffffffffc02023a4 <alloc_pages>
ffffffffc0201680:	89aa                	mv	s3,a0
ffffffffc0201682:	48050a63          	beqz	a0,ffffffffc0201b16 <default_check+0x752>
    assert(alloc_page() == NULL);
ffffffffc0201686:	4505                	li	a0,1
ffffffffc0201688:	51d000ef          	jal	ra,ffffffffc02023a4 <alloc_pages>
ffffffffc020168c:	2e051563          	bnez	a0,ffffffffc0201976 <default_check+0x5b2>

    assert(nr_free == 0);
ffffffffc0201690:	01092783          	lw	a5,16(s2)
ffffffffc0201694:	2c079163          	bnez	a5,ffffffffc0201956 <default_check+0x592>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0201698:	4595                	li	a1,5
ffffffffc020169a:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc020169c:	000ab797          	auipc	a5,0xab
ffffffffc02016a0:	e377a623          	sw	s7,-468(a5) # ffffffffc02ac4c8 <free_area+0x10>
    free_list = free_list_store;
ffffffffc02016a4:	000ab797          	auipc	a5,0xab
ffffffffc02016a8:	e167ba23          	sd	s6,-492(a5) # ffffffffc02ac4b8 <free_area>
ffffffffc02016ac:	000ab797          	auipc	a5,0xab
ffffffffc02016b0:	e157ba23          	sd	s5,-492(a5) # ffffffffc02ac4c0 <free_area+0x8>
    free_pages(p0, 5);
ffffffffc02016b4:	579000ef          	jal	ra,ffffffffc020242c <free_pages>
    return listelm->next;
ffffffffc02016b8:	00893783          	ld	a5,8(s2)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc02016bc:	01278963          	beq	a5,s2,ffffffffc02016ce <default_check+0x30a>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc02016c0:	ff87a703          	lw	a4,-8(a5)
ffffffffc02016c4:	679c                	ld	a5,8(a5)
ffffffffc02016c6:	34fd                	addiw	s1,s1,-1
ffffffffc02016c8:	9c19                	subw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc02016ca:	ff279be3          	bne	a5,s2,ffffffffc02016c0 <default_check+0x2fc>
    }
    assert(count == 0);
ffffffffc02016ce:	26049463          	bnez	s1,ffffffffc0201936 <default_check+0x572>
    assert(total == 0);
ffffffffc02016d2:	46041263          	bnez	s0,ffffffffc0201b36 <default_check+0x772>
}
ffffffffc02016d6:	60a6                	ld	ra,72(sp)
ffffffffc02016d8:	6406                	ld	s0,64(sp)
ffffffffc02016da:	74e2                	ld	s1,56(sp)
ffffffffc02016dc:	7942                	ld	s2,48(sp)
ffffffffc02016de:	79a2                	ld	s3,40(sp)
ffffffffc02016e0:	7a02                	ld	s4,32(sp)
ffffffffc02016e2:	6ae2                	ld	s5,24(sp)
ffffffffc02016e4:	6b42                	ld	s6,16(sp)
ffffffffc02016e6:	6ba2                	ld	s7,8(sp)
ffffffffc02016e8:	6c02                	ld	s8,0(sp)
ffffffffc02016ea:	6161                	addi	sp,sp,80
ffffffffc02016ec:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc02016ee:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc02016f0:	4401                	li	s0,0
ffffffffc02016f2:	4481                	li	s1,0
ffffffffc02016f4:	b30d                	j	ffffffffc0201416 <default_check+0x52>
        assert(PageProperty(p));
ffffffffc02016f6:	00006697          	auipc	a3,0x6
ffffffffc02016fa:	bd268693          	addi	a3,a3,-1070 # ffffffffc02072c8 <commands+0xa08>
ffffffffc02016fe:	00005617          	auipc	a2,0x5
ffffffffc0201702:	68260613          	addi	a2,a2,1666 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0201706:	0f000593          	li	a1,240
ffffffffc020170a:	00006517          	auipc	a0,0x6
ffffffffc020170e:	bce50513          	addi	a0,a0,-1074 # ffffffffc02072d8 <commands+0xa18>
ffffffffc0201712:	d73fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0201716:	00006697          	auipc	a3,0x6
ffffffffc020171a:	c5a68693          	addi	a3,a3,-934 # ffffffffc0207370 <commands+0xab0>
ffffffffc020171e:	00005617          	auipc	a2,0x5
ffffffffc0201722:	66260613          	addi	a2,a2,1634 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0201726:	0bd00593          	li	a1,189
ffffffffc020172a:	00006517          	auipc	a0,0x6
ffffffffc020172e:	bae50513          	addi	a0,a0,-1106 # ffffffffc02072d8 <commands+0xa18>
ffffffffc0201732:	d53fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0201736:	00006697          	auipc	a3,0x6
ffffffffc020173a:	c6268693          	addi	a3,a3,-926 # ffffffffc0207398 <commands+0xad8>
ffffffffc020173e:	00005617          	auipc	a2,0x5
ffffffffc0201742:	64260613          	addi	a2,a2,1602 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0201746:	0be00593          	li	a1,190
ffffffffc020174a:	00006517          	auipc	a0,0x6
ffffffffc020174e:	b8e50513          	addi	a0,a0,-1138 # ffffffffc02072d8 <commands+0xa18>
ffffffffc0201752:	d33fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0201756:	00006697          	auipc	a3,0x6
ffffffffc020175a:	c8268693          	addi	a3,a3,-894 # ffffffffc02073d8 <commands+0xb18>
ffffffffc020175e:	00005617          	auipc	a2,0x5
ffffffffc0201762:	62260613          	addi	a2,a2,1570 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0201766:	0c000593          	li	a1,192
ffffffffc020176a:	00006517          	auipc	a0,0x6
ffffffffc020176e:	b6e50513          	addi	a0,a0,-1170 # ffffffffc02072d8 <commands+0xa18>
ffffffffc0201772:	d13fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(!list_empty(&free_list));
ffffffffc0201776:	00006697          	auipc	a3,0x6
ffffffffc020177a:	cea68693          	addi	a3,a3,-790 # ffffffffc0207460 <commands+0xba0>
ffffffffc020177e:	00005617          	auipc	a2,0x5
ffffffffc0201782:	60260613          	addi	a2,a2,1538 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0201786:	0d900593          	li	a1,217
ffffffffc020178a:	00006517          	auipc	a0,0x6
ffffffffc020178e:	b4e50513          	addi	a0,a0,-1202 # ffffffffc02072d8 <commands+0xa18>
ffffffffc0201792:	cf3fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201796:	00006697          	auipc	a3,0x6
ffffffffc020179a:	b7a68693          	addi	a3,a3,-1158 # ffffffffc0207310 <commands+0xa50>
ffffffffc020179e:	00005617          	auipc	a2,0x5
ffffffffc02017a2:	5e260613          	addi	a2,a2,1506 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc02017a6:	0d200593          	li	a1,210
ffffffffc02017aa:	00006517          	auipc	a0,0x6
ffffffffc02017ae:	b2e50513          	addi	a0,a0,-1234 # ffffffffc02072d8 <commands+0xa18>
ffffffffc02017b2:	cd3fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(nr_free == 3);
ffffffffc02017b6:	00006697          	auipc	a3,0x6
ffffffffc02017ba:	c9a68693          	addi	a3,a3,-870 # ffffffffc0207450 <commands+0xb90>
ffffffffc02017be:	00005617          	auipc	a2,0x5
ffffffffc02017c2:	5c260613          	addi	a2,a2,1474 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc02017c6:	0d000593          	li	a1,208
ffffffffc02017ca:	00006517          	auipc	a0,0x6
ffffffffc02017ce:	b0e50513          	addi	a0,a0,-1266 # ffffffffc02072d8 <commands+0xa18>
ffffffffc02017d2:	cb3fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02017d6:	00006697          	auipc	a3,0x6
ffffffffc02017da:	c6268693          	addi	a3,a3,-926 # ffffffffc0207438 <commands+0xb78>
ffffffffc02017de:	00005617          	auipc	a2,0x5
ffffffffc02017e2:	5a260613          	addi	a2,a2,1442 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc02017e6:	0cb00593          	li	a1,203
ffffffffc02017ea:	00006517          	auipc	a0,0x6
ffffffffc02017ee:	aee50513          	addi	a0,a0,-1298 # ffffffffc02072d8 <commands+0xa18>
ffffffffc02017f2:	c93fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc02017f6:	00006697          	auipc	a3,0x6
ffffffffc02017fa:	c2268693          	addi	a3,a3,-990 # ffffffffc0207418 <commands+0xb58>
ffffffffc02017fe:	00005617          	auipc	a2,0x5
ffffffffc0201802:	58260613          	addi	a2,a2,1410 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0201806:	0c200593          	li	a1,194
ffffffffc020180a:	00006517          	auipc	a0,0x6
ffffffffc020180e:	ace50513          	addi	a0,a0,-1330 # ffffffffc02072d8 <commands+0xa18>
ffffffffc0201812:	c73fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(p0 != NULL);
ffffffffc0201816:	00006697          	auipc	a3,0x6
ffffffffc020181a:	c9268693          	addi	a3,a3,-878 # ffffffffc02074a8 <commands+0xbe8>
ffffffffc020181e:	00005617          	auipc	a2,0x5
ffffffffc0201822:	56260613          	addi	a2,a2,1378 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0201826:	0f800593          	li	a1,248
ffffffffc020182a:	00006517          	auipc	a0,0x6
ffffffffc020182e:	aae50513          	addi	a0,a0,-1362 # ffffffffc02072d8 <commands+0xa18>
ffffffffc0201832:	c53fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(nr_free == 0);
ffffffffc0201836:	00006697          	auipc	a3,0x6
ffffffffc020183a:	c6268693          	addi	a3,a3,-926 # ffffffffc0207498 <commands+0xbd8>
ffffffffc020183e:	00005617          	auipc	a2,0x5
ffffffffc0201842:	54260613          	addi	a2,a2,1346 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0201846:	0df00593          	li	a1,223
ffffffffc020184a:	00006517          	auipc	a0,0x6
ffffffffc020184e:	a8e50513          	addi	a0,a0,-1394 # ffffffffc02072d8 <commands+0xa18>
ffffffffc0201852:	c33fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201856:	00006697          	auipc	a3,0x6
ffffffffc020185a:	be268693          	addi	a3,a3,-1054 # ffffffffc0207438 <commands+0xb78>
ffffffffc020185e:	00005617          	auipc	a2,0x5
ffffffffc0201862:	52260613          	addi	a2,a2,1314 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0201866:	0dd00593          	li	a1,221
ffffffffc020186a:	00006517          	auipc	a0,0x6
ffffffffc020186e:	a6e50513          	addi	a0,a0,-1426 # ffffffffc02072d8 <commands+0xa18>
ffffffffc0201872:	c13fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0201876:	00006697          	auipc	a3,0x6
ffffffffc020187a:	c0268693          	addi	a3,a3,-1022 # ffffffffc0207478 <commands+0xbb8>
ffffffffc020187e:	00005617          	auipc	a2,0x5
ffffffffc0201882:	50260613          	addi	a2,a2,1282 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0201886:	0dc00593          	li	a1,220
ffffffffc020188a:	00006517          	auipc	a0,0x6
ffffffffc020188e:	a4e50513          	addi	a0,a0,-1458 # ffffffffc02072d8 <commands+0xa18>
ffffffffc0201892:	bf3fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201896:	00006697          	auipc	a3,0x6
ffffffffc020189a:	a7a68693          	addi	a3,a3,-1414 # ffffffffc0207310 <commands+0xa50>
ffffffffc020189e:	00005617          	auipc	a2,0x5
ffffffffc02018a2:	4e260613          	addi	a2,a2,1250 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc02018a6:	0b900593          	li	a1,185
ffffffffc02018aa:	00006517          	auipc	a0,0x6
ffffffffc02018ae:	a2e50513          	addi	a0,a0,-1490 # ffffffffc02072d8 <commands+0xa18>
ffffffffc02018b2:	bd3fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02018b6:	00006697          	auipc	a3,0x6
ffffffffc02018ba:	b8268693          	addi	a3,a3,-1150 # ffffffffc0207438 <commands+0xb78>
ffffffffc02018be:	00005617          	auipc	a2,0x5
ffffffffc02018c2:	4c260613          	addi	a2,a2,1218 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc02018c6:	0d600593          	li	a1,214
ffffffffc02018ca:	00006517          	auipc	a0,0x6
ffffffffc02018ce:	a0e50513          	addi	a0,a0,-1522 # ffffffffc02072d8 <commands+0xa18>
ffffffffc02018d2:	bb3fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02018d6:	00006697          	auipc	a3,0x6
ffffffffc02018da:	a7a68693          	addi	a3,a3,-1414 # ffffffffc0207350 <commands+0xa90>
ffffffffc02018de:	00005617          	auipc	a2,0x5
ffffffffc02018e2:	4a260613          	addi	a2,a2,1186 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc02018e6:	0d400593          	li	a1,212
ffffffffc02018ea:	00006517          	auipc	a0,0x6
ffffffffc02018ee:	9ee50513          	addi	a0,a0,-1554 # ffffffffc02072d8 <commands+0xa18>
ffffffffc02018f2:	b93fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02018f6:	00006697          	auipc	a3,0x6
ffffffffc02018fa:	a3a68693          	addi	a3,a3,-1478 # ffffffffc0207330 <commands+0xa70>
ffffffffc02018fe:	00005617          	auipc	a2,0x5
ffffffffc0201902:	48260613          	addi	a2,a2,1154 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0201906:	0d300593          	li	a1,211
ffffffffc020190a:	00006517          	auipc	a0,0x6
ffffffffc020190e:	9ce50513          	addi	a0,a0,-1586 # ffffffffc02072d8 <commands+0xa18>
ffffffffc0201912:	b73fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201916:	00006697          	auipc	a3,0x6
ffffffffc020191a:	a3a68693          	addi	a3,a3,-1478 # ffffffffc0207350 <commands+0xa90>
ffffffffc020191e:	00005617          	auipc	a2,0x5
ffffffffc0201922:	46260613          	addi	a2,a2,1122 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0201926:	0bb00593          	li	a1,187
ffffffffc020192a:	00006517          	auipc	a0,0x6
ffffffffc020192e:	9ae50513          	addi	a0,a0,-1618 # ffffffffc02072d8 <commands+0xa18>
ffffffffc0201932:	b53fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(count == 0);
ffffffffc0201936:	00006697          	auipc	a3,0x6
ffffffffc020193a:	cc268693          	addi	a3,a3,-830 # ffffffffc02075f8 <commands+0xd38>
ffffffffc020193e:	00005617          	auipc	a2,0x5
ffffffffc0201942:	44260613          	addi	a2,a2,1090 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0201946:	12500593          	li	a1,293
ffffffffc020194a:	00006517          	auipc	a0,0x6
ffffffffc020194e:	98e50513          	addi	a0,a0,-1650 # ffffffffc02072d8 <commands+0xa18>
ffffffffc0201952:	b33fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(nr_free == 0);
ffffffffc0201956:	00006697          	auipc	a3,0x6
ffffffffc020195a:	b4268693          	addi	a3,a3,-1214 # ffffffffc0207498 <commands+0xbd8>
ffffffffc020195e:	00005617          	auipc	a2,0x5
ffffffffc0201962:	42260613          	addi	a2,a2,1058 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0201966:	11a00593          	li	a1,282
ffffffffc020196a:	00006517          	auipc	a0,0x6
ffffffffc020196e:	96e50513          	addi	a0,a0,-1682 # ffffffffc02072d8 <commands+0xa18>
ffffffffc0201972:	b13fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201976:	00006697          	auipc	a3,0x6
ffffffffc020197a:	ac268693          	addi	a3,a3,-1342 # ffffffffc0207438 <commands+0xb78>
ffffffffc020197e:	00005617          	auipc	a2,0x5
ffffffffc0201982:	40260613          	addi	a2,a2,1026 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0201986:	11800593          	li	a1,280
ffffffffc020198a:	00006517          	auipc	a0,0x6
ffffffffc020198e:	94e50513          	addi	a0,a0,-1714 # ffffffffc02072d8 <commands+0xa18>
ffffffffc0201992:	af3fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0201996:	00006697          	auipc	a3,0x6
ffffffffc020199a:	a6268693          	addi	a3,a3,-1438 # ffffffffc02073f8 <commands+0xb38>
ffffffffc020199e:	00005617          	auipc	a2,0x5
ffffffffc02019a2:	3e260613          	addi	a2,a2,994 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc02019a6:	0c100593          	li	a1,193
ffffffffc02019aa:	00006517          	auipc	a0,0x6
ffffffffc02019ae:	92e50513          	addi	a0,a0,-1746 # ffffffffc02072d8 <commands+0xa18>
ffffffffc02019b2:	ad3fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc02019b6:	00006697          	auipc	a3,0x6
ffffffffc02019ba:	c0268693          	addi	a3,a3,-1022 # ffffffffc02075b8 <commands+0xcf8>
ffffffffc02019be:	00005617          	auipc	a2,0x5
ffffffffc02019c2:	3c260613          	addi	a2,a2,962 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc02019c6:	11200593          	li	a1,274
ffffffffc02019ca:	00006517          	auipc	a0,0x6
ffffffffc02019ce:	90e50513          	addi	a0,a0,-1778 # ffffffffc02072d8 <commands+0xa18>
ffffffffc02019d2:	ab3fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc02019d6:	00006697          	auipc	a3,0x6
ffffffffc02019da:	bc268693          	addi	a3,a3,-1086 # ffffffffc0207598 <commands+0xcd8>
ffffffffc02019de:	00005617          	auipc	a2,0x5
ffffffffc02019e2:	3a260613          	addi	a2,a2,930 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc02019e6:	11000593          	li	a1,272
ffffffffc02019ea:	00006517          	auipc	a0,0x6
ffffffffc02019ee:	8ee50513          	addi	a0,a0,-1810 # ffffffffc02072d8 <commands+0xa18>
ffffffffc02019f2:	a93fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc02019f6:	00006697          	auipc	a3,0x6
ffffffffc02019fa:	b7a68693          	addi	a3,a3,-1158 # ffffffffc0207570 <commands+0xcb0>
ffffffffc02019fe:	00005617          	auipc	a2,0x5
ffffffffc0201a02:	38260613          	addi	a2,a2,898 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0201a06:	10e00593          	li	a1,270
ffffffffc0201a0a:	00006517          	auipc	a0,0x6
ffffffffc0201a0e:	8ce50513          	addi	a0,a0,-1842 # ffffffffc02072d8 <commands+0xa18>
ffffffffc0201a12:	a73fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0201a16:	00006697          	auipc	a3,0x6
ffffffffc0201a1a:	b3268693          	addi	a3,a3,-1230 # ffffffffc0207548 <commands+0xc88>
ffffffffc0201a1e:	00005617          	auipc	a2,0x5
ffffffffc0201a22:	36260613          	addi	a2,a2,866 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0201a26:	10d00593          	li	a1,269
ffffffffc0201a2a:	00006517          	auipc	a0,0x6
ffffffffc0201a2e:	8ae50513          	addi	a0,a0,-1874 # ffffffffc02072d8 <commands+0xa18>
ffffffffc0201a32:	a53fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(p0 + 2 == p1);
ffffffffc0201a36:	00006697          	auipc	a3,0x6
ffffffffc0201a3a:	b0268693          	addi	a3,a3,-1278 # ffffffffc0207538 <commands+0xc78>
ffffffffc0201a3e:	00005617          	auipc	a2,0x5
ffffffffc0201a42:	34260613          	addi	a2,a2,834 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0201a46:	10800593          	li	a1,264
ffffffffc0201a4a:	00006517          	auipc	a0,0x6
ffffffffc0201a4e:	88e50513          	addi	a0,a0,-1906 # ffffffffc02072d8 <commands+0xa18>
ffffffffc0201a52:	a33fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201a56:	00006697          	auipc	a3,0x6
ffffffffc0201a5a:	9e268693          	addi	a3,a3,-1566 # ffffffffc0207438 <commands+0xb78>
ffffffffc0201a5e:	00005617          	auipc	a2,0x5
ffffffffc0201a62:	32260613          	addi	a2,a2,802 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0201a66:	10700593          	li	a1,263
ffffffffc0201a6a:	00006517          	auipc	a0,0x6
ffffffffc0201a6e:	86e50513          	addi	a0,a0,-1938 # ffffffffc02072d8 <commands+0xa18>
ffffffffc0201a72:	a13fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0201a76:	00006697          	auipc	a3,0x6
ffffffffc0201a7a:	aa268693          	addi	a3,a3,-1374 # ffffffffc0207518 <commands+0xc58>
ffffffffc0201a7e:	00005617          	auipc	a2,0x5
ffffffffc0201a82:	30260613          	addi	a2,a2,770 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0201a86:	10600593          	li	a1,262
ffffffffc0201a8a:	00006517          	auipc	a0,0x6
ffffffffc0201a8e:	84e50513          	addi	a0,a0,-1970 # ffffffffc02072d8 <commands+0xa18>
ffffffffc0201a92:	9f3fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0201a96:	00006697          	auipc	a3,0x6
ffffffffc0201a9a:	a5268693          	addi	a3,a3,-1454 # ffffffffc02074e8 <commands+0xc28>
ffffffffc0201a9e:	00005617          	auipc	a2,0x5
ffffffffc0201aa2:	2e260613          	addi	a2,a2,738 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0201aa6:	10500593          	li	a1,261
ffffffffc0201aaa:	00006517          	auipc	a0,0x6
ffffffffc0201aae:	82e50513          	addi	a0,a0,-2002 # ffffffffc02072d8 <commands+0xa18>
ffffffffc0201ab2:	9d3fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0201ab6:	00006697          	auipc	a3,0x6
ffffffffc0201aba:	a1a68693          	addi	a3,a3,-1510 # ffffffffc02074d0 <commands+0xc10>
ffffffffc0201abe:	00005617          	auipc	a2,0x5
ffffffffc0201ac2:	2c260613          	addi	a2,a2,706 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0201ac6:	10400593          	li	a1,260
ffffffffc0201aca:	00006517          	auipc	a0,0x6
ffffffffc0201ace:	80e50513          	addi	a0,a0,-2034 # ffffffffc02072d8 <commands+0xa18>
ffffffffc0201ad2:	9b3fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201ad6:	00006697          	auipc	a3,0x6
ffffffffc0201ada:	96268693          	addi	a3,a3,-1694 # ffffffffc0207438 <commands+0xb78>
ffffffffc0201ade:	00005617          	auipc	a2,0x5
ffffffffc0201ae2:	2a260613          	addi	a2,a2,674 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0201ae6:	0fe00593          	li	a1,254
ffffffffc0201aea:	00005517          	auipc	a0,0x5
ffffffffc0201aee:	7ee50513          	addi	a0,a0,2030 # ffffffffc02072d8 <commands+0xa18>
ffffffffc0201af2:	993fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(!PageProperty(p0));
ffffffffc0201af6:	00006697          	auipc	a3,0x6
ffffffffc0201afa:	9c268693          	addi	a3,a3,-1598 # ffffffffc02074b8 <commands+0xbf8>
ffffffffc0201afe:	00005617          	auipc	a2,0x5
ffffffffc0201b02:	28260613          	addi	a2,a2,642 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0201b06:	0f900593          	li	a1,249
ffffffffc0201b0a:	00005517          	auipc	a0,0x5
ffffffffc0201b0e:	7ce50513          	addi	a0,a0,1998 # ffffffffc02072d8 <commands+0xa18>
ffffffffc0201b12:	973fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0201b16:	00006697          	auipc	a3,0x6
ffffffffc0201b1a:	ac268693          	addi	a3,a3,-1342 # ffffffffc02075d8 <commands+0xd18>
ffffffffc0201b1e:	00005617          	auipc	a2,0x5
ffffffffc0201b22:	26260613          	addi	a2,a2,610 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0201b26:	11700593          	li	a1,279
ffffffffc0201b2a:	00005517          	auipc	a0,0x5
ffffffffc0201b2e:	7ae50513          	addi	a0,a0,1966 # ffffffffc02072d8 <commands+0xa18>
ffffffffc0201b32:	953fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(total == 0);
ffffffffc0201b36:	00006697          	auipc	a3,0x6
ffffffffc0201b3a:	ad268693          	addi	a3,a3,-1326 # ffffffffc0207608 <commands+0xd48>
ffffffffc0201b3e:	00005617          	auipc	a2,0x5
ffffffffc0201b42:	24260613          	addi	a2,a2,578 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0201b46:	12600593          	li	a1,294
ffffffffc0201b4a:	00005517          	auipc	a0,0x5
ffffffffc0201b4e:	78e50513          	addi	a0,a0,1934 # ffffffffc02072d8 <commands+0xa18>
ffffffffc0201b52:	933fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(total == nr_free_pages());
ffffffffc0201b56:	00005697          	auipc	a3,0x5
ffffffffc0201b5a:	79a68693          	addi	a3,a3,1946 # ffffffffc02072f0 <commands+0xa30>
ffffffffc0201b5e:	00005617          	auipc	a2,0x5
ffffffffc0201b62:	22260613          	addi	a2,a2,546 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0201b66:	0f300593          	li	a1,243
ffffffffc0201b6a:	00005517          	auipc	a0,0x5
ffffffffc0201b6e:	76e50513          	addi	a0,a0,1902 # ffffffffc02072d8 <commands+0xa18>
ffffffffc0201b72:	913fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201b76:	00005697          	auipc	a3,0x5
ffffffffc0201b7a:	7ba68693          	addi	a3,a3,1978 # ffffffffc0207330 <commands+0xa70>
ffffffffc0201b7e:	00005617          	auipc	a2,0x5
ffffffffc0201b82:	20260613          	addi	a2,a2,514 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0201b86:	0ba00593          	li	a1,186
ffffffffc0201b8a:	00005517          	auipc	a0,0x5
ffffffffc0201b8e:	74e50513          	addi	a0,a0,1870 # ffffffffc02072d8 <commands+0xa18>
ffffffffc0201b92:	8f3fe0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0201b96 <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc0201b96:	1141                	addi	sp,sp,-16
ffffffffc0201b98:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201b9a:	16058e63          	beqz	a1,ffffffffc0201d16 <default_free_pages+0x180>
    for (; p != base + n; p ++) {
ffffffffc0201b9e:	00659693          	slli	a3,a1,0x6
ffffffffc0201ba2:	96aa                	add	a3,a3,a0
ffffffffc0201ba4:	02d50d63          	beq	a0,a3,ffffffffc0201bde <default_free_pages+0x48>
ffffffffc0201ba8:	651c                	ld	a5,8(a0)
ffffffffc0201baa:	8b85                	andi	a5,a5,1
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0201bac:	14079563          	bnez	a5,ffffffffc0201cf6 <default_free_pages+0x160>
ffffffffc0201bb0:	651c                	ld	a5,8(a0)
ffffffffc0201bb2:	8385                	srli	a5,a5,0x1
ffffffffc0201bb4:	8b85                	andi	a5,a5,1
ffffffffc0201bb6:	14079063          	bnez	a5,ffffffffc0201cf6 <default_free_pages+0x160>
ffffffffc0201bba:	87aa                	mv	a5,a0
ffffffffc0201bbc:	a809                	j	ffffffffc0201bce <default_free_pages+0x38>
ffffffffc0201bbe:	6798                	ld	a4,8(a5)
ffffffffc0201bc0:	8b05                	andi	a4,a4,1
ffffffffc0201bc2:	12071a63          	bnez	a4,ffffffffc0201cf6 <default_free_pages+0x160>
ffffffffc0201bc6:	6798                	ld	a4,8(a5)
ffffffffc0201bc8:	8b09                	andi	a4,a4,2
ffffffffc0201bca:	12071663          	bnez	a4,ffffffffc0201cf6 <default_free_pages+0x160>
        p->flags = 0;
ffffffffc0201bce:	0007b423          	sd	zero,8(a5)
    return page->ref;
}

static inline void
set_page_ref(struct Page *page, int val) {
    page->ref = val;
ffffffffc0201bd2:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0201bd6:	04078793          	addi	a5,a5,64
ffffffffc0201bda:	fed792e3          	bne	a5,a3,ffffffffc0201bbe <default_free_pages+0x28>
    base->property = n;
ffffffffc0201bde:	2581                	sext.w	a1,a1
ffffffffc0201be0:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc0201be2:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201be6:	4789                	li	a5,2
ffffffffc0201be8:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc0201bec:	000ab697          	auipc	a3,0xab
ffffffffc0201bf0:	8cc68693          	addi	a3,a3,-1844 # ffffffffc02ac4b8 <free_area>
ffffffffc0201bf4:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0201bf6:	669c                	ld	a5,8(a3)
ffffffffc0201bf8:	9db9                	addw	a1,a1,a4
ffffffffc0201bfa:	000ab717          	auipc	a4,0xab
ffffffffc0201bfe:	8cb72723          	sw	a1,-1842(a4) # ffffffffc02ac4c8 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc0201c02:	0cd78163          	beq	a5,a3,ffffffffc0201cc4 <default_free_pages+0x12e>
            struct Page* page = le2page(le, page_link);
ffffffffc0201c06:	fe878713          	addi	a4,a5,-24
ffffffffc0201c0a:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0201c0c:	4801                	li	a6,0
ffffffffc0201c0e:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc0201c12:	00e56a63          	bltu	a0,a4,ffffffffc0201c26 <default_free_pages+0x90>
    return listelm->next;
ffffffffc0201c16:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0201c18:	04d70f63          	beq	a4,a3,ffffffffc0201c76 <default_free_pages+0xe0>
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201c1c:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201c1e:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0201c22:	fee57ae3          	bleu	a4,a0,ffffffffc0201c16 <default_free_pages+0x80>
ffffffffc0201c26:	00080663          	beqz	a6,ffffffffc0201c32 <default_free_pages+0x9c>
ffffffffc0201c2a:	000ab817          	auipc	a6,0xab
ffffffffc0201c2e:	88b83723          	sd	a1,-1906(a6) # ffffffffc02ac4b8 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201c32:	638c                	ld	a1,0(a5)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0201c34:	e390                	sd	a2,0(a5)
ffffffffc0201c36:	e590                	sd	a2,8(a1)
    elm->next = next;
ffffffffc0201c38:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201c3a:	ed0c                	sd	a1,24(a0)
    if (le != &free_list) {
ffffffffc0201c3c:	06d58a63          	beq	a1,a3,ffffffffc0201cb0 <default_free_pages+0x11a>
        if (p + p->property == base) {
ffffffffc0201c40:	ff85a603          	lw	a2,-8(a1)
        p = le2page(le, page_link);
ffffffffc0201c44:	fe858713          	addi	a4,a1,-24
        if (p + p->property == base) {
ffffffffc0201c48:	02061793          	slli	a5,a2,0x20
ffffffffc0201c4c:	83e9                	srli	a5,a5,0x1a
ffffffffc0201c4e:	97ba                	add	a5,a5,a4
ffffffffc0201c50:	04f51b63          	bne	a0,a5,ffffffffc0201ca6 <default_free_pages+0x110>
            p->property += base->property;
ffffffffc0201c54:	491c                	lw	a5,16(a0)
ffffffffc0201c56:	9e3d                	addw	a2,a2,a5
ffffffffc0201c58:	fec5ac23          	sw	a2,-8(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0201c5c:	57f5                	li	a5,-3
ffffffffc0201c5e:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201c62:	01853803          	ld	a6,24(a0)
ffffffffc0201c66:	7110                	ld	a2,32(a0)
            base = p;
ffffffffc0201c68:	853a                	mv	a0,a4
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0201c6a:	00c83423          	sd	a2,8(a6)
    next->prev = prev;
ffffffffc0201c6e:	659c                	ld	a5,8(a1)
ffffffffc0201c70:	01063023          	sd	a6,0(a2)
ffffffffc0201c74:	a815                	j	ffffffffc0201ca8 <default_free_pages+0x112>
    prev->next = next->prev = elm;
ffffffffc0201c76:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201c78:	f114                	sd	a3,32(a0)
ffffffffc0201c7a:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0201c7c:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc0201c7e:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201c80:	00d70563          	beq	a4,a3,ffffffffc0201c8a <default_free_pages+0xf4>
ffffffffc0201c84:	4805                	li	a6,1
ffffffffc0201c86:	87ba                	mv	a5,a4
ffffffffc0201c88:	bf59                	j	ffffffffc0201c1e <default_free_pages+0x88>
ffffffffc0201c8a:	e290                	sd	a2,0(a3)
    return listelm->prev;
ffffffffc0201c8c:	85be                	mv	a1,a5
    if (le != &free_list) {
ffffffffc0201c8e:	00d78d63          	beq	a5,a3,ffffffffc0201ca8 <default_free_pages+0x112>
        if (p + p->property == base) {
ffffffffc0201c92:	ff85a603          	lw	a2,-8(a1)
        p = le2page(le, page_link);
ffffffffc0201c96:	fe858713          	addi	a4,a1,-24
        if (p + p->property == base) {
ffffffffc0201c9a:	02061793          	slli	a5,a2,0x20
ffffffffc0201c9e:	83e9                	srli	a5,a5,0x1a
ffffffffc0201ca0:	97ba                	add	a5,a5,a4
ffffffffc0201ca2:	faf509e3          	beq	a0,a5,ffffffffc0201c54 <default_free_pages+0xbe>
ffffffffc0201ca6:	711c                	ld	a5,32(a0)
    if (le != &free_list) {
ffffffffc0201ca8:	fe878713          	addi	a4,a5,-24
ffffffffc0201cac:	00d78963          	beq	a5,a3,ffffffffc0201cbe <default_free_pages+0x128>
        if (base + base->property == p) {
ffffffffc0201cb0:	4910                	lw	a2,16(a0)
ffffffffc0201cb2:	02061693          	slli	a3,a2,0x20
ffffffffc0201cb6:	82e9                	srli	a3,a3,0x1a
ffffffffc0201cb8:	96aa                	add	a3,a3,a0
ffffffffc0201cba:	00d70e63          	beq	a4,a3,ffffffffc0201cd6 <default_free_pages+0x140>
}
ffffffffc0201cbe:	60a2                	ld	ra,8(sp)
ffffffffc0201cc0:	0141                	addi	sp,sp,16
ffffffffc0201cc2:	8082                	ret
ffffffffc0201cc4:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc0201cc6:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc0201cca:	e398                	sd	a4,0(a5)
ffffffffc0201ccc:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc0201cce:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201cd0:	ed1c                	sd	a5,24(a0)
}
ffffffffc0201cd2:	0141                	addi	sp,sp,16
ffffffffc0201cd4:	8082                	ret
            base->property += p->property;
ffffffffc0201cd6:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201cda:	ff078693          	addi	a3,a5,-16
ffffffffc0201cde:	9e39                	addw	a2,a2,a4
ffffffffc0201ce0:	c910                	sw	a2,16(a0)
ffffffffc0201ce2:	5775                	li	a4,-3
ffffffffc0201ce4:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201ce8:	6398                	ld	a4,0(a5)
ffffffffc0201cea:	679c                	ld	a5,8(a5)
}
ffffffffc0201cec:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc0201cee:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0201cf0:	e398                	sd	a4,0(a5)
ffffffffc0201cf2:	0141                	addi	sp,sp,16
ffffffffc0201cf4:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0201cf6:	00006697          	auipc	a3,0x6
ffffffffc0201cfa:	92268693          	addi	a3,a3,-1758 # ffffffffc0207618 <commands+0xd58>
ffffffffc0201cfe:	00005617          	auipc	a2,0x5
ffffffffc0201d02:	08260613          	addi	a2,a2,130 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0201d06:	08300593          	li	a1,131
ffffffffc0201d0a:	00005517          	auipc	a0,0x5
ffffffffc0201d0e:	5ce50513          	addi	a0,a0,1486 # ffffffffc02072d8 <commands+0xa18>
ffffffffc0201d12:	f72fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(n > 0);
ffffffffc0201d16:	00006697          	auipc	a3,0x6
ffffffffc0201d1a:	92a68693          	addi	a3,a3,-1750 # ffffffffc0207640 <commands+0xd80>
ffffffffc0201d1e:	00005617          	auipc	a2,0x5
ffffffffc0201d22:	06260613          	addi	a2,a2,98 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0201d26:	08000593          	li	a1,128
ffffffffc0201d2a:	00005517          	auipc	a0,0x5
ffffffffc0201d2e:	5ae50513          	addi	a0,a0,1454 # ffffffffc02072d8 <commands+0xa18>
ffffffffc0201d32:	f52fe0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0201d36 <default_alloc_pages>:
    assert(n > 0);
ffffffffc0201d36:	c959                	beqz	a0,ffffffffc0201dcc <default_alloc_pages+0x96>
    if (n > nr_free) {
ffffffffc0201d38:	000aa597          	auipc	a1,0xaa
ffffffffc0201d3c:	78058593          	addi	a1,a1,1920 # ffffffffc02ac4b8 <free_area>
ffffffffc0201d40:	0105a803          	lw	a6,16(a1)
ffffffffc0201d44:	862a                	mv	a2,a0
ffffffffc0201d46:	02081793          	slli	a5,a6,0x20
ffffffffc0201d4a:	9381                	srli	a5,a5,0x20
ffffffffc0201d4c:	00a7ee63          	bltu	a5,a0,ffffffffc0201d68 <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc0201d50:	87ae                	mv	a5,a1
ffffffffc0201d52:	a801                	j	ffffffffc0201d62 <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc0201d54:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201d58:	02071693          	slli	a3,a4,0x20
ffffffffc0201d5c:	9281                	srli	a3,a3,0x20
ffffffffc0201d5e:	00c6f763          	bleu	a2,a3,ffffffffc0201d6c <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc0201d62:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201d64:	feb798e3          	bne	a5,a1,ffffffffc0201d54 <default_alloc_pages+0x1e>
        return NULL;
ffffffffc0201d68:	4501                	li	a0,0
}
ffffffffc0201d6a:	8082                	ret
        struct Page *p = le2page(le, page_link);
ffffffffc0201d6c:	fe878513          	addi	a0,a5,-24
    if (page != NULL) {
ffffffffc0201d70:	dd6d                	beqz	a0,ffffffffc0201d6a <default_alloc_pages+0x34>
    return listelm->prev;
ffffffffc0201d72:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201d76:	0087b303          	ld	t1,8(a5)
    prev->next = next;
ffffffffc0201d7a:	00060e1b          	sext.w	t3,a2
ffffffffc0201d7e:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc0201d82:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc0201d86:	02d67863          	bleu	a3,a2,ffffffffc0201db6 <default_alloc_pages+0x80>
            struct Page *p = page + n;
ffffffffc0201d8a:	061a                	slli	a2,a2,0x6
ffffffffc0201d8c:	962a                	add	a2,a2,a0
            p->property = page->property - n;
ffffffffc0201d8e:	41c7073b          	subw	a4,a4,t3
ffffffffc0201d92:	ca18                	sw	a4,16(a2)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201d94:	00860693          	addi	a3,a2,8
ffffffffc0201d98:	4709                	li	a4,2
ffffffffc0201d9a:	40e6b02f          	amoor.d	zero,a4,(a3)
    __list_add(elm, listelm, listelm->next);
ffffffffc0201d9e:	0088b703          	ld	a4,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc0201da2:	01860693          	addi	a3,a2,24
    prev->next = next->prev = elm;
ffffffffc0201da6:	0105a803          	lw	a6,16(a1)
ffffffffc0201daa:	e314                	sd	a3,0(a4)
ffffffffc0201dac:	00d8b423          	sd	a3,8(a7)
    elm->next = next;
ffffffffc0201db0:	f218                	sd	a4,32(a2)
    elm->prev = prev;
ffffffffc0201db2:	01163c23          	sd	a7,24(a2)
        nr_free -= n;
ffffffffc0201db6:	41c8083b          	subw	a6,a6,t3
ffffffffc0201dba:	000aa717          	auipc	a4,0xaa
ffffffffc0201dbe:	71072723          	sw	a6,1806(a4) # ffffffffc02ac4c8 <free_area+0x10>
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0201dc2:	5775                	li	a4,-3
ffffffffc0201dc4:	17c1                	addi	a5,a5,-16
ffffffffc0201dc6:	60e7b02f          	amoand.d	zero,a4,(a5)
ffffffffc0201dca:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc0201dcc:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0201dce:	00006697          	auipc	a3,0x6
ffffffffc0201dd2:	87268693          	addi	a3,a3,-1934 # ffffffffc0207640 <commands+0xd80>
ffffffffc0201dd6:	00005617          	auipc	a2,0x5
ffffffffc0201dda:	faa60613          	addi	a2,a2,-86 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0201dde:	06200593          	li	a1,98
ffffffffc0201de2:	00005517          	auipc	a0,0x5
ffffffffc0201de6:	4f650513          	addi	a0,a0,1270 # ffffffffc02072d8 <commands+0xa18>
default_alloc_pages(size_t n) {
ffffffffc0201dea:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201dec:	e98fe0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0201df0 <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc0201df0:	1141                	addi	sp,sp,-16
ffffffffc0201df2:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201df4:	c1ed                	beqz	a1,ffffffffc0201ed6 <default_init_memmap+0xe6>
    for (; p != base + n; p ++) {
ffffffffc0201df6:	00659693          	slli	a3,a1,0x6
ffffffffc0201dfa:	96aa                	add	a3,a3,a0
ffffffffc0201dfc:	02d50463          	beq	a0,a3,ffffffffc0201e24 <default_init_memmap+0x34>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0201e00:	6518                	ld	a4,8(a0)
        assert(PageReserved(p));
ffffffffc0201e02:	87aa                	mv	a5,a0
ffffffffc0201e04:	8b05                	andi	a4,a4,1
ffffffffc0201e06:	e709                	bnez	a4,ffffffffc0201e10 <default_init_memmap+0x20>
ffffffffc0201e08:	a07d                	j	ffffffffc0201eb6 <default_init_memmap+0xc6>
ffffffffc0201e0a:	6798                	ld	a4,8(a5)
ffffffffc0201e0c:	8b05                	andi	a4,a4,1
ffffffffc0201e0e:	c745                	beqz	a4,ffffffffc0201eb6 <default_init_memmap+0xc6>
        p->flags = p->property = 0;
ffffffffc0201e10:	0007a823          	sw	zero,16(a5)
ffffffffc0201e14:	0007b423          	sd	zero,8(a5)
ffffffffc0201e18:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0201e1c:	04078793          	addi	a5,a5,64
ffffffffc0201e20:	fed795e3          	bne	a5,a3,ffffffffc0201e0a <default_init_memmap+0x1a>
    base->property = n;
ffffffffc0201e24:	2581                	sext.w	a1,a1
ffffffffc0201e26:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201e28:	4789                	li	a5,2
ffffffffc0201e2a:	00850713          	addi	a4,a0,8
ffffffffc0201e2e:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc0201e32:	000aa697          	auipc	a3,0xaa
ffffffffc0201e36:	68668693          	addi	a3,a3,1670 # ffffffffc02ac4b8 <free_area>
ffffffffc0201e3a:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0201e3c:	669c                	ld	a5,8(a3)
ffffffffc0201e3e:	9db9                	addw	a1,a1,a4
ffffffffc0201e40:	000aa717          	auipc	a4,0xaa
ffffffffc0201e44:	68b72423          	sw	a1,1672(a4) # ffffffffc02ac4c8 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc0201e48:	04d78a63          	beq	a5,a3,ffffffffc0201e9c <default_init_memmap+0xac>
            struct Page* page = le2page(le, page_link);
ffffffffc0201e4c:	fe878713          	addi	a4,a5,-24
ffffffffc0201e50:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0201e52:	4801                	li	a6,0
ffffffffc0201e54:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc0201e58:	00e56a63          	bltu	a0,a4,ffffffffc0201e6c <default_init_memmap+0x7c>
    return listelm->next;
ffffffffc0201e5c:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0201e5e:	02d70563          	beq	a4,a3,ffffffffc0201e88 <default_init_memmap+0x98>
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201e62:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201e64:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0201e68:	fee57ae3          	bleu	a4,a0,ffffffffc0201e5c <default_init_memmap+0x6c>
ffffffffc0201e6c:	00080663          	beqz	a6,ffffffffc0201e78 <default_init_memmap+0x88>
ffffffffc0201e70:	000aa717          	auipc	a4,0xaa
ffffffffc0201e74:	64b73423          	sd	a1,1608(a4) # ffffffffc02ac4b8 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201e78:	6398                	ld	a4,0(a5)
}
ffffffffc0201e7a:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0201e7c:	e390                	sd	a2,0(a5)
ffffffffc0201e7e:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0201e80:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201e82:	ed18                	sd	a4,24(a0)
ffffffffc0201e84:	0141                	addi	sp,sp,16
ffffffffc0201e86:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0201e88:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201e8a:	f114                	sd	a3,32(a0)
ffffffffc0201e8c:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0201e8e:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc0201e90:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201e92:	00d70e63          	beq	a4,a3,ffffffffc0201eae <default_init_memmap+0xbe>
ffffffffc0201e96:	4805                	li	a6,1
ffffffffc0201e98:	87ba                	mv	a5,a4
ffffffffc0201e9a:	b7e9                	j	ffffffffc0201e64 <default_init_memmap+0x74>
}
ffffffffc0201e9c:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc0201e9e:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc0201ea2:	e398                	sd	a4,0(a5)
ffffffffc0201ea4:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc0201ea6:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201ea8:	ed1c                	sd	a5,24(a0)
}
ffffffffc0201eaa:	0141                	addi	sp,sp,16
ffffffffc0201eac:	8082                	ret
ffffffffc0201eae:	60a2                	ld	ra,8(sp)
ffffffffc0201eb0:	e290                	sd	a2,0(a3)
ffffffffc0201eb2:	0141                	addi	sp,sp,16
ffffffffc0201eb4:	8082                	ret
        assert(PageReserved(p));
ffffffffc0201eb6:	00005697          	auipc	a3,0x5
ffffffffc0201eba:	79268693          	addi	a3,a3,1938 # ffffffffc0207648 <commands+0xd88>
ffffffffc0201ebe:	00005617          	auipc	a2,0x5
ffffffffc0201ec2:	ec260613          	addi	a2,a2,-318 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0201ec6:	04900593          	li	a1,73
ffffffffc0201eca:	00005517          	auipc	a0,0x5
ffffffffc0201ece:	40e50513          	addi	a0,a0,1038 # ffffffffc02072d8 <commands+0xa18>
ffffffffc0201ed2:	db2fe0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(n > 0);
ffffffffc0201ed6:	00005697          	auipc	a3,0x5
ffffffffc0201eda:	76a68693          	addi	a3,a3,1898 # ffffffffc0207640 <commands+0xd80>
ffffffffc0201ede:	00005617          	auipc	a2,0x5
ffffffffc0201ee2:	ea260613          	addi	a2,a2,-350 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0201ee6:	04600593          	li	a1,70
ffffffffc0201eea:	00005517          	auipc	a0,0x5
ffffffffc0201eee:	3ee50513          	addi	a0,a0,1006 # ffffffffc02072d8 <commands+0xa18>
ffffffffc0201ef2:	d92fe0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0201ef6 <slob_free>:
static void slob_free(void *block, int size)
{
	slob_t *cur, *b = (slob_t *)block;
	unsigned long flags;

	if (!block)
ffffffffc0201ef6:	c125                	beqz	a0,ffffffffc0201f56 <slob_free+0x60>
		return;

	if (size)
ffffffffc0201ef8:	e1a5                	bnez	a1,ffffffffc0201f58 <slob_free+0x62>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201efa:	100027f3          	csrr	a5,sstatus
ffffffffc0201efe:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0201f00:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201f02:	e3bd                	bnez	a5,ffffffffc0201f68 <slob_free+0x72>
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201f04:	0009f797          	auipc	a5,0x9f
ffffffffc0201f08:	14478793          	addi	a5,a5,324 # ffffffffc02a1048 <slobfree>
ffffffffc0201f0c:	639c                	ld	a5,0(a5)
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201f0e:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201f10:	00a7fa63          	bleu	a0,a5,ffffffffc0201f24 <slob_free+0x2e>
ffffffffc0201f14:	00e56c63          	bltu	a0,a4,ffffffffc0201f2c <slob_free+0x36>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201f18:	00e7fa63          	bleu	a4,a5,ffffffffc0201f2c <slob_free+0x36>
    return 0;
ffffffffc0201f1c:	87ba                	mv	a5,a4
ffffffffc0201f1e:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201f20:	fea7eae3          	bltu	a5,a0,ffffffffc0201f14 <slob_free+0x1e>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201f24:	fee7ece3          	bltu	a5,a4,ffffffffc0201f1c <slob_free+0x26>
ffffffffc0201f28:	fee57ae3          	bleu	a4,a0,ffffffffc0201f1c <slob_free+0x26>
			break;

	if (b + b->units == cur->next) {
ffffffffc0201f2c:	4110                	lw	a2,0(a0)
ffffffffc0201f2e:	00461693          	slli	a3,a2,0x4
ffffffffc0201f32:	96aa                	add	a3,a3,a0
ffffffffc0201f34:	08d70b63          	beq	a4,a3,ffffffffc0201fca <slob_free+0xd4>
		b->units += cur->next->units;
		b->next = cur->next->next;
	} else
		b->next = cur->next;

	if (cur + cur->units == b) {
ffffffffc0201f38:	4394                	lw	a3,0(a5)
		b->next = cur->next;
ffffffffc0201f3a:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc0201f3c:	00469713          	slli	a4,a3,0x4
ffffffffc0201f40:	973e                	add	a4,a4,a5
ffffffffc0201f42:	08e50f63          	beq	a0,a4,ffffffffc0201fe0 <slob_free+0xea>
		cur->units += b->units;
		cur->next = b->next;
	} else
		cur->next = b;
ffffffffc0201f46:	e788                	sd	a0,8(a5)

	slobfree = cur;
ffffffffc0201f48:	0009f717          	auipc	a4,0x9f
ffffffffc0201f4c:	10f73023          	sd	a5,256(a4) # ffffffffc02a1048 <slobfree>
    if (flag) {
ffffffffc0201f50:	c199                	beqz	a1,ffffffffc0201f56 <slob_free+0x60>
        intr_enable();
ffffffffc0201f52:	f02fe06f          	j	ffffffffc0200654 <intr_enable>
ffffffffc0201f56:	8082                	ret
		b->units = SLOB_UNITS(size);
ffffffffc0201f58:	05bd                	addi	a1,a1,15
ffffffffc0201f5a:	8191                	srli	a1,a1,0x4
ffffffffc0201f5c:	c10c                	sw	a1,0(a0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201f5e:	100027f3          	csrr	a5,sstatus
ffffffffc0201f62:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0201f64:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201f66:	dfd9                	beqz	a5,ffffffffc0201f04 <slob_free+0xe>
{
ffffffffc0201f68:	1101                	addi	sp,sp,-32
ffffffffc0201f6a:	e42a                	sd	a0,8(sp)
ffffffffc0201f6c:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc0201f6e:	eecfe0ef          	jal	ra,ffffffffc020065a <intr_disable>
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201f72:	0009f797          	auipc	a5,0x9f
ffffffffc0201f76:	0d678793          	addi	a5,a5,214 # ffffffffc02a1048 <slobfree>
ffffffffc0201f7a:	639c                	ld	a5,0(a5)
        return 1;
ffffffffc0201f7c:	6522                	ld	a0,8(sp)
ffffffffc0201f7e:	4585                	li	a1,1
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201f80:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201f82:	00a7fa63          	bleu	a0,a5,ffffffffc0201f96 <slob_free+0xa0>
ffffffffc0201f86:	00e56c63          	bltu	a0,a4,ffffffffc0201f9e <slob_free+0xa8>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201f8a:	00e7fa63          	bleu	a4,a5,ffffffffc0201f9e <slob_free+0xa8>
    return 0;
ffffffffc0201f8e:	87ba                	mv	a5,a4
ffffffffc0201f90:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201f92:	fea7eae3          	bltu	a5,a0,ffffffffc0201f86 <slob_free+0x90>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201f96:	fee7ece3          	bltu	a5,a4,ffffffffc0201f8e <slob_free+0x98>
ffffffffc0201f9a:	fee57ae3          	bleu	a4,a0,ffffffffc0201f8e <slob_free+0x98>
	if (b + b->units == cur->next) {
ffffffffc0201f9e:	4110                	lw	a2,0(a0)
ffffffffc0201fa0:	00461693          	slli	a3,a2,0x4
ffffffffc0201fa4:	96aa                	add	a3,a3,a0
ffffffffc0201fa6:	04d70763          	beq	a4,a3,ffffffffc0201ff4 <slob_free+0xfe>
		b->next = cur->next;
ffffffffc0201faa:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc0201fac:	4394                	lw	a3,0(a5)
ffffffffc0201fae:	00469713          	slli	a4,a3,0x4
ffffffffc0201fb2:	973e                	add	a4,a4,a5
ffffffffc0201fb4:	04e50663          	beq	a0,a4,ffffffffc0202000 <slob_free+0x10a>
		cur->next = b;
ffffffffc0201fb8:	e788                	sd	a0,8(a5)
	slobfree = cur;
ffffffffc0201fba:	0009f717          	auipc	a4,0x9f
ffffffffc0201fbe:	08f73723          	sd	a5,142(a4) # ffffffffc02a1048 <slobfree>
    if (flag) {
ffffffffc0201fc2:	e58d                	bnez	a1,ffffffffc0201fec <slob_free+0xf6>

	spin_unlock_irqrestore(&slob_lock, flags);
}
ffffffffc0201fc4:	60e2                	ld	ra,24(sp)
ffffffffc0201fc6:	6105                	addi	sp,sp,32
ffffffffc0201fc8:	8082                	ret
		b->units += cur->next->units;
ffffffffc0201fca:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc0201fcc:	6718                	ld	a4,8(a4)
		b->units += cur->next->units;
ffffffffc0201fce:	9e35                	addw	a2,a2,a3
ffffffffc0201fd0:	c110                	sw	a2,0(a0)
	if (cur + cur->units == b) {
ffffffffc0201fd2:	4394                	lw	a3,0(a5)
		b->next = cur->next->next;
ffffffffc0201fd4:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc0201fd6:	00469713          	slli	a4,a3,0x4
ffffffffc0201fda:	973e                	add	a4,a4,a5
ffffffffc0201fdc:	f6e515e3          	bne	a0,a4,ffffffffc0201f46 <slob_free+0x50>
		cur->units += b->units;
ffffffffc0201fe0:	4118                	lw	a4,0(a0)
		cur->next = b->next;
ffffffffc0201fe2:	6510                	ld	a2,8(a0)
		cur->units += b->units;
ffffffffc0201fe4:	9eb9                	addw	a3,a3,a4
ffffffffc0201fe6:	c394                	sw	a3,0(a5)
		cur->next = b->next;
ffffffffc0201fe8:	e790                	sd	a2,8(a5)
ffffffffc0201fea:	bfb9                	j	ffffffffc0201f48 <slob_free+0x52>
}
ffffffffc0201fec:	60e2                	ld	ra,24(sp)
ffffffffc0201fee:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201ff0:	e64fe06f          	j	ffffffffc0200654 <intr_enable>
		b->units += cur->next->units;
ffffffffc0201ff4:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc0201ff6:	6718                	ld	a4,8(a4)
		b->units += cur->next->units;
ffffffffc0201ff8:	9e35                	addw	a2,a2,a3
ffffffffc0201ffa:	c110                	sw	a2,0(a0)
		b->next = cur->next->next;
ffffffffc0201ffc:	e518                	sd	a4,8(a0)
ffffffffc0201ffe:	b77d                	j	ffffffffc0201fac <slob_free+0xb6>
		cur->units += b->units;
ffffffffc0202000:	4118                	lw	a4,0(a0)
		cur->next = b->next;
ffffffffc0202002:	6510                	ld	a2,8(a0)
		cur->units += b->units;
ffffffffc0202004:	9eb9                	addw	a3,a3,a4
ffffffffc0202006:	c394                	sw	a3,0(a5)
		cur->next = b->next;
ffffffffc0202008:	e790                	sd	a2,8(a5)
ffffffffc020200a:	bf45                	j	ffffffffc0201fba <slob_free+0xc4>

ffffffffc020200c <__slob_get_free_pages.isra.0>:
  struct Page * page = alloc_pages(1 << order);
ffffffffc020200c:	4785                	li	a5,1
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc020200e:	1141                	addi	sp,sp,-16
  struct Page * page = alloc_pages(1 << order);
ffffffffc0202010:	00a7953b          	sllw	a0,a5,a0
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0202014:	e406                	sd	ra,8(sp)
  struct Page * page = alloc_pages(1 << order);
ffffffffc0202016:	38e000ef          	jal	ra,ffffffffc02023a4 <alloc_pages>
  if(!page)
ffffffffc020201a:	c139                	beqz	a0,ffffffffc0202060 <__slob_get_free_pages.isra.0+0x54>
    return page - pages + nbase;
ffffffffc020201c:	000aa797          	auipc	a5,0xaa
ffffffffc0202020:	4cc78793          	addi	a5,a5,1228 # ffffffffc02ac4e8 <pages>
ffffffffc0202024:	6394                	ld	a3,0(a5)
ffffffffc0202026:	00007797          	auipc	a5,0x7
ffffffffc020202a:	e6a78793          	addi	a5,a5,-406 # ffffffffc0208e90 <nbase>
    return KADDR(page2pa(page));
ffffffffc020202e:	000aa717          	auipc	a4,0xaa
ffffffffc0202032:	44a70713          	addi	a4,a4,1098 # ffffffffc02ac478 <npage>
    return page - pages + nbase;
ffffffffc0202036:	40d506b3          	sub	a3,a0,a3
ffffffffc020203a:	6388                	ld	a0,0(a5)
ffffffffc020203c:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc020203e:	57fd                	li	a5,-1
ffffffffc0202040:	6318                	ld	a4,0(a4)
    return page - pages + nbase;
ffffffffc0202042:	96aa                	add	a3,a3,a0
    return KADDR(page2pa(page));
ffffffffc0202044:	83b1                	srli	a5,a5,0xc
ffffffffc0202046:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0202048:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020204a:	00e7ff63          	bleu	a4,a5,ffffffffc0202068 <__slob_get_free_pages.isra.0+0x5c>
ffffffffc020204e:	000aa797          	auipc	a5,0xaa
ffffffffc0202052:	48a78793          	addi	a5,a5,1162 # ffffffffc02ac4d8 <va_pa_offset>
ffffffffc0202056:	6388                	ld	a0,0(a5)
}
ffffffffc0202058:	60a2                	ld	ra,8(sp)
ffffffffc020205a:	9536                	add	a0,a0,a3
ffffffffc020205c:	0141                	addi	sp,sp,16
ffffffffc020205e:	8082                	ret
ffffffffc0202060:	60a2                	ld	ra,8(sp)
    return NULL;
ffffffffc0202062:	4501                	li	a0,0
}
ffffffffc0202064:	0141                	addi	sp,sp,16
ffffffffc0202066:	8082                	ret
ffffffffc0202068:	00005617          	auipc	a2,0x5
ffffffffc020206c:	0d060613          	addi	a2,a2,208 # ffffffffc0207138 <commands+0x878>
ffffffffc0202070:	06a00593          	li	a1,106
ffffffffc0202074:	00005517          	auipc	a0,0x5
ffffffffc0202078:	1d450513          	addi	a0,a0,468 # ffffffffc0207248 <commands+0x988>
ffffffffc020207c:	c08fe0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0202080 <slob_alloc.isra.1.constprop.3>:
static void *slob_alloc(size_t size, gfp_t gfp, int align)
ffffffffc0202080:	7179                	addi	sp,sp,-48
ffffffffc0202082:	f406                	sd	ra,40(sp)
ffffffffc0202084:	f022                	sd	s0,32(sp)
ffffffffc0202086:	ec26                	sd	s1,24(sp)
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc0202088:	01050713          	addi	a4,a0,16
ffffffffc020208c:	6785                	lui	a5,0x1
ffffffffc020208e:	0cf77b63          	bleu	a5,a4,ffffffffc0202164 <slob_alloc.isra.1.constprop.3+0xe4>
	int delta = 0, units = SLOB_UNITS(size);
ffffffffc0202092:	00f50413          	addi	s0,a0,15
ffffffffc0202096:	8011                	srli	s0,s0,0x4
ffffffffc0202098:	2401                	sext.w	s0,s0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020209a:	10002673          	csrr	a2,sstatus
ffffffffc020209e:	8a09                	andi	a2,a2,2
ffffffffc02020a0:	ea5d                	bnez	a2,ffffffffc0202156 <slob_alloc.isra.1.constprop.3+0xd6>
	prev = slobfree;
ffffffffc02020a2:	0009f497          	auipc	s1,0x9f
ffffffffc02020a6:	fa648493          	addi	s1,s1,-90 # ffffffffc02a1048 <slobfree>
ffffffffc02020aa:	6094                	ld	a3,0(s1)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc02020ac:	669c                	ld	a5,8(a3)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc02020ae:	4398                	lw	a4,0(a5)
ffffffffc02020b0:	0a875763          	ble	s0,a4,ffffffffc020215e <slob_alloc.isra.1.constprop.3+0xde>
		if (cur == slobfree) {
ffffffffc02020b4:	00f68a63          	beq	a3,a5,ffffffffc02020c8 <slob_alloc.isra.1.constprop.3+0x48>
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc02020b8:	6788                	ld	a0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc02020ba:	4118                	lw	a4,0(a0)
ffffffffc02020bc:	02875763          	ble	s0,a4,ffffffffc02020ea <slob_alloc.isra.1.constprop.3+0x6a>
ffffffffc02020c0:	6094                	ld	a3,0(s1)
ffffffffc02020c2:	87aa                	mv	a5,a0
		if (cur == slobfree) {
ffffffffc02020c4:	fef69ae3          	bne	a3,a5,ffffffffc02020b8 <slob_alloc.isra.1.constprop.3+0x38>
    if (flag) {
ffffffffc02020c8:	ea39                	bnez	a2,ffffffffc020211e <slob_alloc.isra.1.constprop.3+0x9e>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc02020ca:	4501                	li	a0,0
ffffffffc02020cc:	f41ff0ef          	jal	ra,ffffffffc020200c <__slob_get_free_pages.isra.0>
			if (!cur)
ffffffffc02020d0:	cd29                	beqz	a0,ffffffffc020212a <slob_alloc.isra.1.constprop.3+0xaa>
			slob_free(cur, PAGE_SIZE);
ffffffffc02020d2:	6585                	lui	a1,0x1
ffffffffc02020d4:	e23ff0ef          	jal	ra,ffffffffc0201ef6 <slob_free>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02020d8:	10002673          	csrr	a2,sstatus
ffffffffc02020dc:	8a09                	andi	a2,a2,2
ffffffffc02020de:	ea1d                	bnez	a2,ffffffffc0202114 <slob_alloc.isra.1.constprop.3+0x94>
			cur = slobfree;
ffffffffc02020e0:	609c                	ld	a5,0(s1)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc02020e2:	6788                	ld	a0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc02020e4:	4118                	lw	a4,0(a0)
ffffffffc02020e6:	fc874de3          	blt	a4,s0,ffffffffc02020c0 <slob_alloc.isra.1.constprop.3+0x40>
			if (cur->units == units) /* exact fit? */
ffffffffc02020ea:	04e40663          	beq	s0,a4,ffffffffc0202136 <slob_alloc.isra.1.constprop.3+0xb6>
				prev->next = cur + units;
ffffffffc02020ee:	00441693          	slli	a3,s0,0x4
ffffffffc02020f2:	96aa                	add	a3,a3,a0
ffffffffc02020f4:	e794                	sd	a3,8(a5)
				prev->next->next = cur->next;
ffffffffc02020f6:	650c                	ld	a1,8(a0)
				prev->next->units = cur->units - units;
ffffffffc02020f8:	9f01                	subw	a4,a4,s0
ffffffffc02020fa:	c298                	sw	a4,0(a3)
				prev->next->next = cur->next;
ffffffffc02020fc:	e68c                	sd	a1,8(a3)
				cur->units = units;
ffffffffc02020fe:	c100                	sw	s0,0(a0)
			slobfree = prev;
ffffffffc0202100:	0009f717          	auipc	a4,0x9f
ffffffffc0202104:	f4f73423          	sd	a5,-184(a4) # ffffffffc02a1048 <slobfree>
    if (flag) {
ffffffffc0202108:	ee15                	bnez	a2,ffffffffc0202144 <slob_alloc.isra.1.constprop.3+0xc4>
}
ffffffffc020210a:	70a2                	ld	ra,40(sp)
ffffffffc020210c:	7402                	ld	s0,32(sp)
ffffffffc020210e:	64e2                	ld	s1,24(sp)
ffffffffc0202110:	6145                	addi	sp,sp,48
ffffffffc0202112:	8082                	ret
        intr_disable();
ffffffffc0202114:	d46fe0ef          	jal	ra,ffffffffc020065a <intr_disable>
ffffffffc0202118:	4605                	li	a2,1
			cur = slobfree;
ffffffffc020211a:	609c                	ld	a5,0(s1)
ffffffffc020211c:	b7d9                	j	ffffffffc02020e2 <slob_alloc.isra.1.constprop.3+0x62>
        intr_enable();
ffffffffc020211e:	d36fe0ef          	jal	ra,ffffffffc0200654 <intr_enable>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc0202122:	4501                	li	a0,0
ffffffffc0202124:	ee9ff0ef          	jal	ra,ffffffffc020200c <__slob_get_free_pages.isra.0>
			if (!cur)
ffffffffc0202128:	f54d                	bnez	a0,ffffffffc02020d2 <slob_alloc.isra.1.constprop.3+0x52>
}
ffffffffc020212a:	70a2                	ld	ra,40(sp)
ffffffffc020212c:	7402                	ld	s0,32(sp)
ffffffffc020212e:	64e2                	ld	s1,24(sp)
				return 0;
ffffffffc0202130:	4501                	li	a0,0
}
ffffffffc0202132:	6145                	addi	sp,sp,48
ffffffffc0202134:	8082                	ret
				prev->next = cur->next; /* unlink */
ffffffffc0202136:	6518                	ld	a4,8(a0)
ffffffffc0202138:	e798                	sd	a4,8(a5)
			slobfree = prev;
ffffffffc020213a:	0009f717          	auipc	a4,0x9f
ffffffffc020213e:	f0f73723          	sd	a5,-242(a4) # ffffffffc02a1048 <slobfree>
    if (flag) {
ffffffffc0202142:	d661                	beqz	a2,ffffffffc020210a <slob_alloc.isra.1.constprop.3+0x8a>
ffffffffc0202144:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0202146:	d0efe0ef          	jal	ra,ffffffffc0200654 <intr_enable>
}
ffffffffc020214a:	70a2                	ld	ra,40(sp)
ffffffffc020214c:	7402                	ld	s0,32(sp)
ffffffffc020214e:	6522                	ld	a0,8(sp)
ffffffffc0202150:	64e2                	ld	s1,24(sp)
ffffffffc0202152:	6145                	addi	sp,sp,48
ffffffffc0202154:	8082                	ret
        intr_disable();
ffffffffc0202156:	d04fe0ef          	jal	ra,ffffffffc020065a <intr_disable>
ffffffffc020215a:	4605                	li	a2,1
ffffffffc020215c:	b799                	j	ffffffffc02020a2 <slob_alloc.isra.1.constprop.3+0x22>
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc020215e:	853e                	mv	a0,a5
ffffffffc0202160:	87b6                	mv	a5,a3
ffffffffc0202162:	b761                	j	ffffffffc02020ea <slob_alloc.isra.1.constprop.3+0x6a>
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc0202164:	00005697          	auipc	a3,0x5
ffffffffc0202168:	56468693          	addi	a3,a3,1380 # ffffffffc02076c8 <default_pmm_manager+0x70>
ffffffffc020216c:	00005617          	auipc	a2,0x5
ffffffffc0202170:	c1460613          	addi	a2,a2,-1004 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0202174:	06400593          	li	a1,100
ffffffffc0202178:	00005517          	auipc	a0,0x5
ffffffffc020217c:	57050513          	addi	a0,a0,1392 # ffffffffc02076e8 <default_pmm_manager+0x90>
ffffffffc0202180:	b04fe0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0202184 <kmalloc_init>:
slob_init(void) {
  cprintf("use SLOB allocator\n");
}

inline void 
kmalloc_init(void) {
ffffffffc0202184:	1141                	addi	sp,sp,-16
  cprintf("use SLOB allocator\n");
ffffffffc0202186:	00005517          	auipc	a0,0x5
ffffffffc020218a:	57a50513          	addi	a0,a0,1402 # ffffffffc0207700 <default_pmm_manager+0xa8>
kmalloc_init(void) {
ffffffffc020218e:	e406                	sd	ra,8(sp)
  cprintf("use SLOB allocator\n");
ffffffffc0202190:	ffffd0ef          	jal	ra,ffffffffc020018e <cprintf>
    slob_init();
    cprintf("kmalloc_init() succeeded!\n");
}
ffffffffc0202194:	60a2                	ld	ra,8(sp)
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc0202196:	00005517          	auipc	a0,0x5
ffffffffc020219a:	51250513          	addi	a0,a0,1298 # ffffffffc02076a8 <default_pmm_manager+0x50>
}
ffffffffc020219e:	0141                	addi	sp,sp,16
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc02021a0:	feffd06f          	j	ffffffffc020018e <cprintf>

ffffffffc02021a4 <kallocated>:
}

size_t
kallocated(void) {
   return slob_allocated();
}
ffffffffc02021a4:	4501                	li	a0,0
ffffffffc02021a6:	8082                	ret

ffffffffc02021a8 <kmalloc>:
	return 0;
}

void *
kmalloc(size_t size)
{
ffffffffc02021a8:	1101                	addi	sp,sp,-32
ffffffffc02021aa:	e04a                	sd	s2,0(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc02021ac:	6905                	lui	s2,0x1
{
ffffffffc02021ae:	e822                	sd	s0,16(sp)
ffffffffc02021b0:	ec06                	sd	ra,24(sp)
ffffffffc02021b2:	e426                	sd	s1,8(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc02021b4:	fef90793          	addi	a5,s2,-17 # fef <_binary_obj___user_faultread_out_size-0x8581>
{
ffffffffc02021b8:	842a                	mv	s0,a0
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc02021ba:	04a7fc63          	bleu	a0,a5,ffffffffc0202212 <kmalloc+0x6a>
	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
ffffffffc02021be:	4561                	li	a0,24
ffffffffc02021c0:	ec1ff0ef          	jal	ra,ffffffffc0202080 <slob_alloc.isra.1.constprop.3>
ffffffffc02021c4:	84aa                	mv	s1,a0
	if (!bb)
ffffffffc02021c6:	cd21                	beqz	a0,ffffffffc020221e <kmalloc+0x76>
	bb->order = find_order(size);
ffffffffc02021c8:	0004079b          	sext.w	a5,s0
	int order = 0;
ffffffffc02021cc:	4501                	li	a0,0
	for ( ; size > 4096 ; size >>=1)
ffffffffc02021ce:	00f95763          	ble	a5,s2,ffffffffc02021dc <kmalloc+0x34>
ffffffffc02021d2:	6705                	lui	a4,0x1
ffffffffc02021d4:	8785                	srai	a5,a5,0x1
		order++;
ffffffffc02021d6:	2505                	addiw	a0,a0,1
	for ( ; size > 4096 ; size >>=1)
ffffffffc02021d8:	fef74ee3          	blt	a4,a5,ffffffffc02021d4 <kmalloc+0x2c>
	bb->order = find_order(size);
ffffffffc02021dc:	c088                	sw	a0,0(s1)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
ffffffffc02021de:	e2fff0ef          	jal	ra,ffffffffc020200c <__slob_get_free_pages.isra.0>
ffffffffc02021e2:	e488                	sd	a0,8(s1)
ffffffffc02021e4:	842a                	mv	s0,a0
	if (bb->pages) {
ffffffffc02021e6:	c935                	beqz	a0,ffffffffc020225a <kmalloc+0xb2>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02021e8:	100027f3          	csrr	a5,sstatus
ffffffffc02021ec:	8b89                	andi	a5,a5,2
ffffffffc02021ee:	e3a1                	bnez	a5,ffffffffc020222e <kmalloc+0x86>
		bb->next = bigblocks;
ffffffffc02021f0:	000aa797          	auipc	a5,0xaa
ffffffffc02021f4:	27878793          	addi	a5,a5,632 # ffffffffc02ac468 <bigblocks>
ffffffffc02021f8:	639c                	ld	a5,0(a5)
		bigblocks = bb;
ffffffffc02021fa:	000aa717          	auipc	a4,0xaa
ffffffffc02021fe:	26973723          	sd	s1,622(a4) # ffffffffc02ac468 <bigblocks>
		bb->next = bigblocks;
ffffffffc0202202:	e89c                	sd	a5,16(s1)
  return __kmalloc(size, 0);
}
ffffffffc0202204:	8522                	mv	a0,s0
ffffffffc0202206:	60e2                	ld	ra,24(sp)
ffffffffc0202208:	6442                	ld	s0,16(sp)
ffffffffc020220a:	64a2                	ld	s1,8(sp)
ffffffffc020220c:	6902                	ld	s2,0(sp)
ffffffffc020220e:	6105                	addi	sp,sp,32
ffffffffc0202210:	8082                	ret
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
ffffffffc0202212:	0541                	addi	a0,a0,16
ffffffffc0202214:	e6dff0ef          	jal	ra,ffffffffc0202080 <slob_alloc.isra.1.constprop.3>
		return m ? (void *)(m + 1) : 0;
ffffffffc0202218:	01050413          	addi	s0,a0,16
ffffffffc020221c:	f565                	bnez	a0,ffffffffc0202204 <kmalloc+0x5c>
ffffffffc020221e:	4401                	li	s0,0
}
ffffffffc0202220:	8522                	mv	a0,s0
ffffffffc0202222:	60e2                	ld	ra,24(sp)
ffffffffc0202224:	6442                	ld	s0,16(sp)
ffffffffc0202226:	64a2                	ld	s1,8(sp)
ffffffffc0202228:	6902                	ld	s2,0(sp)
ffffffffc020222a:	6105                	addi	sp,sp,32
ffffffffc020222c:	8082                	ret
        intr_disable();
ffffffffc020222e:	c2cfe0ef          	jal	ra,ffffffffc020065a <intr_disable>
		bb->next = bigblocks;
ffffffffc0202232:	000aa797          	auipc	a5,0xaa
ffffffffc0202236:	23678793          	addi	a5,a5,566 # ffffffffc02ac468 <bigblocks>
ffffffffc020223a:	639c                	ld	a5,0(a5)
		bigblocks = bb;
ffffffffc020223c:	000aa717          	auipc	a4,0xaa
ffffffffc0202240:	22973623          	sd	s1,556(a4) # ffffffffc02ac468 <bigblocks>
		bb->next = bigblocks;
ffffffffc0202244:	e89c                	sd	a5,16(s1)
        intr_enable();
ffffffffc0202246:	c0efe0ef          	jal	ra,ffffffffc0200654 <intr_enable>
ffffffffc020224a:	6480                	ld	s0,8(s1)
}
ffffffffc020224c:	60e2                	ld	ra,24(sp)
ffffffffc020224e:	64a2                	ld	s1,8(sp)
ffffffffc0202250:	8522                	mv	a0,s0
ffffffffc0202252:	6442                	ld	s0,16(sp)
ffffffffc0202254:	6902                	ld	s2,0(sp)
ffffffffc0202256:	6105                	addi	sp,sp,32
ffffffffc0202258:	8082                	ret
	slob_free(bb, sizeof(bigblock_t));
ffffffffc020225a:	45e1                	li	a1,24
ffffffffc020225c:	8526                	mv	a0,s1
ffffffffc020225e:	c99ff0ef          	jal	ra,ffffffffc0201ef6 <slob_free>
  return __kmalloc(size, 0);
ffffffffc0202262:	b74d                	j	ffffffffc0202204 <kmalloc+0x5c>

ffffffffc0202264 <kfree>:
void kfree(void *block)
{
	bigblock_t *bb, **last = &bigblocks;
	unsigned long flags;

	if (!block)
ffffffffc0202264:	c175                	beqz	a0,ffffffffc0202348 <kfree+0xe4>
{
ffffffffc0202266:	1101                	addi	sp,sp,-32
ffffffffc0202268:	e426                	sd	s1,8(sp)
ffffffffc020226a:	ec06                	sd	ra,24(sp)
ffffffffc020226c:	e822                	sd	s0,16(sp)
		return;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
ffffffffc020226e:	03451793          	slli	a5,a0,0x34
ffffffffc0202272:	84aa                	mv	s1,a0
ffffffffc0202274:	eb8d                	bnez	a5,ffffffffc02022a6 <kfree+0x42>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202276:	100027f3          	csrr	a5,sstatus
ffffffffc020227a:	8b89                	andi	a5,a5,2
ffffffffc020227c:	efc9                	bnez	a5,ffffffffc0202316 <kfree+0xb2>
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc020227e:	000aa797          	auipc	a5,0xaa
ffffffffc0202282:	1ea78793          	addi	a5,a5,490 # ffffffffc02ac468 <bigblocks>
ffffffffc0202286:	6394                	ld	a3,0(a5)
ffffffffc0202288:	ce99                	beqz	a3,ffffffffc02022a6 <kfree+0x42>
			if (bb->pages == block) {
ffffffffc020228a:	669c                	ld	a5,8(a3)
ffffffffc020228c:	6a80                	ld	s0,16(a3)
ffffffffc020228e:	0af50e63          	beq	a0,a5,ffffffffc020234a <kfree+0xe6>
    return 0;
ffffffffc0202292:	4601                	li	a2,0
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0202294:	c801                	beqz	s0,ffffffffc02022a4 <kfree+0x40>
			if (bb->pages == block) {
ffffffffc0202296:	6418                	ld	a4,8(s0)
ffffffffc0202298:	681c                	ld	a5,16(s0)
ffffffffc020229a:	00970f63          	beq	a4,s1,ffffffffc02022b8 <kfree+0x54>
ffffffffc020229e:	86a2                	mv	a3,s0
ffffffffc02022a0:	843e                	mv	s0,a5
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc02022a2:	f875                	bnez	s0,ffffffffc0202296 <kfree+0x32>
    if (flag) {
ffffffffc02022a4:	e659                	bnez	a2,ffffffffc0202332 <kfree+0xce>
		spin_unlock_irqrestore(&block_lock, flags);
	}

	slob_free((slob_t *)block - 1, 0);
	return;
}
ffffffffc02022a6:	6442                	ld	s0,16(sp)
ffffffffc02022a8:	60e2                	ld	ra,24(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc02022aa:	ff048513          	addi	a0,s1,-16
}
ffffffffc02022ae:	64a2                	ld	s1,8(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc02022b0:	4581                	li	a1,0
}
ffffffffc02022b2:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc02022b4:	c43ff06f          	j	ffffffffc0201ef6 <slob_free>
				*last = bb->next;
ffffffffc02022b8:	ea9c                	sd	a5,16(a3)
ffffffffc02022ba:	e641                	bnez	a2,ffffffffc0202342 <kfree+0xde>
    return pa2page(PADDR(kva));
ffffffffc02022bc:	c02007b7          	lui	a5,0xc0200
				__slob_free_pages((unsigned long)block, bb->order);
ffffffffc02022c0:	4018                	lw	a4,0(s0)
ffffffffc02022c2:	08f4ea63          	bltu	s1,a5,ffffffffc0202356 <kfree+0xf2>
ffffffffc02022c6:	000aa797          	auipc	a5,0xaa
ffffffffc02022ca:	21278793          	addi	a5,a5,530 # ffffffffc02ac4d8 <va_pa_offset>
ffffffffc02022ce:	6394                	ld	a3,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc02022d0:	000aa797          	auipc	a5,0xaa
ffffffffc02022d4:	1a878793          	addi	a5,a5,424 # ffffffffc02ac478 <npage>
ffffffffc02022d8:	639c                	ld	a5,0(a5)
    return pa2page(PADDR(kva));
ffffffffc02022da:	8c95                	sub	s1,s1,a3
    if (PPN(pa) >= npage) {
ffffffffc02022dc:	80b1                	srli	s1,s1,0xc
ffffffffc02022de:	08f4f963          	bleu	a5,s1,ffffffffc0202370 <kfree+0x10c>
    return &pages[PPN(pa) - nbase];
ffffffffc02022e2:	00007797          	auipc	a5,0x7
ffffffffc02022e6:	bae78793          	addi	a5,a5,-1106 # ffffffffc0208e90 <nbase>
ffffffffc02022ea:	639c                	ld	a5,0(a5)
ffffffffc02022ec:	000aa697          	auipc	a3,0xaa
ffffffffc02022f0:	1fc68693          	addi	a3,a3,508 # ffffffffc02ac4e8 <pages>
ffffffffc02022f4:	6288                	ld	a0,0(a3)
ffffffffc02022f6:	8c9d                	sub	s1,s1,a5
ffffffffc02022f8:	049a                	slli	s1,s1,0x6
  free_pages(kva2page(kva), 1 << order);
ffffffffc02022fa:	4585                	li	a1,1
ffffffffc02022fc:	9526                	add	a0,a0,s1
ffffffffc02022fe:	00e595bb          	sllw	a1,a1,a4
ffffffffc0202302:	12a000ef          	jal	ra,ffffffffc020242c <free_pages>
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0202306:	8522                	mv	a0,s0
}
ffffffffc0202308:	6442                	ld	s0,16(sp)
ffffffffc020230a:	60e2                	ld	ra,24(sp)
ffffffffc020230c:	64a2                	ld	s1,8(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc020230e:	45e1                	li	a1,24
}
ffffffffc0202310:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0202312:	be5ff06f          	j	ffffffffc0201ef6 <slob_free>
        intr_disable();
ffffffffc0202316:	b44fe0ef          	jal	ra,ffffffffc020065a <intr_disable>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc020231a:	000aa797          	auipc	a5,0xaa
ffffffffc020231e:	14e78793          	addi	a5,a5,334 # ffffffffc02ac468 <bigblocks>
ffffffffc0202322:	6394                	ld	a3,0(a5)
ffffffffc0202324:	c699                	beqz	a3,ffffffffc0202332 <kfree+0xce>
			if (bb->pages == block) {
ffffffffc0202326:	669c                	ld	a5,8(a3)
ffffffffc0202328:	6a80                	ld	s0,16(a3)
ffffffffc020232a:	00f48763          	beq	s1,a5,ffffffffc0202338 <kfree+0xd4>
        return 1;
ffffffffc020232e:	4605                	li	a2,1
ffffffffc0202330:	b795                	j	ffffffffc0202294 <kfree+0x30>
        intr_enable();
ffffffffc0202332:	b22fe0ef          	jal	ra,ffffffffc0200654 <intr_enable>
ffffffffc0202336:	bf85                	j	ffffffffc02022a6 <kfree+0x42>
				*last = bb->next;
ffffffffc0202338:	000aa797          	auipc	a5,0xaa
ffffffffc020233c:	1287b823          	sd	s0,304(a5) # ffffffffc02ac468 <bigblocks>
ffffffffc0202340:	8436                	mv	s0,a3
ffffffffc0202342:	b12fe0ef          	jal	ra,ffffffffc0200654 <intr_enable>
ffffffffc0202346:	bf9d                	j	ffffffffc02022bc <kfree+0x58>
ffffffffc0202348:	8082                	ret
ffffffffc020234a:	000aa797          	auipc	a5,0xaa
ffffffffc020234e:	1087bf23          	sd	s0,286(a5) # ffffffffc02ac468 <bigblocks>
ffffffffc0202352:	8436                	mv	s0,a3
ffffffffc0202354:	b7a5                	j	ffffffffc02022bc <kfree+0x58>
    return pa2page(PADDR(kva));
ffffffffc0202356:	86a6                	mv	a3,s1
ffffffffc0202358:	00005617          	auipc	a2,0x5
ffffffffc020235c:	e3060613          	addi	a2,a2,-464 # ffffffffc0207188 <commands+0x8c8>
ffffffffc0202360:	06f00593          	li	a1,111
ffffffffc0202364:	00005517          	auipc	a0,0x5
ffffffffc0202368:	ee450513          	addi	a0,a0,-284 # ffffffffc0207248 <commands+0x988>
ffffffffc020236c:	918fe0ef          	jal	ra,ffffffffc0200484 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0202370:	00005617          	auipc	a2,0x5
ffffffffc0202374:	eb860613          	addi	a2,a2,-328 # ffffffffc0207228 <commands+0x968>
ffffffffc0202378:	06300593          	li	a1,99
ffffffffc020237c:	00005517          	auipc	a0,0x5
ffffffffc0202380:	ecc50513          	addi	a0,a0,-308 # ffffffffc0207248 <commands+0x988>
ffffffffc0202384:	900fe0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0202388 <pa2page.part.4>:
pa2page(uintptr_t pa) {
ffffffffc0202388:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc020238a:	00005617          	auipc	a2,0x5
ffffffffc020238e:	e9e60613          	addi	a2,a2,-354 # ffffffffc0207228 <commands+0x968>
ffffffffc0202392:	06300593          	li	a1,99
ffffffffc0202396:	00005517          	auipc	a0,0x5
ffffffffc020239a:	eb250513          	addi	a0,a0,-334 # ffffffffc0207248 <commands+0x988>
pa2page(uintptr_t pa) {
ffffffffc020239e:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc02023a0:	8e4fe0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc02023a4 <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
ffffffffc02023a4:	715d                	addi	sp,sp,-80
ffffffffc02023a6:	e0a2                	sd	s0,64(sp)
ffffffffc02023a8:	fc26                	sd	s1,56(sp)
ffffffffc02023aa:	f84a                	sd	s2,48(sp)
ffffffffc02023ac:	f44e                	sd	s3,40(sp)
ffffffffc02023ae:	f052                	sd	s4,32(sp)
ffffffffc02023b0:	ec56                	sd	s5,24(sp)
ffffffffc02023b2:	e486                	sd	ra,72(sp)
ffffffffc02023b4:	842a                	mv	s0,a0
ffffffffc02023b6:	000aa497          	auipc	s1,0xaa
ffffffffc02023ba:	11a48493          	addi	s1,s1,282 # ffffffffc02ac4d0 <pmm_manager>
        {
            page = pmm_manager->alloc_pages(n);
        }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc02023be:	4985                	li	s3,1
ffffffffc02023c0:	000aaa17          	auipc	s4,0xaa
ffffffffc02023c4:	0c8a0a13          	addi	s4,s4,200 # ffffffffc02ac488 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc02023c8:	0005091b          	sext.w	s2,a0
ffffffffc02023cc:	000aaa97          	auipc	s5,0xaa
ffffffffc02023d0:	1fca8a93          	addi	s5,s5,508 # ffffffffc02ac5c8 <check_mm_struct>
ffffffffc02023d4:	a00d                	j	ffffffffc02023f6 <alloc_pages+0x52>
            page = pmm_manager->alloc_pages(n);
ffffffffc02023d6:	609c                	ld	a5,0(s1)
ffffffffc02023d8:	6f9c                	ld	a5,24(a5)
ffffffffc02023da:	9782                	jalr	a5
        swap_out(check_mm_struct, n, 0);
ffffffffc02023dc:	4601                	li	a2,0
ffffffffc02023de:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc02023e0:	ed0d                	bnez	a0,ffffffffc020241a <alloc_pages+0x76>
ffffffffc02023e2:	0289ec63          	bltu	s3,s0,ffffffffc020241a <alloc_pages+0x76>
ffffffffc02023e6:	000a2783          	lw	a5,0(s4)
ffffffffc02023ea:	2781                	sext.w	a5,a5
ffffffffc02023ec:	c79d                	beqz	a5,ffffffffc020241a <alloc_pages+0x76>
        swap_out(check_mm_struct, n, 0);
ffffffffc02023ee:	000ab503          	ld	a0,0(s5)
ffffffffc02023f2:	259010ef          	jal	ra,ffffffffc0203e4a <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02023f6:	100027f3          	csrr	a5,sstatus
ffffffffc02023fa:	8b89                	andi	a5,a5,2
            page = pmm_manager->alloc_pages(n);
ffffffffc02023fc:	8522                	mv	a0,s0
ffffffffc02023fe:	dfe1                	beqz	a5,ffffffffc02023d6 <alloc_pages+0x32>
        intr_disable();
ffffffffc0202400:	a5afe0ef          	jal	ra,ffffffffc020065a <intr_disable>
ffffffffc0202404:	609c                	ld	a5,0(s1)
ffffffffc0202406:	8522                	mv	a0,s0
ffffffffc0202408:	6f9c                	ld	a5,24(a5)
ffffffffc020240a:	9782                	jalr	a5
ffffffffc020240c:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc020240e:	a46fe0ef          	jal	ra,ffffffffc0200654 <intr_enable>
ffffffffc0202412:	6522                	ld	a0,8(sp)
        swap_out(check_mm_struct, n, 0);
ffffffffc0202414:	4601                	li	a2,0
ffffffffc0202416:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0202418:	d569                	beqz	a0,ffffffffc02023e2 <alloc_pages+0x3e>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc020241a:	60a6                	ld	ra,72(sp)
ffffffffc020241c:	6406                	ld	s0,64(sp)
ffffffffc020241e:	74e2                	ld	s1,56(sp)
ffffffffc0202420:	7942                	ld	s2,48(sp)
ffffffffc0202422:	79a2                	ld	s3,40(sp)
ffffffffc0202424:	7a02                	ld	s4,32(sp)
ffffffffc0202426:	6ae2                	ld	s5,24(sp)
ffffffffc0202428:	6161                	addi	sp,sp,80
ffffffffc020242a:	8082                	ret

ffffffffc020242c <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020242c:	100027f3          	csrr	a5,sstatus
ffffffffc0202430:	8b89                	andi	a5,a5,2
ffffffffc0202432:	eb89                	bnez	a5,ffffffffc0202444 <free_pages+0x18>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0202434:	000aa797          	auipc	a5,0xaa
ffffffffc0202438:	09c78793          	addi	a5,a5,156 # ffffffffc02ac4d0 <pmm_manager>
ffffffffc020243c:	639c                	ld	a5,0(a5)
ffffffffc020243e:	0207b303          	ld	t1,32(a5)
ffffffffc0202442:	8302                	jr	t1
void free_pages(struct Page *base, size_t n) {
ffffffffc0202444:	1101                	addi	sp,sp,-32
ffffffffc0202446:	ec06                	sd	ra,24(sp)
ffffffffc0202448:	e822                	sd	s0,16(sp)
ffffffffc020244a:	e426                	sd	s1,8(sp)
ffffffffc020244c:	842a                	mv	s0,a0
ffffffffc020244e:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0202450:	a0afe0ef          	jal	ra,ffffffffc020065a <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202454:	000aa797          	auipc	a5,0xaa
ffffffffc0202458:	07c78793          	addi	a5,a5,124 # ffffffffc02ac4d0 <pmm_manager>
ffffffffc020245c:	639c                	ld	a5,0(a5)
ffffffffc020245e:	85a6                	mv	a1,s1
ffffffffc0202460:	8522                	mv	a0,s0
ffffffffc0202462:	739c                	ld	a5,32(a5)
ffffffffc0202464:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0202466:	6442                	ld	s0,16(sp)
ffffffffc0202468:	60e2                	ld	ra,24(sp)
ffffffffc020246a:	64a2                	ld	s1,8(sp)
ffffffffc020246c:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc020246e:	9e6fe06f          	j	ffffffffc0200654 <intr_enable>

ffffffffc0202472 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202472:	100027f3          	csrr	a5,sstatus
ffffffffc0202476:	8b89                	andi	a5,a5,2
ffffffffc0202478:	eb89                	bnez	a5,ffffffffc020248a <nr_free_pages+0x18>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc020247a:	000aa797          	auipc	a5,0xaa
ffffffffc020247e:	05678793          	addi	a5,a5,86 # ffffffffc02ac4d0 <pmm_manager>
ffffffffc0202482:	639c                	ld	a5,0(a5)
ffffffffc0202484:	0287b303          	ld	t1,40(a5)
ffffffffc0202488:	8302                	jr	t1
size_t nr_free_pages(void) {
ffffffffc020248a:	1141                	addi	sp,sp,-16
ffffffffc020248c:	e406                	sd	ra,8(sp)
ffffffffc020248e:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0202490:	9cafe0ef          	jal	ra,ffffffffc020065a <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202494:	000aa797          	auipc	a5,0xaa
ffffffffc0202498:	03c78793          	addi	a5,a5,60 # ffffffffc02ac4d0 <pmm_manager>
ffffffffc020249c:	639c                	ld	a5,0(a5)
ffffffffc020249e:	779c                	ld	a5,40(a5)
ffffffffc02024a0:	9782                	jalr	a5
ffffffffc02024a2:	842a                	mv	s0,a0
        intr_enable();
ffffffffc02024a4:	9b0fe0ef          	jal	ra,ffffffffc0200654 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc02024a8:	8522                	mv	a0,s0
ffffffffc02024aa:	60a2                	ld	ra,8(sp)
ffffffffc02024ac:	6402                	ld	s0,0(sp)
ffffffffc02024ae:	0141                	addi	sp,sp,16
ffffffffc02024b0:	8082                	ret

ffffffffc02024b2 <get_pte>:
// parameter:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc02024b2:	7139                	addi	sp,sp,-64
ffffffffc02024b4:	f426                	sd	s1,40(sp)
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc02024b6:	01e5d493          	srli	s1,a1,0x1e
ffffffffc02024ba:	1ff4f493          	andi	s1,s1,511
ffffffffc02024be:	048e                	slli	s1,s1,0x3
ffffffffc02024c0:	94aa                	add	s1,s1,a0
    if (!(*pdep1 & PTE_V)) {
ffffffffc02024c2:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc02024c4:	f04a                	sd	s2,32(sp)
ffffffffc02024c6:	ec4e                	sd	s3,24(sp)
ffffffffc02024c8:	e852                	sd	s4,16(sp)
ffffffffc02024ca:	fc06                	sd	ra,56(sp)
ffffffffc02024cc:	f822                	sd	s0,48(sp)
ffffffffc02024ce:	e456                	sd	s5,8(sp)
ffffffffc02024d0:	e05a                	sd	s6,0(sp)
    if (!(*pdep1 & PTE_V)) {
ffffffffc02024d2:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc02024d6:	892e                	mv	s2,a1
ffffffffc02024d8:	8a32                	mv	s4,a2
ffffffffc02024da:	000aa997          	auipc	s3,0xaa
ffffffffc02024de:	f9e98993          	addi	s3,s3,-98 # ffffffffc02ac478 <npage>
    if (!(*pdep1 & PTE_V)) {
ffffffffc02024e2:	e7bd                	bnez	a5,ffffffffc0202550 <get_pte+0x9e>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc02024e4:	12060c63          	beqz	a2,ffffffffc020261c <get_pte+0x16a>
ffffffffc02024e8:	4505                	li	a0,1
ffffffffc02024ea:	ebbff0ef          	jal	ra,ffffffffc02023a4 <alloc_pages>
ffffffffc02024ee:	842a                	mv	s0,a0
ffffffffc02024f0:	12050663          	beqz	a0,ffffffffc020261c <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc02024f4:	000aab17          	auipc	s6,0xaa
ffffffffc02024f8:	ff4b0b13          	addi	s6,s6,-12 # ffffffffc02ac4e8 <pages>
ffffffffc02024fc:	000b3503          	ld	a0,0(s6)
    page->ref = val;
ffffffffc0202500:	4785                	li	a5,1
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202502:	000aa997          	auipc	s3,0xaa
ffffffffc0202506:	f7698993          	addi	s3,s3,-138 # ffffffffc02ac478 <npage>
    return page - pages + nbase;
ffffffffc020250a:	40a40533          	sub	a0,s0,a0
ffffffffc020250e:	00080ab7          	lui	s5,0x80
ffffffffc0202512:	8519                	srai	a0,a0,0x6
ffffffffc0202514:	0009b703          	ld	a4,0(s3)
    page->ref = val;
ffffffffc0202518:	c01c                	sw	a5,0(s0)
ffffffffc020251a:	57fd                	li	a5,-1
    return page - pages + nbase;
ffffffffc020251c:	9556                	add	a0,a0,s5
ffffffffc020251e:	83b1                	srli	a5,a5,0xc
ffffffffc0202520:	8fe9                	and	a5,a5,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc0202522:	0532                	slli	a0,a0,0xc
ffffffffc0202524:	14e7f363          	bleu	a4,a5,ffffffffc020266a <get_pte+0x1b8>
ffffffffc0202528:	000aa797          	auipc	a5,0xaa
ffffffffc020252c:	fb078793          	addi	a5,a5,-80 # ffffffffc02ac4d8 <va_pa_offset>
ffffffffc0202530:	639c                	ld	a5,0(a5)
ffffffffc0202532:	6605                	lui	a2,0x1
ffffffffc0202534:	4581                	li	a1,0
ffffffffc0202536:	953e                	add	a0,a0,a5
ffffffffc0202538:	22a040ef          	jal	ra,ffffffffc0206762 <memset>
    return page - pages + nbase;
ffffffffc020253c:	000b3683          	ld	a3,0(s6)
ffffffffc0202540:	40d406b3          	sub	a3,s0,a3
ffffffffc0202544:	8699                	srai	a3,a3,0x6
ffffffffc0202546:	96d6                	add	a3,a3,s5
  asm volatile("sfence.vma");
}

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0202548:	06aa                	slli	a3,a3,0xa
ffffffffc020254a:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc020254e:	e094                	sd	a3,0(s1)
    }

    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0202550:	77fd                	lui	a5,0xfffff
ffffffffc0202552:	068a                	slli	a3,a3,0x2
ffffffffc0202554:	0009b703          	ld	a4,0(s3)
ffffffffc0202558:	8efd                	and	a3,a3,a5
ffffffffc020255a:	00c6d793          	srli	a5,a3,0xc
ffffffffc020255e:	0ce7f163          	bleu	a4,a5,ffffffffc0202620 <get_pte+0x16e>
ffffffffc0202562:	000aaa97          	auipc	s5,0xaa
ffffffffc0202566:	f76a8a93          	addi	s5,s5,-138 # ffffffffc02ac4d8 <va_pa_offset>
ffffffffc020256a:	000ab403          	ld	s0,0(s5)
ffffffffc020256e:	01595793          	srli	a5,s2,0x15
ffffffffc0202572:	1ff7f793          	andi	a5,a5,511
ffffffffc0202576:	96a2                	add	a3,a3,s0
ffffffffc0202578:	00379413          	slli	s0,a5,0x3
ffffffffc020257c:	9436                	add	s0,s0,a3
    if (!(*pdep0 & PTE_V)) {
ffffffffc020257e:	6014                	ld	a3,0(s0)
ffffffffc0202580:	0016f793          	andi	a5,a3,1
ffffffffc0202584:	e3ad                	bnez	a5,ffffffffc02025e6 <get_pte+0x134>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0202586:	080a0b63          	beqz	s4,ffffffffc020261c <get_pte+0x16a>
ffffffffc020258a:	4505                	li	a0,1
ffffffffc020258c:	e19ff0ef          	jal	ra,ffffffffc02023a4 <alloc_pages>
ffffffffc0202590:	84aa                	mv	s1,a0
ffffffffc0202592:	c549                	beqz	a0,ffffffffc020261c <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc0202594:	000aab17          	auipc	s6,0xaa
ffffffffc0202598:	f54b0b13          	addi	s6,s6,-172 # ffffffffc02ac4e8 <pages>
ffffffffc020259c:	000b3503          	ld	a0,0(s6)
    page->ref = val;
ffffffffc02025a0:	4785                	li	a5,1
    return page - pages + nbase;
ffffffffc02025a2:	00080a37          	lui	s4,0x80
ffffffffc02025a6:	40a48533          	sub	a0,s1,a0
ffffffffc02025aa:	8519                	srai	a0,a0,0x6
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc02025ac:	0009b703          	ld	a4,0(s3)
    page->ref = val;
ffffffffc02025b0:	c09c                	sw	a5,0(s1)
ffffffffc02025b2:	57fd                	li	a5,-1
    return page - pages + nbase;
ffffffffc02025b4:	9552                	add	a0,a0,s4
ffffffffc02025b6:	83b1                	srli	a5,a5,0xc
ffffffffc02025b8:	8fe9                	and	a5,a5,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc02025ba:	0532                	slli	a0,a0,0xc
ffffffffc02025bc:	08e7fa63          	bleu	a4,a5,ffffffffc0202650 <get_pte+0x19e>
ffffffffc02025c0:	000ab783          	ld	a5,0(s5)
ffffffffc02025c4:	6605                	lui	a2,0x1
ffffffffc02025c6:	4581                	li	a1,0
ffffffffc02025c8:	953e                	add	a0,a0,a5
ffffffffc02025ca:	198040ef          	jal	ra,ffffffffc0206762 <memset>
    return page - pages + nbase;
ffffffffc02025ce:	000b3683          	ld	a3,0(s6)
ffffffffc02025d2:	40d486b3          	sub	a3,s1,a3
ffffffffc02025d6:	8699                	srai	a3,a3,0x6
ffffffffc02025d8:	96d2                	add	a3,a3,s4
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc02025da:	06aa                	slli	a3,a3,0xa
ffffffffc02025dc:	0116e693          	ori	a3,a3,17
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc02025e0:	e014                	sd	a3,0(s0)
ffffffffc02025e2:	0009b703          	ld	a4,0(s3)
        }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc02025e6:	068a                	slli	a3,a3,0x2
ffffffffc02025e8:	757d                	lui	a0,0xfffff
ffffffffc02025ea:	8ee9                	and	a3,a3,a0
ffffffffc02025ec:	00c6d793          	srli	a5,a3,0xc
ffffffffc02025f0:	04e7f463          	bleu	a4,a5,ffffffffc0202638 <get_pte+0x186>
ffffffffc02025f4:	000ab503          	ld	a0,0(s5)
ffffffffc02025f8:	00c95793          	srli	a5,s2,0xc
ffffffffc02025fc:	1ff7f793          	andi	a5,a5,511
ffffffffc0202600:	96aa                	add	a3,a3,a0
ffffffffc0202602:	00379513          	slli	a0,a5,0x3
ffffffffc0202606:	9536                	add	a0,a0,a3
}
ffffffffc0202608:	70e2                	ld	ra,56(sp)
ffffffffc020260a:	7442                	ld	s0,48(sp)
ffffffffc020260c:	74a2                	ld	s1,40(sp)
ffffffffc020260e:	7902                	ld	s2,32(sp)
ffffffffc0202610:	69e2                	ld	s3,24(sp)
ffffffffc0202612:	6a42                	ld	s4,16(sp)
ffffffffc0202614:	6aa2                	ld	s5,8(sp)
ffffffffc0202616:	6b02                	ld	s6,0(sp)
ffffffffc0202618:	6121                	addi	sp,sp,64
ffffffffc020261a:	8082                	ret
            return NULL;
ffffffffc020261c:	4501                	li	a0,0
ffffffffc020261e:	b7ed                	j	ffffffffc0202608 <get_pte+0x156>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0202620:	00005617          	auipc	a2,0x5
ffffffffc0202624:	b1860613          	addi	a2,a2,-1256 # ffffffffc0207138 <commands+0x878>
ffffffffc0202628:	0e400593          	li	a1,228
ffffffffc020262c:	00005517          	auipc	a0,0x5
ffffffffc0202630:	0ec50513          	addi	a0,a0,236 # ffffffffc0207718 <default_pmm_manager+0xc0>
ffffffffc0202634:	e51fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0202638:	00005617          	auipc	a2,0x5
ffffffffc020263c:	b0060613          	addi	a2,a2,-1280 # ffffffffc0207138 <commands+0x878>
ffffffffc0202640:	0ef00593          	li	a1,239
ffffffffc0202644:	00005517          	auipc	a0,0x5
ffffffffc0202648:	0d450513          	addi	a0,a0,212 # ffffffffc0207718 <default_pmm_manager+0xc0>
ffffffffc020264c:	e39fd0ef          	jal	ra,ffffffffc0200484 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202650:	86aa                	mv	a3,a0
ffffffffc0202652:	00005617          	auipc	a2,0x5
ffffffffc0202656:	ae660613          	addi	a2,a2,-1306 # ffffffffc0207138 <commands+0x878>
ffffffffc020265a:	0ec00593          	li	a1,236
ffffffffc020265e:	00005517          	auipc	a0,0x5
ffffffffc0202662:	0ba50513          	addi	a0,a0,186 # ffffffffc0207718 <default_pmm_manager+0xc0>
ffffffffc0202666:	e1ffd0ef          	jal	ra,ffffffffc0200484 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc020266a:	86aa                	mv	a3,a0
ffffffffc020266c:	00005617          	auipc	a2,0x5
ffffffffc0202670:	acc60613          	addi	a2,a2,-1332 # ffffffffc0207138 <commands+0x878>
ffffffffc0202674:	0e000593          	li	a1,224
ffffffffc0202678:	00005517          	auipc	a0,0x5
ffffffffc020267c:	0a050513          	addi	a0,a0,160 # ffffffffc0207718 <default_pmm_manager+0xc0>
ffffffffc0202680:	e05fd0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0202684 <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0202684:	1141                	addi	sp,sp,-16
ffffffffc0202686:	e022                	sd	s0,0(sp)
ffffffffc0202688:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc020268a:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc020268c:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc020268e:	e25ff0ef          	jal	ra,ffffffffc02024b2 <get_pte>
    if (ptep_store != NULL) {
ffffffffc0202692:	c011                	beqz	s0,ffffffffc0202696 <get_page+0x12>
        *ptep_store = ptep;
ffffffffc0202694:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0202696:	c129                	beqz	a0,ffffffffc02026d8 <get_page+0x54>
ffffffffc0202698:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc020269a:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc020269c:	0017f713          	andi	a4,a5,1
ffffffffc02026a0:	e709                	bnez	a4,ffffffffc02026aa <get_page+0x26>
}
ffffffffc02026a2:	60a2                	ld	ra,8(sp)
ffffffffc02026a4:	6402                	ld	s0,0(sp)
ffffffffc02026a6:	0141                	addi	sp,sp,16
ffffffffc02026a8:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc02026aa:	000aa717          	auipc	a4,0xaa
ffffffffc02026ae:	dce70713          	addi	a4,a4,-562 # ffffffffc02ac478 <npage>
ffffffffc02026b2:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc02026b4:	078a                	slli	a5,a5,0x2
ffffffffc02026b6:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02026b8:	02e7f563          	bleu	a4,a5,ffffffffc02026e2 <get_page+0x5e>
    return &pages[PPN(pa) - nbase];
ffffffffc02026bc:	000aa717          	auipc	a4,0xaa
ffffffffc02026c0:	e2c70713          	addi	a4,a4,-468 # ffffffffc02ac4e8 <pages>
ffffffffc02026c4:	6308                	ld	a0,0(a4)
ffffffffc02026c6:	60a2                	ld	ra,8(sp)
ffffffffc02026c8:	6402                	ld	s0,0(sp)
ffffffffc02026ca:	fff80737          	lui	a4,0xfff80
ffffffffc02026ce:	97ba                	add	a5,a5,a4
ffffffffc02026d0:	079a                	slli	a5,a5,0x6
ffffffffc02026d2:	953e                	add	a0,a0,a5
ffffffffc02026d4:	0141                	addi	sp,sp,16
ffffffffc02026d6:	8082                	ret
ffffffffc02026d8:	60a2                	ld	ra,8(sp)
ffffffffc02026da:	6402                	ld	s0,0(sp)
    return NULL;
ffffffffc02026dc:	4501                	li	a0,0
}
ffffffffc02026de:	0141                	addi	sp,sp,16
ffffffffc02026e0:	8082                	ret
ffffffffc02026e2:	ca7ff0ef          	jal	ra,ffffffffc0202388 <pa2page.part.4>

ffffffffc02026e6 <unmap_range>:
        *ptep = 0;                  //(5) clear second page table entry
        tlb_invalidate(pgdir, la);  //(6) flush tlb
    }
}

void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc02026e6:	711d                	addi	sp,sp,-96
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02026e8:	00c5e7b3          	or	a5,a1,a2
void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc02026ec:	ec86                	sd	ra,88(sp)
ffffffffc02026ee:	e8a2                	sd	s0,80(sp)
ffffffffc02026f0:	e4a6                	sd	s1,72(sp)
ffffffffc02026f2:	e0ca                	sd	s2,64(sp)
ffffffffc02026f4:	fc4e                	sd	s3,56(sp)
ffffffffc02026f6:	f852                	sd	s4,48(sp)
ffffffffc02026f8:	f456                	sd	s5,40(sp)
ffffffffc02026fa:	f05a                	sd	s6,32(sp)
ffffffffc02026fc:	ec5e                	sd	s7,24(sp)
ffffffffc02026fe:	e862                	sd	s8,16(sp)
ffffffffc0202700:	e466                	sd	s9,8(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202702:	03479713          	slli	a4,a5,0x34
ffffffffc0202706:	eb71                	bnez	a4,ffffffffc02027da <unmap_range+0xf4>
    assert(USER_ACCESS(start, end));
ffffffffc0202708:	002007b7          	lui	a5,0x200
ffffffffc020270c:	842e                	mv	s0,a1
ffffffffc020270e:	0af5e663          	bltu	a1,a5,ffffffffc02027ba <unmap_range+0xd4>
ffffffffc0202712:	8932                	mv	s2,a2
ffffffffc0202714:	0ac5f363          	bleu	a2,a1,ffffffffc02027ba <unmap_range+0xd4>
ffffffffc0202718:	4785                	li	a5,1
ffffffffc020271a:	07fe                	slli	a5,a5,0x1f
ffffffffc020271c:	08c7ef63          	bltu	a5,a2,ffffffffc02027ba <unmap_range+0xd4>
ffffffffc0202720:	89aa                	mv	s3,a0
            continue;
        }
        if (*ptep != 0) {
            page_remove_pte(pgdir, start, ptep);
        }
        start += PGSIZE;
ffffffffc0202722:	6a05                	lui	s4,0x1
    if (PPN(pa) >= npage) {
ffffffffc0202724:	000aac97          	auipc	s9,0xaa
ffffffffc0202728:	d54c8c93          	addi	s9,s9,-684 # ffffffffc02ac478 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc020272c:	000aac17          	auipc	s8,0xaa
ffffffffc0202730:	dbcc0c13          	addi	s8,s8,-580 # ffffffffc02ac4e8 <pages>
ffffffffc0202734:	fff80bb7          	lui	s7,0xfff80
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc0202738:	00200b37          	lui	s6,0x200
ffffffffc020273c:	ffe00ab7          	lui	s5,0xffe00
        pte_t *ptep = get_pte(pgdir, start, 0);
ffffffffc0202740:	4601                	li	a2,0
ffffffffc0202742:	85a2                	mv	a1,s0
ffffffffc0202744:	854e                	mv	a0,s3
ffffffffc0202746:	d6dff0ef          	jal	ra,ffffffffc02024b2 <get_pte>
ffffffffc020274a:	84aa                	mv	s1,a0
        if (ptep == NULL) {
ffffffffc020274c:	cd21                	beqz	a0,ffffffffc02027a4 <unmap_range+0xbe>
        if (*ptep != 0) {
ffffffffc020274e:	611c                	ld	a5,0(a0)
ffffffffc0202750:	e38d                	bnez	a5,ffffffffc0202772 <unmap_range+0x8c>
        start += PGSIZE;
ffffffffc0202752:	9452                	add	s0,s0,s4
    } while (start != 0 && start < end);
ffffffffc0202754:	ff2466e3          	bltu	s0,s2,ffffffffc0202740 <unmap_range+0x5a>
}
ffffffffc0202758:	60e6                	ld	ra,88(sp)
ffffffffc020275a:	6446                	ld	s0,80(sp)
ffffffffc020275c:	64a6                	ld	s1,72(sp)
ffffffffc020275e:	6906                	ld	s2,64(sp)
ffffffffc0202760:	79e2                	ld	s3,56(sp)
ffffffffc0202762:	7a42                	ld	s4,48(sp)
ffffffffc0202764:	7aa2                	ld	s5,40(sp)
ffffffffc0202766:	7b02                	ld	s6,32(sp)
ffffffffc0202768:	6be2                	ld	s7,24(sp)
ffffffffc020276a:	6c42                	ld	s8,16(sp)
ffffffffc020276c:	6ca2                	ld	s9,8(sp)
ffffffffc020276e:	6125                	addi	sp,sp,96
ffffffffc0202770:	8082                	ret
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc0202772:	0017f713          	andi	a4,a5,1
ffffffffc0202776:	df71                	beqz	a4,ffffffffc0202752 <unmap_range+0x6c>
    if (PPN(pa) >= npage) {
ffffffffc0202778:	000cb703          	ld	a4,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc020277c:	078a                	slli	a5,a5,0x2
ffffffffc020277e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202780:	06e7fd63          	bleu	a4,a5,ffffffffc02027fa <unmap_range+0x114>
    return &pages[PPN(pa) - nbase];
ffffffffc0202784:	000c3503          	ld	a0,0(s8)
ffffffffc0202788:	97de                	add	a5,a5,s7
ffffffffc020278a:	079a                	slli	a5,a5,0x6
ffffffffc020278c:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc020278e:	411c                	lw	a5,0(a0)
ffffffffc0202790:	fff7871b          	addiw	a4,a5,-1
ffffffffc0202794:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0202796:	cf11                	beqz	a4,ffffffffc02027b2 <unmap_range+0xcc>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0202798:	0004b023          	sd	zero,0(s1)
}

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void tlb_invalidate(pde_t *pgdir, uintptr_t la) {
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc020279c:	12040073          	sfence.vma	s0
        start += PGSIZE;
ffffffffc02027a0:	9452                	add	s0,s0,s4
ffffffffc02027a2:	bf4d                	j	ffffffffc0202754 <unmap_range+0x6e>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc02027a4:	945a                	add	s0,s0,s6
ffffffffc02027a6:	01547433          	and	s0,s0,s5
    } while (start != 0 && start < end);
ffffffffc02027aa:	d45d                	beqz	s0,ffffffffc0202758 <unmap_range+0x72>
ffffffffc02027ac:	f9246ae3          	bltu	s0,s2,ffffffffc0202740 <unmap_range+0x5a>
ffffffffc02027b0:	b765                	j	ffffffffc0202758 <unmap_range+0x72>
            free_page(page);
ffffffffc02027b2:	4585                	li	a1,1
ffffffffc02027b4:	c79ff0ef          	jal	ra,ffffffffc020242c <free_pages>
ffffffffc02027b8:	b7c5                	j	ffffffffc0202798 <unmap_range+0xb2>
    assert(USER_ACCESS(start, end));
ffffffffc02027ba:	00005697          	auipc	a3,0x5
ffffffffc02027be:	a5668693          	addi	a3,a3,-1450 # ffffffffc0207210 <commands+0x950>
ffffffffc02027c2:	00004617          	auipc	a2,0x4
ffffffffc02027c6:	5be60613          	addi	a2,a2,1470 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc02027ca:	11100593          	li	a1,273
ffffffffc02027ce:	00005517          	auipc	a0,0x5
ffffffffc02027d2:	f4a50513          	addi	a0,a0,-182 # ffffffffc0207718 <default_pmm_manager+0xc0>
ffffffffc02027d6:	caffd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02027da:	00005697          	auipc	a3,0x5
ffffffffc02027de:	9f668693          	addi	a3,a3,-1546 # ffffffffc02071d0 <commands+0x910>
ffffffffc02027e2:	00004617          	auipc	a2,0x4
ffffffffc02027e6:	59e60613          	addi	a2,a2,1438 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc02027ea:	11000593          	li	a1,272
ffffffffc02027ee:	00005517          	auipc	a0,0x5
ffffffffc02027f2:	f2a50513          	addi	a0,a0,-214 # ffffffffc0207718 <default_pmm_manager+0xc0>
ffffffffc02027f6:	c8ffd0ef          	jal	ra,ffffffffc0200484 <__panic>
ffffffffc02027fa:	b8fff0ef          	jal	ra,ffffffffc0202388 <pa2page.part.4>

ffffffffc02027fe <exit_range>:
void exit_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc02027fe:	7119                	addi	sp,sp,-128
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202800:	00c5e7b3          	or	a5,a1,a2
void exit_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc0202804:	fc86                	sd	ra,120(sp)
ffffffffc0202806:	f8a2                	sd	s0,112(sp)
ffffffffc0202808:	f4a6                	sd	s1,104(sp)
ffffffffc020280a:	f0ca                	sd	s2,96(sp)
ffffffffc020280c:	ecce                	sd	s3,88(sp)
ffffffffc020280e:	e8d2                	sd	s4,80(sp)
ffffffffc0202810:	e4d6                	sd	s5,72(sp)
ffffffffc0202812:	e0da                	sd	s6,64(sp)
ffffffffc0202814:	fc5e                	sd	s7,56(sp)
ffffffffc0202816:	f862                	sd	s8,48(sp)
ffffffffc0202818:	f466                	sd	s9,40(sp)
ffffffffc020281a:	f06a                	sd	s10,32(sp)
ffffffffc020281c:	ec6e                	sd	s11,24(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020281e:	03479713          	slli	a4,a5,0x34
ffffffffc0202822:	1c071163          	bnez	a4,ffffffffc02029e4 <exit_range+0x1e6>
    assert(USER_ACCESS(start, end));
ffffffffc0202826:	002007b7          	lui	a5,0x200
ffffffffc020282a:	20f5e563          	bltu	a1,a5,ffffffffc0202a34 <exit_range+0x236>
ffffffffc020282e:	8b32                	mv	s6,a2
ffffffffc0202830:	20c5f263          	bleu	a2,a1,ffffffffc0202a34 <exit_range+0x236>
ffffffffc0202834:	4785                	li	a5,1
ffffffffc0202836:	07fe                	slli	a5,a5,0x1f
ffffffffc0202838:	1ec7ee63          	bltu	a5,a2,ffffffffc0202a34 <exit_range+0x236>
    d1start = ROUNDDOWN(start, PDSIZE);
ffffffffc020283c:	c00009b7          	lui	s3,0xc0000
ffffffffc0202840:	400007b7          	lui	a5,0x40000
ffffffffc0202844:	0135f9b3          	and	s3,a1,s3
ffffffffc0202848:	99be                	add	s3,s3,a5
        pde1 = pgdir[PDX1(d1start)];
ffffffffc020284a:	c0000337          	lui	t1,0xc0000
ffffffffc020284e:	00698933          	add	s2,s3,t1
ffffffffc0202852:	01e95913          	srli	s2,s2,0x1e
ffffffffc0202856:	1ff97913          	andi	s2,s2,511
ffffffffc020285a:	8e2a                	mv	t3,a0
ffffffffc020285c:	090e                	slli	s2,s2,0x3
ffffffffc020285e:	9972                	add	s2,s2,t3
ffffffffc0202860:	00093b83          	ld	s7,0(s2)
    d0start = ROUNDDOWN(start, PTSIZE);
ffffffffc0202864:	ffe004b7          	lui	s1,0xffe00
    return KADDR(page2pa(page));
ffffffffc0202868:	5dfd                	li	s11,-1
        if (pde1&PTE_V){
ffffffffc020286a:	001bf793          	andi	a5,s7,1
    d0start = ROUNDDOWN(start, PTSIZE);
ffffffffc020286e:	8ced                	and	s1,s1,a1
    if (PPN(pa) >= npage) {
ffffffffc0202870:	000aad17          	auipc	s10,0xaa
ffffffffc0202874:	c08d0d13          	addi	s10,s10,-1016 # ffffffffc02ac478 <npage>
    return KADDR(page2pa(page));
ffffffffc0202878:	00cddd93          	srli	s11,s11,0xc
ffffffffc020287c:	000aa717          	auipc	a4,0xaa
ffffffffc0202880:	c5c70713          	addi	a4,a4,-932 # ffffffffc02ac4d8 <va_pa_offset>
    return &pages[PPN(pa) - nbase];
ffffffffc0202884:	000aae97          	auipc	t4,0xaa
ffffffffc0202888:	c64e8e93          	addi	t4,t4,-924 # ffffffffc02ac4e8 <pages>
        if (pde1&PTE_V){
ffffffffc020288c:	e79d                	bnez	a5,ffffffffc02028ba <exit_range+0xbc>
    } while (d1start != 0 && d1start < end);
ffffffffc020288e:	12098963          	beqz	s3,ffffffffc02029c0 <exit_range+0x1c2>
ffffffffc0202892:	400007b7          	lui	a5,0x40000
ffffffffc0202896:	84ce                	mv	s1,s3
ffffffffc0202898:	97ce                	add	a5,a5,s3
ffffffffc020289a:	1369f363          	bleu	s6,s3,ffffffffc02029c0 <exit_range+0x1c2>
ffffffffc020289e:	89be                	mv	s3,a5
        pde1 = pgdir[PDX1(d1start)];
ffffffffc02028a0:	00698933          	add	s2,s3,t1
ffffffffc02028a4:	01e95913          	srli	s2,s2,0x1e
ffffffffc02028a8:	1ff97913          	andi	s2,s2,511
ffffffffc02028ac:	090e                	slli	s2,s2,0x3
ffffffffc02028ae:	9972                	add	s2,s2,t3
ffffffffc02028b0:	00093b83          	ld	s7,0(s2)
        if (pde1&PTE_V){
ffffffffc02028b4:	001bf793          	andi	a5,s7,1
ffffffffc02028b8:	dbf9                	beqz	a5,ffffffffc020288e <exit_range+0x90>
    if (PPN(pa) >= npage) {
ffffffffc02028ba:	000d3783          	ld	a5,0(s10)
    return pa2page(PDE_ADDR(pde));
ffffffffc02028be:	0b8a                	slli	s7,s7,0x2
ffffffffc02028c0:	00cbdb93          	srli	s7,s7,0xc
    if (PPN(pa) >= npage) {
ffffffffc02028c4:	14fbfc63          	bleu	a5,s7,ffffffffc0202a1c <exit_range+0x21e>
    return &pages[PPN(pa) - nbase];
ffffffffc02028c8:	fff80ab7          	lui	s5,0xfff80
ffffffffc02028cc:	9ade                	add	s5,s5,s7
    return page - pages + nbase;
ffffffffc02028ce:	000806b7          	lui	a3,0x80
ffffffffc02028d2:	96d6                	add	a3,a3,s5
ffffffffc02028d4:	006a9593          	slli	a1,s5,0x6
    return KADDR(page2pa(page));
ffffffffc02028d8:	01b6f633          	and	a2,a3,s11
    return page - pages + nbase;
ffffffffc02028dc:	e42e                	sd	a1,8(sp)
    return page2ppn(page) << PGSHIFT;
ffffffffc02028de:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02028e0:	12f67263          	bleu	a5,a2,ffffffffc0202a04 <exit_range+0x206>
ffffffffc02028e4:	00073a03          	ld	s4,0(a4)
            free_pd0 = 1;
ffffffffc02028e8:	4c85                	li	s9,1
    return &pages[PPN(pa) - nbase];
ffffffffc02028ea:	fff808b7          	lui	a7,0xfff80
    return KADDR(page2pa(page));
ffffffffc02028ee:	9a36                	add	s4,s4,a3
    return page - pages + nbase;
ffffffffc02028f0:	00080837          	lui	a6,0x80
ffffffffc02028f4:	6a85                	lui	s5,0x1
                d0start += PTSIZE;
ffffffffc02028f6:	00200c37          	lui	s8,0x200
ffffffffc02028fa:	a801                	j	ffffffffc020290a <exit_range+0x10c>
                    free_pd0 = 0;
ffffffffc02028fc:	4c81                	li	s9,0
                d0start += PTSIZE;
ffffffffc02028fe:	94e2                	add	s1,s1,s8
            } while (d0start != 0 && d0start < d1start+PDSIZE && d0start < end);
ffffffffc0202900:	c0d9                	beqz	s1,ffffffffc0202986 <exit_range+0x188>
ffffffffc0202902:	0934f263          	bleu	s3,s1,ffffffffc0202986 <exit_range+0x188>
ffffffffc0202906:	0d64fc63          	bleu	s6,s1,ffffffffc02029de <exit_range+0x1e0>
                pde0 = pd0[PDX0(d0start)];
ffffffffc020290a:	0154d413          	srli	s0,s1,0x15
ffffffffc020290e:	1ff47413          	andi	s0,s0,511
ffffffffc0202912:	040e                	slli	s0,s0,0x3
ffffffffc0202914:	9452                	add	s0,s0,s4
ffffffffc0202916:	601c                	ld	a5,0(s0)
                if (pde0&PTE_V) {
ffffffffc0202918:	0017f693          	andi	a3,a5,1
ffffffffc020291c:	d2e5                	beqz	a3,ffffffffc02028fc <exit_range+0xfe>
    if (PPN(pa) >= npage) {
ffffffffc020291e:	000d3583          	ld	a1,0(s10)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202922:	00279513          	slli	a0,a5,0x2
ffffffffc0202926:	8131                	srli	a0,a0,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202928:	0eb57a63          	bleu	a1,a0,ffffffffc0202a1c <exit_range+0x21e>
    return &pages[PPN(pa) - nbase];
ffffffffc020292c:	9546                	add	a0,a0,a7
    return page - pages + nbase;
ffffffffc020292e:	010506b3          	add	a3,a0,a6
    return KADDR(page2pa(page));
ffffffffc0202932:	01b6f7b3          	and	a5,a3,s11
    return page - pages + nbase;
ffffffffc0202936:	051a                	slli	a0,a0,0x6
    return page2ppn(page) << PGSHIFT;
ffffffffc0202938:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020293a:	0cb7f563          	bleu	a1,a5,ffffffffc0202a04 <exit_range+0x206>
ffffffffc020293e:	631c                	ld	a5,0(a4)
ffffffffc0202940:	96be                	add	a3,a3,a5
                    for (int i = 0;i <NPTEENTRY;i++)
ffffffffc0202942:	015685b3          	add	a1,a3,s5
                        if (pt[i]&PTE_V){
ffffffffc0202946:	629c                	ld	a5,0(a3)
ffffffffc0202948:	8b85                	andi	a5,a5,1
ffffffffc020294a:	fbd5                	bnez	a5,ffffffffc02028fe <exit_range+0x100>
ffffffffc020294c:	06a1                	addi	a3,a3,8
                    for (int i = 0;i <NPTEENTRY;i++)
ffffffffc020294e:	fed59ce3          	bne	a1,a3,ffffffffc0202946 <exit_range+0x148>
    return &pages[PPN(pa) - nbase];
ffffffffc0202952:	000eb783          	ld	a5,0(t4)
                        free_page(pde2page(pde0));
ffffffffc0202956:	4585                	li	a1,1
ffffffffc0202958:	e072                	sd	t3,0(sp)
ffffffffc020295a:	953e                	add	a0,a0,a5
ffffffffc020295c:	ad1ff0ef          	jal	ra,ffffffffc020242c <free_pages>
                d0start += PTSIZE;
ffffffffc0202960:	94e2                	add	s1,s1,s8
                        pd0[PDX0(d0start)] = 0;
ffffffffc0202962:	00043023          	sd	zero,0(s0)
ffffffffc0202966:	000aae97          	auipc	t4,0xaa
ffffffffc020296a:	b82e8e93          	addi	t4,t4,-1150 # ffffffffc02ac4e8 <pages>
ffffffffc020296e:	6e02                	ld	t3,0(sp)
ffffffffc0202970:	c0000337          	lui	t1,0xc0000
ffffffffc0202974:	fff808b7          	lui	a7,0xfff80
ffffffffc0202978:	00080837          	lui	a6,0x80
ffffffffc020297c:	000aa717          	auipc	a4,0xaa
ffffffffc0202980:	b5c70713          	addi	a4,a4,-1188 # ffffffffc02ac4d8 <va_pa_offset>
            } while (d0start != 0 && d0start < d1start+PDSIZE && d0start < end);
ffffffffc0202984:	fcbd                	bnez	s1,ffffffffc0202902 <exit_range+0x104>
            if (free_pd0) {
ffffffffc0202986:	f00c84e3          	beqz	s9,ffffffffc020288e <exit_range+0x90>
    if (PPN(pa) >= npage) {
ffffffffc020298a:	000d3783          	ld	a5,0(s10)
ffffffffc020298e:	e072                	sd	t3,0(sp)
ffffffffc0202990:	08fbf663          	bleu	a5,s7,ffffffffc0202a1c <exit_range+0x21e>
    return &pages[PPN(pa) - nbase];
ffffffffc0202994:	000eb503          	ld	a0,0(t4)
                free_page(pde2page(pde1));
ffffffffc0202998:	67a2                	ld	a5,8(sp)
ffffffffc020299a:	4585                	li	a1,1
ffffffffc020299c:	953e                	add	a0,a0,a5
ffffffffc020299e:	a8fff0ef          	jal	ra,ffffffffc020242c <free_pages>
                pgdir[PDX1(d1start)] = 0;
ffffffffc02029a2:	00093023          	sd	zero,0(s2)
ffffffffc02029a6:	000aa717          	auipc	a4,0xaa
ffffffffc02029aa:	b3270713          	addi	a4,a4,-1230 # ffffffffc02ac4d8 <va_pa_offset>
ffffffffc02029ae:	c0000337          	lui	t1,0xc0000
ffffffffc02029b2:	6e02                	ld	t3,0(sp)
ffffffffc02029b4:	000aae97          	auipc	t4,0xaa
ffffffffc02029b8:	b34e8e93          	addi	t4,t4,-1228 # ffffffffc02ac4e8 <pages>
    } while (d1start != 0 && d1start < end);
ffffffffc02029bc:	ec099be3          	bnez	s3,ffffffffc0202892 <exit_range+0x94>
}
ffffffffc02029c0:	70e6                	ld	ra,120(sp)
ffffffffc02029c2:	7446                	ld	s0,112(sp)
ffffffffc02029c4:	74a6                	ld	s1,104(sp)
ffffffffc02029c6:	7906                	ld	s2,96(sp)
ffffffffc02029c8:	69e6                	ld	s3,88(sp)
ffffffffc02029ca:	6a46                	ld	s4,80(sp)
ffffffffc02029cc:	6aa6                	ld	s5,72(sp)
ffffffffc02029ce:	6b06                	ld	s6,64(sp)
ffffffffc02029d0:	7be2                	ld	s7,56(sp)
ffffffffc02029d2:	7c42                	ld	s8,48(sp)
ffffffffc02029d4:	7ca2                	ld	s9,40(sp)
ffffffffc02029d6:	7d02                	ld	s10,32(sp)
ffffffffc02029d8:	6de2                	ld	s11,24(sp)
ffffffffc02029da:	6109                	addi	sp,sp,128
ffffffffc02029dc:	8082                	ret
            if (free_pd0) {
ffffffffc02029de:	ea0c8ae3          	beqz	s9,ffffffffc0202892 <exit_range+0x94>
ffffffffc02029e2:	b765                	j	ffffffffc020298a <exit_range+0x18c>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02029e4:	00004697          	auipc	a3,0x4
ffffffffc02029e8:	7ec68693          	addi	a3,a3,2028 # ffffffffc02071d0 <commands+0x910>
ffffffffc02029ec:	00004617          	auipc	a2,0x4
ffffffffc02029f0:	39460613          	addi	a2,a2,916 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc02029f4:	12100593          	li	a1,289
ffffffffc02029f8:	00005517          	auipc	a0,0x5
ffffffffc02029fc:	d2050513          	addi	a0,a0,-736 # ffffffffc0207718 <default_pmm_manager+0xc0>
ffffffffc0202a00:	a85fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    return KADDR(page2pa(page));
ffffffffc0202a04:	00004617          	auipc	a2,0x4
ffffffffc0202a08:	73460613          	addi	a2,a2,1844 # ffffffffc0207138 <commands+0x878>
ffffffffc0202a0c:	06a00593          	li	a1,106
ffffffffc0202a10:	00005517          	auipc	a0,0x5
ffffffffc0202a14:	83850513          	addi	a0,a0,-1992 # ffffffffc0207248 <commands+0x988>
ffffffffc0202a18:	a6dfd0ef          	jal	ra,ffffffffc0200484 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0202a1c:	00005617          	auipc	a2,0x5
ffffffffc0202a20:	80c60613          	addi	a2,a2,-2036 # ffffffffc0207228 <commands+0x968>
ffffffffc0202a24:	06300593          	li	a1,99
ffffffffc0202a28:	00005517          	auipc	a0,0x5
ffffffffc0202a2c:	82050513          	addi	a0,a0,-2016 # ffffffffc0207248 <commands+0x988>
ffffffffc0202a30:	a55fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc0202a34:	00004697          	auipc	a3,0x4
ffffffffc0202a38:	7dc68693          	addi	a3,a3,2012 # ffffffffc0207210 <commands+0x950>
ffffffffc0202a3c:	00004617          	auipc	a2,0x4
ffffffffc0202a40:	34460613          	addi	a2,a2,836 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0202a44:	12200593          	li	a1,290
ffffffffc0202a48:	00005517          	auipc	a0,0x5
ffffffffc0202a4c:	cd050513          	addi	a0,a0,-816 # ffffffffc0207718 <default_pmm_manager+0xc0>
ffffffffc0202a50:	a35fd0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0202a54 <page_remove>:
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0202a54:	1101                	addi	sp,sp,-32
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202a56:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0202a58:	e426                	sd	s1,8(sp)
ffffffffc0202a5a:	ec06                	sd	ra,24(sp)
ffffffffc0202a5c:	e822                	sd	s0,16(sp)
ffffffffc0202a5e:	84ae                	mv	s1,a1
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202a60:	a53ff0ef          	jal	ra,ffffffffc02024b2 <get_pte>
    if (ptep != NULL) {
ffffffffc0202a64:	c511                	beqz	a0,ffffffffc0202a70 <page_remove+0x1c>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc0202a66:	611c                	ld	a5,0(a0)
ffffffffc0202a68:	842a                	mv	s0,a0
ffffffffc0202a6a:	0017f713          	andi	a4,a5,1
ffffffffc0202a6e:	e711                	bnez	a4,ffffffffc0202a7a <page_remove+0x26>
}
ffffffffc0202a70:	60e2                	ld	ra,24(sp)
ffffffffc0202a72:	6442                	ld	s0,16(sp)
ffffffffc0202a74:	64a2                	ld	s1,8(sp)
ffffffffc0202a76:	6105                	addi	sp,sp,32
ffffffffc0202a78:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0202a7a:	000aa717          	auipc	a4,0xaa
ffffffffc0202a7e:	9fe70713          	addi	a4,a4,-1538 # ffffffffc02ac478 <npage>
ffffffffc0202a82:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202a84:	078a                	slli	a5,a5,0x2
ffffffffc0202a86:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202a88:	02e7fe63          	bleu	a4,a5,ffffffffc0202ac4 <page_remove+0x70>
    return &pages[PPN(pa) - nbase];
ffffffffc0202a8c:	000aa717          	auipc	a4,0xaa
ffffffffc0202a90:	a5c70713          	addi	a4,a4,-1444 # ffffffffc02ac4e8 <pages>
ffffffffc0202a94:	6308                	ld	a0,0(a4)
ffffffffc0202a96:	fff80737          	lui	a4,0xfff80
ffffffffc0202a9a:	97ba                	add	a5,a5,a4
ffffffffc0202a9c:	079a                	slli	a5,a5,0x6
ffffffffc0202a9e:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc0202aa0:	411c                	lw	a5,0(a0)
ffffffffc0202aa2:	fff7871b          	addiw	a4,a5,-1
ffffffffc0202aa6:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0202aa8:	cb11                	beqz	a4,ffffffffc0202abc <page_remove+0x68>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0202aaa:	00043023          	sd	zero,0(s0)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202aae:	12048073          	sfence.vma	s1
}
ffffffffc0202ab2:	60e2                	ld	ra,24(sp)
ffffffffc0202ab4:	6442                	ld	s0,16(sp)
ffffffffc0202ab6:	64a2                	ld	s1,8(sp)
ffffffffc0202ab8:	6105                	addi	sp,sp,32
ffffffffc0202aba:	8082                	ret
            free_page(page);
ffffffffc0202abc:	4585                	li	a1,1
ffffffffc0202abe:	96fff0ef          	jal	ra,ffffffffc020242c <free_pages>
ffffffffc0202ac2:	b7e5                	j	ffffffffc0202aaa <page_remove+0x56>
ffffffffc0202ac4:	8c5ff0ef          	jal	ra,ffffffffc0202388 <pa2page.part.4>

ffffffffc0202ac8 <page_insert>:
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0202ac8:	7179                	addi	sp,sp,-48
ffffffffc0202aca:	e44e                	sd	s3,8(sp)
ffffffffc0202acc:	89b2                	mv	s3,a2
ffffffffc0202ace:	f022                	sd	s0,32(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0202ad0:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0202ad2:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0202ad4:	85ce                	mv	a1,s3
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0202ad6:	ec26                	sd	s1,24(sp)
ffffffffc0202ad8:	f406                	sd	ra,40(sp)
ffffffffc0202ada:	e84a                	sd	s2,16(sp)
ffffffffc0202adc:	e052                	sd	s4,0(sp)
ffffffffc0202ade:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0202ae0:	9d3ff0ef          	jal	ra,ffffffffc02024b2 <get_pte>
    if (ptep == NULL) {
ffffffffc0202ae4:	cd49                	beqz	a0,ffffffffc0202b7e <page_insert+0xb6>
    page->ref += 1;
ffffffffc0202ae6:	4014                	lw	a3,0(s0)
    if (*ptep & PTE_V) {
ffffffffc0202ae8:	611c                	ld	a5,0(a0)
ffffffffc0202aea:	892a                	mv	s2,a0
ffffffffc0202aec:	0016871b          	addiw	a4,a3,1
ffffffffc0202af0:	c018                	sw	a4,0(s0)
ffffffffc0202af2:	0017f713          	andi	a4,a5,1
ffffffffc0202af6:	ef05                	bnez	a4,ffffffffc0202b2e <page_insert+0x66>
ffffffffc0202af8:	000aa797          	auipc	a5,0xaa
ffffffffc0202afc:	9f078793          	addi	a5,a5,-1552 # ffffffffc02ac4e8 <pages>
ffffffffc0202b00:	6398                	ld	a4,0(a5)
    return page - pages + nbase;
ffffffffc0202b02:	8c19                	sub	s0,s0,a4
ffffffffc0202b04:	000806b7          	lui	a3,0x80
ffffffffc0202b08:	8419                	srai	s0,s0,0x6
ffffffffc0202b0a:	9436                	add	s0,s0,a3
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0202b0c:	042a                	slli	s0,s0,0xa
ffffffffc0202b0e:	8c45                	or	s0,s0,s1
ffffffffc0202b10:	00146413          	ori	s0,s0,1
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc0202b14:	00893023          	sd	s0,0(s2)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202b18:	12098073          	sfence.vma	s3
    return 0;
ffffffffc0202b1c:	4501                	li	a0,0
}
ffffffffc0202b1e:	70a2                	ld	ra,40(sp)
ffffffffc0202b20:	7402                	ld	s0,32(sp)
ffffffffc0202b22:	64e2                	ld	s1,24(sp)
ffffffffc0202b24:	6942                	ld	s2,16(sp)
ffffffffc0202b26:	69a2                	ld	s3,8(sp)
ffffffffc0202b28:	6a02                	ld	s4,0(sp)
ffffffffc0202b2a:	6145                	addi	sp,sp,48
ffffffffc0202b2c:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0202b2e:	000aa717          	auipc	a4,0xaa
ffffffffc0202b32:	94a70713          	addi	a4,a4,-1718 # ffffffffc02ac478 <npage>
ffffffffc0202b36:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202b38:	078a                	slli	a5,a5,0x2
ffffffffc0202b3a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202b3c:	04e7f363          	bleu	a4,a5,ffffffffc0202b82 <page_insert+0xba>
    return &pages[PPN(pa) - nbase];
ffffffffc0202b40:	000aaa17          	auipc	s4,0xaa
ffffffffc0202b44:	9a8a0a13          	addi	s4,s4,-1624 # ffffffffc02ac4e8 <pages>
ffffffffc0202b48:	000a3703          	ld	a4,0(s4)
ffffffffc0202b4c:	fff80537          	lui	a0,0xfff80
ffffffffc0202b50:	953e                	add	a0,a0,a5
ffffffffc0202b52:	051a                	slli	a0,a0,0x6
ffffffffc0202b54:	953a                	add	a0,a0,a4
        if (p == page) {
ffffffffc0202b56:	00a40a63          	beq	s0,a0,ffffffffc0202b6a <page_insert+0xa2>
    page->ref -= 1;
ffffffffc0202b5a:	411c                	lw	a5,0(a0)
ffffffffc0202b5c:	fff7869b          	addiw	a3,a5,-1
ffffffffc0202b60:	c114                	sw	a3,0(a0)
        if (page_ref(page) ==
ffffffffc0202b62:	c691                	beqz	a3,ffffffffc0202b6e <page_insert+0xa6>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202b64:	12098073          	sfence.vma	s3
ffffffffc0202b68:	bf69                	j	ffffffffc0202b02 <page_insert+0x3a>
ffffffffc0202b6a:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc0202b6c:	bf59                	j	ffffffffc0202b02 <page_insert+0x3a>
            free_page(page);
ffffffffc0202b6e:	4585                	li	a1,1
ffffffffc0202b70:	8bdff0ef          	jal	ra,ffffffffc020242c <free_pages>
ffffffffc0202b74:	000a3703          	ld	a4,0(s4)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202b78:	12098073          	sfence.vma	s3
ffffffffc0202b7c:	b759                	j	ffffffffc0202b02 <page_insert+0x3a>
        return -E_NO_MEM;
ffffffffc0202b7e:	5571                	li	a0,-4
ffffffffc0202b80:	bf79                	j	ffffffffc0202b1e <page_insert+0x56>
ffffffffc0202b82:	807ff0ef          	jal	ra,ffffffffc0202388 <pa2page.part.4>

ffffffffc0202b86 <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc0202b86:	00005797          	auipc	a5,0x5
ffffffffc0202b8a:	ad278793          	addi	a5,a5,-1326 # ffffffffc0207658 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0202b8e:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc0202b90:	715d                	addi	sp,sp,-80
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0202b92:	00005517          	auipc	a0,0x5
ffffffffc0202b96:	bae50513          	addi	a0,a0,-1106 # ffffffffc0207740 <default_pmm_manager+0xe8>
void pmm_init(void) {
ffffffffc0202b9a:	e486                	sd	ra,72(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0202b9c:	000aa717          	auipc	a4,0xaa
ffffffffc0202ba0:	92f73a23          	sd	a5,-1740(a4) # ffffffffc02ac4d0 <pmm_manager>
void pmm_init(void) {
ffffffffc0202ba4:	e0a2                	sd	s0,64(sp)
ffffffffc0202ba6:	fc26                	sd	s1,56(sp)
ffffffffc0202ba8:	f84a                	sd	s2,48(sp)
ffffffffc0202baa:	f44e                	sd	s3,40(sp)
ffffffffc0202bac:	f052                	sd	s4,32(sp)
ffffffffc0202bae:	ec56                	sd	s5,24(sp)
ffffffffc0202bb0:	e85a                	sd	s6,16(sp)
ffffffffc0202bb2:	e45e                	sd	s7,8(sp)
ffffffffc0202bb4:	e062                	sd	s8,0(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0202bb6:	000aa417          	auipc	s0,0xaa
ffffffffc0202bba:	91a40413          	addi	s0,s0,-1766 # ffffffffc02ac4d0 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0202bbe:	dd0fd0ef          	jal	ra,ffffffffc020018e <cprintf>
    pmm_manager->init();
ffffffffc0202bc2:	601c                	ld	a5,0(s0)
ffffffffc0202bc4:	000aa497          	auipc	s1,0xaa
ffffffffc0202bc8:	8b448493          	addi	s1,s1,-1868 # ffffffffc02ac478 <npage>
ffffffffc0202bcc:	000aa917          	auipc	s2,0xaa
ffffffffc0202bd0:	91c90913          	addi	s2,s2,-1764 # ffffffffc02ac4e8 <pages>
ffffffffc0202bd4:	679c                	ld	a5,8(a5)
ffffffffc0202bd6:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0202bd8:	57f5                	li	a5,-3
ffffffffc0202bda:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc0202bdc:	00005517          	auipc	a0,0x5
ffffffffc0202be0:	b7c50513          	addi	a0,a0,-1156 # ffffffffc0207758 <default_pmm_manager+0x100>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0202be4:	000aa717          	auipc	a4,0xaa
ffffffffc0202be8:	8ef73a23          	sd	a5,-1804(a4) # ffffffffc02ac4d8 <va_pa_offset>
    cprintf("physcial memory map:\n");
ffffffffc0202bec:	da2fd0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc0202bf0:	46c5                	li	a3,17
ffffffffc0202bf2:	06ee                	slli	a3,a3,0x1b
ffffffffc0202bf4:	40100613          	li	a2,1025
ffffffffc0202bf8:	16fd                	addi	a3,a3,-1
ffffffffc0202bfa:	0656                	slli	a2,a2,0x15
ffffffffc0202bfc:	07e005b7          	lui	a1,0x7e00
ffffffffc0202c00:	00005517          	auipc	a0,0x5
ffffffffc0202c04:	b7050513          	addi	a0,a0,-1168 # ffffffffc0207770 <default_pmm_manager+0x118>
ffffffffc0202c08:	d86fd0ef          	jal	ra,ffffffffc020018e <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0202c0c:	777d                	lui	a4,0xfffff
ffffffffc0202c0e:	000ab797          	auipc	a5,0xab
ffffffffc0202c12:	9d178793          	addi	a5,a5,-1583 # ffffffffc02ad5df <end+0xfff>
ffffffffc0202c16:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0202c18:	00088737          	lui	a4,0x88
ffffffffc0202c1c:	000aa697          	auipc	a3,0xaa
ffffffffc0202c20:	84e6be23          	sd	a4,-1956(a3) # ffffffffc02ac478 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0202c24:	000aa717          	auipc	a4,0xaa
ffffffffc0202c28:	8cf73223          	sd	a5,-1852(a4) # ffffffffc02ac4e8 <pages>
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0202c2c:	4701                	li	a4,0
ffffffffc0202c2e:	4685                	li	a3,1
ffffffffc0202c30:	fff80837          	lui	a6,0xfff80
ffffffffc0202c34:	a019                	j	ffffffffc0202c3a <pmm_init+0xb4>
ffffffffc0202c36:	00093783          	ld	a5,0(s2)
        SetPageReserved(pages + i);
ffffffffc0202c3a:	00671613          	slli	a2,a4,0x6
ffffffffc0202c3e:	97b2                	add	a5,a5,a2
ffffffffc0202c40:	07a1                	addi	a5,a5,8
ffffffffc0202c42:	40d7b02f          	amoor.d	zero,a3,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0202c46:	6090                	ld	a2,0(s1)
ffffffffc0202c48:	0705                	addi	a4,a4,1
ffffffffc0202c4a:	010607b3          	add	a5,a2,a6
ffffffffc0202c4e:	fef764e3          	bltu	a4,a5,ffffffffc0202c36 <pmm_init+0xb0>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0202c52:	00093503          	ld	a0,0(s2)
ffffffffc0202c56:	fe0007b7          	lui	a5,0xfe000
ffffffffc0202c5a:	00661693          	slli	a3,a2,0x6
ffffffffc0202c5e:	97aa                	add	a5,a5,a0
ffffffffc0202c60:	96be                	add	a3,a3,a5
ffffffffc0202c62:	c02007b7          	lui	a5,0xc0200
ffffffffc0202c66:	7af6ed63          	bltu	a3,a5,ffffffffc0203420 <pmm_init+0x89a>
ffffffffc0202c6a:	000aa997          	auipc	s3,0xaa
ffffffffc0202c6e:	86e98993          	addi	s3,s3,-1938 # ffffffffc02ac4d8 <va_pa_offset>
ffffffffc0202c72:	0009b583          	ld	a1,0(s3)
    if (freemem < mem_end) {
ffffffffc0202c76:	47c5                	li	a5,17
ffffffffc0202c78:	07ee                	slli	a5,a5,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0202c7a:	8e8d                	sub	a3,a3,a1
    if (freemem < mem_end) {
ffffffffc0202c7c:	02f6f763          	bleu	a5,a3,ffffffffc0202caa <pmm_init+0x124>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0202c80:	6585                	lui	a1,0x1
ffffffffc0202c82:	15fd                	addi	a1,a1,-1
ffffffffc0202c84:	96ae                	add	a3,a3,a1
    if (PPN(pa) >= npage) {
ffffffffc0202c86:	00c6d713          	srli	a4,a3,0xc
ffffffffc0202c8a:	48c77a63          	bleu	a2,a4,ffffffffc020311e <pmm_init+0x598>
    pmm_manager->init_memmap(base, n);
ffffffffc0202c8e:	6010                	ld	a2,0(s0)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0202c90:	75fd                	lui	a1,0xfffff
ffffffffc0202c92:	8eed                	and	a3,a3,a1
    return &pages[PPN(pa) - nbase];
ffffffffc0202c94:	9742                	add	a4,a4,a6
    pmm_manager->init_memmap(base, n);
ffffffffc0202c96:	6a10                	ld	a2,16(a2)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0202c98:	40d786b3          	sub	a3,a5,a3
ffffffffc0202c9c:	071a                	slli	a4,a4,0x6
    pmm_manager->init_memmap(base, n);
ffffffffc0202c9e:	00c6d593          	srli	a1,a3,0xc
ffffffffc0202ca2:	953a                	add	a0,a0,a4
ffffffffc0202ca4:	9602                	jalr	a2
ffffffffc0202ca6:	0009b583          	ld	a1,0(s3)
    cprintf("vapaofset is %llu\n",va_pa_offset);
ffffffffc0202caa:	00005517          	auipc	a0,0x5
ffffffffc0202cae:	aee50513          	addi	a0,a0,-1298 # ffffffffc0207798 <default_pmm_manager+0x140>
ffffffffc0202cb2:	cdcfd0ef          	jal	ra,ffffffffc020018e <cprintf>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0202cb6:	601c                	ld	a5,0(s0)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0202cb8:	000a9417          	auipc	s0,0xa9
ffffffffc0202cbc:	7b840413          	addi	s0,s0,1976 # ffffffffc02ac470 <boot_pgdir>
    pmm_manager->check();
ffffffffc0202cc0:	7b9c                	ld	a5,48(a5)
ffffffffc0202cc2:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0202cc4:	00005517          	auipc	a0,0x5
ffffffffc0202cc8:	aec50513          	addi	a0,a0,-1300 # ffffffffc02077b0 <default_pmm_manager+0x158>
ffffffffc0202ccc:	cc2fd0ef          	jal	ra,ffffffffc020018e <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0202cd0:	00008697          	auipc	a3,0x8
ffffffffc0202cd4:	33068693          	addi	a3,a3,816 # ffffffffc020b000 <boot_page_table_sv39>
ffffffffc0202cd8:	000a9797          	auipc	a5,0xa9
ffffffffc0202cdc:	78d7bc23          	sd	a3,1944(a5) # ffffffffc02ac470 <boot_pgdir>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0202ce0:	c02007b7          	lui	a5,0xc0200
ffffffffc0202ce4:	10f6eae3          	bltu	a3,a5,ffffffffc02035f8 <pmm_init+0xa72>
ffffffffc0202ce8:	0009b783          	ld	a5,0(s3)
ffffffffc0202cec:	8e9d                	sub	a3,a3,a5
ffffffffc0202cee:	000a9797          	auipc	a5,0xa9
ffffffffc0202cf2:	7ed7b923          	sd	a3,2034(a5) # ffffffffc02ac4e0 <boot_cr3>
    // assert(npage <= KMEMSIZE / PGSIZE);
    // The memory starts at 2GB in RISC-V
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();
ffffffffc0202cf6:	f7cff0ef          	jal	ra,ffffffffc0202472 <nr_free_pages>

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0202cfa:	6098                	ld	a4,0(s1)
ffffffffc0202cfc:	c80007b7          	lui	a5,0xc8000
ffffffffc0202d00:	83b1                	srli	a5,a5,0xc
    nr_free_store=nr_free_pages();
ffffffffc0202d02:	8a2a                	mv	s4,a0
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0202d04:	0ce7eae3          	bltu	a5,a4,ffffffffc02035d8 <pmm_init+0xa52>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0202d08:	6008                	ld	a0,0(s0)
ffffffffc0202d0a:	44050463          	beqz	a0,ffffffffc0203152 <pmm_init+0x5cc>
ffffffffc0202d0e:	6785                	lui	a5,0x1
ffffffffc0202d10:	17fd                	addi	a5,a5,-1
ffffffffc0202d12:	8fe9                	and	a5,a5,a0
ffffffffc0202d14:	2781                	sext.w	a5,a5
ffffffffc0202d16:	42079e63          	bnez	a5,ffffffffc0203152 <pmm_init+0x5cc>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0202d1a:	4601                	li	a2,0
ffffffffc0202d1c:	4581                	li	a1,0
ffffffffc0202d1e:	967ff0ef          	jal	ra,ffffffffc0202684 <get_page>
ffffffffc0202d22:	78051b63          	bnez	a0,ffffffffc02034b8 <pmm_init+0x932>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc0202d26:	4505                	li	a0,1
ffffffffc0202d28:	e7cff0ef          	jal	ra,ffffffffc02023a4 <alloc_pages>
ffffffffc0202d2c:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0202d2e:	6008                	ld	a0,0(s0)
ffffffffc0202d30:	4681                	li	a3,0
ffffffffc0202d32:	4601                	li	a2,0
ffffffffc0202d34:	85d6                	mv	a1,s5
ffffffffc0202d36:	d93ff0ef          	jal	ra,ffffffffc0202ac8 <page_insert>
ffffffffc0202d3a:	7a051f63          	bnez	a0,ffffffffc02034f8 <pmm_init+0x972>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0202d3e:	6008                	ld	a0,0(s0)
ffffffffc0202d40:	4601                	li	a2,0
ffffffffc0202d42:	4581                	li	a1,0
ffffffffc0202d44:	f6eff0ef          	jal	ra,ffffffffc02024b2 <get_pte>
ffffffffc0202d48:	78050863          	beqz	a0,ffffffffc02034d8 <pmm_init+0x952>
    assert(pte2page(*ptep) == p1);
ffffffffc0202d4c:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0202d4e:	0017f713          	andi	a4,a5,1
ffffffffc0202d52:	3e070463          	beqz	a4,ffffffffc020313a <pmm_init+0x5b4>
    if (PPN(pa) >= npage) {
ffffffffc0202d56:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202d58:	078a                	slli	a5,a5,0x2
ffffffffc0202d5a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202d5c:	3ce7f163          	bleu	a4,a5,ffffffffc020311e <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc0202d60:	00093683          	ld	a3,0(s2)
ffffffffc0202d64:	fff80637          	lui	a2,0xfff80
ffffffffc0202d68:	97b2                	add	a5,a5,a2
ffffffffc0202d6a:	079a                	slli	a5,a5,0x6
ffffffffc0202d6c:	97b6                	add	a5,a5,a3
ffffffffc0202d6e:	72fa9563          	bne	s5,a5,ffffffffc0203498 <pmm_init+0x912>
    assert(page_ref(p1) == 1);
ffffffffc0202d72:	000aab83          	lw	s7,0(s5) # 1000 <_binary_obj___user_faultread_out_size-0x8570>
ffffffffc0202d76:	4785                	li	a5,1
ffffffffc0202d78:	70fb9063          	bne	s7,a5,ffffffffc0203478 <pmm_init+0x8f2>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0202d7c:	6008                	ld	a0,0(s0)
ffffffffc0202d7e:	76fd                	lui	a3,0xfffff
ffffffffc0202d80:	611c                	ld	a5,0(a0)
ffffffffc0202d82:	078a                	slli	a5,a5,0x2
ffffffffc0202d84:	8ff5                	and	a5,a5,a3
ffffffffc0202d86:	00c7d613          	srli	a2,a5,0xc
ffffffffc0202d8a:	66e67e63          	bleu	a4,a2,ffffffffc0203406 <pmm_init+0x880>
ffffffffc0202d8e:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202d92:	97e2                	add	a5,a5,s8
ffffffffc0202d94:	0007bb03          	ld	s6,0(a5) # 1000 <_binary_obj___user_faultread_out_size-0x8570>
ffffffffc0202d98:	0b0a                	slli	s6,s6,0x2
ffffffffc0202d9a:	00db7b33          	and	s6,s6,a3
ffffffffc0202d9e:	00cb5793          	srli	a5,s6,0xc
ffffffffc0202da2:	56e7f863          	bleu	a4,a5,ffffffffc0203312 <pmm_init+0x78c>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0202da6:	4601                	li	a2,0
ffffffffc0202da8:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202daa:	9b62                	add	s6,s6,s8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0202dac:	f06ff0ef          	jal	ra,ffffffffc02024b2 <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202db0:	0b21                	addi	s6,s6,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0202db2:	55651063          	bne	a0,s6,ffffffffc02032f2 <pmm_init+0x76c>

    p2 = alloc_page();
ffffffffc0202db6:	4505                	li	a0,1
ffffffffc0202db8:	decff0ef          	jal	ra,ffffffffc02023a4 <alloc_pages>
ffffffffc0202dbc:	8b2a                	mv	s6,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0202dbe:	6008                	ld	a0,0(s0)
ffffffffc0202dc0:	46d1                	li	a3,20
ffffffffc0202dc2:	6605                	lui	a2,0x1
ffffffffc0202dc4:	85da                	mv	a1,s6
ffffffffc0202dc6:	d03ff0ef          	jal	ra,ffffffffc0202ac8 <page_insert>
ffffffffc0202dca:	50051463          	bnez	a0,ffffffffc02032d2 <pmm_init+0x74c>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0202dce:	6008                	ld	a0,0(s0)
ffffffffc0202dd0:	4601                	li	a2,0
ffffffffc0202dd2:	6585                	lui	a1,0x1
ffffffffc0202dd4:	edeff0ef          	jal	ra,ffffffffc02024b2 <get_pte>
ffffffffc0202dd8:	4c050d63          	beqz	a0,ffffffffc02032b2 <pmm_init+0x72c>
    assert(*ptep & PTE_U);
ffffffffc0202ddc:	611c                	ld	a5,0(a0)
ffffffffc0202dde:	0107f713          	andi	a4,a5,16
ffffffffc0202de2:	4a070863          	beqz	a4,ffffffffc0203292 <pmm_init+0x70c>
    assert(*ptep & PTE_W);
ffffffffc0202de6:	8b91                	andi	a5,a5,4
ffffffffc0202de8:	48078563          	beqz	a5,ffffffffc0203272 <pmm_init+0x6ec>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0202dec:	6008                	ld	a0,0(s0)
ffffffffc0202dee:	611c                	ld	a5,0(a0)
ffffffffc0202df0:	8bc1                	andi	a5,a5,16
ffffffffc0202df2:	46078063          	beqz	a5,ffffffffc0203252 <pmm_init+0x6cc>
    assert(page_ref(p2) == 1);
ffffffffc0202df6:	000b2783          	lw	a5,0(s6) # 200000 <_binary_obj___user_exit_out_size+0x1f5580>
ffffffffc0202dfa:	43779c63          	bne	a5,s7,ffffffffc0203232 <pmm_init+0x6ac>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0202dfe:	4681                	li	a3,0
ffffffffc0202e00:	6605                	lui	a2,0x1
ffffffffc0202e02:	85d6                	mv	a1,s5
ffffffffc0202e04:	cc5ff0ef          	jal	ra,ffffffffc0202ac8 <page_insert>
ffffffffc0202e08:	40051563          	bnez	a0,ffffffffc0203212 <pmm_init+0x68c>
    assert(page_ref(p1) == 2);
ffffffffc0202e0c:	000aa703          	lw	a4,0(s5)
ffffffffc0202e10:	4789                	li	a5,2
ffffffffc0202e12:	3ef71063          	bne	a4,a5,ffffffffc02031f2 <pmm_init+0x66c>
    assert(page_ref(p2) == 0);
ffffffffc0202e16:	000b2783          	lw	a5,0(s6)
ffffffffc0202e1a:	3a079c63          	bnez	a5,ffffffffc02031d2 <pmm_init+0x64c>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0202e1e:	6008                	ld	a0,0(s0)
ffffffffc0202e20:	4601                	li	a2,0
ffffffffc0202e22:	6585                	lui	a1,0x1
ffffffffc0202e24:	e8eff0ef          	jal	ra,ffffffffc02024b2 <get_pte>
ffffffffc0202e28:	38050563          	beqz	a0,ffffffffc02031b2 <pmm_init+0x62c>
    assert(pte2page(*ptep) == p1);
ffffffffc0202e2c:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0202e2e:	00177793          	andi	a5,a4,1
ffffffffc0202e32:	30078463          	beqz	a5,ffffffffc020313a <pmm_init+0x5b4>
    if (PPN(pa) >= npage) {
ffffffffc0202e36:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202e38:	00271793          	slli	a5,a4,0x2
ffffffffc0202e3c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202e3e:	2ed7f063          	bleu	a3,a5,ffffffffc020311e <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc0202e42:	00093683          	ld	a3,0(s2)
ffffffffc0202e46:	fff80637          	lui	a2,0xfff80
ffffffffc0202e4a:	97b2                	add	a5,a5,a2
ffffffffc0202e4c:	079a                	slli	a5,a5,0x6
ffffffffc0202e4e:	97b6                	add	a5,a5,a3
ffffffffc0202e50:	32fa9163          	bne	s5,a5,ffffffffc0203172 <pmm_init+0x5ec>
    assert((*ptep & PTE_U) == 0);
ffffffffc0202e54:	8b41                	andi	a4,a4,16
ffffffffc0202e56:	70071163          	bnez	a4,ffffffffc0203558 <pmm_init+0x9d2>

    page_remove(boot_pgdir, 0x0);
ffffffffc0202e5a:	6008                	ld	a0,0(s0)
ffffffffc0202e5c:	4581                	li	a1,0
ffffffffc0202e5e:	bf7ff0ef          	jal	ra,ffffffffc0202a54 <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc0202e62:	000aa703          	lw	a4,0(s5)
ffffffffc0202e66:	4785                	li	a5,1
ffffffffc0202e68:	6cf71863          	bne	a4,a5,ffffffffc0203538 <pmm_init+0x9b2>
    assert(page_ref(p2) == 0);
ffffffffc0202e6c:	000b2783          	lw	a5,0(s6)
ffffffffc0202e70:	6a079463          	bnez	a5,ffffffffc0203518 <pmm_init+0x992>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc0202e74:	6008                	ld	a0,0(s0)
ffffffffc0202e76:	6585                	lui	a1,0x1
ffffffffc0202e78:	bddff0ef          	jal	ra,ffffffffc0202a54 <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc0202e7c:	000aa783          	lw	a5,0(s5)
ffffffffc0202e80:	50079363          	bnez	a5,ffffffffc0203386 <pmm_init+0x800>
    assert(page_ref(p2) == 0);
ffffffffc0202e84:	000b2783          	lw	a5,0(s6)
ffffffffc0202e88:	4c079f63          	bnez	a5,ffffffffc0203366 <pmm_init+0x7e0>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0202e8c:	00043a83          	ld	s5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0202e90:	6090                	ld	a2,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202e92:	000ab783          	ld	a5,0(s5)
ffffffffc0202e96:	078a                	slli	a5,a5,0x2
ffffffffc0202e98:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202e9a:	28c7f263          	bleu	a2,a5,ffffffffc020311e <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc0202e9e:	fff80737          	lui	a4,0xfff80
ffffffffc0202ea2:	00093503          	ld	a0,0(s2)
ffffffffc0202ea6:	97ba                	add	a5,a5,a4
ffffffffc0202ea8:	079a                	slli	a5,a5,0x6
ffffffffc0202eaa:	00f50733          	add	a4,a0,a5
ffffffffc0202eae:	4314                	lw	a3,0(a4)
ffffffffc0202eb0:	4705                	li	a4,1
ffffffffc0202eb2:	48e69a63          	bne	a3,a4,ffffffffc0203346 <pmm_init+0x7c0>
    return page - pages + nbase;
ffffffffc0202eb6:	8799                	srai	a5,a5,0x6
ffffffffc0202eb8:	00080b37          	lui	s6,0x80
    return KADDR(page2pa(page));
ffffffffc0202ebc:	577d                	li	a4,-1
    return page - pages + nbase;
ffffffffc0202ebe:	97da                	add	a5,a5,s6
    return KADDR(page2pa(page));
ffffffffc0202ec0:	8331                	srli	a4,a4,0xc
ffffffffc0202ec2:	8f7d                	and	a4,a4,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0202ec4:	07b2                	slli	a5,a5,0xc
    return KADDR(page2pa(page));
ffffffffc0202ec6:	46c77363          	bleu	a2,a4,ffffffffc020332c <pmm_init+0x7a6>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc0202eca:	0009b683          	ld	a3,0(s3)
ffffffffc0202ece:	97b6                	add	a5,a5,a3
    return pa2page(PDE_ADDR(pde));
ffffffffc0202ed0:	639c                	ld	a5,0(a5)
ffffffffc0202ed2:	078a                	slli	a5,a5,0x2
ffffffffc0202ed4:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202ed6:	24c7f463          	bleu	a2,a5,ffffffffc020311e <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc0202eda:	416787b3          	sub	a5,a5,s6
ffffffffc0202ede:	079a                	slli	a5,a5,0x6
ffffffffc0202ee0:	953e                	add	a0,a0,a5
ffffffffc0202ee2:	4585                	li	a1,1
ffffffffc0202ee4:	d48ff0ef          	jal	ra,ffffffffc020242c <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0202ee8:	000ab783          	ld	a5,0(s5)
    if (PPN(pa) >= npage) {
ffffffffc0202eec:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202eee:	078a                	slli	a5,a5,0x2
ffffffffc0202ef0:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202ef2:	22e7f663          	bleu	a4,a5,ffffffffc020311e <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc0202ef6:	00093503          	ld	a0,0(s2)
ffffffffc0202efa:	416787b3          	sub	a5,a5,s6
ffffffffc0202efe:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc0202f00:	953e                	add	a0,a0,a5
ffffffffc0202f02:	4585                	li	a1,1
ffffffffc0202f04:	d28ff0ef          	jal	ra,ffffffffc020242c <free_pages>
    boot_pgdir[0] = 0;
ffffffffc0202f08:	601c                	ld	a5,0(s0)
ffffffffc0202f0a:	0007b023          	sd	zero,0(a5)
  asm volatile("sfence.vma");
ffffffffc0202f0e:	12000073          	sfence.vma
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc0202f12:	d60ff0ef          	jal	ra,ffffffffc0202472 <nr_free_pages>
ffffffffc0202f16:	68aa1163          	bne	s4,a0,ffffffffc0203598 <pmm_init+0xa12>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc0202f1a:	00005517          	auipc	a0,0x5
ffffffffc0202f1e:	b7e50513          	addi	a0,a0,-1154 # ffffffffc0207a98 <default_pmm_manager+0x440>
ffffffffc0202f22:	a6cfd0ef          	jal	ra,ffffffffc020018e <cprintf>
static void check_boot_pgdir(void) {
    size_t nr_free_store;
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();
ffffffffc0202f26:	d4cff0ef          	jal	ra,ffffffffc0202472 <nr_free_pages>

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0202f2a:	6098                	ld	a4,0(s1)
ffffffffc0202f2c:	c02007b7          	lui	a5,0xc0200
    nr_free_store=nr_free_pages();
ffffffffc0202f30:	8a2a                	mv	s4,a0
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0202f32:	00c71693          	slli	a3,a4,0xc
ffffffffc0202f36:	18d7f563          	bleu	a3,a5,ffffffffc02030c0 <pmm_init+0x53a>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202f3a:	83b1                	srli	a5,a5,0xc
ffffffffc0202f3c:	6008                	ld	a0,0(s0)
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0202f3e:	c0200ab7          	lui	s5,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202f42:	1ae7f163          	bleu	a4,a5,ffffffffc02030e4 <pmm_init+0x55e>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202f46:	7bfd                	lui	s7,0xfffff
ffffffffc0202f48:	6b05                	lui	s6,0x1
ffffffffc0202f4a:	a029                	j	ffffffffc0202f54 <pmm_init+0x3ce>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202f4c:	00cad713          	srli	a4,s5,0xc
ffffffffc0202f50:	18f77a63          	bleu	a5,a4,ffffffffc02030e4 <pmm_init+0x55e>
ffffffffc0202f54:	0009b583          	ld	a1,0(s3)
ffffffffc0202f58:	4601                	li	a2,0
ffffffffc0202f5a:	95d6                	add	a1,a1,s5
ffffffffc0202f5c:	d56ff0ef          	jal	ra,ffffffffc02024b2 <get_pte>
ffffffffc0202f60:	16050263          	beqz	a0,ffffffffc02030c4 <pmm_init+0x53e>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202f64:	611c                	ld	a5,0(a0)
ffffffffc0202f66:	078a                	slli	a5,a5,0x2
ffffffffc0202f68:	0177f7b3          	and	a5,a5,s7
ffffffffc0202f6c:	19579963          	bne	a5,s5,ffffffffc02030fe <pmm_init+0x578>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0202f70:	609c                	ld	a5,0(s1)
ffffffffc0202f72:	9ada                	add	s5,s5,s6
ffffffffc0202f74:	6008                	ld	a0,0(s0)
ffffffffc0202f76:	00c79713          	slli	a4,a5,0xc
ffffffffc0202f7a:	fceae9e3          	bltu	s5,a4,ffffffffc0202f4c <pmm_init+0x3c6>
    }


    assert(boot_pgdir[0] == 0);
ffffffffc0202f7e:	611c                	ld	a5,0(a0)
ffffffffc0202f80:	62079c63          	bnez	a5,ffffffffc02035b8 <pmm_init+0xa32>

    struct Page *p;
    p = alloc_page();
ffffffffc0202f84:	4505                	li	a0,1
ffffffffc0202f86:	c1eff0ef          	jal	ra,ffffffffc02023a4 <alloc_pages>
ffffffffc0202f8a:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0202f8c:	6008                	ld	a0,0(s0)
ffffffffc0202f8e:	4699                	li	a3,6
ffffffffc0202f90:	10000613          	li	a2,256
ffffffffc0202f94:	85d6                	mv	a1,s5
ffffffffc0202f96:	b33ff0ef          	jal	ra,ffffffffc0202ac8 <page_insert>
ffffffffc0202f9a:	1e051c63          	bnez	a0,ffffffffc0203192 <pmm_init+0x60c>
    assert(page_ref(p) == 1);
ffffffffc0202f9e:	000aa703          	lw	a4,0(s5) # ffffffffc0200000 <kern_entry>
ffffffffc0202fa2:	4785                	li	a5,1
ffffffffc0202fa4:	44f71163          	bne	a4,a5,ffffffffc02033e6 <pmm_init+0x860>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0202fa8:	6008                	ld	a0,0(s0)
ffffffffc0202faa:	6b05                	lui	s6,0x1
ffffffffc0202fac:	4699                	li	a3,6
ffffffffc0202fae:	100b0613          	addi	a2,s6,256 # 1100 <_binary_obj___user_faultread_out_size-0x8470>
ffffffffc0202fb2:	85d6                	mv	a1,s5
ffffffffc0202fb4:	b15ff0ef          	jal	ra,ffffffffc0202ac8 <page_insert>
ffffffffc0202fb8:	40051763          	bnez	a0,ffffffffc02033c6 <pmm_init+0x840>
    assert(page_ref(p) == 2);
ffffffffc0202fbc:	000aa703          	lw	a4,0(s5)
ffffffffc0202fc0:	4789                	li	a5,2
ffffffffc0202fc2:	3ef71263          	bne	a4,a5,ffffffffc02033a6 <pmm_init+0x820>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc0202fc6:	00005597          	auipc	a1,0x5
ffffffffc0202fca:	c0a58593          	addi	a1,a1,-1014 # ffffffffc0207bd0 <default_pmm_manager+0x578>
ffffffffc0202fce:	10000513          	li	a0,256
ffffffffc0202fd2:	736030ef          	jal	ra,ffffffffc0206708 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0202fd6:	100b0593          	addi	a1,s6,256
ffffffffc0202fda:	10000513          	li	a0,256
ffffffffc0202fde:	73c030ef          	jal	ra,ffffffffc020671a <strcmp>
ffffffffc0202fe2:	44051b63          	bnez	a0,ffffffffc0203438 <pmm_init+0x8b2>
    return page - pages + nbase;
ffffffffc0202fe6:	00093683          	ld	a3,0(s2)
ffffffffc0202fea:	00080737          	lui	a4,0x80
    return KADDR(page2pa(page));
ffffffffc0202fee:	5b7d                	li	s6,-1
    return page - pages + nbase;
ffffffffc0202ff0:	40da86b3          	sub	a3,s5,a3
ffffffffc0202ff4:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0202ff6:	609c                	ld	a5,0(s1)
    return page - pages + nbase;
ffffffffc0202ff8:	96ba                	add	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc0202ffa:	00cb5b13          	srli	s6,s6,0xc
ffffffffc0202ffe:	0166f733          	and	a4,a3,s6
    return page2ppn(page) << PGSHIFT;
ffffffffc0203002:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0203004:	10f77f63          	bleu	a5,a4,ffffffffc0203122 <pmm_init+0x59c>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0203008:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc020300c:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0203010:	96be                	add	a3,a3,a5
ffffffffc0203012:	10068023          	sb	zero,256(a3) # fffffffffffff100 <end+0x3fd52b20>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0203016:	6ae030ef          	jal	ra,ffffffffc02066c4 <strlen>
ffffffffc020301a:	54051f63          	bnez	a0,ffffffffc0203578 <pmm_init+0x9f2>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc020301e:	00043b83          	ld	s7,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0203022:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203024:	000bb683          	ld	a3,0(s7) # fffffffffffff000 <end+0x3fd52a20>
ffffffffc0203028:	068a                	slli	a3,a3,0x2
ffffffffc020302a:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc020302c:	0ef6f963          	bleu	a5,a3,ffffffffc020311e <pmm_init+0x598>
    return KADDR(page2pa(page));
ffffffffc0203030:	0166fb33          	and	s6,a3,s6
    return page2ppn(page) << PGSHIFT;
ffffffffc0203034:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0203036:	0efb7663          	bleu	a5,s6,ffffffffc0203122 <pmm_init+0x59c>
ffffffffc020303a:	0009b983          	ld	s3,0(s3)
    free_page(p);
ffffffffc020303e:	4585                	li	a1,1
ffffffffc0203040:	8556                	mv	a0,s5
ffffffffc0203042:	99b6                	add	s3,s3,a3
ffffffffc0203044:	be8ff0ef          	jal	ra,ffffffffc020242c <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0203048:	0009b783          	ld	a5,0(s3)
    if (PPN(pa) >= npage) {
ffffffffc020304c:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc020304e:	078a                	slli	a5,a5,0x2
ffffffffc0203050:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203052:	0ce7f663          	bleu	a4,a5,ffffffffc020311e <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc0203056:	00093503          	ld	a0,0(s2)
ffffffffc020305a:	fff809b7          	lui	s3,0xfff80
ffffffffc020305e:	97ce                	add	a5,a5,s3
ffffffffc0203060:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd0[0]));
ffffffffc0203062:	953e                	add	a0,a0,a5
ffffffffc0203064:	4585                	li	a1,1
ffffffffc0203066:	bc6ff0ef          	jal	ra,ffffffffc020242c <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc020306a:	000bb783          	ld	a5,0(s7)
    if (PPN(pa) >= npage) {
ffffffffc020306e:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203070:	078a                	slli	a5,a5,0x2
ffffffffc0203072:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203074:	0ae7f563          	bleu	a4,a5,ffffffffc020311e <pmm_init+0x598>
    return &pages[PPN(pa) - nbase];
ffffffffc0203078:	00093503          	ld	a0,0(s2)
ffffffffc020307c:	97ce                	add	a5,a5,s3
ffffffffc020307e:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc0203080:	953e                	add	a0,a0,a5
ffffffffc0203082:	4585                	li	a1,1
ffffffffc0203084:	ba8ff0ef          	jal	ra,ffffffffc020242c <free_pages>
    boot_pgdir[0] = 0;
ffffffffc0203088:	601c                	ld	a5,0(s0)
ffffffffc020308a:	0007b023          	sd	zero,0(a5) # ffffffffc0200000 <kern_entry>
  asm volatile("sfence.vma");
ffffffffc020308e:	12000073          	sfence.vma
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc0203092:	be0ff0ef          	jal	ra,ffffffffc0202472 <nr_free_pages>
ffffffffc0203096:	3caa1163          	bne	s4,a0,ffffffffc0203458 <pmm_init+0x8d2>

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc020309a:	00005517          	auipc	a0,0x5
ffffffffc020309e:	bae50513          	addi	a0,a0,-1106 # ffffffffc0207c48 <default_pmm_manager+0x5f0>
ffffffffc02030a2:	8ecfd0ef          	jal	ra,ffffffffc020018e <cprintf>
}
ffffffffc02030a6:	6406                	ld	s0,64(sp)
ffffffffc02030a8:	60a6                	ld	ra,72(sp)
ffffffffc02030aa:	74e2                	ld	s1,56(sp)
ffffffffc02030ac:	7942                	ld	s2,48(sp)
ffffffffc02030ae:	79a2                	ld	s3,40(sp)
ffffffffc02030b0:	7a02                	ld	s4,32(sp)
ffffffffc02030b2:	6ae2                	ld	s5,24(sp)
ffffffffc02030b4:	6b42                	ld	s6,16(sp)
ffffffffc02030b6:	6ba2                	ld	s7,8(sp)
ffffffffc02030b8:	6c02                	ld	s8,0(sp)
ffffffffc02030ba:	6161                	addi	sp,sp,80
    kmalloc_init();
ffffffffc02030bc:	8c8ff06f          	j	ffffffffc0202184 <kmalloc_init>
ffffffffc02030c0:	6008                	ld	a0,0(s0)
ffffffffc02030c2:	bd75                	j	ffffffffc0202f7e <pmm_init+0x3f8>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02030c4:	00005697          	auipc	a3,0x5
ffffffffc02030c8:	9f468693          	addi	a3,a3,-1548 # ffffffffc0207ab8 <default_pmm_manager+0x460>
ffffffffc02030cc:	00004617          	auipc	a2,0x4
ffffffffc02030d0:	cb460613          	addi	a2,a2,-844 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc02030d4:	22800593          	li	a1,552
ffffffffc02030d8:	00004517          	auipc	a0,0x4
ffffffffc02030dc:	64050513          	addi	a0,a0,1600 # ffffffffc0207718 <default_pmm_manager+0xc0>
ffffffffc02030e0:	ba4fd0ef          	jal	ra,ffffffffc0200484 <__panic>
ffffffffc02030e4:	86d6                	mv	a3,s5
ffffffffc02030e6:	00004617          	auipc	a2,0x4
ffffffffc02030ea:	05260613          	addi	a2,a2,82 # ffffffffc0207138 <commands+0x878>
ffffffffc02030ee:	22800593          	li	a1,552
ffffffffc02030f2:	00004517          	auipc	a0,0x4
ffffffffc02030f6:	62650513          	addi	a0,a0,1574 # ffffffffc0207718 <default_pmm_manager+0xc0>
ffffffffc02030fa:	b8afd0ef          	jal	ra,ffffffffc0200484 <__panic>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc02030fe:	00005697          	auipc	a3,0x5
ffffffffc0203102:	9fa68693          	addi	a3,a3,-1542 # ffffffffc0207af8 <default_pmm_manager+0x4a0>
ffffffffc0203106:	00004617          	auipc	a2,0x4
ffffffffc020310a:	c7a60613          	addi	a2,a2,-902 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc020310e:	22900593          	li	a1,553
ffffffffc0203112:	00004517          	auipc	a0,0x4
ffffffffc0203116:	60650513          	addi	a0,a0,1542 # ffffffffc0207718 <default_pmm_manager+0xc0>
ffffffffc020311a:	b6afd0ef          	jal	ra,ffffffffc0200484 <__panic>
ffffffffc020311e:	a6aff0ef          	jal	ra,ffffffffc0202388 <pa2page.part.4>
    return KADDR(page2pa(page));
ffffffffc0203122:	00004617          	auipc	a2,0x4
ffffffffc0203126:	01660613          	addi	a2,a2,22 # ffffffffc0207138 <commands+0x878>
ffffffffc020312a:	06a00593          	li	a1,106
ffffffffc020312e:	00004517          	auipc	a0,0x4
ffffffffc0203132:	11a50513          	addi	a0,a0,282 # ffffffffc0207248 <commands+0x988>
ffffffffc0203136:	b4efd0ef          	jal	ra,ffffffffc0200484 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc020313a:	00004617          	auipc	a2,0x4
ffffffffc020313e:	15660613          	addi	a2,a2,342 # ffffffffc0207290 <commands+0x9d0>
ffffffffc0203142:	07500593          	li	a1,117
ffffffffc0203146:	00004517          	auipc	a0,0x4
ffffffffc020314a:	10250513          	addi	a0,a0,258 # ffffffffc0207248 <commands+0x988>
ffffffffc020314e:	b36fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0203152:	00004697          	auipc	a3,0x4
ffffffffc0203156:	69e68693          	addi	a3,a3,1694 # ffffffffc02077f0 <default_pmm_manager+0x198>
ffffffffc020315a:	00004617          	auipc	a2,0x4
ffffffffc020315e:	c2660613          	addi	a2,a2,-986 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0203162:	1ec00593          	li	a1,492
ffffffffc0203166:	00004517          	auipc	a0,0x4
ffffffffc020316a:	5b250513          	addi	a0,a0,1458 # ffffffffc0207718 <default_pmm_manager+0xc0>
ffffffffc020316e:	b16fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0203172:	00004697          	auipc	a3,0x4
ffffffffc0203176:	73e68693          	addi	a3,a3,1854 # ffffffffc02078b0 <default_pmm_manager+0x258>
ffffffffc020317a:	00004617          	auipc	a2,0x4
ffffffffc020317e:	c0660613          	addi	a2,a2,-1018 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0203182:	20800593          	li	a1,520
ffffffffc0203186:	00004517          	auipc	a0,0x4
ffffffffc020318a:	59250513          	addi	a0,a0,1426 # ffffffffc0207718 <default_pmm_manager+0xc0>
ffffffffc020318e:	af6fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0203192:	00005697          	auipc	a3,0x5
ffffffffc0203196:	99668693          	addi	a3,a3,-1642 # ffffffffc0207b28 <default_pmm_manager+0x4d0>
ffffffffc020319a:	00004617          	auipc	a2,0x4
ffffffffc020319e:	be660613          	addi	a2,a2,-1050 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc02031a2:	23100593          	li	a1,561
ffffffffc02031a6:	00004517          	auipc	a0,0x4
ffffffffc02031aa:	57250513          	addi	a0,a0,1394 # ffffffffc0207718 <default_pmm_manager+0xc0>
ffffffffc02031ae:	ad6fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc02031b2:	00004697          	auipc	a3,0x4
ffffffffc02031b6:	78e68693          	addi	a3,a3,1934 # ffffffffc0207940 <default_pmm_manager+0x2e8>
ffffffffc02031ba:	00004617          	auipc	a2,0x4
ffffffffc02031be:	bc660613          	addi	a2,a2,-1082 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc02031c2:	20700593          	li	a1,519
ffffffffc02031c6:	00004517          	auipc	a0,0x4
ffffffffc02031ca:	55250513          	addi	a0,a0,1362 # ffffffffc0207718 <default_pmm_manager+0xc0>
ffffffffc02031ce:	ab6fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc02031d2:	00005697          	auipc	a3,0x5
ffffffffc02031d6:	83668693          	addi	a3,a3,-1994 # ffffffffc0207a08 <default_pmm_manager+0x3b0>
ffffffffc02031da:	00004617          	auipc	a2,0x4
ffffffffc02031de:	ba660613          	addi	a2,a2,-1114 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc02031e2:	20600593          	li	a1,518
ffffffffc02031e6:	00004517          	auipc	a0,0x4
ffffffffc02031ea:	53250513          	addi	a0,a0,1330 # ffffffffc0207718 <default_pmm_manager+0xc0>
ffffffffc02031ee:	a96fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc02031f2:	00004697          	auipc	a3,0x4
ffffffffc02031f6:	7fe68693          	addi	a3,a3,2046 # ffffffffc02079f0 <default_pmm_manager+0x398>
ffffffffc02031fa:	00004617          	auipc	a2,0x4
ffffffffc02031fe:	b8660613          	addi	a2,a2,-1146 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0203202:	20500593          	li	a1,517
ffffffffc0203206:	00004517          	auipc	a0,0x4
ffffffffc020320a:	51250513          	addi	a0,a0,1298 # ffffffffc0207718 <default_pmm_manager+0xc0>
ffffffffc020320e:	a76fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0203212:	00004697          	auipc	a3,0x4
ffffffffc0203216:	7ae68693          	addi	a3,a3,1966 # ffffffffc02079c0 <default_pmm_manager+0x368>
ffffffffc020321a:	00004617          	auipc	a2,0x4
ffffffffc020321e:	b6660613          	addi	a2,a2,-1178 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0203222:	20400593          	li	a1,516
ffffffffc0203226:	00004517          	auipc	a0,0x4
ffffffffc020322a:	4f250513          	addi	a0,a0,1266 # ffffffffc0207718 <default_pmm_manager+0xc0>
ffffffffc020322e:	a56fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc0203232:	00004697          	auipc	a3,0x4
ffffffffc0203236:	77668693          	addi	a3,a3,1910 # ffffffffc02079a8 <default_pmm_manager+0x350>
ffffffffc020323a:	00004617          	auipc	a2,0x4
ffffffffc020323e:	b4660613          	addi	a2,a2,-1210 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0203242:	20200593          	li	a1,514
ffffffffc0203246:	00004517          	auipc	a0,0x4
ffffffffc020324a:	4d250513          	addi	a0,a0,1234 # ffffffffc0207718 <default_pmm_manager+0xc0>
ffffffffc020324e:	a36fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0203252:	00004697          	auipc	a3,0x4
ffffffffc0203256:	73e68693          	addi	a3,a3,1854 # ffffffffc0207990 <default_pmm_manager+0x338>
ffffffffc020325a:	00004617          	auipc	a2,0x4
ffffffffc020325e:	b2660613          	addi	a2,a2,-1242 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0203262:	20100593          	li	a1,513
ffffffffc0203266:	00004517          	auipc	a0,0x4
ffffffffc020326a:	4b250513          	addi	a0,a0,1202 # ffffffffc0207718 <default_pmm_manager+0xc0>
ffffffffc020326e:	a16fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(*ptep & PTE_W);
ffffffffc0203272:	00004697          	auipc	a3,0x4
ffffffffc0203276:	70e68693          	addi	a3,a3,1806 # ffffffffc0207980 <default_pmm_manager+0x328>
ffffffffc020327a:	00004617          	auipc	a2,0x4
ffffffffc020327e:	b0660613          	addi	a2,a2,-1274 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0203282:	20000593          	li	a1,512
ffffffffc0203286:	00004517          	auipc	a0,0x4
ffffffffc020328a:	49250513          	addi	a0,a0,1170 # ffffffffc0207718 <default_pmm_manager+0xc0>
ffffffffc020328e:	9f6fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(*ptep & PTE_U);
ffffffffc0203292:	00004697          	auipc	a3,0x4
ffffffffc0203296:	6de68693          	addi	a3,a3,1758 # ffffffffc0207970 <default_pmm_manager+0x318>
ffffffffc020329a:	00004617          	auipc	a2,0x4
ffffffffc020329e:	ae660613          	addi	a2,a2,-1306 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc02032a2:	1ff00593          	li	a1,511
ffffffffc02032a6:	00004517          	auipc	a0,0x4
ffffffffc02032aa:	47250513          	addi	a0,a0,1138 # ffffffffc0207718 <default_pmm_manager+0xc0>
ffffffffc02032ae:	9d6fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc02032b2:	00004697          	auipc	a3,0x4
ffffffffc02032b6:	68e68693          	addi	a3,a3,1678 # ffffffffc0207940 <default_pmm_manager+0x2e8>
ffffffffc02032ba:	00004617          	auipc	a2,0x4
ffffffffc02032be:	ac660613          	addi	a2,a2,-1338 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc02032c2:	1fe00593          	li	a1,510
ffffffffc02032c6:	00004517          	auipc	a0,0x4
ffffffffc02032ca:	45250513          	addi	a0,a0,1106 # ffffffffc0207718 <default_pmm_manager+0xc0>
ffffffffc02032ce:	9b6fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc02032d2:	00004697          	auipc	a3,0x4
ffffffffc02032d6:	63668693          	addi	a3,a3,1590 # ffffffffc0207908 <default_pmm_manager+0x2b0>
ffffffffc02032da:	00004617          	auipc	a2,0x4
ffffffffc02032de:	aa660613          	addi	a2,a2,-1370 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc02032e2:	1fd00593          	li	a1,509
ffffffffc02032e6:	00004517          	auipc	a0,0x4
ffffffffc02032ea:	43250513          	addi	a0,a0,1074 # ffffffffc0207718 <default_pmm_manager+0xc0>
ffffffffc02032ee:	996fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc02032f2:	00004697          	auipc	a3,0x4
ffffffffc02032f6:	5ee68693          	addi	a3,a3,1518 # ffffffffc02078e0 <default_pmm_manager+0x288>
ffffffffc02032fa:	00004617          	auipc	a2,0x4
ffffffffc02032fe:	a8660613          	addi	a2,a2,-1402 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0203302:	1fa00593          	li	a1,506
ffffffffc0203306:	00004517          	auipc	a0,0x4
ffffffffc020330a:	41250513          	addi	a0,a0,1042 # ffffffffc0207718 <default_pmm_manager+0xc0>
ffffffffc020330e:	976fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0203312:	86da                	mv	a3,s6
ffffffffc0203314:	00004617          	auipc	a2,0x4
ffffffffc0203318:	e2460613          	addi	a2,a2,-476 # ffffffffc0207138 <commands+0x878>
ffffffffc020331c:	1f900593          	li	a1,505
ffffffffc0203320:	00004517          	auipc	a0,0x4
ffffffffc0203324:	3f850513          	addi	a0,a0,1016 # ffffffffc0207718 <default_pmm_manager+0xc0>
ffffffffc0203328:	95cfd0ef          	jal	ra,ffffffffc0200484 <__panic>
    return KADDR(page2pa(page));
ffffffffc020332c:	86be                	mv	a3,a5
ffffffffc020332e:	00004617          	auipc	a2,0x4
ffffffffc0203332:	e0a60613          	addi	a2,a2,-502 # ffffffffc0207138 <commands+0x878>
ffffffffc0203336:	06a00593          	li	a1,106
ffffffffc020333a:	00004517          	auipc	a0,0x4
ffffffffc020333e:	f0e50513          	addi	a0,a0,-242 # ffffffffc0207248 <commands+0x988>
ffffffffc0203342:	942fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0203346:	00004697          	auipc	a3,0x4
ffffffffc020334a:	70a68693          	addi	a3,a3,1802 # ffffffffc0207a50 <default_pmm_manager+0x3f8>
ffffffffc020334e:	00004617          	auipc	a2,0x4
ffffffffc0203352:	a3260613          	addi	a2,a2,-1486 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0203356:	21300593          	li	a1,531
ffffffffc020335a:	00004517          	auipc	a0,0x4
ffffffffc020335e:	3be50513          	addi	a0,a0,958 # ffffffffc0207718 <default_pmm_manager+0xc0>
ffffffffc0203362:	922fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0203366:	00004697          	auipc	a3,0x4
ffffffffc020336a:	6a268693          	addi	a3,a3,1698 # ffffffffc0207a08 <default_pmm_manager+0x3b0>
ffffffffc020336e:	00004617          	auipc	a2,0x4
ffffffffc0203372:	a1260613          	addi	a2,a2,-1518 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0203376:	21100593          	li	a1,529
ffffffffc020337a:	00004517          	auipc	a0,0x4
ffffffffc020337e:	39e50513          	addi	a0,a0,926 # ffffffffc0207718 <default_pmm_manager+0xc0>
ffffffffc0203382:	902fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc0203386:	00004697          	auipc	a3,0x4
ffffffffc020338a:	6b268693          	addi	a3,a3,1714 # ffffffffc0207a38 <default_pmm_manager+0x3e0>
ffffffffc020338e:	00004617          	auipc	a2,0x4
ffffffffc0203392:	9f260613          	addi	a2,a2,-1550 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0203396:	21000593          	li	a1,528
ffffffffc020339a:	00004517          	auipc	a0,0x4
ffffffffc020339e:	37e50513          	addi	a0,a0,894 # ffffffffc0207718 <default_pmm_manager+0xc0>
ffffffffc02033a2:	8e2fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_ref(p) == 2);
ffffffffc02033a6:	00005697          	auipc	a3,0x5
ffffffffc02033aa:	81268693          	addi	a3,a3,-2030 # ffffffffc0207bb8 <default_pmm_manager+0x560>
ffffffffc02033ae:	00004617          	auipc	a2,0x4
ffffffffc02033b2:	9d260613          	addi	a2,a2,-1582 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc02033b6:	23400593          	li	a1,564
ffffffffc02033ba:	00004517          	auipc	a0,0x4
ffffffffc02033be:	35e50513          	addi	a0,a0,862 # ffffffffc0207718 <default_pmm_manager+0xc0>
ffffffffc02033c2:	8c2fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc02033c6:	00004697          	auipc	a3,0x4
ffffffffc02033ca:	7b268693          	addi	a3,a3,1970 # ffffffffc0207b78 <default_pmm_manager+0x520>
ffffffffc02033ce:	00004617          	auipc	a2,0x4
ffffffffc02033d2:	9b260613          	addi	a2,a2,-1614 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc02033d6:	23300593          	li	a1,563
ffffffffc02033da:	00004517          	auipc	a0,0x4
ffffffffc02033de:	33e50513          	addi	a0,a0,830 # ffffffffc0207718 <default_pmm_manager+0xc0>
ffffffffc02033e2:	8a2fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_ref(p) == 1);
ffffffffc02033e6:	00004697          	auipc	a3,0x4
ffffffffc02033ea:	77a68693          	addi	a3,a3,1914 # ffffffffc0207b60 <default_pmm_manager+0x508>
ffffffffc02033ee:	00004617          	auipc	a2,0x4
ffffffffc02033f2:	99260613          	addi	a2,a2,-1646 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc02033f6:	23200593          	li	a1,562
ffffffffc02033fa:	00004517          	auipc	a0,0x4
ffffffffc02033fe:	31e50513          	addi	a0,a0,798 # ffffffffc0207718 <default_pmm_manager+0xc0>
ffffffffc0203402:	882fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0203406:	86be                	mv	a3,a5
ffffffffc0203408:	00004617          	auipc	a2,0x4
ffffffffc020340c:	d3060613          	addi	a2,a2,-720 # ffffffffc0207138 <commands+0x878>
ffffffffc0203410:	1f800593          	li	a1,504
ffffffffc0203414:	00004517          	auipc	a0,0x4
ffffffffc0203418:	30450513          	addi	a0,a0,772 # ffffffffc0207718 <default_pmm_manager+0xc0>
ffffffffc020341c:	868fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0203420:	00004617          	auipc	a2,0x4
ffffffffc0203424:	d6860613          	addi	a2,a2,-664 # ffffffffc0207188 <commands+0x8c8>
ffffffffc0203428:	08000593          	li	a1,128
ffffffffc020342c:	00004517          	auipc	a0,0x4
ffffffffc0203430:	2ec50513          	addi	a0,a0,748 # ffffffffc0207718 <default_pmm_manager+0xc0>
ffffffffc0203434:	850fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0203438:	00004697          	auipc	a3,0x4
ffffffffc020343c:	7b068693          	addi	a3,a3,1968 # ffffffffc0207be8 <default_pmm_manager+0x590>
ffffffffc0203440:	00004617          	auipc	a2,0x4
ffffffffc0203444:	94060613          	addi	a2,a2,-1728 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0203448:	23800593          	li	a1,568
ffffffffc020344c:	00004517          	auipc	a0,0x4
ffffffffc0203450:	2cc50513          	addi	a0,a0,716 # ffffffffc0207718 <default_pmm_manager+0xc0>
ffffffffc0203454:	830fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0203458:	00004697          	auipc	a3,0x4
ffffffffc020345c:	62068693          	addi	a3,a3,1568 # ffffffffc0207a78 <default_pmm_manager+0x420>
ffffffffc0203460:	00004617          	auipc	a2,0x4
ffffffffc0203464:	92060613          	addi	a2,a2,-1760 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0203468:	24400593          	li	a1,580
ffffffffc020346c:	00004517          	auipc	a0,0x4
ffffffffc0203470:	2ac50513          	addi	a0,a0,684 # ffffffffc0207718 <default_pmm_manager+0xc0>
ffffffffc0203474:	810fd0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0203478:	00004697          	auipc	a3,0x4
ffffffffc020347c:	45068693          	addi	a3,a3,1104 # ffffffffc02078c8 <default_pmm_manager+0x270>
ffffffffc0203480:	00004617          	auipc	a2,0x4
ffffffffc0203484:	90060613          	addi	a2,a2,-1792 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0203488:	1f600593          	li	a1,502
ffffffffc020348c:	00004517          	auipc	a0,0x4
ffffffffc0203490:	28c50513          	addi	a0,a0,652 # ffffffffc0207718 <default_pmm_manager+0xc0>
ffffffffc0203494:	ff1fc0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0203498:	00004697          	auipc	a3,0x4
ffffffffc020349c:	41868693          	addi	a3,a3,1048 # ffffffffc02078b0 <default_pmm_manager+0x258>
ffffffffc02034a0:	00004617          	auipc	a2,0x4
ffffffffc02034a4:	8e060613          	addi	a2,a2,-1824 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc02034a8:	1f500593          	li	a1,501
ffffffffc02034ac:	00004517          	auipc	a0,0x4
ffffffffc02034b0:	26c50513          	addi	a0,a0,620 # ffffffffc0207718 <default_pmm_manager+0xc0>
ffffffffc02034b4:	fd1fc0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc02034b8:	00004697          	auipc	a3,0x4
ffffffffc02034bc:	37068693          	addi	a3,a3,880 # ffffffffc0207828 <default_pmm_manager+0x1d0>
ffffffffc02034c0:	00004617          	auipc	a2,0x4
ffffffffc02034c4:	8c060613          	addi	a2,a2,-1856 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc02034c8:	1ed00593          	li	a1,493
ffffffffc02034cc:	00004517          	auipc	a0,0x4
ffffffffc02034d0:	24c50513          	addi	a0,a0,588 # ffffffffc0207718 <default_pmm_manager+0xc0>
ffffffffc02034d4:	fb1fc0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc02034d8:	00004697          	auipc	a3,0x4
ffffffffc02034dc:	3a868693          	addi	a3,a3,936 # ffffffffc0207880 <default_pmm_manager+0x228>
ffffffffc02034e0:	00004617          	auipc	a2,0x4
ffffffffc02034e4:	8a060613          	addi	a2,a2,-1888 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc02034e8:	1f400593          	li	a1,500
ffffffffc02034ec:	00004517          	auipc	a0,0x4
ffffffffc02034f0:	22c50513          	addi	a0,a0,556 # ffffffffc0207718 <default_pmm_manager+0xc0>
ffffffffc02034f4:	f91fc0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc02034f8:	00004697          	auipc	a3,0x4
ffffffffc02034fc:	35868693          	addi	a3,a3,856 # ffffffffc0207850 <default_pmm_manager+0x1f8>
ffffffffc0203500:	00004617          	auipc	a2,0x4
ffffffffc0203504:	88060613          	addi	a2,a2,-1920 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0203508:	1f100593          	li	a1,497
ffffffffc020350c:	00004517          	auipc	a0,0x4
ffffffffc0203510:	20c50513          	addi	a0,a0,524 # ffffffffc0207718 <default_pmm_manager+0xc0>
ffffffffc0203514:	f71fc0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0203518:	00004697          	auipc	a3,0x4
ffffffffc020351c:	4f068693          	addi	a3,a3,1264 # ffffffffc0207a08 <default_pmm_manager+0x3b0>
ffffffffc0203520:	00004617          	auipc	a2,0x4
ffffffffc0203524:	86060613          	addi	a2,a2,-1952 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0203528:	20d00593          	li	a1,525
ffffffffc020352c:	00004517          	auipc	a0,0x4
ffffffffc0203530:	1ec50513          	addi	a0,a0,492 # ffffffffc0207718 <default_pmm_manager+0xc0>
ffffffffc0203534:	f51fc0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0203538:	00004697          	auipc	a3,0x4
ffffffffc020353c:	39068693          	addi	a3,a3,912 # ffffffffc02078c8 <default_pmm_manager+0x270>
ffffffffc0203540:	00004617          	auipc	a2,0x4
ffffffffc0203544:	84060613          	addi	a2,a2,-1984 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0203548:	20c00593          	li	a1,524
ffffffffc020354c:	00004517          	auipc	a0,0x4
ffffffffc0203550:	1cc50513          	addi	a0,a0,460 # ffffffffc0207718 <default_pmm_manager+0xc0>
ffffffffc0203554:	f31fc0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc0203558:	00004697          	auipc	a3,0x4
ffffffffc020355c:	4c868693          	addi	a3,a3,1224 # ffffffffc0207a20 <default_pmm_manager+0x3c8>
ffffffffc0203560:	00004617          	auipc	a2,0x4
ffffffffc0203564:	82060613          	addi	a2,a2,-2016 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0203568:	20900593          	li	a1,521
ffffffffc020356c:	00004517          	auipc	a0,0x4
ffffffffc0203570:	1ac50513          	addi	a0,a0,428 # ffffffffc0207718 <default_pmm_manager+0xc0>
ffffffffc0203574:	f11fc0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0203578:	00004697          	auipc	a3,0x4
ffffffffc020357c:	6a868693          	addi	a3,a3,1704 # ffffffffc0207c20 <default_pmm_manager+0x5c8>
ffffffffc0203580:	00004617          	auipc	a2,0x4
ffffffffc0203584:	80060613          	addi	a2,a2,-2048 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0203588:	23b00593          	li	a1,571
ffffffffc020358c:	00004517          	auipc	a0,0x4
ffffffffc0203590:	18c50513          	addi	a0,a0,396 # ffffffffc0207718 <default_pmm_manager+0xc0>
ffffffffc0203594:	ef1fc0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0203598:	00004697          	auipc	a3,0x4
ffffffffc020359c:	4e068693          	addi	a3,a3,1248 # ffffffffc0207a78 <default_pmm_manager+0x420>
ffffffffc02035a0:	00003617          	auipc	a2,0x3
ffffffffc02035a4:	7e060613          	addi	a2,a2,2016 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc02035a8:	21b00593          	li	a1,539
ffffffffc02035ac:	00004517          	auipc	a0,0x4
ffffffffc02035b0:	16c50513          	addi	a0,a0,364 # ffffffffc0207718 <default_pmm_manager+0xc0>
ffffffffc02035b4:	ed1fc0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc02035b8:	00004697          	auipc	a3,0x4
ffffffffc02035bc:	55868693          	addi	a3,a3,1368 # ffffffffc0207b10 <default_pmm_manager+0x4b8>
ffffffffc02035c0:	00003617          	auipc	a2,0x3
ffffffffc02035c4:	7c060613          	addi	a2,a2,1984 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc02035c8:	22d00593          	li	a1,557
ffffffffc02035cc:	00004517          	auipc	a0,0x4
ffffffffc02035d0:	14c50513          	addi	a0,a0,332 # ffffffffc0207718 <default_pmm_manager+0xc0>
ffffffffc02035d4:	eb1fc0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc02035d8:	00004697          	auipc	a3,0x4
ffffffffc02035dc:	1f868693          	addi	a3,a3,504 # ffffffffc02077d0 <default_pmm_manager+0x178>
ffffffffc02035e0:	00003617          	auipc	a2,0x3
ffffffffc02035e4:	7a060613          	addi	a2,a2,1952 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc02035e8:	1eb00593          	li	a1,491
ffffffffc02035ec:	00004517          	auipc	a0,0x4
ffffffffc02035f0:	12c50513          	addi	a0,a0,300 # ffffffffc0207718 <default_pmm_manager+0xc0>
ffffffffc02035f4:	e91fc0ef          	jal	ra,ffffffffc0200484 <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc02035f8:	00004617          	auipc	a2,0x4
ffffffffc02035fc:	b9060613          	addi	a2,a2,-1136 # ffffffffc0207188 <commands+0x8c8>
ffffffffc0203600:	0c200593          	li	a1,194
ffffffffc0203604:	00004517          	auipc	a0,0x4
ffffffffc0203608:	11450513          	addi	a0,a0,276 # ffffffffc0207718 <default_pmm_manager+0xc0>
ffffffffc020360c:	e79fc0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0203610 <tlb_invalidate>:
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0203610:	12058073          	sfence.vma	a1
}
ffffffffc0203614:	8082                	ret

ffffffffc0203616 <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0203616:	7179                	addi	sp,sp,-48
ffffffffc0203618:	e84a                	sd	s2,16(sp)
ffffffffc020361a:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc020361c:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc020361e:	f022                	sd	s0,32(sp)
ffffffffc0203620:	ec26                	sd	s1,24(sp)
ffffffffc0203622:	e44e                	sd	s3,8(sp)
ffffffffc0203624:	f406                	sd	ra,40(sp)
ffffffffc0203626:	84ae                	mv	s1,a1
ffffffffc0203628:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc020362a:	d7bfe0ef          	jal	ra,ffffffffc02023a4 <alloc_pages>
ffffffffc020362e:	842a                	mv	s0,a0
    if (page != NULL) {
ffffffffc0203630:	cd1d                	beqz	a0,ffffffffc020366e <pgdir_alloc_page+0x58>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc0203632:	85aa                	mv	a1,a0
ffffffffc0203634:	86ce                	mv	a3,s3
ffffffffc0203636:	8626                	mv	a2,s1
ffffffffc0203638:	854a                	mv	a0,s2
ffffffffc020363a:	c8eff0ef          	jal	ra,ffffffffc0202ac8 <page_insert>
ffffffffc020363e:	e121                	bnez	a0,ffffffffc020367e <pgdir_alloc_page+0x68>
        if (swap_init_ok) {
ffffffffc0203640:	000a9797          	auipc	a5,0xa9
ffffffffc0203644:	e4878793          	addi	a5,a5,-440 # ffffffffc02ac488 <swap_init_ok>
ffffffffc0203648:	439c                	lw	a5,0(a5)
ffffffffc020364a:	2781                	sext.w	a5,a5
ffffffffc020364c:	c38d                	beqz	a5,ffffffffc020366e <pgdir_alloc_page+0x58>
            if (check_mm_struct != NULL) {
ffffffffc020364e:	000a9797          	auipc	a5,0xa9
ffffffffc0203652:	f7a78793          	addi	a5,a5,-134 # ffffffffc02ac5c8 <check_mm_struct>
ffffffffc0203656:	6388                	ld	a0,0(a5)
ffffffffc0203658:	c919                	beqz	a0,ffffffffc020366e <pgdir_alloc_page+0x58>
                swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc020365a:	4681                	li	a3,0
ffffffffc020365c:	8622                	mv	a2,s0
ffffffffc020365e:	85a6                	mv	a1,s1
ffffffffc0203660:	7da000ef          	jal	ra,ffffffffc0203e3a <swap_map_swappable>
                assert(page_ref(page) == 1);
ffffffffc0203664:	4018                	lw	a4,0(s0)
                page->pra_vaddr = la;
ffffffffc0203666:	fc04                	sd	s1,56(s0)
                assert(page_ref(page) == 1);
ffffffffc0203668:	4785                	li	a5,1
ffffffffc020366a:	02f71063          	bne	a4,a5,ffffffffc020368a <pgdir_alloc_page+0x74>
}
ffffffffc020366e:	8522                	mv	a0,s0
ffffffffc0203670:	70a2                	ld	ra,40(sp)
ffffffffc0203672:	7402                	ld	s0,32(sp)
ffffffffc0203674:	64e2                	ld	s1,24(sp)
ffffffffc0203676:	6942                	ld	s2,16(sp)
ffffffffc0203678:	69a2                	ld	s3,8(sp)
ffffffffc020367a:	6145                	addi	sp,sp,48
ffffffffc020367c:	8082                	ret
            free_page(page);
ffffffffc020367e:	8522                	mv	a0,s0
ffffffffc0203680:	4585                	li	a1,1
ffffffffc0203682:	dabfe0ef          	jal	ra,ffffffffc020242c <free_pages>
            return NULL;
ffffffffc0203686:	4401                	li	s0,0
ffffffffc0203688:	b7dd                	j	ffffffffc020366e <pgdir_alloc_page+0x58>
                assert(page_ref(page) == 1);
ffffffffc020368a:	00004697          	auipc	a3,0x4
ffffffffc020368e:	09e68693          	addi	a3,a3,158 # ffffffffc0207728 <default_pmm_manager+0xd0>
ffffffffc0203692:	00003617          	auipc	a2,0x3
ffffffffc0203696:	6ee60613          	addi	a2,a2,1774 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc020369a:	1cc00593          	li	a1,460
ffffffffc020369e:	00004517          	auipc	a0,0x4
ffffffffc02036a2:	07a50513          	addi	a0,a0,122 # ffffffffc0207718 <default_pmm_manager+0xc0>
ffffffffc02036a6:	ddffc0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc02036aa <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
ffffffffc02036aa:	7135                	addi	sp,sp,-160
ffffffffc02036ac:	ed06                	sd	ra,152(sp)
ffffffffc02036ae:	e922                	sd	s0,144(sp)
ffffffffc02036b0:	e526                	sd	s1,136(sp)
ffffffffc02036b2:	e14a                	sd	s2,128(sp)
ffffffffc02036b4:	fcce                	sd	s3,120(sp)
ffffffffc02036b6:	f8d2                	sd	s4,112(sp)
ffffffffc02036b8:	f4d6                	sd	s5,104(sp)
ffffffffc02036ba:	f0da                	sd	s6,96(sp)
ffffffffc02036bc:	ecde                	sd	s7,88(sp)
ffffffffc02036be:	e8e2                	sd	s8,80(sp)
ffffffffc02036c0:	e4e6                	sd	s9,72(sp)
ffffffffc02036c2:	e0ea                	sd	s10,64(sp)
ffffffffc02036c4:	fc6e                	sd	s11,56(sp)
     swapfs_init();
ffffffffc02036c6:	724010ef          	jal	ra,ffffffffc0204dea <swapfs_init>

     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc02036ca:	000a9797          	auipc	a5,0xa9
ffffffffc02036ce:	eae78793          	addi	a5,a5,-338 # ffffffffc02ac578 <max_swap_offset>
ffffffffc02036d2:	6394                	ld	a3,0(a5)
ffffffffc02036d4:	010007b7          	lui	a5,0x1000
ffffffffc02036d8:	17e1                	addi	a5,a5,-8
ffffffffc02036da:	ff968713          	addi	a4,a3,-7
ffffffffc02036de:	4ae7ee63          	bltu	a5,a4,ffffffffc0203b9a <swap_init+0x4f0>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }
     

     sm = &swap_manager_fifo;
ffffffffc02036e2:	0009e797          	auipc	a5,0x9e
ffffffffc02036e6:	92678793          	addi	a5,a5,-1754 # ffffffffc02a1008 <swap_manager_fifo>
     int r = sm->init();
ffffffffc02036ea:	6798                	ld	a4,8(a5)
     sm = &swap_manager_fifo;
ffffffffc02036ec:	000a9697          	auipc	a3,0xa9
ffffffffc02036f0:	d8f6ba23          	sd	a5,-620(a3) # ffffffffc02ac480 <sm>
     int r = sm->init();
ffffffffc02036f4:	9702                	jalr	a4
ffffffffc02036f6:	8aaa                	mv	s5,a0
     
     if (r == 0)
ffffffffc02036f8:	c10d                	beqz	a0,ffffffffc020371a <swap_init+0x70>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc02036fa:	60ea                	ld	ra,152(sp)
ffffffffc02036fc:	644a                	ld	s0,144(sp)
ffffffffc02036fe:	8556                	mv	a0,s5
ffffffffc0203700:	64aa                	ld	s1,136(sp)
ffffffffc0203702:	690a                	ld	s2,128(sp)
ffffffffc0203704:	79e6                	ld	s3,120(sp)
ffffffffc0203706:	7a46                	ld	s4,112(sp)
ffffffffc0203708:	7aa6                	ld	s5,104(sp)
ffffffffc020370a:	7b06                	ld	s6,96(sp)
ffffffffc020370c:	6be6                	ld	s7,88(sp)
ffffffffc020370e:	6c46                	ld	s8,80(sp)
ffffffffc0203710:	6ca6                	ld	s9,72(sp)
ffffffffc0203712:	6d06                	ld	s10,64(sp)
ffffffffc0203714:	7de2                	ld	s11,56(sp)
ffffffffc0203716:	610d                	addi	sp,sp,160
ffffffffc0203718:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc020371a:	000a9797          	auipc	a5,0xa9
ffffffffc020371e:	d6678793          	addi	a5,a5,-666 # ffffffffc02ac480 <sm>
ffffffffc0203722:	639c                	ld	a5,0(a5)
ffffffffc0203724:	00004517          	auipc	a0,0x4
ffffffffc0203728:	5c450513          	addi	a0,a0,1476 # ffffffffc0207ce8 <default_pmm_manager+0x690>
    return listelm->next;
ffffffffc020372c:	000a9417          	auipc	s0,0xa9
ffffffffc0203730:	d8c40413          	addi	s0,s0,-628 # ffffffffc02ac4b8 <free_area>
ffffffffc0203734:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc0203736:	4785                	li	a5,1
ffffffffc0203738:	000a9717          	auipc	a4,0xa9
ffffffffc020373c:	d4f72823          	sw	a5,-688(a4) # ffffffffc02ac488 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0203740:	a4ffc0ef          	jal	ra,ffffffffc020018e <cprintf>
ffffffffc0203744:	641c                	ld	a5,8(s0)
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0203746:	36878e63          	beq	a5,s0,ffffffffc0203ac2 <swap_init+0x418>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc020374a:	ff07b703          	ld	a4,-16(a5)
ffffffffc020374e:	8305                	srli	a4,a4,0x1
ffffffffc0203750:	8b05                	andi	a4,a4,1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0203752:	36070c63          	beqz	a4,ffffffffc0203aca <swap_init+0x420>
     int ret, count = 0, total = 0, i;
ffffffffc0203756:	4481                	li	s1,0
ffffffffc0203758:	4901                	li	s2,0
ffffffffc020375a:	a031                	j	ffffffffc0203766 <swap_init+0xbc>
ffffffffc020375c:	ff07b703          	ld	a4,-16(a5)
        assert(PageProperty(p));
ffffffffc0203760:	8b09                	andi	a4,a4,2
ffffffffc0203762:	36070463          	beqz	a4,ffffffffc0203aca <swap_init+0x420>
        count ++, total += p->property;
ffffffffc0203766:	ff87a703          	lw	a4,-8(a5)
ffffffffc020376a:	679c                	ld	a5,8(a5)
ffffffffc020376c:	2905                	addiw	s2,s2,1
ffffffffc020376e:	9cb9                	addw	s1,s1,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc0203770:	fe8796e3          	bne	a5,s0,ffffffffc020375c <swap_init+0xb2>
ffffffffc0203774:	89a6                	mv	s3,s1
     }
     assert(total == nr_free_pages());
ffffffffc0203776:	cfdfe0ef          	jal	ra,ffffffffc0202472 <nr_free_pages>
ffffffffc020377a:	69351863          	bne	a0,s3,ffffffffc0203e0a <swap_init+0x760>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc020377e:	8626                	mv	a2,s1
ffffffffc0203780:	85ca                	mv	a1,s2
ffffffffc0203782:	00004517          	auipc	a0,0x4
ffffffffc0203786:	57e50513          	addi	a0,a0,1406 # ffffffffc0207d00 <default_pmm_manager+0x6a8>
ffffffffc020378a:	a05fc0ef          	jal	ra,ffffffffc020018e <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc020378e:	457000ef          	jal	ra,ffffffffc02043e4 <mm_create>
ffffffffc0203792:	8baa                	mv	s7,a0
     assert(mm != NULL);
ffffffffc0203794:	60050b63          	beqz	a0,ffffffffc0203daa <swap_init+0x700>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc0203798:	000a9797          	auipc	a5,0xa9
ffffffffc020379c:	e3078793          	addi	a5,a5,-464 # ffffffffc02ac5c8 <check_mm_struct>
ffffffffc02037a0:	639c                	ld	a5,0(a5)
ffffffffc02037a2:	62079463          	bnez	a5,ffffffffc0203dca <swap_init+0x720>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02037a6:	000a9797          	auipc	a5,0xa9
ffffffffc02037aa:	cca78793          	addi	a5,a5,-822 # ffffffffc02ac470 <boot_pgdir>
ffffffffc02037ae:	0007bb03          	ld	s6,0(a5)
     check_mm_struct = mm;
ffffffffc02037b2:	000a9797          	auipc	a5,0xa9
ffffffffc02037b6:	e0a7bb23          	sd	a0,-490(a5) # ffffffffc02ac5c8 <check_mm_struct>
     assert(pgdir[0] == 0);
ffffffffc02037ba:	000b3783          	ld	a5,0(s6)
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02037be:	01653c23          	sd	s6,24(a0)
     assert(pgdir[0] == 0);
ffffffffc02037c2:	4e079863          	bnez	a5,ffffffffc0203cb2 <swap_init+0x608>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc02037c6:	6599                	lui	a1,0x6
ffffffffc02037c8:	460d                	li	a2,3
ffffffffc02037ca:	6505                	lui	a0,0x1
ffffffffc02037cc:	465000ef          	jal	ra,ffffffffc0204430 <vma_create>
ffffffffc02037d0:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc02037d2:	50050063          	beqz	a0,ffffffffc0203cd2 <swap_init+0x628>

     insert_vma_struct(mm, vma);
ffffffffc02037d6:	855e                	mv	a0,s7
ffffffffc02037d8:	4c5000ef          	jal	ra,ffffffffc020449c <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc02037dc:	00004517          	auipc	a0,0x4
ffffffffc02037e0:	59450513          	addi	a0,a0,1428 # ffffffffc0207d70 <default_pmm_manager+0x718>
ffffffffc02037e4:	9abfc0ef          	jal	ra,ffffffffc020018e <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc02037e8:	018bb503          	ld	a0,24(s7)
ffffffffc02037ec:	4605                	li	a2,1
ffffffffc02037ee:	6585                	lui	a1,0x1
ffffffffc02037f0:	cc3fe0ef          	jal	ra,ffffffffc02024b2 <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc02037f4:	4e050f63          	beqz	a0,ffffffffc0203cf2 <swap_init+0x648>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc02037f8:	00004517          	auipc	a0,0x4
ffffffffc02037fc:	5c850513          	addi	a0,a0,1480 # ffffffffc0207dc0 <default_pmm_manager+0x768>
ffffffffc0203800:	000a9997          	auipc	s3,0xa9
ffffffffc0203804:	cf098993          	addi	s3,s3,-784 # ffffffffc02ac4f0 <check_rp>
ffffffffc0203808:	987fc0ef          	jal	ra,ffffffffc020018e <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020380c:	000a9a17          	auipc	s4,0xa9
ffffffffc0203810:	d04a0a13          	addi	s4,s4,-764 # ffffffffc02ac510 <swap_in_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0203814:	8c4e                	mv	s8,s3
          check_rp[i] = alloc_page();
ffffffffc0203816:	4505                	li	a0,1
ffffffffc0203818:	b8dfe0ef          	jal	ra,ffffffffc02023a4 <alloc_pages>
ffffffffc020381c:	00ac3023          	sd	a0,0(s8) # 200000 <_binary_obj___user_exit_out_size+0x1f5580>
          assert(check_rp[i] != NULL );
ffffffffc0203820:	32050d63          	beqz	a0,ffffffffc0203b5a <swap_init+0x4b0>
ffffffffc0203824:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc0203826:	8b89                	andi	a5,a5,2
ffffffffc0203828:	30079963          	bnez	a5,ffffffffc0203b3a <swap_init+0x490>
ffffffffc020382c:	0c21                	addi	s8,s8,8
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020382e:	ff4c14e3          	bne	s8,s4,ffffffffc0203816 <swap_init+0x16c>
     }
     list_entry_t free_list_store = free_list;
ffffffffc0203832:	601c                	ld	a5,0(s0)
     assert(list_empty(&free_list));
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
     nr_free = 0;
ffffffffc0203834:	000a9c17          	auipc	s8,0xa9
ffffffffc0203838:	cbcc0c13          	addi	s8,s8,-836 # ffffffffc02ac4f0 <check_rp>
     list_entry_t free_list_store = free_list;
ffffffffc020383c:	ec3e                	sd	a5,24(sp)
ffffffffc020383e:	641c                	ld	a5,8(s0)
ffffffffc0203840:	f03e                	sd	a5,32(sp)
     unsigned int nr_free_store = nr_free;
ffffffffc0203842:	481c                	lw	a5,16(s0)
ffffffffc0203844:	f43e                	sd	a5,40(sp)
    elm->prev = elm->next = elm;
ffffffffc0203846:	000a9797          	auipc	a5,0xa9
ffffffffc020384a:	c687bd23          	sd	s0,-902(a5) # ffffffffc02ac4c0 <free_area+0x8>
ffffffffc020384e:	000a9797          	auipc	a5,0xa9
ffffffffc0203852:	c687b523          	sd	s0,-918(a5) # ffffffffc02ac4b8 <free_area>
     nr_free = 0;
ffffffffc0203856:	000a9797          	auipc	a5,0xa9
ffffffffc020385a:	c607a923          	sw	zero,-910(a5) # ffffffffc02ac4c8 <free_area+0x10>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
        free_pages(check_rp[i],1);
ffffffffc020385e:	000c3503          	ld	a0,0(s8)
ffffffffc0203862:	4585                	li	a1,1
ffffffffc0203864:	0c21                	addi	s8,s8,8
ffffffffc0203866:	bc7fe0ef          	jal	ra,ffffffffc020242c <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020386a:	ff4c1ae3          	bne	s8,s4,ffffffffc020385e <swap_init+0x1b4>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc020386e:	01042c03          	lw	s8,16(s0)
ffffffffc0203872:	4791                	li	a5,4
ffffffffc0203874:	50fc1b63          	bne	s8,a5,ffffffffc0203d8a <swap_init+0x6e0>
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc0203878:	00004517          	auipc	a0,0x4
ffffffffc020387c:	5d050513          	addi	a0,a0,1488 # ffffffffc0207e48 <default_pmm_manager+0x7f0>
ffffffffc0203880:	90ffc0ef          	jal	ra,ffffffffc020018e <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203884:	6685                	lui	a3,0x1
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc0203886:	000a9797          	auipc	a5,0xa9
ffffffffc020388a:	c007a323          	sw	zero,-1018(a5) # ffffffffc02ac48c <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc020388e:	4629                	li	a2,10
     pgfault_num=0;
ffffffffc0203890:	000a9797          	auipc	a5,0xa9
ffffffffc0203894:	bfc78793          	addi	a5,a5,-1028 # ffffffffc02ac48c <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203898:	00c68023          	sb	a2,0(a3) # 1000 <_binary_obj___user_faultread_out_size-0x8570>
     assert(pgfault_num==1);
ffffffffc020389c:	4398                	lw	a4,0(a5)
ffffffffc020389e:	4585                	li	a1,1
ffffffffc02038a0:	2701                	sext.w	a4,a4
ffffffffc02038a2:	38b71863          	bne	a4,a1,ffffffffc0203c32 <swap_init+0x588>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc02038a6:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==1);
ffffffffc02038aa:	4394                	lw	a3,0(a5)
ffffffffc02038ac:	2681                	sext.w	a3,a3
ffffffffc02038ae:	3ae69263          	bne	a3,a4,ffffffffc0203c52 <swap_init+0x5a8>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc02038b2:	6689                	lui	a3,0x2
ffffffffc02038b4:	462d                	li	a2,11
ffffffffc02038b6:	00c68023          	sb	a2,0(a3) # 2000 <_binary_obj___user_faultread_out_size-0x7570>
     assert(pgfault_num==2);
ffffffffc02038ba:	4398                	lw	a4,0(a5)
ffffffffc02038bc:	4589                	li	a1,2
ffffffffc02038be:	2701                	sext.w	a4,a4
ffffffffc02038c0:	2eb71963          	bne	a4,a1,ffffffffc0203bb2 <swap_init+0x508>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc02038c4:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==2);
ffffffffc02038c8:	4394                	lw	a3,0(a5)
ffffffffc02038ca:	2681                	sext.w	a3,a3
ffffffffc02038cc:	30e69363          	bne	a3,a4,ffffffffc0203bd2 <swap_init+0x528>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc02038d0:	668d                	lui	a3,0x3
ffffffffc02038d2:	4631                	li	a2,12
ffffffffc02038d4:	00c68023          	sb	a2,0(a3) # 3000 <_binary_obj___user_faultread_out_size-0x6570>
     assert(pgfault_num==3);
ffffffffc02038d8:	4398                	lw	a4,0(a5)
ffffffffc02038da:	458d                	li	a1,3
ffffffffc02038dc:	2701                	sext.w	a4,a4
ffffffffc02038de:	30b71a63          	bne	a4,a1,ffffffffc0203bf2 <swap_init+0x548>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc02038e2:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==3);
ffffffffc02038e6:	4394                	lw	a3,0(a5)
ffffffffc02038e8:	2681                	sext.w	a3,a3
ffffffffc02038ea:	32e69463          	bne	a3,a4,ffffffffc0203c12 <swap_init+0x568>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc02038ee:	6691                	lui	a3,0x4
ffffffffc02038f0:	4635                	li	a2,13
ffffffffc02038f2:	00c68023          	sb	a2,0(a3) # 4000 <_binary_obj___user_faultread_out_size-0x5570>
     assert(pgfault_num==4);
ffffffffc02038f6:	4398                	lw	a4,0(a5)
ffffffffc02038f8:	2701                	sext.w	a4,a4
ffffffffc02038fa:	37871c63          	bne	a4,s8,ffffffffc0203c72 <swap_init+0x5c8>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc02038fe:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==4);
ffffffffc0203902:	439c                	lw	a5,0(a5)
ffffffffc0203904:	2781                	sext.w	a5,a5
ffffffffc0203906:	38e79663          	bne	a5,a4,ffffffffc0203c92 <swap_init+0x5e8>
     
     check_content_set();
     assert( nr_free == 0);         
ffffffffc020390a:	481c                	lw	a5,16(s0)
ffffffffc020390c:	40079363          	bnez	a5,ffffffffc0203d12 <swap_init+0x668>
ffffffffc0203910:	000a9797          	auipc	a5,0xa9
ffffffffc0203914:	c0078793          	addi	a5,a5,-1024 # ffffffffc02ac510 <swap_in_seq_no>
ffffffffc0203918:	000a9717          	auipc	a4,0xa9
ffffffffc020391c:	c2070713          	addi	a4,a4,-992 # ffffffffc02ac538 <swap_out_seq_no>
ffffffffc0203920:	000a9617          	auipc	a2,0xa9
ffffffffc0203924:	c1860613          	addi	a2,a2,-1000 # ffffffffc02ac538 <swap_out_seq_no>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc0203928:	56fd                	li	a3,-1
ffffffffc020392a:	c394                	sw	a3,0(a5)
ffffffffc020392c:	c314                	sw	a3,0(a4)
ffffffffc020392e:	0791                	addi	a5,a5,4
ffffffffc0203930:	0711                	addi	a4,a4,4
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc0203932:	fef61ce3          	bne	a2,a5,ffffffffc020392a <swap_init+0x280>
ffffffffc0203936:	000a9697          	auipc	a3,0xa9
ffffffffc020393a:	c6268693          	addi	a3,a3,-926 # ffffffffc02ac598 <check_ptep>
ffffffffc020393e:	000a9817          	auipc	a6,0xa9
ffffffffc0203942:	bb280813          	addi	a6,a6,-1102 # ffffffffc02ac4f0 <check_rp>
ffffffffc0203946:	6d05                	lui	s10,0x1
    if (PPN(pa) >= npage) {
ffffffffc0203948:	000a9c97          	auipc	s9,0xa9
ffffffffc020394c:	b30c8c93          	addi	s9,s9,-1232 # ffffffffc02ac478 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0203950:	00005d97          	auipc	s11,0x5
ffffffffc0203954:	540d8d93          	addi	s11,s11,1344 # ffffffffc0208e90 <nbase>
ffffffffc0203958:	000a9c17          	auipc	s8,0xa9
ffffffffc020395c:	b90c0c13          	addi	s8,s8,-1136 # ffffffffc02ac4e8 <pages>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         check_ptep[i]=0;
ffffffffc0203960:	0006b023          	sd	zero,0(a3)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0203964:	4601                	li	a2,0
ffffffffc0203966:	85ea                	mv	a1,s10
ffffffffc0203968:	855a                	mv	a0,s6
ffffffffc020396a:	e842                	sd	a6,16(sp)
         check_ptep[i]=0;
ffffffffc020396c:	e436                	sd	a3,8(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc020396e:	b45fe0ef          	jal	ra,ffffffffc02024b2 <get_pte>
ffffffffc0203972:	66a2                	ld	a3,8(sp)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
ffffffffc0203974:	6842                	ld	a6,16(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0203976:	e288                	sd	a0,0(a3)
         assert(check_ptep[i] != NULL);
ffffffffc0203978:	20050163          	beqz	a0,ffffffffc0203b7a <swap_init+0x4d0>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc020397c:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc020397e:	0017f613          	andi	a2,a5,1
ffffffffc0203982:	1a060063          	beqz	a2,ffffffffc0203b22 <swap_init+0x478>
    if (PPN(pa) >= npage) {
ffffffffc0203986:	000cb603          	ld	a2,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc020398a:	078a                	slli	a5,a5,0x2
ffffffffc020398c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020398e:	14c7fe63          	bleu	a2,a5,ffffffffc0203aea <swap_init+0x440>
    return &pages[PPN(pa) - nbase];
ffffffffc0203992:	000db703          	ld	a4,0(s11)
ffffffffc0203996:	000c3603          	ld	a2,0(s8)
ffffffffc020399a:	00083583          	ld	a1,0(a6)
ffffffffc020399e:	8f99                	sub	a5,a5,a4
ffffffffc02039a0:	079a                	slli	a5,a5,0x6
ffffffffc02039a2:	e43a                	sd	a4,8(sp)
ffffffffc02039a4:	97b2                	add	a5,a5,a2
ffffffffc02039a6:	14f59e63          	bne	a1,a5,ffffffffc0203b02 <swap_init+0x458>
ffffffffc02039aa:	6785                	lui	a5,0x1
ffffffffc02039ac:	9d3e                	add	s10,s10,a5
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02039ae:	6795                	lui	a5,0x5
ffffffffc02039b0:	06a1                	addi	a3,a3,8
ffffffffc02039b2:	0821                	addi	a6,a6,8
ffffffffc02039b4:	fafd16e3          	bne	s10,a5,ffffffffc0203960 <swap_init+0x2b6>
         assert((*check_ptep[i] & PTE_V));          
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc02039b8:	00004517          	auipc	a0,0x4
ffffffffc02039bc:	53850513          	addi	a0,a0,1336 # ffffffffc0207ef0 <default_pmm_manager+0x898>
ffffffffc02039c0:	fcefc0ef          	jal	ra,ffffffffc020018e <cprintf>
    int ret = sm->check_swap();
ffffffffc02039c4:	000a9797          	auipc	a5,0xa9
ffffffffc02039c8:	abc78793          	addi	a5,a5,-1348 # ffffffffc02ac480 <sm>
ffffffffc02039cc:	639c                	ld	a5,0(a5)
ffffffffc02039ce:	7f9c                	ld	a5,56(a5)
ffffffffc02039d0:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
ffffffffc02039d2:	40051c63          	bnez	a0,ffffffffc0203dea <swap_init+0x740>

     nr_free = nr_free_store;
ffffffffc02039d6:	77a2                	ld	a5,40(sp)
ffffffffc02039d8:	000a9717          	auipc	a4,0xa9
ffffffffc02039dc:	aef72823          	sw	a5,-1296(a4) # ffffffffc02ac4c8 <free_area+0x10>
     free_list = free_list_store;
ffffffffc02039e0:	67e2                	ld	a5,24(sp)
ffffffffc02039e2:	000a9717          	auipc	a4,0xa9
ffffffffc02039e6:	acf73b23          	sd	a5,-1322(a4) # ffffffffc02ac4b8 <free_area>
ffffffffc02039ea:	7782                	ld	a5,32(sp)
ffffffffc02039ec:	000a9717          	auipc	a4,0xa9
ffffffffc02039f0:	acf73a23          	sd	a5,-1324(a4) # ffffffffc02ac4c0 <free_area+0x8>

     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         free_pages(check_rp[i],1);
ffffffffc02039f4:	0009b503          	ld	a0,0(s3)
ffffffffc02039f8:	4585                	li	a1,1
ffffffffc02039fa:	09a1                	addi	s3,s3,8
ffffffffc02039fc:	a31fe0ef          	jal	ra,ffffffffc020242c <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0203a00:	ff499ae3          	bne	s3,s4,ffffffffc02039f4 <swap_init+0x34a>
     } 

     //free_page(pte2page(*temp_ptep));

     mm->pgdir = NULL;
ffffffffc0203a04:	000bbc23          	sd	zero,24(s7)
     mm_destroy(mm);
ffffffffc0203a08:	855e                	mv	a0,s7
ffffffffc0203a0a:	361000ef          	jal	ra,ffffffffc020456a <mm_destroy>
     check_mm_struct = NULL;

     pde_t *pd1=pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0203a0e:	000a9797          	auipc	a5,0xa9
ffffffffc0203a12:	a6278793          	addi	a5,a5,-1438 # ffffffffc02ac470 <boot_pgdir>
ffffffffc0203a16:	639c                	ld	a5,0(a5)
     check_mm_struct = NULL;
ffffffffc0203a18:	000a9697          	auipc	a3,0xa9
ffffffffc0203a1c:	ba06b823          	sd	zero,-1104(a3) # ffffffffc02ac5c8 <check_mm_struct>
    if (PPN(pa) >= npage) {
ffffffffc0203a20:	000cb703          	ld	a4,0(s9)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203a24:	6394                	ld	a3,0(a5)
ffffffffc0203a26:	068a                	slli	a3,a3,0x2
ffffffffc0203a28:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203a2a:	0ce6f063          	bleu	a4,a3,ffffffffc0203aea <swap_init+0x440>
    return &pages[PPN(pa) - nbase];
ffffffffc0203a2e:	67a2                	ld	a5,8(sp)
ffffffffc0203a30:	000c3503          	ld	a0,0(s8)
ffffffffc0203a34:	8e9d                	sub	a3,a3,a5
ffffffffc0203a36:	069a                	slli	a3,a3,0x6
    return page - pages + nbase;
ffffffffc0203a38:	8699                	srai	a3,a3,0x6
ffffffffc0203a3a:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0203a3c:	57fd                	li	a5,-1
ffffffffc0203a3e:	83b1                	srli	a5,a5,0xc
ffffffffc0203a40:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0203a42:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0203a44:	2ee7f763          	bleu	a4,a5,ffffffffc0203d32 <swap_init+0x688>
     free_page(pde2page(pd0[0]));
ffffffffc0203a48:	000a9797          	auipc	a5,0xa9
ffffffffc0203a4c:	a9078793          	addi	a5,a5,-1392 # ffffffffc02ac4d8 <va_pa_offset>
ffffffffc0203a50:	639c                	ld	a5,0(a5)
ffffffffc0203a52:	96be                	add	a3,a3,a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0203a54:	629c                	ld	a5,0(a3)
ffffffffc0203a56:	078a                	slli	a5,a5,0x2
ffffffffc0203a58:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203a5a:	08e7f863          	bleu	a4,a5,ffffffffc0203aea <swap_init+0x440>
    return &pages[PPN(pa) - nbase];
ffffffffc0203a5e:	69a2                	ld	s3,8(sp)
ffffffffc0203a60:	4585                	li	a1,1
ffffffffc0203a62:	413787b3          	sub	a5,a5,s3
ffffffffc0203a66:	079a                	slli	a5,a5,0x6
ffffffffc0203a68:	953e                	add	a0,a0,a5
ffffffffc0203a6a:	9c3fe0ef          	jal	ra,ffffffffc020242c <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0203a6e:	000b3783          	ld	a5,0(s6)
    if (PPN(pa) >= npage) {
ffffffffc0203a72:	000cb703          	ld	a4,0(s9)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203a76:	078a                	slli	a5,a5,0x2
ffffffffc0203a78:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203a7a:	06e7f863          	bleu	a4,a5,ffffffffc0203aea <swap_init+0x440>
    return &pages[PPN(pa) - nbase];
ffffffffc0203a7e:	000c3503          	ld	a0,0(s8)
ffffffffc0203a82:	413787b3          	sub	a5,a5,s3
ffffffffc0203a86:	079a                	slli	a5,a5,0x6
     free_page(pde2page(pd1[0]));
ffffffffc0203a88:	4585                	li	a1,1
ffffffffc0203a8a:	953e                	add	a0,a0,a5
ffffffffc0203a8c:	9a1fe0ef          	jal	ra,ffffffffc020242c <free_pages>
     pgdir[0] = 0;
ffffffffc0203a90:	000b3023          	sd	zero,0(s6)
  asm volatile("sfence.vma");
ffffffffc0203a94:	12000073          	sfence.vma
    return listelm->next;
ffffffffc0203a98:	641c                	ld	a5,8(s0)
     flush_tlb();

     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0203a9a:	00878963          	beq	a5,s0,ffffffffc0203aac <swap_init+0x402>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
ffffffffc0203a9e:	ff87a703          	lw	a4,-8(a5)
ffffffffc0203aa2:	679c                	ld	a5,8(a5)
ffffffffc0203aa4:	397d                	addiw	s2,s2,-1
ffffffffc0203aa6:	9c99                	subw	s1,s1,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc0203aa8:	fe879be3          	bne	a5,s0,ffffffffc0203a9e <swap_init+0x3f4>
     }
     assert(count==0);
ffffffffc0203aac:	28091f63          	bnez	s2,ffffffffc0203d4a <swap_init+0x6a0>
     assert(total==0);
ffffffffc0203ab0:	2a049d63          	bnez	s1,ffffffffc0203d6a <swap_init+0x6c0>

     cprintf("check_swap() succeeded!\n");
ffffffffc0203ab4:	00004517          	auipc	a0,0x4
ffffffffc0203ab8:	48c50513          	addi	a0,a0,1164 # ffffffffc0207f40 <default_pmm_manager+0x8e8>
ffffffffc0203abc:	ed2fc0ef          	jal	ra,ffffffffc020018e <cprintf>
ffffffffc0203ac0:	b92d                	j	ffffffffc02036fa <swap_init+0x50>
     int ret, count = 0, total = 0, i;
ffffffffc0203ac2:	4481                	li	s1,0
ffffffffc0203ac4:	4901                	li	s2,0
     while ((le = list_next(le)) != &free_list) {
ffffffffc0203ac6:	4981                	li	s3,0
ffffffffc0203ac8:	b17d                	j	ffffffffc0203776 <swap_init+0xcc>
        assert(PageProperty(p));
ffffffffc0203aca:	00003697          	auipc	a3,0x3
ffffffffc0203ace:	7fe68693          	addi	a3,a3,2046 # ffffffffc02072c8 <commands+0xa08>
ffffffffc0203ad2:	00003617          	auipc	a2,0x3
ffffffffc0203ad6:	2ae60613          	addi	a2,a2,686 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0203ada:	0bc00593          	li	a1,188
ffffffffc0203ade:	00004517          	auipc	a0,0x4
ffffffffc0203ae2:	1fa50513          	addi	a0,a0,506 # ffffffffc0207cd8 <default_pmm_manager+0x680>
ffffffffc0203ae6:	99ffc0ef          	jal	ra,ffffffffc0200484 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0203aea:	00003617          	auipc	a2,0x3
ffffffffc0203aee:	73e60613          	addi	a2,a2,1854 # ffffffffc0207228 <commands+0x968>
ffffffffc0203af2:	06300593          	li	a1,99
ffffffffc0203af6:	00003517          	auipc	a0,0x3
ffffffffc0203afa:	75250513          	addi	a0,a0,1874 # ffffffffc0207248 <commands+0x988>
ffffffffc0203afe:	987fc0ef          	jal	ra,ffffffffc0200484 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0203b02:	00004697          	auipc	a3,0x4
ffffffffc0203b06:	3c668693          	addi	a3,a3,966 # ffffffffc0207ec8 <default_pmm_manager+0x870>
ffffffffc0203b0a:	00003617          	auipc	a2,0x3
ffffffffc0203b0e:	27660613          	addi	a2,a2,630 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0203b12:	0fc00593          	li	a1,252
ffffffffc0203b16:	00004517          	auipc	a0,0x4
ffffffffc0203b1a:	1c250513          	addi	a0,a0,450 # ffffffffc0207cd8 <default_pmm_manager+0x680>
ffffffffc0203b1e:	967fc0ef          	jal	ra,ffffffffc0200484 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0203b22:	00003617          	auipc	a2,0x3
ffffffffc0203b26:	76e60613          	addi	a2,a2,1902 # ffffffffc0207290 <commands+0x9d0>
ffffffffc0203b2a:	07500593          	li	a1,117
ffffffffc0203b2e:	00003517          	auipc	a0,0x3
ffffffffc0203b32:	71a50513          	addi	a0,a0,1818 # ffffffffc0207248 <commands+0x988>
ffffffffc0203b36:	94ffc0ef          	jal	ra,ffffffffc0200484 <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc0203b3a:	00004697          	auipc	a3,0x4
ffffffffc0203b3e:	2c668693          	addi	a3,a3,710 # ffffffffc0207e00 <default_pmm_manager+0x7a8>
ffffffffc0203b42:	00003617          	auipc	a2,0x3
ffffffffc0203b46:	23e60613          	addi	a2,a2,574 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0203b4a:	0dd00593          	li	a1,221
ffffffffc0203b4e:	00004517          	auipc	a0,0x4
ffffffffc0203b52:	18a50513          	addi	a0,a0,394 # ffffffffc0207cd8 <default_pmm_manager+0x680>
ffffffffc0203b56:	92ffc0ef          	jal	ra,ffffffffc0200484 <__panic>
          assert(check_rp[i] != NULL );
ffffffffc0203b5a:	00004697          	auipc	a3,0x4
ffffffffc0203b5e:	28e68693          	addi	a3,a3,654 # ffffffffc0207de8 <default_pmm_manager+0x790>
ffffffffc0203b62:	00003617          	auipc	a2,0x3
ffffffffc0203b66:	21e60613          	addi	a2,a2,542 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0203b6a:	0dc00593          	li	a1,220
ffffffffc0203b6e:	00004517          	auipc	a0,0x4
ffffffffc0203b72:	16a50513          	addi	a0,a0,362 # ffffffffc0207cd8 <default_pmm_manager+0x680>
ffffffffc0203b76:	90ffc0ef          	jal	ra,ffffffffc0200484 <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc0203b7a:	00004697          	auipc	a3,0x4
ffffffffc0203b7e:	33668693          	addi	a3,a3,822 # ffffffffc0207eb0 <default_pmm_manager+0x858>
ffffffffc0203b82:	00003617          	auipc	a2,0x3
ffffffffc0203b86:	1fe60613          	addi	a2,a2,510 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0203b8a:	0fb00593          	li	a1,251
ffffffffc0203b8e:	00004517          	auipc	a0,0x4
ffffffffc0203b92:	14a50513          	addi	a0,a0,330 # ffffffffc0207cd8 <default_pmm_manager+0x680>
ffffffffc0203b96:	8effc0ef          	jal	ra,ffffffffc0200484 <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc0203b9a:	00004617          	auipc	a2,0x4
ffffffffc0203b9e:	11e60613          	addi	a2,a2,286 # ffffffffc0207cb8 <default_pmm_manager+0x660>
ffffffffc0203ba2:	02800593          	li	a1,40
ffffffffc0203ba6:	00004517          	auipc	a0,0x4
ffffffffc0203baa:	13250513          	addi	a0,a0,306 # ffffffffc0207cd8 <default_pmm_manager+0x680>
ffffffffc0203bae:	8d7fc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(pgfault_num==2);
ffffffffc0203bb2:	00004697          	auipc	a3,0x4
ffffffffc0203bb6:	2ce68693          	addi	a3,a3,718 # ffffffffc0207e80 <default_pmm_manager+0x828>
ffffffffc0203bba:	00003617          	auipc	a2,0x3
ffffffffc0203bbe:	1c660613          	addi	a2,a2,454 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0203bc2:	09700593          	li	a1,151
ffffffffc0203bc6:	00004517          	auipc	a0,0x4
ffffffffc0203bca:	11250513          	addi	a0,a0,274 # ffffffffc0207cd8 <default_pmm_manager+0x680>
ffffffffc0203bce:	8b7fc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(pgfault_num==2);
ffffffffc0203bd2:	00004697          	auipc	a3,0x4
ffffffffc0203bd6:	2ae68693          	addi	a3,a3,686 # ffffffffc0207e80 <default_pmm_manager+0x828>
ffffffffc0203bda:	00003617          	auipc	a2,0x3
ffffffffc0203bde:	1a660613          	addi	a2,a2,422 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0203be2:	09900593          	li	a1,153
ffffffffc0203be6:	00004517          	auipc	a0,0x4
ffffffffc0203bea:	0f250513          	addi	a0,a0,242 # ffffffffc0207cd8 <default_pmm_manager+0x680>
ffffffffc0203bee:	897fc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(pgfault_num==3);
ffffffffc0203bf2:	00004697          	auipc	a3,0x4
ffffffffc0203bf6:	29e68693          	addi	a3,a3,670 # ffffffffc0207e90 <default_pmm_manager+0x838>
ffffffffc0203bfa:	00003617          	auipc	a2,0x3
ffffffffc0203bfe:	18660613          	addi	a2,a2,390 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0203c02:	09b00593          	li	a1,155
ffffffffc0203c06:	00004517          	auipc	a0,0x4
ffffffffc0203c0a:	0d250513          	addi	a0,a0,210 # ffffffffc0207cd8 <default_pmm_manager+0x680>
ffffffffc0203c0e:	877fc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(pgfault_num==3);
ffffffffc0203c12:	00004697          	auipc	a3,0x4
ffffffffc0203c16:	27e68693          	addi	a3,a3,638 # ffffffffc0207e90 <default_pmm_manager+0x838>
ffffffffc0203c1a:	00003617          	auipc	a2,0x3
ffffffffc0203c1e:	16660613          	addi	a2,a2,358 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0203c22:	09d00593          	li	a1,157
ffffffffc0203c26:	00004517          	auipc	a0,0x4
ffffffffc0203c2a:	0b250513          	addi	a0,a0,178 # ffffffffc0207cd8 <default_pmm_manager+0x680>
ffffffffc0203c2e:	857fc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(pgfault_num==1);
ffffffffc0203c32:	00004697          	auipc	a3,0x4
ffffffffc0203c36:	23e68693          	addi	a3,a3,574 # ffffffffc0207e70 <default_pmm_manager+0x818>
ffffffffc0203c3a:	00003617          	auipc	a2,0x3
ffffffffc0203c3e:	14660613          	addi	a2,a2,326 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0203c42:	09300593          	li	a1,147
ffffffffc0203c46:	00004517          	auipc	a0,0x4
ffffffffc0203c4a:	09250513          	addi	a0,a0,146 # ffffffffc0207cd8 <default_pmm_manager+0x680>
ffffffffc0203c4e:	837fc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(pgfault_num==1);
ffffffffc0203c52:	00004697          	auipc	a3,0x4
ffffffffc0203c56:	21e68693          	addi	a3,a3,542 # ffffffffc0207e70 <default_pmm_manager+0x818>
ffffffffc0203c5a:	00003617          	auipc	a2,0x3
ffffffffc0203c5e:	12660613          	addi	a2,a2,294 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0203c62:	09500593          	li	a1,149
ffffffffc0203c66:	00004517          	auipc	a0,0x4
ffffffffc0203c6a:	07250513          	addi	a0,a0,114 # ffffffffc0207cd8 <default_pmm_manager+0x680>
ffffffffc0203c6e:	817fc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(pgfault_num==4);
ffffffffc0203c72:	00004697          	auipc	a3,0x4
ffffffffc0203c76:	22e68693          	addi	a3,a3,558 # ffffffffc0207ea0 <default_pmm_manager+0x848>
ffffffffc0203c7a:	00003617          	auipc	a2,0x3
ffffffffc0203c7e:	10660613          	addi	a2,a2,262 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0203c82:	09f00593          	li	a1,159
ffffffffc0203c86:	00004517          	auipc	a0,0x4
ffffffffc0203c8a:	05250513          	addi	a0,a0,82 # ffffffffc0207cd8 <default_pmm_manager+0x680>
ffffffffc0203c8e:	ff6fc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(pgfault_num==4);
ffffffffc0203c92:	00004697          	auipc	a3,0x4
ffffffffc0203c96:	20e68693          	addi	a3,a3,526 # ffffffffc0207ea0 <default_pmm_manager+0x848>
ffffffffc0203c9a:	00003617          	auipc	a2,0x3
ffffffffc0203c9e:	0e660613          	addi	a2,a2,230 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0203ca2:	0a100593          	li	a1,161
ffffffffc0203ca6:	00004517          	auipc	a0,0x4
ffffffffc0203caa:	03250513          	addi	a0,a0,50 # ffffffffc0207cd8 <default_pmm_manager+0x680>
ffffffffc0203cae:	fd6fc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(pgdir[0] == 0);
ffffffffc0203cb2:	00004697          	auipc	a3,0x4
ffffffffc0203cb6:	09e68693          	addi	a3,a3,158 # ffffffffc0207d50 <default_pmm_manager+0x6f8>
ffffffffc0203cba:	00003617          	auipc	a2,0x3
ffffffffc0203cbe:	0c660613          	addi	a2,a2,198 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0203cc2:	0cc00593          	li	a1,204
ffffffffc0203cc6:	00004517          	auipc	a0,0x4
ffffffffc0203cca:	01250513          	addi	a0,a0,18 # ffffffffc0207cd8 <default_pmm_manager+0x680>
ffffffffc0203cce:	fb6fc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(vma != NULL);
ffffffffc0203cd2:	00004697          	auipc	a3,0x4
ffffffffc0203cd6:	08e68693          	addi	a3,a3,142 # ffffffffc0207d60 <default_pmm_manager+0x708>
ffffffffc0203cda:	00003617          	auipc	a2,0x3
ffffffffc0203cde:	0a660613          	addi	a2,a2,166 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0203ce2:	0cf00593          	li	a1,207
ffffffffc0203ce6:	00004517          	auipc	a0,0x4
ffffffffc0203cea:	ff250513          	addi	a0,a0,-14 # ffffffffc0207cd8 <default_pmm_manager+0x680>
ffffffffc0203cee:	f96fc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(temp_ptep!= NULL);
ffffffffc0203cf2:	00004697          	auipc	a3,0x4
ffffffffc0203cf6:	0b668693          	addi	a3,a3,182 # ffffffffc0207da8 <default_pmm_manager+0x750>
ffffffffc0203cfa:	00003617          	auipc	a2,0x3
ffffffffc0203cfe:	08660613          	addi	a2,a2,134 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0203d02:	0d700593          	li	a1,215
ffffffffc0203d06:	00004517          	auipc	a0,0x4
ffffffffc0203d0a:	fd250513          	addi	a0,a0,-46 # ffffffffc0207cd8 <default_pmm_manager+0x680>
ffffffffc0203d0e:	f76fc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert( nr_free == 0);         
ffffffffc0203d12:	00003697          	auipc	a3,0x3
ffffffffc0203d16:	78668693          	addi	a3,a3,1926 # ffffffffc0207498 <commands+0xbd8>
ffffffffc0203d1a:	00003617          	auipc	a2,0x3
ffffffffc0203d1e:	06660613          	addi	a2,a2,102 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0203d22:	0f300593          	li	a1,243
ffffffffc0203d26:	00004517          	auipc	a0,0x4
ffffffffc0203d2a:	fb250513          	addi	a0,a0,-78 # ffffffffc0207cd8 <default_pmm_manager+0x680>
ffffffffc0203d2e:	f56fc0ef          	jal	ra,ffffffffc0200484 <__panic>
    return KADDR(page2pa(page));
ffffffffc0203d32:	00003617          	auipc	a2,0x3
ffffffffc0203d36:	40660613          	addi	a2,a2,1030 # ffffffffc0207138 <commands+0x878>
ffffffffc0203d3a:	06a00593          	li	a1,106
ffffffffc0203d3e:	00003517          	auipc	a0,0x3
ffffffffc0203d42:	50a50513          	addi	a0,a0,1290 # ffffffffc0207248 <commands+0x988>
ffffffffc0203d46:	f3efc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(count==0);
ffffffffc0203d4a:	00004697          	auipc	a3,0x4
ffffffffc0203d4e:	1d668693          	addi	a3,a3,470 # ffffffffc0207f20 <default_pmm_manager+0x8c8>
ffffffffc0203d52:	00003617          	auipc	a2,0x3
ffffffffc0203d56:	02e60613          	addi	a2,a2,46 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0203d5a:	11d00593          	li	a1,285
ffffffffc0203d5e:	00004517          	auipc	a0,0x4
ffffffffc0203d62:	f7a50513          	addi	a0,a0,-134 # ffffffffc0207cd8 <default_pmm_manager+0x680>
ffffffffc0203d66:	f1efc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(total==0);
ffffffffc0203d6a:	00004697          	auipc	a3,0x4
ffffffffc0203d6e:	1c668693          	addi	a3,a3,454 # ffffffffc0207f30 <default_pmm_manager+0x8d8>
ffffffffc0203d72:	00003617          	auipc	a2,0x3
ffffffffc0203d76:	00e60613          	addi	a2,a2,14 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0203d7a:	11e00593          	li	a1,286
ffffffffc0203d7e:	00004517          	auipc	a0,0x4
ffffffffc0203d82:	f5a50513          	addi	a0,a0,-166 # ffffffffc0207cd8 <default_pmm_manager+0x680>
ffffffffc0203d86:	efefc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0203d8a:	00004697          	auipc	a3,0x4
ffffffffc0203d8e:	09668693          	addi	a3,a3,150 # ffffffffc0207e20 <default_pmm_manager+0x7c8>
ffffffffc0203d92:	00003617          	auipc	a2,0x3
ffffffffc0203d96:	fee60613          	addi	a2,a2,-18 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0203d9a:	0ea00593          	li	a1,234
ffffffffc0203d9e:	00004517          	auipc	a0,0x4
ffffffffc0203da2:	f3a50513          	addi	a0,a0,-198 # ffffffffc0207cd8 <default_pmm_manager+0x680>
ffffffffc0203da6:	edefc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(mm != NULL);
ffffffffc0203daa:	00004697          	auipc	a3,0x4
ffffffffc0203dae:	f7e68693          	addi	a3,a3,-130 # ffffffffc0207d28 <default_pmm_manager+0x6d0>
ffffffffc0203db2:	00003617          	auipc	a2,0x3
ffffffffc0203db6:	fce60613          	addi	a2,a2,-50 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0203dba:	0c400593          	li	a1,196
ffffffffc0203dbe:	00004517          	auipc	a0,0x4
ffffffffc0203dc2:	f1a50513          	addi	a0,a0,-230 # ffffffffc0207cd8 <default_pmm_manager+0x680>
ffffffffc0203dc6:	ebefc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(check_mm_struct == NULL);
ffffffffc0203dca:	00004697          	auipc	a3,0x4
ffffffffc0203dce:	f6e68693          	addi	a3,a3,-146 # ffffffffc0207d38 <default_pmm_manager+0x6e0>
ffffffffc0203dd2:	00003617          	auipc	a2,0x3
ffffffffc0203dd6:	fae60613          	addi	a2,a2,-82 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0203dda:	0c700593          	li	a1,199
ffffffffc0203dde:	00004517          	auipc	a0,0x4
ffffffffc0203de2:	efa50513          	addi	a0,a0,-262 # ffffffffc0207cd8 <default_pmm_manager+0x680>
ffffffffc0203de6:	e9efc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(ret==0);
ffffffffc0203dea:	00004697          	auipc	a3,0x4
ffffffffc0203dee:	12e68693          	addi	a3,a3,302 # ffffffffc0207f18 <default_pmm_manager+0x8c0>
ffffffffc0203df2:	00003617          	auipc	a2,0x3
ffffffffc0203df6:	f8e60613          	addi	a2,a2,-114 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0203dfa:	10200593          	li	a1,258
ffffffffc0203dfe:	00004517          	auipc	a0,0x4
ffffffffc0203e02:	eda50513          	addi	a0,a0,-294 # ffffffffc0207cd8 <default_pmm_manager+0x680>
ffffffffc0203e06:	e7efc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(total == nr_free_pages());
ffffffffc0203e0a:	00003697          	auipc	a3,0x3
ffffffffc0203e0e:	4e668693          	addi	a3,a3,1254 # ffffffffc02072f0 <commands+0xa30>
ffffffffc0203e12:	00003617          	auipc	a2,0x3
ffffffffc0203e16:	f6e60613          	addi	a2,a2,-146 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0203e1a:	0bf00593          	li	a1,191
ffffffffc0203e1e:	00004517          	auipc	a0,0x4
ffffffffc0203e22:	eba50513          	addi	a0,a0,-326 # ffffffffc0207cd8 <default_pmm_manager+0x680>
ffffffffc0203e26:	e5efc0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0203e2a <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc0203e2a:	000a8797          	auipc	a5,0xa8
ffffffffc0203e2e:	65678793          	addi	a5,a5,1622 # ffffffffc02ac480 <sm>
ffffffffc0203e32:	639c                	ld	a5,0(a5)
ffffffffc0203e34:	0107b303          	ld	t1,16(a5)
ffffffffc0203e38:	8302                	jr	t1

ffffffffc0203e3a <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc0203e3a:	000a8797          	auipc	a5,0xa8
ffffffffc0203e3e:	64678793          	addi	a5,a5,1606 # ffffffffc02ac480 <sm>
ffffffffc0203e42:	639c                	ld	a5,0(a5)
ffffffffc0203e44:	0207b303          	ld	t1,32(a5)
ffffffffc0203e48:	8302                	jr	t1

ffffffffc0203e4a <swap_out>:
{
ffffffffc0203e4a:	711d                	addi	sp,sp,-96
ffffffffc0203e4c:	ec86                	sd	ra,88(sp)
ffffffffc0203e4e:	e8a2                	sd	s0,80(sp)
ffffffffc0203e50:	e4a6                	sd	s1,72(sp)
ffffffffc0203e52:	e0ca                	sd	s2,64(sp)
ffffffffc0203e54:	fc4e                	sd	s3,56(sp)
ffffffffc0203e56:	f852                	sd	s4,48(sp)
ffffffffc0203e58:	f456                	sd	s5,40(sp)
ffffffffc0203e5a:	f05a                	sd	s6,32(sp)
ffffffffc0203e5c:	ec5e                	sd	s7,24(sp)
ffffffffc0203e5e:	e862                	sd	s8,16(sp)
     for (i = 0; i != n; ++ i)
ffffffffc0203e60:	cde9                	beqz	a1,ffffffffc0203f3a <swap_out+0xf0>
ffffffffc0203e62:	8ab2                	mv	s5,a2
ffffffffc0203e64:	892a                	mv	s2,a0
ffffffffc0203e66:	8a2e                	mv	s4,a1
ffffffffc0203e68:	4401                	li	s0,0
ffffffffc0203e6a:	000a8997          	auipc	s3,0xa8
ffffffffc0203e6e:	61698993          	addi	s3,s3,1558 # ffffffffc02ac480 <sm>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203e72:	00004b17          	auipc	s6,0x4
ffffffffc0203e76:	14eb0b13          	addi	s6,s6,334 # ffffffffc0207fc0 <default_pmm_manager+0x968>
                    cprintf("SWAP: failed to save\n");
ffffffffc0203e7a:	00004b97          	auipc	s7,0x4
ffffffffc0203e7e:	12eb8b93          	addi	s7,s7,302 # ffffffffc0207fa8 <default_pmm_manager+0x950>
ffffffffc0203e82:	a825                	j	ffffffffc0203eba <swap_out+0x70>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203e84:	67a2                	ld	a5,8(sp)
ffffffffc0203e86:	8626                	mv	a2,s1
ffffffffc0203e88:	85a2                	mv	a1,s0
ffffffffc0203e8a:	7f94                	ld	a3,56(a5)
ffffffffc0203e8c:	855a                	mv	a0,s6
     for (i = 0; i != n; ++ i)
ffffffffc0203e8e:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203e90:	82b1                	srli	a3,a3,0xc
ffffffffc0203e92:	0685                	addi	a3,a3,1
ffffffffc0203e94:	afafc0ef          	jal	ra,ffffffffc020018e <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0203e98:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc0203e9a:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0203e9c:	7d1c                	ld	a5,56(a0)
ffffffffc0203e9e:	83b1                	srli	a5,a5,0xc
ffffffffc0203ea0:	0785                	addi	a5,a5,1
ffffffffc0203ea2:	07a2                	slli	a5,a5,0x8
ffffffffc0203ea4:	00fc3023          	sd	a5,0(s8)
                    free_page(page);
ffffffffc0203ea8:	d84fe0ef          	jal	ra,ffffffffc020242c <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc0203eac:	01893503          	ld	a0,24(s2)
ffffffffc0203eb0:	85a6                	mv	a1,s1
ffffffffc0203eb2:	f5eff0ef          	jal	ra,ffffffffc0203610 <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc0203eb6:	048a0d63          	beq	s4,s0,ffffffffc0203f10 <swap_out+0xc6>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc0203eba:	0009b783          	ld	a5,0(s3)
ffffffffc0203ebe:	8656                	mv	a2,s5
ffffffffc0203ec0:	002c                	addi	a1,sp,8
ffffffffc0203ec2:	7b9c                	ld	a5,48(a5)
ffffffffc0203ec4:	854a                	mv	a0,s2
ffffffffc0203ec6:	9782                	jalr	a5
          if (r != 0) {
ffffffffc0203ec8:	e12d                	bnez	a0,ffffffffc0203f2a <swap_out+0xe0>
          v=page->pra_vaddr; 
ffffffffc0203eca:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203ecc:	01893503          	ld	a0,24(s2)
ffffffffc0203ed0:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc0203ed2:	7f84                	ld	s1,56(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203ed4:	85a6                	mv	a1,s1
ffffffffc0203ed6:	ddcfe0ef          	jal	ra,ffffffffc02024b2 <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc0203eda:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203edc:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc0203ede:	8b85                	andi	a5,a5,1
ffffffffc0203ee0:	cfb9                	beqz	a5,ffffffffc0203f3e <swap_out+0xf4>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc0203ee2:	65a2                	ld	a1,8(sp)
ffffffffc0203ee4:	7d9c                	ld	a5,56(a1)
ffffffffc0203ee6:	83b1                	srli	a5,a5,0xc
ffffffffc0203ee8:	00178513          	addi	a0,a5,1
ffffffffc0203eec:	0522                	slli	a0,a0,0x8
ffffffffc0203eee:	7cd000ef          	jal	ra,ffffffffc0204eba <swapfs_write>
ffffffffc0203ef2:	d949                	beqz	a0,ffffffffc0203e84 <swap_out+0x3a>
                    cprintf("SWAP: failed to save\n");
ffffffffc0203ef4:	855e                	mv	a0,s7
ffffffffc0203ef6:	a98fc0ef          	jal	ra,ffffffffc020018e <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0203efa:	0009b783          	ld	a5,0(s3)
ffffffffc0203efe:	6622                	ld	a2,8(sp)
ffffffffc0203f00:	4681                	li	a3,0
ffffffffc0203f02:	739c                	ld	a5,32(a5)
ffffffffc0203f04:	85a6                	mv	a1,s1
ffffffffc0203f06:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc0203f08:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0203f0a:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc0203f0c:	fa8a17e3          	bne	s4,s0,ffffffffc0203eba <swap_out+0x70>
}
ffffffffc0203f10:	8522                	mv	a0,s0
ffffffffc0203f12:	60e6                	ld	ra,88(sp)
ffffffffc0203f14:	6446                	ld	s0,80(sp)
ffffffffc0203f16:	64a6                	ld	s1,72(sp)
ffffffffc0203f18:	6906                	ld	s2,64(sp)
ffffffffc0203f1a:	79e2                	ld	s3,56(sp)
ffffffffc0203f1c:	7a42                	ld	s4,48(sp)
ffffffffc0203f1e:	7aa2                	ld	s5,40(sp)
ffffffffc0203f20:	7b02                	ld	s6,32(sp)
ffffffffc0203f22:	6be2                	ld	s7,24(sp)
ffffffffc0203f24:	6c42                	ld	s8,16(sp)
ffffffffc0203f26:	6125                	addi	sp,sp,96
ffffffffc0203f28:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc0203f2a:	85a2                	mv	a1,s0
ffffffffc0203f2c:	00004517          	auipc	a0,0x4
ffffffffc0203f30:	03450513          	addi	a0,a0,52 # ffffffffc0207f60 <default_pmm_manager+0x908>
ffffffffc0203f34:	a5afc0ef          	jal	ra,ffffffffc020018e <cprintf>
                  break;
ffffffffc0203f38:	bfe1                	j	ffffffffc0203f10 <swap_out+0xc6>
     for (i = 0; i != n; ++ i)
ffffffffc0203f3a:	4401                	li	s0,0
ffffffffc0203f3c:	bfd1                	j	ffffffffc0203f10 <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc0203f3e:	00004697          	auipc	a3,0x4
ffffffffc0203f42:	05268693          	addi	a3,a3,82 # ffffffffc0207f90 <default_pmm_manager+0x938>
ffffffffc0203f46:	00003617          	auipc	a2,0x3
ffffffffc0203f4a:	e3a60613          	addi	a2,a2,-454 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0203f4e:	06800593          	li	a1,104
ffffffffc0203f52:	00004517          	auipc	a0,0x4
ffffffffc0203f56:	d8650513          	addi	a0,a0,-634 # ffffffffc0207cd8 <default_pmm_manager+0x680>
ffffffffc0203f5a:	d2afc0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0203f5e <swap_in>:
{
ffffffffc0203f5e:	7179                	addi	sp,sp,-48
ffffffffc0203f60:	e84a                	sd	s2,16(sp)
ffffffffc0203f62:	892a                	mv	s2,a0
     struct Page *result = alloc_page();
ffffffffc0203f64:	4505                	li	a0,1
{
ffffffffc0203f66:	ec26                	sd	s1,24(sp)
ffffffffc0203f68:	e44e                	sd	s3,8(sp)
ffffffffc0203f6a:	f406                	sd	ra,40(sp)
ffffffffc0203f6c:	f022                	sd	s0,32(sp)
ffffffffc0203f6e:	84ae                	mv	s1,a1
ffffffffc0203f70:	89b2                	mv	s3,a2
     struct Page *result = alloc_page();
ffffffffc0203f72:	c32fe0ef          	jal	ra,ffffffffc02023a4 <alloc_pages>
     assert(result!=NULL);
ffffffffc0203f76:	c129                	beqz	a0,ffffffffc0203fb8 <swap_in+0x5a>
     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
ffffffffc0203f78:	842a                	mv	s0,a0
ffffffffc0203f7a:	01893503          	ld	a0,24(s2)
ffffffffc0203f7e:	4601                	li	a2,0
ffffffffc0203f80:	85a6                	mv	a1,s1
ffffffffc0203f82:	d30fe0ef          	jal	ra,ffffffffc02024b2 <get_pte>
ffffffffc0203f86:	892a                	mv	s2,a0
     if ((r = swapfs_read((*ptep), result)) != 0)
ffffffffc0203f88:	6108                	ld	a0,0(a0)
ffffffffc0203f8a:	85a2                	mv	a1,s0
ffffffffc0203f8c:	697000ef          	jal	ra,ffffffffc0204e22 <swapfs_read>
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
ffffffffc0203f90:	00093583          	ld	a1,0(s2)
ffffffffc0203f94:	8626                	mv	a2,s1
ffffffffc0203f96:	00004517          	auipc	a0,0x4
ffffffffc0203f9a:	ce250513          	addi	a0,a0,-798 # ffffffffc0207c78 <default_pmm_manager+0x620>
ffffffffc0203f9e:	81a1                	srli	a1,a1,0x8
ffffffffc0203fa0:	9eefc0ef          	jal	ra,ffffffffc020018e <cprintf>
}
ffffffffc0203fa4:	70a2                	ld	ra,40(sp)
     *ptr_result=result;
ffffffffc0203fa6:	0089b023          	sd	s0,0(s3)
}
ffffffffc0203faa:	7402                	ld	s0,32(sp)
ffffffffc0203fac:	64e2                	ld	s1,24(sp)
ffffffffc0203fae:	6942                	ld	s2,16(sp)
ffffffffc0203fb0:	69a2                	ld	s3,8(sp)
ffffffffc0203fb2:	4501                	li	a0,0
ffffffffc0203fb4:	6145                	addi	sp,sp,48
ffffffffc0203fb6:	8082                	ret
     assert(result!=NULL);
ffffffffc0203fb8:	00004697          	auipc	a3,0x4
ffffffffc0203fbc:	cb068693          	addi	a3,a3,-848 # ffffffffc0207c68 <default_pmm_manager+0x610>
ffffffffc0203fc0:	00003617          	auipc	a2,0x3
ffffffffc0203fc4:	dc060613          	addi	a2,a2,-576 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0203fc8:	07e00593          	li	a1,126
ffffffffc0203fcc:	00004517          	auipc	a0,0x4
ffffffffc0203fd0:	d0c50513          	addi	a0,a0,-756 # ffffffffc0207cd8 <default_pmm_manager+0x680>
ffffffffc0203fd4:	cb0fc0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0203fd8 <_fifo_init_mm>:
    elm->prev = elm->next = elm;
ffffffffc0203fd8:	000a8797          	auipc	a5,0xa8
ffffffffc0203fdc:	5e078793          	addi	a5,a5,1504 # ffffffffc02ac5b8 <pra_list_head>
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{     
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
ffffffffc0203fe0:	f51c                	sd	a5,40(a0)
ffffffffc0203fe2:	e79c                	sd	a5,8(a5)
ffffffffc0203fe4:	e39c                	sd	a5,0(a5)
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
}
ffffffffc0203fe6:	4501                	li	a0,0
ffffffffc0203fe8:	8082                	ret

ffffffffc0203fea <_fifo_init>:

static int
_fifo_init(void)
{
    return 0;
}
ffffffffc0203fea:	4501                	li	a0,0
ffffffffc0203fec:	8082                	ret

ffffffffc0203fee <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc0203fee:	4501                	li	a0,0
ffffffffc0203ff0:	8082                	ret

ffffffffc0203ff2 <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{ return 0; }
ffffffffc0203ff2:	4501                	li	a0,0
ffffffffc0203ff4:	8082                	ret

ffffffffc0203ff6 <_fifo_check_swap>:
_fifo_check_swap(void) {
ffffffffc0203ff6:	711d                	addi	sp,sp,-96
ffffffffc0203ff8:	fc4e                	sd	s3,56(sp)
ffffffffc0203ffa:	f852                	sd	s4,48(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0203ffc:	00004517          	auipc	a0,0x4
ffffffffc0204000:	00450513          	addi	a0,a0,4 # ffffffffc0208000 <default_pmm_manager+0x9a8>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0204004:	698d                	lui	s3,0x3
ffffffffc0204006:	4a31                	li	s4,12
_fifo_check_swap(void) {
ffffffffc0204008:	e8a2                	sd	s0,80(sp)
ffffffffc020400a:	e4a6                	sd	s1,72(sp)
ffffffffc020400c:	ec86                	sd	ra,88(sp)
ffffffffc020400e:	e0ca                	sd	s2,64(sp)
ffffffffc0204010:	f456                	sd	s5,40(sp)
ffffffffc0204012:	f05a                	sd	s6,32(sp)
ffffffffc0204014:	ec5e                	sd	s7,24(sp)
ffffffffc0204016:	e862                	sd	s8,16(sp)
ffffffffc0204018:	e466                	sd	s9,8(sp)
    assert(pgfault_num==4);
ffffffffc020401a:	000a8417          	auipc	s0,0xa8
ffffffffc020401e:	47240413          	addi	s0,s0,1138 # ffffffffc02ac48c <pgfault_num>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0204022:	96cfc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0204026:	01498023          	sb	s4,0(s3) # 3000 <_binary_obj___user_faultread_out_size-0x6570>
    assert(pgfault_num==4);
ffffffffc020402a:	4004                	lw	s1,0(s0)
ffffffffc020402c:	4791                	li	a5,4
ffffffffc020402e:	2481                	sext.w	s1,s1
ffffffffc0204030:	14f49963          	bne	s1,a5,ffffffffc0204182 <_fifo_check_swap+0x18c>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0204034:	00004517          	auipc	a0,0x4
ffffffffc0204038:	00c50513          	addi	a0,a0,12 # ffffffffc0208040 <default_pmm_manager+0x9e8>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc020403c:	6a85                	lui	s5,0x1
ffffffffc020403e:	4b29                	li	s6,10
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0204040:	94efc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0204044:	016a8023          	sb	s6,0(s5) # 1000 <_binary_obj___user_faultread_out_size-0x8570>
    assert(pgfault_num==4);
ffffffffc0204048:	00042903          	lw	s2,0(s0)
ffffffffc020404c:	2901                	sext.w	s2,s2
ffffffffc020404e:	2a991a63          	bne	s2,s1,ffffffffc0204302 <_fifo_check_swap+0x30c>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0204052:	00004517          	auipc	a0,0x4
ffffffffc0204056:	01650513          	addi	a0,a0,22 # ffffffffc0208068 <default_pmm_manager+0xa10>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc020405a:	6b91                	lui	s7,0x4
ffffffffc020405c:	4c35                	li	s8,13
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc020405e:	930fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0204062:	018b8023          	sb	s8,0(s7) # 4000 <_binary_obj___user_faultread_out_size-0x5570>
    assert(pgfault_num==4);
ffffffffc0204066:	4004                	lw	s1,0(s0)
ffffffffc0204068:	2481                	sext.w	s1,s1
ffffffffc020406a:	27249c63          	bne	s1,s2,ffffffffc02042e2 <_fifo_check_swap+0x2ec>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc020406e:	00004517          	auipc	a0,0x4
ffffffffc0204072:	02250513          	addi	a0,a0,34 # ffffffffc0208090 <default_pmm_manager+0xa38>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0204076:	6909                	lui	s2,0x2
ffffffffc0204078:	4cad                	li	s9,11
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc020407a:	914fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc020407e:	01990023          	sb	s9,0(s2) # 2000 <_binary_obj___user_faultread_out_size-0x7570>
    assert(pgfault_num==4);
ffffffffc0204082:	401c                	lw	a5,0(s0)
ffffffffc0204084:	2781                	sext.w	a5,a5
ffffffffc0204086:	22979e63          	bne	a5,s1,ffffffffc02042c2 <_fifo_check_swap+0x2cc>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc020408a:	00004517          	auipc	a0,0x4
ffffffffc020408e:	02e50513          	addi	a0,a0,46 # ffffffffc02080b8 <default_pmm_manager+0xa60>
ffffffffc0204092:	8fcfc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0204096:	6795                	lui	a5,0x5
ffffffffc0204098:	4739                	li	a4,14
ffffffffc020409a:	00e78023          	sb	a4,0(a5) # 5000 <_binary_obj___user_faultread_out_size-0x4570>
    assert(pgfault_num==5);
ffffffffc020409e:	4004                	lw	s1,0(s0)
ffffffffc02040a0:	4795                	li	a5,5
ffffffffc02040a2:	2481                	sext.w	s1,s1
ffffffffc02040a4:	1ef49f63          	bne	s1,a5,ffffffffc02042a2 <_fifo_check_swap+0x2ac>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc02040a8:	00004517          	auipc	a0,0x4
ffffffffc02040ac:	fe850513          	addi	a0,a0,-24 # ffffffffc0208090 <default_pmm_manager+0xa38>
ffffffffc02040b0:	8defc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc02040b4:	01990023          	sb	s9,0(s2)
    assert(pgfault_num==5);
ffffffffc02040b8:	401c                	lw	a5,0(s0)
ffffffffc02040ba:	2781                	sext.w	a5,a5
ffffffffc02040bc:	1c979363          	bne	a5,s1,ffffffffc0204282 <_fifo_check_swap+0x28c>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc02040c0:	00004517          	auipc	a0,0x4
ffffffffc02040c4:	f8050513          	addi	a0,a0,-128 # ffffffffc0208040 <default_pmm_manager+0x9e8>
ffffffffc02040c8:	8c6fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc02040cc:	016a8023          	sb	s6,0(s5)
    assert(pgfault_num==6);
ffffffffc02040d0:	401c                	lw	a5,0(s0)
ffffffffc02040d2:	4719                	li	a4,6
ffffffffc02040d4:	2781                	sext.w	a5,a5
ffffffffc02040d6:	18e79663          	bne	a5,a4,ffffffffc0204262 <_fifo_check_swap+0x26c>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc02040da:	00004517          	auipc	a0,0x4
ffffffffc02040de:	fb650513          	addi	a0,a0,-74 # ffffffffc0208090 <default_pmm_manager+0xa38>
ffffffffc02040e2:	8acfc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc02040e6:	01990023          	sb	s9,0(s2)
    assert(pgfault_num==7);
ffffffffc02040ea:	401c                	lw	a5,0(s0)
ffffffffc02040ec:	471d                	li	a4,7
ffffffffc02040ee:	2781                	sext.w	a5,a5
ffffffffc02040f0:	14e79963          	bne	a5,a4,ffffffffc0204242 <_fifo_check_swap+0x24c>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc02040f4:	00004517          	auipc	a0,0x4
ffffffffc02040f8:	f0c50513          	addi	a0,a0,-244 # ffffffffc0208000 <default_pmm_manager+0x9a8>
ffffffffc02040fc:	892fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0204100:	01498023          	sb	s4,0(s3)
    assert(pgfault_num==8);
ffffffffc0204104:	401c                	lw	a5,0(s0)
ffffffffc0204106:	4721                	li	a4,8
ffffffffc0204108:	2781                	sext.w	a5,a5
ffffffffc020410a:	10e79c63          	bne	a5,a4,ffffffffc0204222 <_fifo_check_swap+0x22c>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc020410e:	00004517          	auipc	a0,0x4
ffffffffc0204112:	f5a50513          	addi	a0,a0,-166 # ffffffffc0208068 <default_pmm_manager+0xa10>
ffffffffc0204116:	878fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc020411a:	018b8023          	sb	s8,0(s7)
    assert(pgfault_num==9);
ffffffffc020411e:	401c                	lw	a5,0(s0)
ffffffffc0204120:	4725                	li	a4,9
ffffffffc0204122:	2781                	sext.w	a5,a5
ffffffffc0204124:	0ce79f63          	bne	a5,a4,ffffffffc0204202 <_fifo_check_swap+0x20c>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc0204128:	00004517          	auipc	a0,0x4
ffffffffc020412c:	f9050513          	addi	a0,a0,-112 # ffffffffc02080b8 <default_pmm_manager+0xa60>
ffffffffc0204130:	85efc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0204134:	6795                	lui	a5,0x5
ffffffffc0204136:	4739                	li	a4,14
ffffffffc0204138:	00e78023          	sb	a4,0(a5) # 5000 <_binary_obj___user_faultread_out_size-0x4570>
    assert(pgfault_num==10);
ffffffffc020413c:	4004                	lw	s1,0(s0)
ffffffffc020413e:	47a9                	li	a5,10
ffffffffc0204140:	2481                	sext.w	s1,s1
ffffffffc0204142:	0af49063          	bne	s1,a5,ffffffffc02041e2 <_fifo_check_swap+0x1ec>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0204146:	00004517          	auipc	a0,0x4
ffffffffc020414a:	efa50513          	addi	a0,a0,-262 # ffffffffc0208040 <default_pmm_manager+0x9e8>
ffffffffc020414e:	840fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0204152:	6785                	lui	a5,0x1
ffffffffc0204154:	0007c783          	lbu	a5,0(a5) # 1000 <_binary_obj___user_faultread_out_size-0x8570>
ffffffffc0204158:	06979563          	bne	a5,s1,ffffffffc02041c2 <_fifo_check_swap+0x1cc>
    assert(pgfault_num==11);
ffffffffc020415c:	401c                	lw	a5,0(s0)
ffffffffc020415e:	472d                	li	a4,11
ffffffffc0204160:	2781                	sext.w	a5,a5
ffffffffc0204162:	04e79063          	bne	a5,a4,ffffffffc02041a2 <_fifo_check_swap+0x1ac>
}
ffffffffc0204166:	60e6                	ld	ra,88(sp)
ffffffffc0204168:	6446                	ld	s0,80(sp)
ffffffffc020416a:	64a6                	ld	s1,72(sp)
ffffffffc020416c:	6906                	ld	s2,64(sp)
ffffffffc020416e:	79e2                	ld	s3,56(sp)
ffffffffc0204170:	7a42                	ld	s4,48(sp)
ffffffffc0204172:	7aa2                	ld	s5,40(sp)
ffffffffc0204174:	7b02                	ld	s6,32(sp)
ffffffffc0204176:	6be2                	ld	s7,24(sp)
ffffffffc0204178:	6c42                	ld	s8,16(sp)
ffffffffc020417a:	6ca2                	ld	s9,8(sp)
ffffffffc020417c:	4501                	li	a0,0
ffffffffc020417e:	6125                	addi	sp,sp,96
ffffffffc0204180:	8082                	ret
    assert(pgfault_num==4);
ffffffffc0204182:	00004697          	auipc	a3,0x4
ffffffffc0204186:	d1e68693          	addi	a3,a3,-738 # ffffffffc0207ea0 <default_pmm_manager+0x848>
ffffffffc020418a:	00003617          	auipc	a2,0x3
ffffffffc020418e:	bf660613          	addi	a2,a2,-1034 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0204192:	05100593          	li	a1,81
ffffffffc0204196:	00004517          	auipc	a0,0x4
ffffffffc020419a:	e9250513          	addi	a0,a0,-366 # ffffffffc0208028 <default_pmm_manager+0x9d0>
ffffffffc020419e:	ae6fc0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pgfault_num==11);
ffffffffc02041a2:	00004697          	auipc	a3,0x4
ffffffffc02041a6:	fc668693          	addi	a3,a3,-58 # ffffffffc0208168 <default_pmm_manager+0xb10>
ffffffffc02041aa:	00003617          	auipc	a2,0x3
ffffffffc02041ae:	bd660613          	addi	a2,a2,-1066 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc02041b2:	07300593          	li	a1,115
ffffffffc02041b6:	00004517          	auipc	a0,0x4
ffffffffc02041ba:	e7250513          	addi	a0,a0,-398 # ffffffffc0208028 <default_pmm_manager+0x9d0>
ffffffffc02041be:	ac6fc0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc02041c2:	00004697          	auipc	a3,0x4
ffffffffc02041c6:	f7e68693          	addi	a3,a3,-130 # ffffffffc0208140 <default_pmm_manager+0xae8>
ffffffffc02041ca:	00003617          	auipc	a2,0x3
ffffffffc02041ce:	bb660613          	addi	a2,a2,-1098 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc02041d2:	07100593          	li	a1,113
ffffffffc02041d6:	00004517          	auipc	a0,0x4
ffffffffc02041da:	e5250513          	addi	a0,a0,-430 # ffffffffc0208028 <default_pmm_manager+0x9d0>
ffffffffc02041de:	aa6fc0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pgfault_num==10);
ffffffffc02041e2:	00004697          	auipc	a3,0x4
ffffffffc02041e6:	f4e68693          	addi	a3,a3,-178 # ffffffffc0208130 <default_pmm_manager+0xad8>
ffffffffc02041ea:	00003617          	auipc	a2,0x3
ffffffffc02041ee:	b9660613          	addi	a2,a2,-1130 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc02041f2:	06f00593          	li	a1,111
ffffffffc02041f6:	00004517          	auipc	a0,0x4
ffffffffc02041fa:	e3250513          	addi	a0,a0,-462 # ffffffffc0208028 <default_pmm_manager+0x9d0>
ffffffffc02041fe:	a86fc0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pgfault_num==9);
ffffffffc0204202:	00004697          	auipc	a3,0x4
ffffffffc0204206:	f1e68693          	addi	a3,a3,-226 # ffffffffc0208120 <default_pmm_manager+0xac8>
ffffffffc020420a:	00003617          	auipc	a2,0x3
ffffffffc020420e:	b7660613          	addi	a2,a2,-1162 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0204212:	06c00593          	li	a1,108
ffffffffc0204216:	00004517          	auipc	a0,0x4
ffffffffc020421a:	e1250513          	addi	a0,a0,-494 # ffffffffc0208028 <default_pmm_manager+0x9d0>
ffffffffc020421e:	a66fc0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pgfault_num==8);
ffffffffc0204222:	00004697          	auipc	a3,0x4
ffffffffc0204226:	eee68693          	addi	a3,a3,-274 # ffffffffc0208110 <default_pmm_manager+0xab8>
ffffffffc020422a:	00003617          	auipc	a2,0x3
ffffffffc020422e:	b5660613          	addi	a2,a2,-1194 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0204232:	06900593          	li	a1,105
ffffffffc0204236:	00004517          	auipc	a0,0x4
ffffffffc020423a:	df250513          	addi	a0,a0,-526 # ffffffffc0208028 <default_pmm_manager+0x9d0>
ffffffffc020423e:	a46fc0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pgfault_num==7);
ffffffffc0204242:	00004697          	auipc	a3,0x4
ffffffffc0204246:	ebe68693          	addi	a3,a3,-322 # ffffffffc0208100 <default_pmm_manager+0xaa8>
ffffffffc020424a:	00003617          	auipc	a2,0x3
ffffffffc020424e:	b3660613          	addi	a2,a2,-1226 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0204252:	06600593          	li	a1,102
ffffffffc0204256:	00004517          	auipc	a0,0x4
ffffffffc020425a:	dd250513          	addi	a0,a0,-558 # ffffffffc0208028 <default_pmm_manager+0x9d0>
ffffffffc020425e:	a26fc0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pgfault_num==6);
ffffffffc0204262:	00004697          	auipc	a3,0x4
ffffffffc0204266:	e8e68693          	addi	a3,a3,-370 # ffffffffc02080f0 <default_pmm_manager+0xa98>
ffffffffc020426a:	00003617          	auipc	a2,0x3
ffffffffc020426e:	b1660613          	addi	a2,a2,-1258 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0204272:	06300593          	li	a1,99
ffffffffc0204276:	00004517          	auipc	a0,0x4
ffffffffc020427a:	db250513          	addi	a0,a0,-590 # ffffffffc0208028 <default_pmm_manager+0x9d0>
ffffffffc020427e:	a06fc0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pgfault_num==5);
ffffffffc0204282:	00004697          	auipc	a3,0x4
ffffffffc0204286:	e5e68693          	addi	a3,a3,-418 # ffffffffc02080e0 <default_pmm_manager+0xa88>
ffffffffc020428a:	00003617          	auipc	a2,0x3
ffffffffc020428e:	af660613          	addi	a2,a2,-1290 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0204292:	06000593          	li	a1,96
ffffffffc0204296:	00004517          	auipc	a0,0x4
ffffffffc020429a:	d9250513          	addi	a0,a0,-622 # ffffffffc0208028 <default_pmm_manager+0x9d0>
ffffffffc020429e:	9e6fc0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pgfault_num==5);
ffffffffc02042a2:	00004697          	auipc	a3,0x4
ffffffffc02042a6:	e3e68693          	addi	a3,a3,-450 # ffffffffc02080e0 <default_pmm_manager+0xa88>
ffffffffc02042aa:	00003617          	auipc	a2,0x3
ffffffffc02042ae:	ad660613          	addi	a2,a2,-1322 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc02042b2:	05d00593          	li	a1,93
ffffffffc02042b6:	00004517          	auipc	a0,0x4
ffffffffc02042ba:	d7250513          	addi	a0,a0,-654 # ffffffffc0208028 <default_pmm_manager+0x9d0>
ffffffffc02042be:	9c6fc0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pgfault_num==4);
ffffffffc02042c2:	00004697          	auipc	a3,0x4
ffffffffc02042c6:	bde68693          	addi	a3,a3,-1058 # ffffffffc0207ea0 <default_pmm_manager+0x848>
ffffffffc02042ca:	00003617          	auipc	a2,0x3
ffffffffc02042ce:	ab660613          	addi	a2,a2,-1354 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc02042d2:	05a00593          	li	a1,90
ffffffffc02042d6:	00004517          	auipc	a0,0x4
ffffffffc02042da:	d5250513          	addi	a0,a0,-686 # ffffffffc0208028 <default_pmm_manager+0x9d0>
ffffffffc02042de:	9a6fc0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pgfault_num==4);
ffffffffc02042e2:	00004697          	auipc	a3,0x4
ffffffffc02042e6:	bbe68693          	addi	a3,a3,-1090 # ffffffffc0207ea0 <default_pmm_manager+0x848>
ffffffffc02042ea:	00003617          	auipc	a2,0x3
ffffffffc02042ee:	a9660613          	addi	a2,a2,-1386 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc02042f2:	05700593          	li	a1,87
ffffffffc02042f6:	00004517          	auipc	a0,0x4
ffffffffc02042fa:	d3250513          	addi	a0,a0,-718 # ffffffffc0208028 <default_pmm_manager+0x9d0>
ffffffffc02042fe:	986fc0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pgfault_num==4);
ffffffffc0204302:	00004697          	auipc	a3,0x4
ffffffffc0204306:	b9e68693          	addi	a3,a3,-1122 # ffffffffc0207ea0 <default_pmm_manager+0x848>
ffffffffc020430a:	00003617          	auipc	a2,0x3
ffffffffc020430e:	a7660613          	addi	a2,a2,-1418 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0204312:	05400593          	li	a1,84
ffffffffc0204316:	00004517          	auipc	a0,0x4
ffffffffc020431a:	d1250513          	addi	a0,a0,-750 # ffffffffc0208028 <default_pmm_manager+0x9d0>
ffffffffc020431e:	966fc0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0204322 <_fifo_swap_out_victim>:
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc0204322:	751c                	ld	a5,40(a0)
{
ffffffffc0204324:	1141                	addi	sp,sp,-16
ffffffffc0204326:	e406                	sd	ra,8(sp)
         assert(head != NULL);
ffffffffc0204328:	cf91                	beqz	a5,ffffffffc0204344 <_fifo_swap_out_victim+0x22>
     assert(in_tick==0);
ffffffffc020432a:	ee0d                	bnez	a2,ffffffffc0204364 <_fifo_swap_out_victim+0x42>
    return listelm->next;
ffffffffc020432c:	679c                	ld	a5,8(a5)
}
ffffffffc020432e:	60a2                	ld	ra,8(sp)
ffffffffc0204330:	4501                	li	a0,0
    __list_del(listelm->prev, listelm->next);
ffffffffc0204332:	6394                	ld	a3,0(a5)
ffffffffc0204334:	6798                	ld	a4,8(a5)
    *ptr_page = le2page(entry, pra_page_link);
ffffffffc0204336:	fd878793          	addi	a5,a5,-40
    prev->next = next;
ffffffffc020433a:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc020433c:	e314                	sd	a3,0(a4)
ffffffffc020433e:	e19c                	sd	a5,0(a1)
}
ffffffffc0204340:	0141                	addi	sp,sp,16
ffffffffc0204342:	8082                	ret
         assert(head != NULL);
ffffffffc0204344:	00004697          	auipc	a3,0x4
ffffffffc0204348:	e5468693          	addi	a3,a3,-428 # ffffffffc0208198 <default_pmm_manager+0xb40>
ffffffffc020434c:	00003617          	auipc	a2,0x3
ffffffffc0204350:	a3460613          	addi	a2,a2,-1484 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0204354:	04100593          	li	a1,65
ffffffffc0204358:	00004517          	auipc	a0,0x4
ffffffffc020435c:	cd050513          	addi	a0,a0,-816 # ffffffffc0208028 <default_pmm_manager+0x9d0>
ffffffffc0204360:	924fc0ef          	jal	ra,ffffffffc0200484 <__panic>
     assert(in_tick==0);
ffffffffc0204364:	00004697          	auipc	a3,0x4
ffffffffc0204368:	e4468693          	addi	a3,a3,-444 # ffffffffc02081a8 <default_pmm_manager+0xb50>
ffffffffc020436c:	00003617          	auipc	a2,0x3
ffffffffc0204370:	a1460613          	addi	a2,a2,-1516 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0204374:	04200593          	li	a1,66
ffffffffc0204378:	00004517          	auipc	a0,0x4
ffffffffc020437c:	cb050513          	addi	a0,a0,-848 # ffffffffc0208028 <default_pmm_manager+0x9d0>
ffffffffc0204380:	904fc0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0204384 <_fifo_map_swappable>:
    list_entry_t *entry=&(page->pra_page_link);
ffffffffc0204384:	02860713          	addi	a4,a2,40
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc0204388:	751c                	ld	a5,40(a0)
    assert(entry != NULL && head != NULL);
ffffffffc020438a:	cb09                	beqz	a4,ffffffffc020439c <_fifo_map_swappable+0x18>
ffffffffc020438c:	cb81                	beqz	a5,ffffffffc020439c <_fifo_map_swappable+0x18>
    __list_add(elm, listelm->prev, listelm);
ffffffffc020438e:	6394                	ld	a3,0(a5)
    prev->next = next->prev = elm;
ffffffffc0204390:	e398                	sd	a4,0(a5)
}
ffffffffc0204392:	4501                	li	a0,0
ffffffffc0204394:	e698                	sd	a4,8(a3)
    elm->next = next;
ffffffffc0204396:	fa1c                	sd	a5,48(a2)
    elm->prev = prev;
ffffffffc0204398:	f614                	sd	a3,40(a2)
ffffffffc020439a:	8082                	ret
{
ffffffffc020439c:	1141                	addi	sp,sp,-16
    assert(entry != NULL && head != NULL);
ffffffffc020439e:	00004697          	auipc	a3,0x4
ffffffffc02043a2:	dda68693          	addi	a3,a3,-550 # ffffffffc0208178 <default_pmm_manager+0xb20>
ffffffffc02043a6:	00003617          	auipc	a2,0x3
ffffffffc02043aa:	9da60613          	addi	a2,a2,-1574 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc02043ae:	03200593          	li	a1,50
ffffffffc02043b2:	00004517          	auipc	a0,0x4
ffffffffc02043b6:	c7650513          	addi	a0,a0,-906 # ffffffffc0208028 <default_pmm_manager+0x9d0>
{
ffffffffc02043ba:	e406                	sd	ra,8(sp)
    assert(entry != NULL && head != NULL);
ffffffffc02043bc:	8c8fc0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc02043c0 <check_vma_overlap.isra.0.part.1>:
}


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc02043c0:	1141                	addi	sp,sp,-16
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc02043c2:	00004697          	auipc	a3,0x4
ffffffffc02043c6:	e0e68693          	addi	a3,a3,-498 # ffffffffc02081d0 <default_pmm_manager+0xb78>
ffffffffc02043ca:	00003617          	auipc	a2,0x3
ffffffffc02043ce:	9b660613          	addi	a2,a2,-1610 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc02043d2:	06e00593          	li	a1,110
ffffffffc02043d6:	00004517          	auipc	a0,0x4
ffffffffc02043da:	e1a50513          	addi	a0,a0,-486 # ffffffffc02081f0 <default_pmm_manager+0xb98>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc02043de:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc02043e0:	8a4fc0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc02043e4 <mm_create>:
mm_create(void) {
ffffffffc02043e4:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc02043e6:	04000513          	li	a0,64
mm_create(void) {
ffffffffc02043ea:	e022                	sd	s0,0(sp)
ffffffffc02043ec:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc02043ee:	dbbfd0ef          	jal	ra,ffffffffc02021a8 <kmalloc>
ffffffffc02043f2:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc02043f4:	c515                	beqz	a0,ffffffffc0204420 <mm_create+0x3c>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc02043f6:	000a8797          	auipc	a5,0xa8
ffffffffc02043fa:	09278793          	addi	a5,a5,146 # ffffffffc02ac488 <swap_init_ok>
ffffffffc02043fe:	439c                	lw	a5,0(a5)
    elm->prev = elm->next = elm;
ffffffffc0204400:	e408                	sd	a0,8(s0)
ffffffffc0204402:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;
ffffffffc0204404:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0204408:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc020440c:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0204410:	2781                	sext.w	a5,a5
ffffffffc0204412:	ef81                	bnez	a5,ffffffffc020442a <mm_create+0x46>
        else mm->sm_priv = NULL;
ffffffffc0204414:	02053423          	sd	zero,40(a0)
    mm->mm_count = val;
ffffffffc0204418:	02042823          	sw	zero,48(s0)
    *lock = 0;
ffffffffc020441c:	02043c23          	sd	zero,56(s0)
}
ffffffffc0204420:	8522                	mv	a0,s0
ffffffffc0204422:	60a2                	ld	ra,8(sp)
ffffffffc0204424:	6402                	ld	s0,0(sp)
ffffffffc0204426:	0141                	addi	sp,sp,16
ffffffffc0204428:	8082                	ret
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc020442a:	a01ff0ef          	jal	ra,ffffffffc0203e2a <swap_init_mm>
ffffffffc020442e:	b7ed                	j	ffffffffc0204418 <mm_create+0x34>

ffffffffc0204430 <vma_create>:
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc0204430:	1101                	addi	sp,sp,-32
ffffffffc0204432:	e04a                	sd	s2,0(sp)
ffffffffc0204434:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0204436:	03000513          	li	a0,48
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc020443a:	e822                	sd	s0,16(sp)
ffffffffc020443c:	e426                	sd	s1,8(sp)
ffffffffc020443e:	ec06                	sd	ra,24(sp)
ffffffffc0204440:	84ae                	mv	s1,a1
ffffffffc0204442:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0204444:	d65fd0ef          	jal	ra,ffffffffc02021a8 <kmalloc>
    if (vma != NULL) {
ffffffffc0204448:	c509                	beqz	a0,ffffffffc0204452 <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc020444a:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc020444e:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0204450:	cd00                	sw	s0,24(a0)
}
ffffffffc0204452:	60e2                	ld	ra,24(sp)
ffffffffc0204454:	6442                	ld	s0,16(sp)
ffffffffc0204456:	64a2                	ld	s1,8(sp)
ffffffffc0204458:	6902                	ld	s2,0(sp)
ffffffffc020445a:	6105                	addi	sp,sp,32
ffffffffc020445c:	8082                	ret

ffffffffc020445e <find_vma>:
    if (mm != NULL) {
ffffffffc020445e:	c51d                	beqz	a0,ffffffffc020448c <find_vma+0x2e>
        vma = mm->mmap_cache;
ffffffffc0204460:	691c                	ld	a5,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0204462:	c781                	beqz	a5,ffffffffc020446a <find_vma+0xc>
ffffffffc0204464:	6798                	ld	a4,8(a5)
ffffffffc0204466:	02e5f663          	bleu	a4,a1,ffffffffc0204492 <find_vma+0x34>
                list_entry_t *list = &(mm->mmap_list), *le = list;
ffffffffc020446a:	87aa                	mv	a5,a0
    return listelm->next;
ffffffffc020446c:	679c                	ld	a5,8(a5)
                while ((le = list_next(le)) != list) {
ffffffffc020446e:	00f50f63          	beq	a0,a5,ffffffffc020448c <find_vma+0x2e>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
ffffffffc0204472:	fe87b703          	ld	a4,-24(a5)
ffffffffc0204476:	fee5ebe3          	bltu	a1,a4,ffffffffc020446c <find_vma+0xe>
ffffffffc020447a:	ff07b703          	ld	a4,-16(a5)
ffffffffc020447e:	fee5f7e3          	bleu	a4,a1,ffffffffc020446c <find_vma+0xe>
                    vma = le2vma(le, list_link);
ffffffffc0204482:	1781                	addi	a5,a5,-32
        if (vma != NULL) {
ffffffffc0204484:	c781                	beqz	a5,ffffffffc020448c <find_vma+0x2e>
            mm->mmap_cache = vma;
ffffffffc0204486:	e91c                	sd	a5,16(a0)
}
ffffffffc0204488:	853e                	mv	a0,a5
ffffffffc020448a:	8082                	ret
    struct vma_struct *vma = NULL;
ffffffffc020448c:	4781                	li	a5,0
}
ffffffffc020448e:	853e                	mv	a0,a5
ffffffffc0204490:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0204492:	6b98                	ld	a4,16(a5)
ffffffffc0204494:	fce5fbe3          	bleu	a4,a1,ffffffffc020446a <find_vma+0xc>
            mm->mmap_cache = vma;
ffffffffc0204498:	e91c                	sd	a5,16(a0)
    return vma;
ffffffffc020449a:	b7fd                	j	ffffffffc0204488 <find_vma+0x2a>

ffffffffc020449c <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    assert(vma->vm_start < vma->vm_end);
ffffffffc020449c:	6590                	ld	a2,8(a1)
ffffffffc020449e:	0105b803          	ld	a6,16(a1) # 1010 <_binary_obj___user_faultread_out_size-0x8560>
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
ffffffffc02044a2:	1141                	addi	sp,sp,-16
ffffffffc02044a4:	e406                	sd	ra,8(sp)
ffffffffc02044a6:	872a                	mv	a4,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc02044a8:	01066863          	bltu	a2,a6,ffffffffc02044b8 <insert_vma_struct+0x1c>
ffffffffc02044ac:	a8b9                	j	ffffffffc020450a <insert_vma_struct+0x6e>
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc02044ae:	fe87b683          	ld	a3,-24(a5)
ffffffffc02044b2:	04d66763          	bltu	a2,a3,ffffffffc0204500 <insert_vma_struct+0x64>
ffffffffc02044b6:	873e                	mv	a4,a5
ffffffffc02044b8:	671c                	ld	a5,8(a4)
        while ((le = list_next(le)) != list) {
ffffffffc02044ba:	fef51ae3          	bne	a0,a5,ffffffffc02044ae <insert_vma_struct+0x12>
        }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list) {
ffffffffc02044be:	02a70463          	beq	a4,a0,ffffffffc02044e6 <insert_vma_struct+0x4a>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc02044c2:	ff073683          	ld	a3,-16(a4)
    assert(prev->vm_start < prev->vm_end);
ffffffffc02044c6:	fe873883          	ld	a7,-24(a4)
ffffffffc02044ca:	08d8f063          	bleu	a3,a7,ffffffffc020454a <insert_vma_struct+0xae>
    assert(prev->vm_end <= next->vm_start);
ffffffffc02044ce:	04d66e63          	bltu	a2,a3,ffffffffc020452a <insert_vma_struct+0x8e>
    }
    if (le_next != list) {
ffffffffc02044d2:	00f50a63          	beq	a0,a5,ffffffffc02044e6 <insert_vma_struct+0x4a>
ffffffffc02044d6:	fe87b683          	ld	a3,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc02044da:	0506e863          	bltu	a3,a6,ffffffffc020452a <insert_vma_struct+0x8e>
    assert(next->vm_start < next->vm_end);
ffffffffc02044de:	ff07b603          	ld	a2,-16(a5)
ffffffffc02044e2:	02c6f263          	bleu	a2,a3,ffffffffc0204506 <insert_vma_struct+0x6a>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count ++;
ffffffffc02044e6:	5114                	lw	a3,32(a0)
    vma->vm_mm = mm;
ffffffffc02044e8:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc02044ea:	02058613          	addi	a2,a1,32
    prev->next = next->prev = elm;
ffffffffc02044ee:	e390                	sd	a2,0(a5)
ffffffffc02044f0:	e710                	sd	a2,8(a4)
}
ffffffffc02044f2:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc02044f4:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc02044f6:	f198                	sd	a4,32(a1)
    mm->map_count ++;
ffffffffc02044f8:	2685                	addiw	a3,a3,1
ffffffffc02044fa:	d114                	sw	a3,32(a0)
}
ffffffffc02044fc:	0141                	addi	sp,sp,16
ffffffffc02044fe:	8082                	ret
    if (le_prev != list) {
ffffffffc0204500:	fca711e3          	bne	a4,a0,ffffffffc02044c2 <insert_vma_struct+0x26>
ffffffffc0204504:	bfd9                	j	ffffffffc02044da <insert_vma_struct+0x3e>
ffffffffc0204506:	ebbff0ef          	jal	ra,ffffffffc02043c0 <check_vma_overlap.isra.0.part.1>
    assert(vma->vm_start < vma->vm_end);
ffffffffc020450a:	00004697          	auipc	a3,0x4
ffffffffc020450e:	db668693          	addi	a3,a3,-586 # ffffffffc02082c0 <default_pmm_manager+0xc68>
ffffffffc0204512:	00003617          	auipc	a2,0x3
ffffffffc0204516:	86e60613          	addi	a2,a2,-1938 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc020451a:	07500593          	li	a1,117
ffffffffc020451e:	00004517          	auipc	a0,0x4
ffffffffc0204522:	cd250513          	addi	a0,a0,-814 # ffffffffc02081f0 <default_pmm_manager+0xb98>
ffffffffc0204526:	f5ffb0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc020452a:	00004697          	auipc	a3,0x4
ffffffffc020452e:	dd668693          	addi	a3,a3,-554 # ffffffffc0208300 <default_pmm_manager+0xca8>
ffffffffc0204532:	00003617          	auipc	a2,0x3
ffffffffc0204536:	84e60613          	addi	a2,a2,-1970 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc020453a:	06d00593          	li	a1,109
ffffffffc020453e:	00004517          	auipc	a0,0x4
ffffffffc0204542:	cb250513          	addi	a0,a0,-846 # ffffffffc02081f0 <default_pmm_manager+0xb98>
ffffffffc0204546:	f3ffb0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc020454a:	00004697          	auipc	a3,0x4
ffffffffc020454e:	d9668693          	addi	a3,a3,-618 # ffffffffc02082e0 <default_pmm_manager+0xc88>
ffffffffc0204552:	00003617          	auipc	a2,0x3
ffffffffc0204556:	82e60613          	addi	a2,a2,-2002 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc020455a:	06c00593          	li	a1,108
ffffffffc020455e:	00004517          	auipc	a0,0x4
ffffffffc0204562:	c9250513          	addi	a0,a0,-878 # ffffffffc02081f0 <default_pmm_manager+0xb98>
ffffffffc0204566:	f1ffb0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc020456a <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
    assert(mm_count(mm) == 0);
ffffffffc020456a:	591c                	lw	a5,48(a0)
mm_destroy(struct mm_struct *mm) {
ffffffffc020456c:	1141                	addi	sp,sp,-16
ffffffffc020456e:	e406                	sd	ra,8(sp)
ffffffffc0204570:	e022                	sd	s0,0(sp)
    assert(mm_count(mm) == 0);
ffffffffc0204572:	e78d                	bnez	a5,ffffffffc020459c <mm_destroy+0x32>
ffffffffc0204574:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc0204576:	6508                	ld	a0,8(a0)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
ffffffffc0204578:	00a40c63          	beq	s0,a0,ffffffffc0204590 <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc020457c:	6118                	ld	a4,0(a0)
ffffffffc020457e:	651c                	ld	a5,8(a0)
        list_del(le);
        kfree(le2vma(le, list_link));  //kfree vma        
ffffffffc0204580:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc0204582:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0204584:	e398                	sd	a4,0(a5)
ffffffffc0204586:	cdffd0ef          	jal	ra,ffffffffc0202264 <kfree>
    return listelm->next;
ffffffffc020458a:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc020458c:	fea418e3          	bne	s0,a0,ffffffffc020457c <mm_destroy+0x12>
    }
    kfree(mm); //kfree mm
ffffffffc0204590:	8522                	mv	a0,s0
    mm=NULL;
}
ffffffffc0204592:	6402                	ld	s0,0(sp)
ffffffffc0204594:	60a2                	ld	ra,8(sp)
ffffffffc0204596:	0141                	addi	sp,sp,16
    kfree(mm); //kfree mm
ffffffffc0204598:	ccdfd06f          	j	ffffffffc0202264 <kfree>
    assert(mm_count(mm) == 0);
ffffffffc020459c:	00004697          	auipc	a3,0x4
ffffffffc02045a0:	d8468693          	addi	a3,a3,-636 # ffffffffc0208320 <default_pmm_manager+0xcc8>
ffffffffc02045a4:	00002617          	auipc	a2,0x2
ffffffffc02045a8:	7dc60613          	addi	a2,a2,2012 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc02045ac:	09500593          	li	a1,149
ffffffffc02045b0:	00004517          	auipc	a0,0x4
ffffffffc02045b4:	c4050513          	addi	a0,a0,-960 # ffffffffc02081f0 <default_pmm_manager+0xb98>
ffffffffc02045b8:	ecdfb0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc02045bc <mm_map>:

int
mm_map(struct mm_struct *mm, uintptr_t addr, size_t len, uint32_t vm_flags,
       struct vma_struct **vma_store) {
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc02045bc:	6785                	lui	a5,0x1
       struct vma_struct **vma_store) {
ffffffffc02045be:	7139                	addi	sp,sp,-64
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc02045c0:	17fd                	addi	a5,a5,-1
ffffffffc02045c2:	787d                	lui	a6,0xfffff
       struct vma_struct **vma_store) {
ffffffffc02045c4:	f822                	sd	s0,48(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc02045c6:	00f60433          	add	s0,a2,a5
       struct vma_struct **vma_store) {
ffffffffc02045ca:	f426                	sd	s1,40(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc02045cc:	942e                	add	s0,s0,a1
       struct vma_struct **vma_store) {
ffffffffc02045ce:	fc06                	sd	ra,56(sp)
ffffffffc02045d0:	f04a                	sd	s2,32(sp)
ffffffffc02045d2:	ec4e                	sd	s3,24(sp)
ffffffffc02045d4:	e852                	sd	s4,16(sp)
ffffffffc02045d6:	e456                	sd	s5,8(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc02045d8:	0105f4b3          	and	s1,a1,a6
    if (!USER_ACCESS(start, end)) {
ffffffffc02045dc:	002007b7          	lui	a5,0x200
ffffffffc02045e0:	01047433          	and	s0,s0,a6
ffffffffc02045e4:	06f4e363          	bltu	s1,a5,ffffffffc020464a <mm_map+0x8e>
ffffffffc02045e8:	0684f163          	bleu	s0,s1,ffffffffc020464a <mm_map+0x8e>
ffffffffc02045ec:	4785                	li	a5,1
ffffffffc02045ee:	07fe                	slli	a5,a5,0x1f
ffffffffc02045f0:	0487ed63          	bltu	a5,s0,ffffffffc020464a <mm_map+0x8e>
ffffffffc02045f4:	89aa                	mv	s3,a0
ffffffffc02045f6:	8a3a                	mv	s4,a4
ffffffffc02045f8:	8ab6                	mv	s5,a3
        return -E_INVAL;
    }

    assert(mm != NULL);
ffffffffc02045fa:	c931                	beqz	a0,ffffffffc020464e <mm_map+0x92>

    int ret = -E_INVAL;

    struct vma_struct *vma;
    if ((vma = find_vma(mm, start)) != NULL && end > vma->vm_start) {
ffffffffc02045fc:	85a6                	mv	a1,s1
ffffffffc02045fe:	e61ff0ef          	jal	ra,ffffffffc020445e <find_vma>
ffffffffc0204602:	c501                	beqz	a0,ffffffffc020460a <mm_map+0x4e>
ffffffffc0204604:	651c                	ld	a5,8(a0)
ffffffffc0204606:	0487e263          	bltu	a5,s0,ffffffffc020464a <mm_map+0x8e>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020460a:	03000513          	li	a0,48
ffffffffc020460e:	b9bfd0ef          	jal	ra,ffffffffc02021a8 <kmalloc>
ffffffffc0204612:	892a                	mv	s2,a0
        goto out;
    }
    ret = -E_NO_MEM;
ffffffffc0204614:	5571                	li	a0,-4
    if (vma != NULL) {
ffffffffc0204616:	02090163          	beqz	s2,ffffffffc0204638 <mm_map+0x7c>

    if ((vma = vma_create(start, end, vm_flags)) == NULL) {
        goto out;
    }
    insert_vma_struct(mm, vma);
ffffffffc020461a:	854e                	mv	a0,s3
        vma->vm_start = vm_start;
ffffffffc020461c:	00993423          	sd	s1,8(s2)
        vma->vm_end = vm_end;
ffffffffc0204620:	00893823          	sd	s0,16(s2)
        vma->vm_flags = vm_flags;
ffffffffc0204624:	01592c23          	sw	s5,24(s2)
    insert_vma_struct(mm, vma);
ffffffffc0204628:	85ca                	mv	a1,s2
ffffffffc020462a:	e73ff0ef          	jal	ra,ffffffffc020449c <insert_vma_struct>
    if (vma_store != NULL) {
        *vma_store = vma;
    }
    ret = 0;
ffffffffc020462e:	4501                	li	a0,0
    if (vma_store != NULL) {
ffffffffc0204630:	000a0463          	beqz	s4,ffffffffc0204638 <mm_map+0x7c>
        *vma_store = vma;
ffffffffc0204634:	012a3023          	sd	s2,0(s4)

out:
    return ret;
}
ffffffffc0204638:	70e2                	ld	ra,56(sp)
ffffffffc020463a:	7442                	ld	s0,48(sp)
ffffffffc020463c:	74a2                	ld	s1,40(sp)
ffffffffc020463e:	7902                	ld	s2,32(sp)
ffffffffc0204640:	69e2                	ld	s3,24(sp)
ffffffffc0204642:	6a42                	ld	s4,16(sp)
ffffffffc0204644:	6aa2                	ld	s5,8(sp)
ffffffffc0204646:	6121                	addi	sp,sp,64
ffffffffc0204648:	8082                	ret
        return -E_INVAL;
ffffffffc020464a:	5575                	li	a0,-3
ffffffffc020464c:	b7f5                	j	ffffffffc0204638 <mm_map+0x7c>
    assert(mm != NULL);
ffffffffc020464e:	00003697          	auipc	a3,0x3
ffffffffc0204652:	6da68693          	addi	a3,a3,1754 # ffffffffc0207d28 <default_pmm_manager+0x6d0>
ffffffffc0204656:	00002617          	auipc	a2,0x2
ffffffffc020465a:	72a60613          	addi	a2,a2,1834 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc020465e:	0a800593          	li	a1,168
ffffffffc0204662:	00004517          	auipc	a0,0x4
ffffffffc0204666:	b8e50513          	addi	a0,a0,-1138 # ffffffffc02081f0 <default_pmm_manager+0xb98>
ffffffffc020466a:	e1bfb0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc020466e <exit_mmap>:
    }
    return 0;
}

void
exit_mmap(struct mm_struct *mm) {
ffffffffc020466e:	1101                	addi	sp,sp,-32
ffffffffc0204670:	ec06                	sd	ra,24(sp)
ffffffffc0204672:	e822                	sd	s0,16(sp)
ffffffffc0204674:	e426                	sd	s1,8(sp)
ffffffffc0204676:	e04a                	sd	s2,0(sp)
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc0204678:	c531                	beqz	a0,ffffffffc02046c4 <exit_mmap+0x56>
ffffffffc020467a:	591c                	lw	a5,48(a0)
ffffffffc020467c:	84aa                	mv	s1,a0
ffffffffc020467e:	e3b9                	bnez	a5,ffffffffc02046c4 <exit_mmap+0x56>
ffffffffc0204680:	6500                	ld	s0,8(a0)
    pde_t *pgdir = mm->pgdir;
ffffffffc0204682:	01853903          	ld	s2,24(a0)
    list_entry_t *list = &(mm->mmap_list), *le = list;
    while ((le = list_next(le)) != list) {
ffffffffc0204686:	02850663          	beq	a0,s0,ffffffffc02046b2 <exit_mmap+0x44>
        struct vma_struct *vma = le2vma(le, list_link);
        unmap_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc020468a:	ff043603          	ld	a2,-16(s0)
ffffffffc020468e:	fe843583          	ld	a1,-24(s0)
ffffffffc0204692:	854a                	mv	a0,s2
ffffffffc0204694:	852fe0ef          	jal	ra,ffffffffc02026e6 <unmap_range>
ffffffffc0204698:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list) {
ffffffffc020469a:	fe8498e3          	bne	s1,s0,ffffffffc020468a <exit_mmap+0x1c>
ffffffffc020469e:	6400                	ld	s0,8(s0)
    }
    while ((le = list_next(le)) != list) {
ffffffffc02046a0:	00848c63          	beq	s1,s0,ffffffffc02046b8 <exit_mmap+0x4a>
        struct vma_struct *vma = le2vma(le, list_link);
        exit_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc02046a4:	ff043603          	ld	a2,-16(s0)
ffffffffc02046a8:	fe843583          	ld	a1,-24(s0)
ffffffffc02046ac:	854a                	mv	a0,s2
ffffffffc02046ae:	950fe0ef          	jal	ra,ffffffffc02027fe <exit_range>
ffffffffc02046b2:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list) {
ffffffffc02046b4:	fe8498e3          	bne	s1,s0,ffffffffc02046a4 <exit_mmap+0x36>
    }
}
ffffffffc02046b8:	60e2                	ld	ra,24(sp)
ffffffffc02046ba:	6442                	ld	s0,16(sp)
ffffffffc02046bc:	64a2                	ld	s1,8(sp)
ffffffffc02046be:	6902                	ld	s2,0(sp)
ffffffffc02046c0:	6105                	addi	sp,sp,32
ffffffffc02046c2:	8082                	ret
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc02046c4:	00004697          	auipc	a3,0x4
ffffffffc02046c8:	bdc68693          	addi	a3,a3,-1060 # ffffffffc02082a0 <default_pmm_manager+0xc48>
ffffffffc02046cc:	00002617          	auipc	a2,0x2
ffffffffc02046d0:	6b460613          	addi	a2,a2,1716 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc02046d4:	0d700593          	li	a1,215
ffffffffc02046d8:	00004517          	auipc	a0,0x4
ffffffffc02046dc:	b1850513          	addi	a0,a0,-1256 # ffffffffc02081f0 <default_pmm_manager+0xb98>
ffffffffc02046e0:	da5fb0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc02046e4 <vmm_init>:
}

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
ffffffffc02046e4:	7139                	addi	sp,sp,-64
ffffffffc02046e6:	f822                	sd	s0,48(sp)
ffffffffc02046e8:	f426                	sd	s1,40(sp)
ffffffffc02046ea:	fc06                	sd	ra,56(sp)
ffffffffc02046ec:	f04a                	sd	s2,32(sp)
ffffffffc02046ee:	ec4e                	sd	s3,24(sp)
ffffffffc02046f0:	e852                	sd	s4,16(sp)
ffffffffc02046f2:	e456                	sd	s5,8(sp)

static void
check_vma_struct(void) {
    // size_t nr_free_pages_store = nr_free_pages();

    struct mm_struct *mm = mm_create();
ffffffffc02046f4:	cf1ff0ef          	jal	ra,ffffffffc02043e4 <mm_create>
    assert(mm != NULL);
ffffffffc02046f8:	842a                	mv	s0,a0
ffffffffc02046fa:	03200493          	li	s1,50
ffffffffc02046fe:	e919                	bnez	a0,ffffffffc0204714 <vmm_init+0x30>
ffffffffc0204700:	a989                	j	ffffffffc0204b52 <vmm_init+0x46e>
        vma->vm_start = vm_start;
ffffffffc0204702:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc0204704:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0204706:	00052c23          	sw	zero,24(a0)

    int i;
    for (i = step1; i >= 1; i --) {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc020470a:	14ed                	addi	s1,s1,-5
ffffffffc020470c:	8522                	mv	a0,s0
ffffffffc020470e:	d8fff0ef          	jal	ra,ffffffffc020449c <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
ffffffffc0204712:	c88d                	beqz	s1,ffffffffc0204744 <vmm_init+0x60>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0204714:	03000513          	li	a0,48
ffffffffc0204718:	a91fd0ef          	jal	ra,ffffffffc02021a8 <kmalloc>
ffffffffc020471c:	85aa                	mv	a1,a0
ffffffffc020471e:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc0204722:	f165                	bnez	a0,ffffffffc0204702 <vmm_init+0x1e>
        assert(vma != NULL);
ffffffffc0204724:	00003697          	auipc	a3,0x3
ffffffffc0204728:	63c68693          	addi	a3,a3,1596 # ffffffffc0207d60 <default_pmm_manager+0x708>
ffffffffc020472c:	00002617          	auipc	a2,0x2
ffffffffc0204730:	65460613          	addi	a2,a2,1620 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0204734:	11400593          	li	a1,276
ffffffffc0204738:	00004517          	auipc	a0,0x4
ffffffffc020473c:	ab850513          	addi	a0,a0,-1352 # ffffffffc02081f0 <default_pmm_manager+0xb98>
ffffffffc0204740:	d45fb0ef          	jal	ra,ffffffffc0200484 <__panic>
    for (i = step1; i >= 1; i --) {
ffffffffc0204744:	03700493          	li	s1,55
    }

    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0204748:	1f900913          	li	s2,505
ffffffffc020474c:	a819                	j	ffffffffc0204762 <vmm_init+0x7e>
        vma->vm_start = vm_start;
ffffffffc020474e:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc0204750:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0204752:	00052c23          	sw	zero,24(a0)
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0204756:	0495                	addi	s1,s1,5
ffffffffc0204758:	8522                	mv	a0,s0
ffffffffc020475a:	d43ff0ef          	jal	ra,ffffffffc020449c <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc020475e:	03248a63          	beq	s1,s2,ffffffffc0204792 <vmm_init+0xae>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0204762:	03000513          	li	a0,48
ffffffffc0204766:	a43fd0ef          	jal	ra,ffffffffc02021a8 <kmalloc>
ffffffffc020476a:	85aa                	mv	a1,a0
ffffffffc020476c:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc0204770:	fd79                	bnez	a0,ffffffffc020474e <vmm_init+0x6a>
        assert(vma != NULL);
ffffffffc0204772:	00003697          	auipc	a3,0x3
ffffffffc0204776:	5ee68693          	addi	a3,a3,1518 # ffffffffc0207d60 <default_pmm_manager+0x708>
ffffffffc020477a:	00002617          	auipc	a2,0x2
ffffffffc020477e:	60660613          	addi	a2,a2,1542 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0204782:	11a00593          	li	a1,282
ffffffffc0204786:	00004517          	auipc	a0,0x4
ffffffffc020478a:	a6a50513          	addi	a0,a0,-1430 # ffffffffc02081f0 <default_pmm_manager+0xb98>
ffffffffc020478e:	cf7fb0ef          	jal	ra,ffffffffc0200484 <__panic>
ffffffffc0204792:	6418                	ld	a4,8(s0)
ffffffffc0204794:	479d                	li	a5,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
ffffffffc0204796:	1fb00593          	li	a1,507
        assert(le != &(mm->mmap_list));
ffffffffc020479a:	2ee40063          	beq	s0,a4,ffffffffc0204a7a <vmm_init+0x396>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc020479e:	fe873603          	ld	a2,-24(a4)
ffffffffc02047a2:	ffe78693          	addi	a3,a5,-2 # 1ffffe <_binary_obj___user_exit_out_size+0x1f557e>
ffffffffc02047a6:	24d61a63          	bne	a2,a3,ffffffffc02049fa <vmm_init+0x316>
ffffffffc02047aa:	ff073683          	ld	a3,-16(a4)
ffffffffc02047ae:	24f69663          	bne	a3,a5,ffffffffc02049fa <vmm_init+0x316>
ffffffffc02047b2:	0795                	addi	a5,a5,5
ffffffffc02047b4:	6718                	ld	a4,8(a4)
    for (i = 1; i <= step2; i ++) {
ffffffffc02047b6:	feb792e3          	bne	a5,a1,ffffffffc020479a <vmm_init+0xb6>
ffffffffc02047ba:	491d                	li	s2,7
ffffffffc02047bc:	4495                	li	s1,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc02047be:	1f900a93          	li	s5,505
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc02047c2:	85a6                	mv	a1,s1
ffffffffc02047c4:	8522                	mv	a0,s0
ffffffffc02047c6:	c99ff0ef          	jal	ra,ffffffffc020445e <find_vma>
ffffffffc02047ca:	8a2a                	mv	s4,a0
        assert(vma1 != NULL);
ffffffffc02047cc:	30050763          	beqz	a0,ffffffffc0204ada <vmm_init+0x3f6>
        struct vma_struct *vma2 = find_vma(mm, i+1);
ffffffffc02047d0:	00148593          	addi	a1,s1,1
ffffffffc02047d4:	8522                	mv	a0,s0
ffffffffc02047d6:	c89ff0ef          	jal	ra,ffffffffc020445e <find_vma>
ffffffffc02047da:	89aa                	mv	s3,a0
        assert(vma2 != NULL);
ffffffffc02047dc:	2c050f63          	beqz	a0,ffffffffc0204aba <vmm_init+0x3d6>
        struct vma_struct *vma3 = find_vma(mm, i+2);
ffffffffc02047e0:	85ca                	mv	a1,s2
ffffffffc02047e2:	8522                	mv	a0,s0
ffffffffc02047e4:	c7bff0ef          	jal	ra,ffffffffc020445e <find_vma>
        assert(vma3 == NULL);
ffffffffc02047e8:	2a051963          	bnez	a0,ffffffffc0204a9a <vmm_init+0x3b6>
        struct vma_struct *vma4 = find_vma(mm, i+3);
ffffffffc02047ec:	00348593          	addi	a1,s1,3
ffffffffc02047f0:	8522                	mv	a0,s0
ffffffffc02047f2:	c6dff0ef          	jal	ra,ffffffffc020445e <find_vma>
        assert(vma4 == NULL);
ffffffffc02047f6:	32051263          	bnez	a0,ffffffffc0204b1a <vmm_init+0x436>
        struct vma_struct *vma5 = find_vma(mm, i+4);
ffffffffc02047fa:	00448593          	addi	a1,s1,4
ffffffffc02047fe:	8522                	mv	a0,s0
ffffffffc0204800:	c5fff0ef          	jal	ra,ffffffffc020445e <find_vma>
        assert(vma5 == NULL);
ffffffffc0204804:	2e051b63          	bnez	a0,ffffffffc0204afa <vmm_init+0x416>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0204808:	008a3783          	ld	a5,8(s4)
ffffffffc020480c:	20979763          	bne	a5,s1,ffffffffc0204a1a <vmm_init+0x336>
ffffffffc0204810:	010a3783          	ld	a5,16(s4)
ffffffffc0204814:	21279363          	bne	a5,s2,ffffffffc0204a1a <vmm_init+0x336>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0204818:	0089b783          	ld	a5,8(s3)
ffffffffc020481c:	20979f63          	bne	a5,s1,ffffffffc0204a3a <vmm_init+0x356>
ffffffffc0204820:	0109b783          	ld	a5,16(s3)
ffffffffc0204824:	21279b63          	bne	a5,s2,ffffffffc0204a3a <vmm_init+0x356>
ffffffffc0204828:	0495                	addi	s1,s1,5
ffffffffc020482a:	0915                	addi	s2,s2,5
    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc020482c:	f9549be3          	bne	s1,s5,ffffffffc02047c2 <vmm_init+0xde>
ffffffffc0204830:	4491                	li	s1,4
    }

    for (i =4; i>=0; i--) {
ffffffffc0204832:	597d                	li	s2,-1
        struct vma_struct *vma_below_5= find_vma(mm,i);
ffffffffc0204834:	85a6                	mv	a1,s1
ffffffffc0204836:	8522                	mv	a0,s0
ffffffffc0204838:	c27ff0ef          	jal	ra,ffffffffc020445e <find_vma>
ffffffffc020483c:	0004859b          	sext.w	a1,s1
        if (vma_below_5 != NULL ) {
ffffffffc0204840:	c90d                	beqz	a0,ffffffffc0204872 <vmm_init+0x18e>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
ffffffffc0204842:	6914                	ld	a3,16(a0)
ffffffffc0204844:	6510                	ld	a2,8(a0)
ffffffffc0204846:	00004517          	auipc	a0,0x4
ffffffffc020484a:	bf250513          	addi	a0,a0,-1038 # ffffffffc0208438 <default_pmm_manager+0xde0>
ffffffffc020484e:	941fb0ef          	jal	ra,ffffffffc020018e <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc0204852:	00004697          	auipc	a3,0x4
ffffffffc0204856:	c0e68693          	addi	a3,a3,-1010 # ffffffffc0208460 <default_pmm_manager+0xe08>
ffffffffc020485a:	00002617          	auipc	a2,0x2
ffffffffc020485e:	52660613          	addi	a2,a2,1318 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0204862:	13c00593          	li	a1,316
ffffffffc0204866:	00004517          	auipc	a0,0x4
ffffffffc020486a:	98a50513          	addi	a0,a0,-1654 # ffffffffc02081f0 <default_pmm_manager+0xb98>
ffffffffc020486e:	c17fb0ef          	jal	ra,ffffffffc0200484 <__panic>
ffffffffc0204872:	14fd                	addi	s1,s1,-1
    for (i =4; i>=0; i--) {
ffffffffc0204874:	fd2490e3          	bne	s1,s2,ffffffffc0204834 <vmm_init+0x150>
    }

    mm_destroy(mm);
ffffffffc0204878:	8522                	mv	a0,s0
ffffffffc020487a:	cf1ff0ef          	jal	ra,ffffffffc020456a <mm_destroy>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc020487e:	00004517          	auipc	a0,0x4
ffffffffc0204882:	bfa50513          	addi	a0,a0,-1030 # ffffffffc0208478 <default_pmm_manager+0xe20>
ffffffffc0204886:	909fb0ef          	jal	ra,ffffffffc020018e <cprintf>
struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc020488a:	be9fd0ef          	jal	ra,ffffffffc0202472 <nr_free_pages>
ffffffffc020488e:	89aa                	mv	s3,a0

    check_mm_struct = mm_create();
ffffffffc0204890:	b55ff0ef          	jal	ra,ffffffffc02043e4 <mm_create>
ffffffffc0204894:	000a8797          	auipc	a5,0xa8
ffffffffc0204898:	d2a7ba23          	sd	a0,-716(a5) # ffffffffc02ac5c8 <check_mm_struct>
ffffffffc020489c:	84aa                	mv	s1,a0
    assert(check_mm_struct != NULL);
ffffffffc020489e:	36050663          	beqz	a0,ffffffffc0204c0a <vmm_init+0x526>

    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02048a2:	000a8797          	auipc	a5,0xa8
ffffffffc02048a6:	bce78793          	addi	a5,a5,-1074 # ffffffffc02ac470 <boot_pgdir>
ffffffffc02048aa:	0007b903          	ld	s2,0(a5)
    assert(pgdir[0] == 0);
ffffffffc02048ae:	00093783          	ld	a5,0(s2)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02048b2:	01253c23          	sd	s2,24(a0)
    assert(pgdir[0] == 0);
ffffffffc02048b6:	2c079e63          	bnez	a5,ffffffffc0204b92 <vmm_init+0x4ae>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02048ba:	03000513          	li	a0,48
ffffffffc02048be:	8ebfd0ef          	jal	ra,ffffffffc02021a8 <kmalloc>
ffffffffc02048c2:	842a                	mv	s0,a0
    if (vma != NULL) {
ffffffffc02048c4:	18050b63          	beqz	a0,ffffffffc0204a5a <vmm_init+0x376>
        vma->vm_end = vm_end;
ffffffffc02048c8:	002007b7          	lui	a5,0x200
ffffffffc02048cc:	e81c                	sd	a5,16(s0)
        vma->vm_flags = vm_flags;
ffffffffc02048ce:	4789                	li	a5,2

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc02048d0:	85aa                	mv	a1,a0
        vma->vm_flags = vm_flags;
ffffffffc02048d2:	cc1c                	sw	a5,24(s0)
    insert_vma_struct(mm, vma);
ffffffffc02048d4:	8526                	mv	a0,s1
        vma->vm_start = vm_start;
ffffffffc02048d6:	00043423          	sd	zero,8(s0)
    insert_vma_struct(mm, vma);
ffffffffc02048da:	bc3ff0ef          	jal	ra,ffffffffc020449c <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc02048de:	10000593          	li	a1,256
ffffffffc02048e2:	8526                	mv	a0,s1
ffffffffc02048e4:	b7bff0ef          	jal	ra,ffffffffc020445e <find_vma>
ffffffffc02048e8:	10000793          	li	a5,256

    int i, sum = 0;

    for (i = 0; i < 100; i ++) {
ffffffffc02048ec:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc02048f0:	2ca41163          	bne	s0,a0,ffffffffc0204bb2 <vmm_init+0x4ce>
        *(char *)(addr + i) = i;
ffffffffc02048f4:	00f78023          	sb	a5,0(a5) # 200000 <_binary_obj___user_exit_out_size+0x1f5580>
        sum += i;
ffffffffc02048f8:	0785                	addi	a5,a5,1
    for (i = 0; i < 100; i ++) {
ffffffffc02048fa:	fee79de3          	bne	a5,a4,ffffffffc02048f4 <vmm_init+0x210>
        sum += i;
ffffffffc02048fe:	6705                	lui	a4,0x1
    for (i = 0; i < 100; i ++) {
ffffffffc0204900:	10000793          	li	a5,256
        sum += i;
ffffffffc0204904:	35670713          	addi	a4,a4,854 # 1356 <_binary_obj___user_faultread_out_size-0x821a>
    }
    for (i = 0; i < 100; i ++) {
ffffffffc0204908:	16400613          	li	a2,356
        sum -= *(char *)(addr + i);
ffffffffc020490c:	0007c683          	lbu	a3,0(a5)
ffffffffc0204910:	0785                	addi	a5,a5,1
ffffffffc0204912:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i ++) {
ffffffffc0204914:	fec79ce3          	bne	a5,a2,ffffffffc020490c <vmm_init+0x228>
    }

    assert(sum == 0);
ffffffffc0204918:	2c071963          	bnez	a4,ffffffffc0204bea <vmm_init+0x506>
    return pa2page(PDE_ADDR(pde));
ffffffffc020491c:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0204920:	000a8a97          	auipc	s5,0xa8
ffffffffc0204924:	b58a8a93          	addi	s5,s5,-1192 # ffffffffc02ac478 <npage>
ffffffffc0204928:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc020492c:	078a                	slli	a5,a5,0x2
ffffffffc020492e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0204930:	20e7f563          	bleu	a4,a5,ffffffffc0204b3a <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc0204934:	00004697          	auipc	a3,0x4
ffffffffc0204938:	55c68693          	addi	a3,a3,1372 # ffffffffc0208e90 <nbase>
ffffffffc020493c:	0006ba03          	ld	s4,0(a3)
ffffffffc0204940:	414786b3          	sub	a3,a5,s4
ffffffffc0204944:	069a                	slli	a3,a3,0x6
    return page - pages + nbase;
ffffffffc0204946:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0204948:	57fd                	li	a5,-1
    return page - pages + nbase;
ffffffffc020494a:	96d2                	add	a3,a3,s4
    return KADDR(page2pa(page));
ffffffffc020494c:	83b1                	srli	a5,a5,0xc
ffffffffc020494e:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204950:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204952:	28e7f063          	bleu	a4,a5,ffffffffc0204bd2 <vmm_init+0x4ee>
ffffffffc0204956:	000a8797          	auipc	a5,0xa8
ffffffffc020495a:	b8278793          	addi	a5,a5,-1150 # ffffffffc02ac4d8 <va_pa_offset>
ffffffffc020495e:	6380                	ld	s0,0(a5)

    pde_t *pd1=pgdir,*pd0=page2kva(pde2page(pgdir[0]));
    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc0204960:	4581                	li	a1,0
ffffffffc0204962:	854a                	mv	a0,s2
ffffffffc0204964:	9436                	add	s0,s0,a3
ffffffffc0204966:	8eefe0ef          	jal	ra,ffffffffc0202a54 <page_remove>
    return pa2page(PDE_ADDR(pde));
ffffffffc020496a:	601c                	ld	a5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc020496c:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0204970:	078a                	slli	a5,a5,0x2
ffffffffc0204972:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0204974:	1ce7f363          	bleu	a4,a5,ffffffffc0204b3a <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc0204978:	000a8417          	auipc	s0,0xa8
ffffffffc020497c:	b7040413          	addi	s0,s0,-1168 # ffffffffc02ac4e8 <pages>
ffffffffc0204980:	6008                	ld	a0,0(s0)
ffffffffc0204982:	414787b3          	sub	a5,a5,s4
ffffffffc0204986:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd0[0]));
ffffffffc0204988:	953e                	add	a0,a0,a5
ffffffffc020498a:	4585                	li	a1,1
ffffffffc020498c:	aa1fd0ef          	jal	ra,ffffffffc020242c <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0204990:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0204994:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0204998:	078a                	slli	a5,a5,0x2
ffffffffc020499a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020499c:	18e7ff63          	bleu	a4,a5,ffffffffc0204b3a <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc02049a0:	6008                	ld	a0,0(s0)
ffffffffc02049a2:	414787b3          	sub	a5,a5,s4
ffffffffc02049a6:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc02049a8:	4585                	li	a1,1
ffffffffc02049aa:	953e                	add	a0,a0,a5
ffffffffc02049ac:	a81fd0ef          	jal	ra,ffffffffc020242c <free_pages>
    pgdir[0] = 0;
ffffffffc02049b0:	00093023          	sd	zero,0(s2)
  asm volatile("sfence.vma");
ffffffffc02049b4:	12000073          	sfence.vma
    flush_tlb();

    mm->pgdir = NULL;
ffffffffc02049b8:	0004bc23          	sd	zero,24(s1)
    mm_destroy(mm);
ffffffffc02049bc:	8526                	mv	a0,s1
ffffffffc02049be:	badff0ef          	jal	ra,ffffffffc020456a <mm_destroy>
    check_mm_struct = NULL;
ffffffffc02049c2:	000a8797          	auipc	a5,0xa8
ffffffffc02049c6:	c007b323          	sd	zero,-1018(a5) # ffffffffc02ac5c8 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02049ca:	aa9fd0ef          	jal	ra,ffffffffc0202472 <nr_free_pages>
ffffffffc02049ce:	1aa99263          	bne	s3,a0,ffffffffc0204b72 <vmm_init+0x48e>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc02049d2:	00004517          	auipc	a0,0x4
ffffffffc02049d6:	b3650513          	addi	a0,a0,-1226 # ffffffffc0208508 <default_pmm_manager+0xeb0>
ffffffffc02049da:	fb4fb0ef          	jal	ra,ffffffffc020018e <cprintf>
}
ffffffffc02049de:	7442                	ld	s0,48(sp)
ffffffffc02049e0:	70e2                	ld	ra,56(sp)
ffffffffc02049e2:	74a2                	ld	s1,40(sp)
ffffffffc02049e4:	7902                	ld	s2,32(sp)
ffffffffc02049e6:	69e2                	ld	s3,24(sp)
ffffffffc02049e8:	6a42                	ld	s4,16(sp)
ffffffffc02049ea:	6aa2                	ld	s5,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc02049ec:	00004517          	auipc	a0,0x4
ffffffffc02049f0:	b3c50513          	addi	a0,a0,-1220 # ffffffffc0208528 <default_pmm_manager+0xed0>
}
ffffffffc02049f4:	6121                	addi	sp,sp,64
    cprintf("check_vmm() succeeded.\n");
ffffffffc02049f6:	f98fb06f          	j	ffffffffc020018e <cprintf>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc02049fa:	00004697          	auipc	a3,0x4
ffffffffc02049fe:	95668693          	addi	a3,a3,-1706 # ffffffffc0208350 <default_pmm_manager+0xcf8>
ffffffffc0204a02:	00002617          	auipc	a2,0x2
ffffffffc0204a06:	37e60613          	addi	a2,a2,894 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0204a0a:	12300593          	li	a1,291
ffffffffc0204a0e:	00003517          	auipc	a0,0x3
ffffffffc0204a12:	7e250513          	addi	a0,a0,2018 # ffffffffc02081f0 <default_pmm_manager+0xb98>
ffffffffc0204a16:	a6ffb0ef          	jal	ra,ffffffffc0200484 <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc0204a1a:	00004697          	auipc	a3,0x4
ffffffffc0204a1e:	9be68693          	addi	a3,a3,-1602 # ffffffffc02083d8 <default_pmm_manager+0xd80>
ffffffffc0204a22:	00002617          	auipc	a2,0x2
ffffffffc0204a26:	35e60613          	addi	a2,a2,862 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0204a2a:	13300593          	li	a1,307
ffffffffc0204a2e:	00003517          	auipc	a0,0x3
ffffffffc0204a32:	7c250513          	addi	a0,a0,1986 # ffffffffc02081f0 <default_pmm_manager+0xb98>
ffffffffc0204a36:	a4ffb0ef          	jal	ra,ffffffffc0200484 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc0204a3a:	00004697          	auipc	a3,0x4
ffffffffc0204a3e:	9ce68693          	addi	a3,a3,-1586 # ffffffffc0208408 <default_pmm_manager+0xdb0>
ffffffffc0204a42:	00002617          	auipc	a2,0x2
ffffffffc0204a46:	33e60613          	addi	a2,a2,830 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0204a4a:	13400593          	li	a1,308
ffffffffc0204a4e:	00003517          	auipc	a0,0x3
ffffffffc0204a52:	7a250513          	addi	a0,a0,1954 # ffffffffc02081f0 <default_pmm_manager+0xb98>
ffffffffc0204a56:	a2ffb0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(vma != NULL);
ffffffffc0204a5a:	00003697          	auipc	a3,0x3
ffffffffc0204a5e:	30668693          	addi	a3,a3,774 # ffffffffc0207d60 <default_pmm_manager+0x708>
ffffffffc0204a62:	00002617          	auipc	a2,0x2
ffffffffc0204a66:	31e60613          	addi	a2,a2,798 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0204a6a:	15300593          	li	a1,339
ffffffffc0204a6e:	00003517          	auipc	a0,0x3
ffffffffc0204a72:	78250513          	addi	a0,a0,1922 # ffffffffc02081f0 <default_pmm_manager+0xb98>
ffffffffc0204a76:	a0ffb0ef          	jal	ra,ffffffffc0200484 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc0204a7a:	00004697          	auipc	a3,0x4
ffffffffc0204a7e:	8be68693          	addi	a3,a3,-1858 # ffffffffc0208338 <default_pmm_manager+0xce0>
ffffffffc0204a82:	00002617          	auipc	a2,0x2
ffffffffc0204a86:	2fe60613          	addi	a2,a2,766 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0204a8a:	12100593          	li	a1,289
ffffffffc0204a8e:	00003517          	auipc	a0,0x3
ffffffffc0204a92:	76250513          	addi	a0,a0,1890 # ffffffffc02081f0 <default_pmm_manager+0xb98>
ffffffffc0204a96:	9effb0ef          	jal	ra,ffffffffc0200484 <__panic>
        assert(vma3 == NULL);
ffffffffc0204a9a:	00004697          	auipc	a3,0x4
ffffffffc0204a9e:	90e68693          	addi	a3,a3,-1778 # ffffffffc02083a8 <default_pmm_manager+0xd50>
ffffffffc0204aa2:	00002617          	auipc	a2,0x2
ffffffffc0204aa6:	2de60613          	addi	a2,a2,734 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0204aaa:	12d00593          	li	a1,301
ffffffffc0204aae:	00003517          	auipc	a0,0x3
ffffffffc0204ab2:	74250513          	addi	a0,a0,1858 # ffffffffc02081f0 <default_pmm_manager+0xb98>
ffffffffc0204ab6:	9cffb0ef          	jal	ra,ffffffffc0200484 <__panic>
        assert(vma2 != NULL);
ffffffffc0204aba:	00004697          	auipc	a3,0x4
ffffffffc0204abe:	8de68693          	addi	a3,a3,-1826 # ffffffffc0208398 <default_pmm_manager+0xd40>
ffffffffc0204ac2:	00002617          	auipc	a2,0x2
ffffffffc0204ac6:	2be60613          	addi	a2,a2,702 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0204aca:	12b00593          	li	a1,299
ffffffffc0204ace:	00003517          	auipc	a0,0x3
ffffffffc0204ad2:	72250513          	addi	a0,a0,1826 # ffffffffc02081f0 <default_pmm_manager+0xb98>
ffffffffc0204ad6:	9affb0ef          	jal	ra,ffffffffc0200484 <__panic>
        assert(vma1 != NULL);
ffffffffc0204ada:	00004697          	auipc	a3,0x4
ffffffffc0204ade:	8ae68693          	addi	a3,a3,-1874 # ffffffffc0208388 <default_pmm_manager+0xd30>
ffffffffc0204ae2:	00002617          	auipc	a2,0x2
ffffffffc0204ae6:	29e60613          	addi	a2,a2,670 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0204aea:	12900593          	li	a1,297
ffffffffc0204aee:	00003517          	auipc	a0,0x3
ffffffffc0204af2:	70250513          	addi	a0,a0,1794 # ffffffffc02081f0 <default_pmm_manager+0xb98>
ffffffffc0204af6:	98ffb0ef          	jal	ra,ffffffffc0200484 <__panic>
        assert(vma5 == NULL);
ffffffffc0204afa:	00004697          	auipc	a3,0x4
ffffffffc0204afe:	8ce68693          	addi	a3,a3,-1842 # ffffffffc02083c8 <default_pmm_manager+0xd70>
ffffffffc0204b02:	00002617          	auipc	a2,0x2
ffffffffc0204b06:	27e60613          	addi	a2,a2,638 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0204b0a:	13100593          	li	a1,305
ffffffffc0204b0e:	00003517          	auipc	a0,0x3
ffffffffc0204b12:	6e250513          	addi	a0,a0,1762 # ffffffffc02081f0 <default_pmm_manager+0xb98>
ffffffffc0204b16:	96ffb0ef          	jal	ra,ffffffffc0200484 <__panic>
        assert(vma4 == NULL);
ffffffffc0204b1a:	00004697          	auipc	a3,0x4
ffffffffc0204b1e:	89e68693          	addi	a3,a3,-1890 # ffffffffc02083b8 <default_pmm_manager+0xd60>
ffffffffc0204b22:	00002617          	auipc	a2,0x2
ffffffffc0204b26:	25e60613          	addi	a2,a2,606 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0204b2a:	12f00593          	li	a1,303
ffffffffc0204b2e:	00003517          	auipc	a0,0x3
ffffffffc0204b32:	6c250513          	addi	a0,a0,1730 # ffffffffc02081f0 <default_pmm_manager+0xb98>
ffffffffc0204b36:	94ffb0ef          	jal	ra,ffffffffc0200484 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0204b3a:	00002617          	auipc	a2,0x2
ffffffffc0204b3e:	6ee60613          	addi	a2,a2,1774 # ffffffffc0207228 <commands+0x968>
ffffffffc0204b42:	06300593          	li	a1,99
ffffffffc0204b46:	00002517          	auipc	a0,0x2
ffffffffc0204b4a:	70250513          	addi	a0,a0,1794 # ffffffffc0207248 <commands+0x988>
ffffffffc0204b4e:	937fb0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(mm != NULL);
ffffffffc0204b52:	00003697          	auipc	a3,0x3
ffffffffc0204b56:	1d668693          	addi	a3,a3,470 # ffffffffc0207d28 <default_pmm_manager+0x6d0>
ffffffffc0204b5a:	00002617          	auipc	a2,0x2
ffffffffc0204b5e:	22660613          	addi	a2,a2,550 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0204b62:	10d00593          	li	a1,269
ffffffffc0204b66:	00003517          	auipc	a0,0x3
ffffffffc0204b6a:	68a50513          	addi	a0,a0,1674 # ffffffffc02081f0 <default_pmm_manager+0xb98>
ffffffffc0204b6e:	917fb0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0204b72:	00004697          	auipc	a3,0x4
ffffffffc0204b76:	96e68693          	addi	a3,a3,-1682 # ffffffffc02084e0 <default_pmm_manager+0xe88>
ffffffffc0204b7a:	00002617          	auipc	a2,0x2
ffffffffc0204b7e:	20660613          	addi	a2,a2,518 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0204b82:	17100593          	li	a1,369
ffffffffc0204b86:	00003517          	auipc	a0,0x3
ffffffffc0204b8a:	66a50513          	addi	a0,a0,1642 # ffffffffc02081f0 <default_pmm_manager+0xb98>
ffffffffc0204b8e:	8f7fb0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pgdir[0] == 0);
ffffffffc0204b92:	00003697          	auipc	a3,0x3
ffffffffc0204b96:	1be68693          	addi	a3,a3,446 # ffffffffc0207d50 <default_pmm_manager+0x6f8>
ffffffffc0204b9a:	00002617          	auipc	a2,0x2
ffffffffc0204b9e:	1e660613          	addi	a2,a2,486 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0204ba2:	15000593          	li	a1,336
ffffffffc0204ba6:	00003517          	auipc	a0,0x3
ffffffffc0204baa:	64a50513          	addi	a0,a0,1610 # ffffffffc02081f0 <default_pmm_manager+0xb98>
ffffffffc0204bae:	8d7fb0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc0204bb2:	00004697          	auipc	a3,0x4
ffffffffc0204bb6:	8fe68693          	addi	a3,a3,-1794 # ffffffffc02084b0 <default_pmm_manager+0xe58>
ffffffffc0204bba:	00002617          	auipc	a2,0x2
ffffffffc0204bbe:	1c660613          	addi	a2,a2,454 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0204bc2:	15800593          	li	a1,344
ffffffffc0204bc6:	00003517          	auipc	a0,0x3
ffffffffc0204bca:	62a50513          	addi	a0,a0,1578 # ffffffffc02081f0 <default_pmm_manager+0xb98>
ffffffffc0204bce:	8b7fb0ef          	jal	ra,ffffffffc0200484 <__panic>
    return KADDR(page2pa(page));
ffffffffc0204bd2:	00002617          	auipc	a2,0x2
ffffffffc0204bd6:	56660613          	addi	a2,a2,1382 # ffffffffc0207138 <commands+0x878>
ffffffffc0204bda:	06a00593          	li	a1,106
ffffffffc0204bde:	00002517          	auipc	a0,0x2
ffffffffc0204be2:	66a50513          	addi	a0,a0,1642 # ffffffffc0207248 <commands+0x988>
ffffffffc0204be6:	89ffb0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(sum == 0);
ffffffffc0204bea:	00004697          	auipc	a3,0x4
ffffffffc0204bee:	8e668693          	addi	a3,a3,-1818 # ffffffffc02084d0 <default_pmm_manager+0xe78>
ffffffffc0204bf2:	00002617          	auipc	a2,0x2
ffffffffc0204bf6:	18e60613          	addi	a2,a2,398 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0204bfa:	16400593          	li	a1,356
ffffffffc0204bfe:	00003517          	auipc	a0,0x3
ffffffffc0204c02:	5f250513          	addi	a0,a0,1522 # ffffffffc02081f0 <default_pmm_manager+0xb98>
ffffffffc0204c06:	87ffb0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(check_mm_struct != NULL);
ffffffffc0204c0a:	00004697          	auipc	a3,0x4
ffffffffc0204c0e:	88e68693          	addi	a3,a3,-1906 # ffffffffc0208498 <default_pmm_manager+0xe40>
ffffffffc0204c12:	00002617          	auipc	a2,0x2
ffffffffc0204c16:	16e60613          	addi	a2,a2,366 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0204c1a:	14c00593          	li	a1,332
ffffffffc0204c1e:	00003517          	auipc	a0,0x3
ffffffffc0204c22:	5d250513          	addi	a0,a0,1490 # ffffffffc02081f0 <default_pmm_manager+0xb98>
ffffffffc0204c26:	85ffb0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0204c2a <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0204c2a:	7139                	addi	sp,sp,-64
ffffffffc0204c2c:	f04a                	sd	s2,32(sp)
ffffffffc0204c2e:	892e                	mv	s2,a1
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0204c30:	85b2                	mv	a1,a2
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0204c32:	f822                	sd	s0,48(sp)
ffffffffc0204c34:	f426                	sd	s1,40(sp)
ffffffffc0204c36:	fc06                	sd	ra,56(sp)
ffffffffc0204c38:	ec4e                	sd	s3,24(sp)
ffffffffc0204c3a:	8432                	mv	s0,a2
ffffffffc0204c3c:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0204c3e:	821ff0ef          	jal	ra,ffffffffc020445e <find_vma>

    pgfault_num++;
ffffffffc0204c42:	000a8797          	auipc	a5,0xa8
ffffffffc0204c46:	84a78793          	addi	a5,a5,-1974 # ffffffffc02ac48c <pgfault_num>
ffffffffc0204c4a:	439c                	lw	a5,0(a5)
ffffffffc0204c4c:	2785                	addiw	a5,a5,1
ffffffffc0204c4e:	000a8717          	auipc	a4,0xa8
ffffffffc0204c52:	82f72f23          	sw	a5,-1986(a4) # ffffffffc02ac48c <pgfault_num>
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc0204c56:	c579                	beqz	a0,ffffffffc0204d24 <do_pgfault+0xfa>
ffffffffc0204c58:	651c                	ld	a5,8(a0)
ffffffffc0204c5a:	0cf46563          	bltu	s0,a5,ffffffffc0204d24 <do_pgfault+0xfa>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0204c5e:	4d1c                	lw	a5,24(a0)
    uint32_t perm = PTE_U;
ffffffffc0204c60:	49c1                	li	s3,16
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0204c62:	8b89                	andi	a5,a5,2
ffffffffc0204c64:	ebb9                	bnez	a5,ffffffffc0204cba <do_pgfault+0x90>
        perm |= READ_WRITE;
    }
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0204c66:	767d                	lui	a2,0xfffff
    ret = -E_NO_MEM;

    pte_t *ptep=NULL;
    
    // 判断页表项权限，如果有效但是不可写，跳转到COW
    if ((ptep = get_pte(mm->pgdir, addr, 0)) != NULL) {
ffffffffc0204c68:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0204c6a:	8c71                	and	s0,s0,a2
    if ((ptep = get_pte(mm->pgdir, addr, 0)) != NULL) {
ffffffffc0204c6c:	85a2                	mv	a1,s0
ffffffffc0204c6e:	4601                	li	a2,0
ffffffffc0204c70:	843fd0ef          	jal	ra,ffffffffc02024b2 <get_pte>
ffffffffc0204c74:	c501                	beqz	a0,ffffffffc0204c7c <do_pgfault+0x52>
        if((*ptep & PTE_V) & ~(*ptep & PTE_W)) {
ffffffffc0204c76:	611c                	ld	a5,0(a0)
ffffffffc0204c78:	8b85                	andi	a5,a5,1
ffffffffc0204c7a:	e7d9                	bnez	a5,ffffffffc0204d08 <do_pgfault+0xde>
    }


    // try to find a pte, if pte's PT(Page Table) isn't existed, then create a PT.
    // (notice the 3th parameter '1')
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc0204c7c:	6c88                	ld	a0,24(s1)
ffffffffc0204c7e:	4605                	li	a2,1
ffffffffc0204c80:	85a2                	mv	a1,s0
ffffffffc0204c82:	831fd0ef          	jal	ra,ffffffffc02024b2 <get_pte>
ffffffffc0204c86:	c161                	beqz	a0,ffffffffc0204d46 <do_pgfault+0x11c>
        cprintf("get_pte in do_pgfault failed\n");
        goto failed;
    }
    
    if (*ptep == 0) { // if the phy addr isn't exist, then alloc a page & map the phy addr with logical addr
ffffffffc0204c88:	610c                	ld	a1,0(a0)
ffffffffc0204c8a:	c1a5                	beqz	a1,ffffffffc0204cea <do_pgfault+0xc0>
        *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
        *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */
        if (swap_init_ok) {
ffffffffc0204c8c:	000a7797          	auipc	a5,0xa7
ffffffffc0204c90:	7fc78793          	addi	a5,a5,2044 # ffffffffc02ac488 <swap_init_ok>
ffffffffc0204c94:	439c                	lw	a5,0(a5)
ffffffffc0204c96:	2781                	sext.w	a5,a5
ffffffffc0204c98:	cfd9                	beqz	a5,ffffffffc0204d36 <do_pgfault+0x10c>
            //addr AND page, setup the
            //map of phy addr <--->
            //logical addr
            //(3) make the page swappable.
            // cprintf("do_pgfault called!!!\n");
            if((ret = swap_in(mm,addr,&page)) != 0) {
ffffffffc0204c9a:	0030                	addi	a2,sp,8
ffffffffc0204c9c:	85a2                	mv	a1,s0
ffffffffc0204c9e:	8526                	mv	a0,s1
            struct Page *page = NULL;
ffffffffc0204ca0:	e402                	sd	zero,8(sp)
            if((ret = swap_in(mm,addr,&page)) != 0) {
ffffffffc0204ca2:	abcff0ef          	jal	ra,ffffffffc0203f5e <swap_in>
ffffffffc0204ca6:	892a                	mv	s2,a0
ffffffffc0204ca8:	c919                	beqz	a0,ffffffffc0204cbe <do_pgfault+0x94>
        }
   }
   ret = 0;
failed:
    return ret;
}
ffffffffc0204caa:	70e2                	ld	ra,56(sp)
ffffffffc0204cac:	7442                	ld	s0,48(sp)
ffffffffc0204cae:	854a                	mv	a0,s2
ffffffffc0204cb0:	74a2                	ld	s1,40(sp)
ffffffffc0204cb2:	7902                	ld	s2,32(sp)
ffffffffc0204cb4:	69e2                	ld	s3,24(sp)
ffffffffc0204cb6:	6121                	addi	sp,sp,64
ffffffffc0204cb8:	8082                	ret
        perm |= READ_WRITE;
ffffffffc0204cba:	49dd                	li	s3,23
ffffffffc0204cbc:	b76d                	j	ffffffffc0204c66 <do_pgfault+0x3c>
            page_insert(mm->pgdir,page,addr,perm);
ffffffffc0204cbe:	65a2                	ld	a1,8(sp)
ffffffffc0204cc0:	6c88                	ld	a0,24(s1)
ffffffffc0204cc2:	86ce                	mv	a3,s3
ffffffffc0204cc4:	8622                	mv	a2,s0
ffffffffc0204cc6:	e03fd0ef          	jal	ra,ffffffffc0202ac8 <page_insert>
            swap_map_swappable(mm,addr,page,1);
ffffffffc0204cca:	6622                	ld	a2,8(sp)
ffffffffc0204ccc:	85a2                	mv	a1,s0
ffffffffc0204cce:	8526                	mv	a0,s1
ffffffffc0204cd0:	4685                	li	a3,1
ffffffffc0204cd2:	968ff0ef          	jal	ra,ffffffffc0203e3a <swap_map_swappable>
            page->pra_vaddr = addr;
ffffffffc0204cd6:	67a2                	ld	a5,8(sp)
}
ffffffffc0204cd8:	70e2                	ld	ra,56(sp)
ffffffffc0204cda:	854a                	mv	a0,s2
            page->pra_vaddr = addr;
ffffffffc0204cdc:	ff80                	sd	s0,56(a5)
}
ffffffffc0204cde:	7442                	ld	s0,48(sp)
ffffffffc0204ce0:	74a2                	ld	s1,40(sp)
ffffffffc0204ce2:	7902                	ld	s2,32(sp)
ffffffffc0204ce4:	69e2                	ld	s3,24(sp)
ffffffffc0204ce6:	6121                	addi	sp,sp,64
ffffffffc0204ce8:	8082                	ret
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0204cea:	6c88                	ld	a0,24(s1)
ffffffffc0204cec:	864e                	mv	a2,s3
ffffffffc0204cee:	85a2                	mv	a1,s0
ffffffffc0204cf0:	927fe0ef          	jal	ra,ffffffffc0203616 <pgdir_alloc_page>
   ret = 0;
ffffffffc0204cf4:	4901                	li	s2,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0204cf6:	f955                	bnez	a0,ffffffffc0204caa <do_pgfault+0x80>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc0204cf8:	00003517          	auipc	a0,0x3
ffffffffc0204cfc:	55850513          	addi	a0,a0,1368 # ffffffffc0208250 <default_pmm_manager+0xbf8>
ffffffffc0204d00:	c8efb0ef          	jal	ra,ffffffffc020018e <cprintf>
    ret = -E_NO_MEM;
ffffffffc0204d04:	5971                	li	s2,-4
            goto failed;
ffffffffc0204d06:	b755                	j	ffffffffc0204caa <do_pgfault+0x80>
            return cow_pgfault(mm, error_code, addr);
ffffffffc0204d08:	8622                	mv	a2,s0
ffffffffc0204d0a:	85ca                	mv	a1,s2
ffffffffc0204d0c:	8526                	mv	a0,s1
ffffffffc0204d0e:	d06fc0ef          	jal	ra,ffffffffc0201214 <cow_pgfault>
}
ffffffffc0204d12:	70e2                	ld	ra,56(sp)
ffffffffc0204d14:	7442                	ld	s0,48(sp)
            return cow_pgfault(mm, error_code, addr);
ffffffffc0204d16:	892a                	mv	s2,a0
}
ffffffffc0204d18:	854a                	mv	a0,s2
ffffffffc0204d1a:	74a2                	ld	s1,40(sp)
ffffffffc0204d1c:	7902                	ld	s2,32(sp)
ffffffffc0204d1e:	69e2                	ld	s3,24(sp)
ffffffffc0204d20:	6121                	addi	sp,sp,64
ffffffffc0204d22:	8082                	ret
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc0204d24:	85a2                	mv	a1,s0
ffffffffc0204d26:	00003517          	auipc	a0,0x3
ffffffffc0204d2a:	4da50513          	addi	a0,a0,1242 # ffffffffc0208200 <default_pmm_manager+0xba8>
ffffffffc0204d2e:	c60fb0ef          	jal	ra,ffffffffc020018e <cprintf>
    int ret = -E_INVAL;
ffffffffc0204d32:	5975                	li	s2,-3
        goto failed;
ffffffffc0204d34:	bf9d                	j	ffffffffc0204caa <do_pgfault+0x80>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
ffffffffc0204d36:	00003517          	auipc	a0,0x3
ffffffffc0204d3a:	54250513          	addi	a0,a0,1346 # ffffffffc0208278 <default_pmm_manager+0xc20>
ffffffffc0204d3e:	c50fb0ef          	jal	ra,ffffffffc020018e <cprintf>
    ret = -E_NO_MEM;
ffffffffc0204d42:	5971                	li	s2,-4
            goto failed;
ffffffffc0204d44:	b79d                	j	ffffffffc0204caa <do_pgfault+0x80>
        cprintf("get_pte in do_pgfault failed\n");
ffffffffc0204d46:	00003517          	auipc	a0,0x3
ffffffffc0204d4a:	4ea50513          	addi	a0,a0,1258 # ffffffffc0208230 <default_pmm_manager+0xbd8>
ffffffffc0204d4e:	c40fb0ef          	jal	ra,ffffffffc020018e <cprintf>
    ret = -E_NO_MEM;
ffffffffc0204d52:	5971                	li	s2,-4
        goto failed;
ffffffffc0204d54:	bf99                	j	ffffffffc0204caa <do_pgfault+0x80>

ffffffffc0204d56 <user_mem_check>:

bool
user_mem_check(struct mm_struct *mm, uintptr_t addr, size_t len, bool write) {
ffffffffc0204d56:	7179                	addi	sp,sp,-48
ffffffffc0204d58:	f022                	sd	s0,32(sp)
ffffffffc0204d5a:	f406                	sd	ra,40(sp)
ffffffffc0204d5c:	ec26                	sd	s1,24(sp)
ffffffffc0204d5e:	e84a                	sd	s2,16(sp)
ffffffffc0204d60:	e44e                	sd	s3,8(sp)
ffffffffc0204d62:	e052                	sd	s4,0(sp)
ffffffffc0204d64:	842e                	mv	s0,a1
    if (mm != NULL) {
ffffffffc0204d66:	c135                	beqz	a0,ffffffffc0204dca <user_mem_check+0x74>
        if (!USER_ACCESS(addr, addr + len)) {
ffffffffc0204d68:	002007b7          	lui	a5,0x200
ffffffffc0204d6c:	04f5e663          	bltu	a1,a5,ffffffffc0204db8 <user_mem_check+0x62>
ffffffffc0204d70:	00c584b3          	add	s1,a1,a2
ffffffffc0204d74:	0495f263          	bleu	s1,a1,ffffffffc0204db8 <user_mem_check+0x62>
ffffffffc0204d78:	4785                	li	a5,1
ffffffffc0204d7a:	07fe                	slli	a5,a5,0x1f
ffffffffc0204d7c:	0297ee63          	bltu	a5,s1,ffffffffc0204db8 <user_mem_check+0x62>
ffffffffc0204d80:	892a                	mv	s2,a0
ffffffffc0204d82:	89b6                	mv	s3,a3
            }
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
                return 0;
            }
            if (write && (vma->vm_flags & VM_STACK)) {
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc0204d84:	6a05                	lui	s4,0x1
ffffffffc0204d86:	a821                	j	ffffffffc0204d9e <user_mem_check+0x48>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc0204d88:	0027f693          	andi	a3,a5,2
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc0204d8c:	9752                	add	a4,a4,s4
            if (write && (vma->vm_flags & VM_STACK)) {
ffffffffc0204d8e:	8ba1                	andi	a5,a5,8
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc0204d90:	c685                	beqz	a3,ffffffffc0204db8 <user_mem_check+0x62>
            if (write && (vma->vm_flags & VM_STACK)) {
ffffffffc0204d92:	c399                	beqz	a5,ffffffffc0204d98 <user_mem_check+0x42>
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc0204d94:	02e46263          	bltu	s0,a4,ffffffffc0204db8 <user_mem_check+0x62>
                    return 0;
                }
            }
            start = vma->vm_end;
ffffffffc0204d98:	6900                	ld	s0,16(a0)
        while (start < end) {
ffffffffc0204d9a:	04947663          	bleu	s1,s0,ffffffffc0204de6 <user_mem_check+0x90>
            if ((vma = find_vma(mm, start)) == NULL || start < vma->vm_start) {
ffffffffc0204d9e:	85a2                	mv	a1,s0
ffffffffc0204da0:	854a                	mv	a0,s2
ffffffffc0204da2:	ebcff0ef          	jal	ra,ffffffffc020445e <find_vma>
ffffffffc0204da6:	c909                	beqz	a0,ffffffffc0204db8 <user_mem_check+0x62>
ffffffffc0204da8:	6518                	ld	a4,8(a0)
ffffffffc0204daa:	00e46763          	bltu	s0,a4,ffffffffc0204db8 <user_mem_check+0x62>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc0204dae:	4d1c                	lw	a5,24(a0)
ffffffffc0204db0:	fc099ce3          	bnez	s3,ffffffffc0204d88 <user_mem_check+0x32>
ffffffffc0204db4:	8b85                	andi	a5,a5,1
ffffffffc0204db6:	f3ed                	bnez	a5,ffffffffc0204d98 <user_mem_check+0x42>
            return 0;
ffffffffc0204db8:	4501                	li	a0,0
        }
        return 1;
    }
    return KERN_ACCESS(addr, addr + len);
}
ffffffffc0204dba:	70a2                	ld	ra,40(sp)
ffffffffc0204dbc:	7402                	ld	s0,32(sp)
ffffffffc0204dbe:	64e2                	ld	s1,24(sp)
ffffffffc0204dc0:	6942                	ld	s2,16(sp)
ffffffffc0204dc2:	69a2                	ld	s3,8(sp)
ffffffffc0204dc4:	6a02                	ld	s4,0(sp)
ffffffffc0204dc6:	6145                	addi	sp,sp,48
ffffffffc0204dc8:	8082                	ret
    return KERN_ACCESS(addr, addr + len);
ffffffffc0204dca:	c02007b7          	lui	a5,0xc0200
ffffffffc0204dce:	4501                	li	a0,0
ffffffffc0204dd0:	fef5e5e3          	bltu	a1,a5,ffffffffc0204dba <user_mem_check+0x64>
ffffffffc0204dd4:	962e                	add	a2,a2,a1
ffffffffc0204dd6:	fec5f2e3          	bleu	a2,a1,ffffffffc0204dba <user_mem_check+0x64>
ffffffffc0204dda:	c8000537          	lui	a0,0xc8000
ffffffffc0204dde:	0505                	addi	a0,a0,1
ffffffffc0204de0:	00a63533          	sltu	a0,a2,a0
ffffffffc0204de4:	bfd9                	j	ffffffffc0204dba <user_mem_check+0x64>
        return 1;
ffffffffc0204de6:	4505                	li	a0,1
ffffffffc0204de8:	bfc9                	j	ffffffffc0204dba <user_mem_check+0x64>

ffffffffc0204dea <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc0204dea:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0204dec:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc0204dee:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0204df0:	80ffb0ef          	jal	ra,ffffffffc02005fe <ide_device_valid>
ffffffffc0204df4:	cd01                	beqz	a0,ffffffffc0204e0c <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0204df6:	4505                	li	a0,1
ffffffffc0204df8:	80dfb0ef          	jal	ra,ffffffffc0200604 <ide_device_size>
}
ffffffffc0204dfc:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0204dfe:	810d                	srli	a0,a0,0x3
ffffffffc0204e00:	000a7797          	auipc	a5,0xa7
ffffffffc0204e04:	76a7bc23          	sd	a0,1912(a5) # ffffffffc02ac578 <max_swap_offset>
}
ffffffffc0204e08:	0141                	addi	sp,sp,16
ffffffffc0204e0a:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc0204e0c:	00003617          	auipc	a2,0x3
ffffffffc0204e10:	73460613          	addi	a2,a2,1844 # ffffffffc0208540 <default_pmm_manager+0xee8>
ffffffffc0204e14:	45b5                	li	a1,13
ffffffffc0204e16:	00003517          	auipc	a0,0x3
ffffffffc0204e1a:	74a50513          	addi	a0,a0,1866 # ffffffffc0208560 <default_pmm_manager+0xf08>
ffffffffc0204e1e:	e66fb0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0204e22 <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
ffffffffc0204e22:	1141                	addi	sp,sp,-16
ffffffffc0204e24:	e406                	sd	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204e26:	00855793          	srli	a5,a0,0x8
ffffffffc0204e2a:	cfb9                	beqz	a5,ffffffffc0204e88 <swapfs_read+0x66>
ffffffffc0204e2c:	000a7717          	auipc	a4,0xa7
ffffffffc0204e30:	74c70713          	addi	a4,a4,1868 # ffffffffc02ac578 <max_swap_offset>
ffffffffc0204e34:	6318                	ld	a4,0(a4)
ffffffffc0204e36:	04e7f963          	bleu	a4,a5,ffffffffc0204e88 <swapfs_read+0x66>
    return page - pages + nbase;
ffffffffc0204e3a:	000a7717          	auipc	a4,0xa7
ffffffffc0204e3e:	6ae70713          	addi	a4,a4,1710 # ffffffffc02ac4e8 <pages>
ffffffffc0204e42:	6310                	ld	a2,0(a4)
ffffffffc0204e44:	00004717          	auipc	a4,0x4
ffffffffc0204e48:	04c70713          	addi	a4,a4,76 # ffffffffc0208e90 <nbase>
    return KADDR(page2pa(page));
ffffffffc0204e4c:	000a7697          	auipc	a3,0xa7
ffffffffc0204e50:	62c68693          	addi	a3,a3,1580 # ffffffffc02ac478 <npage>
    return page - pages + nbase;
ffffffffc0204e54:	40c58633          	sub	a2,a1,a2
ffffffffc0204e58:	630c                	ld	a1,0(a4)
ffffffffc0204e5a:	8619                	srai	a2,a2,0x6
    return KADDR(page2pa(page));
ffffffffc0204e5c:	577d                	li	a4,-1
ffffffffc0204e5e:	6294                	ld	a3,0(a3)
    return page - pages + nbase;
ffffffffc0204e60:	962e                	add	a2,a2,a1
    return KADDR(page2pa(page));
ffffffffc0204e62:	8331                	srli	a4,a4,0xc
ffffffffc0204e64:	8f71                	and	a4,a4,a2
ffffffffc0204e66:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204e6a:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc0204e6c:	02d77a63          	bleu	a3,a4,ffffffffc0204ea0 <swapfs_read+0x7e>
ffffffffc0204e70:	000a7797          	auipc	a5,0xa7
ffffffffc0204e74:	66878793          	addi	a5,a5,1640 # ffffffffc02ac4d8 <va_pa_offset>
ffffffffc0204e78:	639c                	ld	a5,0(a5)
}
ffffffffc0204e7a:	60a2                	ld	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204e7c:	46a1                	li	a3,8
ffffffffc0204e7e:	963e                	add	a2,a2,a5
ffffffffc0204e80:	4505                	li	a0,1
}
ffffffffc0204e82:	0141                	addi	sp,sp,16
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204e84:	f86fb06f          	j	ffffffffc020060a <ide_read_secs>
ffffffffc0204e88:	86aa                	mv	a3,a0
ffffffffc0204e8a:	00003617          	auipc	a2,0x3
ffffffffc0204e8e:	6ee60613          	addi	a2,a2,1774 # ffffffffc0208578 <default_pmm_manager+0xf20>
ffffffffc0204e92:	45d1                	li	a1,20
ffffffffc0204e94:	00003517          	auipc	a0,0x3
ffffffffc0204e98:	6cc50513          	addi	a0,a0,1740 # ffffffffc0208560 <default_pmm_manager+0xf08>
ffffffffc0204e9c:	de8fb0ef          	jal	ra,ffffffffc0200484 <__panic>
ffffffffc0204ea0:	86b2                	mv	a3,a2
ffffffffc0204ea2:	06a00593          	li	a1,106
ffffffffc0204ea6:	00002617          	auipc	a2,0x2
ffffffffc0204eaa:	29260613          	addi	a2,a2,658 # ffffffffc0207138 <commands+0x878>
ffffffffc0204eae:	00002517          	auipc	a0,0x2
ffffffffc0204eb2:	39a50513          	addi	a0,a0,922 # ffffffffc0207248 <commands+0x988>
ffffffffc0204eb6:	dcefb0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0204eba <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc0204eba:	1141                	addi	sp,sp,-16
ffffffffc0204ebc:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204ebe:	00855793          	srli	a5,a0,0x8
ffffffffc0204ec2:	cfb9                	beqz	a5,ffffffffc0204f20 <swapfs_write+0x66>
ffffffffc0204ec4:	000a7717          	auipc	a4,0xa7
ffffffffc0204ec8:	6b470713          	addi	a4,a4,1716 # ffffffffc02ac578 <max_swap_offset>
ffffffffc0204ecc:	6318                	ld	a4,0(a4)
ffffffffc0204ece:	04e7f963          	bleu	a4,a5,ffffffffc0204f20 <swapfs_write+0x66>
    return page - pages + nbase;
ffffffffc0204ed2:	000a7717          	auipc	a4,0xa7
ffffffffc0204ed6:	61670713          	addi	a4,a4,1558 # ffffffffc02ac4e8 <pages>
ffffffffc0204eda:	6310                	ld	a2,0(a4)
ffffffffc0204edc:	00004717          	auipc	a4,0x4
ffffffffc0204ee0:	fb470713          	addi	a4,a4,-76 # ffffffffc0208e90 <nbase>
    return KADDR(page2pa(page));
ffffffffc0204ee4:	000a7697          	auipc	a3,0xa7
ffffffffc0204ee8:	59468693          	addi	a3,a3,1428 # ffffffffc02ac478 <npage>
    return page - pages + nbase;
ffffffffc0204eec:	40c58633          	sub	a2,a1,a2
ffffffffc0204ef0:	630c                	ld	a1,0(a4)
ffffffffc0204ef2:	8619                	srai	a2,a2,0x6
    return KADDR(page2pa(page));
ffffffffc0204ef4:	577d                	li	a4,-1
ffffffffc0204ef6:	6294                	ld	a3,0(a3)
    return page - pages + nbase;
ffffffffc0204ef8:	962e                	add	a2,a2,a1
    return KADDR(page2pa(page));
ffffffffc0204efa:	8331                	srli	a4,a4,0xc
ffffffffc0204efc:	8f71                	and	a4,a4,a2
ffffffffc0204efe:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204f02:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc0204f04:	02d77a63          	bleu	a3,a4,ffffffffc0204f38 <swapfs_write+0x7e>
ffffffffc0204f08:	000a7797          	auipc	a5,0xa7
ffffffffc0204f0c:	5d078793          	addi	a5,a5,1488 # ffffffffc02ac4d8 <va_pa_offset>
ffffffffc0204f10:	639c                	ld	a5,0(a5)
}
ffffffffc0204f12:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204f14:	46a1                	li	a3,8
ffffffffc0204f16:	963e                	add	a2,a2,a5
ffffffffc0204f18:	4505                	li	a0,1
}
ffffffffc0204f1a:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204f1c:	f12fb06f          	j	ffffffffc020062e <ide_write_secs>
ffffffffc0204f20:	86aa                	mv	a3,a0
ffffffffc0204f22:	00003617          	auipc	a2,0x3
ffffffffc0204f26:	65660613          	addi	a2,a2,1622 # ffffffffc0208578 <default_pmm_manager+0xf20>
ffffffffc0204f2a:	45e5                	li	a1,25
ffffffffc0204f2c:	00003517          	auipc	a0,0x3
ffffffffc0204f30:	63450513          	addi	a0,a0,1588 # ffffffffc0208560 <default_pmm_manager+0xf08>
ffffffffc0204f34:	d50fb0ef          	jal	ra,ffffffffc0200484 <__panic>
ffffffffc0204f38:	86b2                	mv	a3,a2
ffffffffc0204f3a:	06a00593          	li	a1,106
ffffffffc0204f3e:	00002617          	auipc	a2,0x2
ffffffffc0204f42:	1fa60613          	addi	a2,a2,506 # ffffffffc0207138 <commands+0x878>
ffffffffc0204f46:	00002517          	auipc	a0,0x2
ffffffffc0204f4a:	30250513          	addi	a0,a0,770 # ffffffffc0207248 <commands+0x988>
ffffffffc0204f4e:	d36fb0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0204f52 <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)
	move a0, s1
ffffffffc0204f52:	8526                	mv	a0,s1
	jalr s0
ffffffffc0204f54:	9402                	jalr	s0

	jal do_exit
ffffffffc0204f56:	5e4000ef          	jal	ra,ffffffffc020553a <do_exit>

ffffffffc0204f5a <alloc_proc>:
void forkrets(struct trapframe *tf);
void switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void) {
ffffffffc0204f5a:	1141                	addi	sp,sp,-16
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0204f5c:	10800513          	li	a0,264
alloc_proc(void) {
ffffffffc0204f60:	e022                	sd	s0,0(sp)
ffffffffc0204f62:	e406                	sd	ra,8(sp)
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0204f64:	a44fd0ef          	jal	ra,ffffffffc02021a8 <kmalloc>
ffffffffc0204f68:	842a                	mv	s0,a0
    if (proc != NULL) {
ffffffffc0204f6a:	cd29                	beqz	a0,ffffffffc0204fc4 <alloc_proc+0x6a>
     /*
     * below fields(add in LAB5) in proc_struct need to be initialized  
     *       uint32_t wait_state;                        // waiting state
     *       struct proc_struct *cptr, *yptr, *optr;     // relations between processes
     */
        proc->state = PROC_UNINIT;
ffffffffc0204f6c:	57fd                	li	a5,-1
ffffffffc0204f6e:	1782                	slli	a5,a5,0x20
ffffffffc0204f70:	e11c                	sd	a5,0(a0)
        proc->runs = 0;
        proc->kstack = 0;
        proc->need_resched = 0;
        proc->parent = NULL;
        proc->mm = NULL;
        memset(&(proc->context), 0, sizeof(struct context));
ffffffffc0204f72:	07000613          	li	a2,112
ffffffffc0204f76:	4581                	li	a1,0
        proc->runs = 0;
ffffffffc0204f78:	00052423          	sw	zero,8(a0)
        proc->kstack = 0;
ffffffffc0204f7c:	00053823          	sd	zero,16(a0)
        proc->need_resched = 0;
ffffffffc0204f80:	00053c23          	sd	zero,24(a0)
        proc->parent = NULL;
ffffffffc0204f84:	02053023          	sd	zero,32(a0)
        proc->mm = NULL;
ffffffffc0204f88:	02053423          	sd	zero,40(a0)
        memset(&(proc->context), 0, sizeof(struct context));
ffffffffc0204f8c:	03050513          	addi	a0,a0,48
ffffffffc0204f90:	7d2010ef          	jal	ra,ffffffffc0206762 <memset>
        proc->tf = NULL;
        proc->cr3 = boot_cr3;
ffffffffc0204f94:	000a7797          	auipc	a5,0xa7
ffffffffc0204f98:	54c78793          	addi	a5,a5,1356 # ffffffffc02ac4e0 <boot_cr3>
ffffffffc0204f9c:	639c                	ld	a5,0(a5)
        proc->tf = NULL;
ffffffffc0204f9e:	0a043023          	sd	zero,160(s0)
        proc->flags = 0;
ffffffffc0204fa2:	0a042823          	sw	zero,176(s0)
        proc->cr3 = boot_cr3;
ffffffffc0204fa6:	f45c                	sd	a5,168(s0)
        memset(proc->name, 0, PROC_NAME_LEN);
ffffffffc0204fa8:	463d                	li	a2,15
ffffffffc0204faa:	4581                	li	a1,0
ffffffffc0204fac:	0b440513          	addi	a0,s0,180
ffffffffc0204fb0:	7b2010ef          	jal	ra,ffffffffc0206762 <memset>
        proc->wait_state = 0;
ffffffffc0204fb4:	0e042623          	sw	zero,236(s0)
        proc->cptr = NULL;
ffffffffc0204fb8:	0e043823          	sd	zero,240(s0)
        proc->optr = NULL;
ffffffffc0204fbc:	10043023          	sd	zero,256(s0)
        proc->yptr = NULL;
ffffffffc0204fc0:	0e043c23          	sd	zero,248(s0)
    }
    return proc;
}
ffffffffc0204fc4:	8522                	mv	a0,s0
ffffffffc0204fc6:	60a2                	ld	ra,8(sp)
ffffffffc0204fc8:	6402                	ld	s0,0(sp)
ffffffffc0204fca:	0141                	addi	sp,sp,16
ffffffffc0204fcc:	8082                	ret

ffffffffc0204fce <forkret>:
// forkret -- the first kernel entry point of a new thread/process
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void) {
    forkrets(current->tf);
ffffffffc0204fce:	000a7797          	auipc	a5,0xa7
ffffffffc0204fd2:	4c278793          	addi	a5,a5,1218 # ffffffffc02ac490 <current>
ffffffffc0204fd6:	639c                	ld	a5,0(a5)
ffffffffc0204fd8:	73c8                	ld	a0,160(a5)
ffffffffc0204fda:	dd1fb06f          	j	ffffffffc0200daa <forkrets>

ffffffffc0204fde <user_main>:

// user_main - kernel thread used to exec a user program
static int
user_main(void *arg) {
#ifdef TEST
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204fde:	000a7797          	auipc	a5,0xa7
ffffffffc0204fe2:	4b278793          	addi	a5,a5,1202 # ffffffffc02ac490 <current>
ffffffffc0204fe6:	639c                	ld	a5,0(a5)
user_main(void *arg) {
ffffffffc0204fe8:	7139                	addi	sp,sp,-64
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204fea:	00004617          	auipc	a2,0x4
ffffffffc0204fee:	97660613          	addi	a2,a2,-1674 # ffffffffc0208960 <default_pmm_manager+0x1308>
ffffffffc0204ff2:	43cc                	lw	a1,4(a5)
ffffffffc0204ff4:	00004517          	auipc	a0,0x4
ffffffffc0204ff8:	97c50513          	addi	a0,a0,-1668 # ffffffffc0208970 <default_pmm_manager+0x1318>
user_main(void *arg) {
ffffffffc0204ffc:	fc06                	sd	ra,56(sp)
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204ffe:	990fb0ef          	jal	ra,ffffffffc020018e <cprintf>
ffffffffc0205002:	00004797          	auipc	a5,0x4
ffffffffc0205006:	95e78793          	addi	a5,a5,-1698 # ffffffffc0208960 <default_pmm_manager+0x1308>
ffffffffc020500a:	3fe05717          	auipc	a4,0x3fe05
ffffffffc020500e:	2c670713          	addi	a4,a4,710 # a2d0 <_binary_obj___user_forktest_out_size>
ffffffffc0205012:	e43a                	sd	a4,8(sp)
    int64_t ret=0, len = strlen(name);
ffffffffc0205014:	853e                	mv	a0,a5
ffffffffc0205016:	00043717          	auipc	a4,0x43
ffffffffc020501a:	02a70713          	addi	a4,a4,42 # ffffffffc0248040 <_binary_obj___user_forktest_out_start>
ffffffffc020501e:	f03a                	sd	a4,32(sp)
ffffffffc0205020:	f43e                	sd	a5,40(sp)
ffffffffc0205022:	e802                	sd	zero,16(sp)
ffffffffc0205024:	6a0010ef          	jal	ra,ffffffffc02066c4 <strlen>
ffffffffc0205028:	ec2a                	sd	a0,24(sp)
    asm volatile(
ffffffffc020502a:	4511                	li	a0,4
ffffffffc020502c:	55a2                	lw	a1,40(sp)
ffffffffc020502e:	4662                	lw	a2,24(sp)
ffffffffc0205030:	5682                	lw	a3,32(sp)
ffffffffc0205032:	4722                	lw	a4,8(sp)
ffffffffc0205034:	48a9                	li	a7,10
ffffffffc0205036:	9002                	ebreak
ffffffffc0205038:	c82a                	sw	a0,16(sp)
    cprintf("ret = %d\n", ret);
ffffffffc020503a:	65c2                	ld	a1,16(sp)
ffffffffc020503c:	00004517          	auipc	a0,0x4
ffffffffc0205040:	95c50513          	addi	a0,a0,-1700 # ffffffffc0208998 <default_pmm_manager+0x1340>
ffffffffc0205044:	94afb0ef          	jal	ra,ffffffffc020018e <cprintf>
#else
    KERNEL_EXECVE(exit);
#endif
    panic("user_main execve failed.\n");
ffffffffc0205048:	00004617          	auipc	a2,0x4
ffffffffc020504c:	96060613          	addi	a2,a2,-1696 # ffffffffc02089a8 <default_pmm_manager+0x1350>
ffffffffc0205050:	35500593          	li	a1,853
ffffffffc0205054:	00004517          	auipc	a0,0x4
ffffffffc0205058:	97450513          	addi	a0,a0,-1676 # ffffffffc02089c8 <default_pmm_manager+0x1370>
ffffffffc020505c:	c28fb0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0205060 <put_pgdir>:
    return pa2page(PADDR(kva));
ffffffffc0205060:	6d14                	ld	a3,24(a0)
put_pgdir(struct mm_struct *mm) {
ffffffffc0205062:	1141                	addi	sp,sp,-16
ffffffffc0205064:	e406                	sd	ra,8(sp)
ffffffffc0205066:	c02007b7          	lui	a5,0xc0200
ffffffffc020506a:	04f6e263          	bltu	a3,a5,ffffffffc02050ae <put_pgdir+0x4e>
ffffffffc020506e:	000a7797          	auipc	a5,0xa7
ffffffffc0205072:	46a78793          	addi	a5,a5,1130 # ffffffffc02ac4d8 <va_pa_offset>
ffffffffc0205076:	6388                	ld	a0,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0205078:	000a7797          	auipc	a5,0xa7
ffffffffc020507c:	40078793          	addi	a5,a5,1024 # ffffffffc02ac478 <npage>
ffffffffc0205080:	639c                	ld	a5,0(a5)
    return pa2page(PADDR(kva));
ffffffffc0205082:	8e89                	sub	a3,a3,a0
    if (PPN(pa) >= npage) {
ffffffffc0205084:	82b1                	srli	a3,a3,0xc
ffffffffc0205086:	04f6f063          	bleu	a5,a3,ffffffffc02050c6 <put_pgdir+0x66>
    return &pages[PPN(pa) - nbase];
ffffffffc020508a:	00004797          	auipc	a5,0x4
ffffffffc020508e:	e0678793          	addi	a5,a5,-506 # ffffffffc0208e90 <nbase>
ffffffffc0205092:	639c                	ld	a5,0(a5)
ffffffffc0205094:	000a7717          	auipc	a4,0xa7
ffffffffc0205098:	45470713          	addi	a4,a4,1108 # ffffffffc02ac4e8 <pages>
ffffffffc020509c:	6308                	ld	a0,0(a4)
}
ffffffffc020509e:	60a2                	ld	ra,8(sp)
ffffffffc02050a0:	8e9d                	sub	a3,a3,a5
ffffffffc02050a2:	069a                	slli	a3,a3,0x6
    free_page(kva2page(mm->pgdir));
ffffffffc02050a4:	4585                	li	a1,1
ffffffffc02050a6:	9536                	add	a0,a0,a3
}
ffffffffc02050a8:	0141                	addi	sp,sp,16
    free_page(kva2page(mm->pgdir));
ffffffffc02050aa:	b82fd06f          	j	ffffffffc020242c <free_pages>
    return pa2page(PADDR(kva));
ffffffffc02050ae:	00002617          	auipc	a2,0x2
ffffffffc02050b2:	0da60613          	addi	a2,a2,218 # ffffffffc0207188 <commands+0x8c8>
ffffffffc02050b6:	06f00593          	li	a1,111
ffffffffc02050ba:	00002517          	auipc	a0,0x2
ffffffffc02050be:	18e50513          	addi	a0,a0,398 # ffffffffc0207248 <commands+0x988>
ffffffffc02050c2:	bc2fb0ef          	jal	ra,ffffffffc0200484 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02050c6:	00002617          	auipc	a2,0x2
ffffffffc02050ca:	16260613          	addi	a2,a2,354 # ffffffffc0207228 <commands+0x968>
ffffffffc02050ce:	06300593          	li	a1,99
ffffffffc02050d2:	00002517          	auipc	a0,0x2
ffffffffc02050d6:	17650513          	addi	a0,a0,374 # ffffffffc0207248 <commands+0x988>
ffffffffc02050da:	baafb0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc02050de <set_proc_name>:
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc02050de:	1101                	addi	sp,sp,-32
ffffffffc02050e0:	e822                	sd	s0,16(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02050e2:	0b450413          	addi	s0,a0,180
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc02050e6:	e426                	sd	s1,8(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02050e8:	4641                	li	a2,16
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc02050ea:	84ae                	mv	s1,a1
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02050ec:	8522                	mv	a0,s0
ffffffffc02050ee:	4581                	li	a1,0
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc02050f0:	ec06                	sd	ra,24(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02050f2:	670010ef          	jal	ra,ffffffffc0206762 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc02050f6:	8522                	mv	a0,s0
}
ffffffffc02050f8:	6442                	ld	s0,16(sp)
ffffffffc02050fa:	60e2                	ld	ra,24(sp)
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc02050fc:	85a6                	mv	a1,s1
}
ffffffffc02050fe:	64a2                	ld	s1,8(sp)
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0205100:	463d                	li	a2,15
}
ffffffffc0205102:	6105                	addi	sp,sp,32
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0205104:	6700106f          	j	ffffffffc0206774 <memcpy>

ffffffffc0205108 <proc_run>:
proc_run(struct proc_struct *proc) {
ffffffffc0205108:	1101                	addi	sp,sp,-32
    if (proc != current) {
ffffffffc020510a:	000a7797          	auipc	a5,0xa7
ffffffffc020510e:	38678793          	addi	a5,a5,902 # ffffffffc02ac490 <current>
proc_run(struct proc_struct *proc) {
ffffffffc0205112:	e426                	sd	s1,8(sp)
    if (proc != current) {
ffffffffc0205114:	6384                	ld	s1,0(a5)
proc_run(struct proc_struct *proc) {
ffffffffc0205116:	ec06                	sd	ra,24(sp)
ffffffffc0205118:	e822                	sd	s0,16(sp)
ffffffffc020511a:	e04a                	sd	s2,0(sp)
    if (proc != current) {
ffffffffc020511c:	02a48b63          	beq	s1,a0,ffffffffc0205152 <proc_run+0x4a>
ffffffffc0205120:	842a                	mv	s0,a0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205122:	100027f3          	csrr	a5,sstatus
ffffffffc0205126:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0205128:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020512a:	e3a9                	bnez	a5,ffffffffc020516c <proc_run+0x64>

#define barrier() __asm__ __volatile__ ("fence" ::: "memory")

static inline void
lcr3(unsigned long cr3) {
    write_csr(satp, 0x8000000000000000 | (cr3 >> RISCV_PGSHIFT));
ffffffffc020512c:	745c                	ld	a5,168(s0)
            current = proc;
ffffffffc020512e:	000a7717          	auipc	a4,0xa7
ffffffffc0205132:	36873123          	sd	s0,866(a4) # ffffffffc02ac490 <current>
ffffffffc0205136:	577d                	li	a4,-1
ffffffffc0205138:	177e                	slli	a4,a4,0x3f
ffffffffc020513a:	83b1                	srli	a5,a5,0xc
ffffffffc020513c:	8fd9                	or	a5,a5,a4
ffffffffc020513e:	18079073          	csrw	satp,a5
            switch_to(&(prev->context), &(next->context));
ffffffffc0205142:	03040593          	addi	a1,s0,48
ffffffffc0205146:	03048513          	addi	a0,s1,48
ffffffffc020514a:	70f000ef          	jal	ra,ffffffffc0206058 <switch_to>
    if (flag) {
ffffffffc020514e:	00091863          	bnez	s2,ffffffffc020515e <proc_run+0x56>
}
ffffffffc0205152:	60e2                	ld	ra,24(sp)
ffffffffc0205154:	6442                	ld	s0,16(sp)
ffffffffc0205156:	64a2                	ld	s1,8(sp)
ffffffffc0205158:	6902                	ld	s2,0(sp)
ffffffffc020515a:	6105                	addi	sp,sp,32
ffffffffc020515c:	8082                	ret
ffffffffc020515e:	6442                	ld	s0,16(sp)
ffffffffc0205160:	60e2                	ld	ra,24(sp)
ffffffffc0205162:	64a2                	ld	s1,8(sp)
ffffffffc0205164:	6902                	ld	s2,0(sp)
ffffffffc0205166:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0205168:	cecfb06f          	j	ffffffffc0200654 <intr_enable>
        intr_disable();
ffffffffc020516c:	ceefb0ef          	jal	ra,ffffffffc020065a <intr_disable>
        return 1;
ffffffffc0205170:	4905                	li	s2,1
ffffffffc0205172:	bf6d                	j	ffffffffc020512c <proc_run+0x24>

ffffffffc0205174 <find_proc>:
    if (0 < pid && pid < MAX_PID) {
ffffffffc0205174:	0005071b          	sext.w	a4,a0
ffffffffc0205178:	6789                	lui	a5,0x2
ffffffffc020517a:	fff7069b          	addiw	a3,a4,-1
ffffffffc020517e:	17f9                	addi	a5,a5,-2
ffffffffc0205180:	04d7e063          	bltu	a5,a3,ffffffffc02051c0 <find_proc+0x4c>
find_proc(int pid) {
ffffffffc0205184:	1141                	addi	sp,sp,-16
ffffffffc0205186:	e022                	sd	s0,0(sp)
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0205188:	45a9                	li	a1,10
ffffffffc020518a:	842a                	mv	s0,a0
ffffffffc020518c:	853a                	mv	a0,a4
find_proc(int pid) {
ffffffffc020518e:	e406                	sd	ra,8(sp)
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0205190:	124010ef          	jal	ra,ffffffffc02062b4 <hash32>
ffffffffc0205194:	02051693          	slli	a3,a0,0x20
ffffffffc0205198:	82f1                	srli	a3,a3,0x1c
ffffffffc020519a:	000a3517          	auipc	a0,0xa3
ffffffffc020519e:	2be50513          	addi	a0,a0,702 # ffffffffc02a8458 <hash_list>
ffffffffc02051a2:	96aa                	add	a3,a3,a0
ffffffffc02051a4:	87b6                	mv	a5,a3
        while ((le = list_next(le)) != list) {
ffffffffc02051a6:	a029                	j	ffffffffc02051b0 <find_proc+0x3c>
            if (proc->pid == pid) {
ffffffffc02051a8:	f2c7a703          	lw	a4,-212(a5) # 1f2c <_binary_obj___user_faultread_out_size-0x7644>
ffffffffc02051ac:	00870c63          	beq	a4,s0,ffffffffc02051c4 <find_proc+0x50>
ffffffffc02051b0:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc02051b2:	fef69be3          	bne	a3,a5,ffffffffc02051a8 <find_proc+0x34>
}
ffffffffc02051b6:	60a2                	ld	ra,8(sp)
ffffffffc02051b8:	6402                	ld	s0,0(sp)
    return NULL;
ffffffffc02051ba:	4501                	li	a0,0
}
ffffffffc02051bc:	0141                	addi	sp,sp,16
ffffffffc02051be:	8082                	ret
    return NULL;
ffffffffc02051c0:	4501                	li	a0,0
}
ffffffffc02051c2:	8082                	ret
ffffffffc02051c4:	60a2                	ld	ra,8(sp)
ffffffffc02051c6:	6402                	ld	s0,0(sp)
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc02051c8:	f2878513          	addi	a0,a5,-216
}
ffffffffc02051cc:	0141                	addi	sp,sp,16
ffffffffc02051ce:	8082                	ret

ffffffffc02051d0 <do_fork>:
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc02051d0:	715d                	addi	sp,sp,-80
ffffffffc02051d2:	f44e                	sd	s3,40(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc02051d4:	000a7997          	auipc	s3,0xa7
ffffffffc02051d8:	2d498993          	addi	s3,s3,724 # ffffffffc02ac4a8 <nr_process>
ffffffffc02051dc:	0009a703          	lw	a4,0(s3)
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc02051e0:	e486                	sd	ra,72(sp)
ffffffffc02051e2:	e0a2                	sd	s0,64(sp)
ffffffffc02051e4:	fc26                	sd	s1,56(sp)
ffffffffc02051e6:	f84a                	sd	s2,48(sp)
ffffffffc02051e8:	f052                	sd	s4,32(sp)
ffffffffc02051ea:	ec56                	sd	s5,24(sp)
ffffffffc02051ec:	e85a                	sd	s6,16(sp)
ffffffffc02051ee:	e45e                	sd	s7,8(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc02051f0:	6785                	lui	a5,0x1
ffffffffc02051f2:	28f75663          	ble	a5,a4,ffffffffc020547e <do_fork+0x2ae>
ffffffffc02051f6:	892e                	mv	s2,a1
ffffffffc02051f8:	84b2                	mv	s1,a2
    if((proc = alloc_proc()) == NULL) {
ffffffffc02051fa:	d61ff0ef          	jal	ra,ffffffffc0204f5a <alloc_proc>
ffffffffc02051fe:	842a                	mv	s0,a0
ffffffffc0205200:	26050d63          	beqz	a0,ffffffffc020547a <do_fork+0x2aa>
    proc->parent = current;
ffffffffc0205204:	000a7797          	auipc	a5,0xa7
ffffffffc0205208:	28c78793          	addi	a5,a5,652 # ffffffffc02ac490 <current>
ffffffffc020520c:	639c                	ld	a5,0(a5)
    assert(current->wait_state == 0);
ffffffffc020520e:	0ec7a703          	lw	a4,236(a5)
    proc->parent = current;
ffffffffc0205212:	f11c                	sd	a5,32(a0)
    assert(current->wait_state == 0);
ffffffffc0205214:	26071763          	bnez	a4,ffffffffc0205482 <do_fork+0x2b2>
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc0205218:	4509                	li	a0,2
ffffffffc020521a:	98afd0ef          	jal	ra,ffffffffc02023a4 <alloc_pages>
    if (page != NULL) {
ffffffffc020521e:	24050b63          	beqz	a0,ffffffffc0205474 <do_fork+0x2a4>
    return page - pages + nbase;
ffffffffc0205222:	000a7b17          	auipc	s6,0xa7
ffffffffc0205226:	2c6b0b13          	addi	s6,s6,710 # ffffffffc02ac4e8 <pages>
ffffffffc020522a:	000b3683          	ld	a3,0(s6)
ffffffffc020522e:	00004797          	auipc	a5,0x4
ffffffffc0205232:	c6278793          	addi	a5,a5,-926 # ffffffffc0208e90 <nbase>
ffffffffc0205236:	0007ba03          	ld	s4,0(a5)
ffffffffc020523a:	40d506b3          	sub	a3,a0,a3
    return KADDR(page2pa(page));
ffffffffc020523e:	000a7b97          	auipc	s7,0xa7
ffffffffc0205242:	23ab8b93          	addi	s7,s7,570 # ffffffffc02ac478 <npage>
    return page - pages + nbase;
ffffffffc0205246:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0205248:	57fd                	li	a5,-1
ffffffffc020524a:	000bb703          	ld	a4,0(s7)
    return page - pages + nbase;
ffffffffc020524e:	96d2                	add	a3,a3,s4
    return KADDR(page2pa(page));
ffffffffc0205250:	83b1                	srli	a5,a5,0xc
ffffffffc0205252:	8ff5                	and	a5,a5,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0205254:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205256:	24e7f663          	bleu	a4,a5,ffffffffc02054a2 <do_fork+0x2d2>
ffffffffc020525a:	000a7a97          	auipc	s5,0xa7
ffffffffc020525e:	27ea8a93          	addi	s5,s5,638 # ffffffffc02ac4d8 <va_pa_offset>
ffffffffc0205262:	000ab783          	ld	a5,0(s5)
    if(cow_copy_mm(proc) != 0) {
ffffffffc0205266:	8522                	mv	a0,s0
ffffffffc0205268:	96be                	add	a3,a3,a5
        proc->kstack = (uintptr_t)page2kva(page);
ffffffffc020526a:	e814                	sd	a3,16(s0)
    if(cow_copy_mm(proc) != 0) {
ffffffffc020526c:	dddfb0ef          	jal	ra,ffffffffc0201048 <cow_copy_mm>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc0205270:	6814                	ld	a3,16(s0)
    if(cow_copy_mm(proc) != 0) {
ffffffffc0205272:	1c051b63          	bnez	a0,ffffffffc0205448 <do_fork+0x278>
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc0205276:	6789                	lui	a5,0x2
ffffffffc0205278:	ee078793          	addi	a5,a5,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x7690>
ffffffffc020527c:	97b6                	add	a5,a5,a3
    *(proc->tf) = *tf;
ffffffffc020527e:	8626                	mv	a2,s1
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc0205280:	f05c                	sd	a5,160(s0)
    *(proc->tf) = *tf;
ffffffffc0205282:	873e                	mv	a4,a5
ffffffffc0205284:	12048313          	addi	t1,s1,288
ffffffffc0205288:	00063883          	ld	a7,0(a2)
ffffffffc020528c:	00863803          	ld	a6,8(a2)
ffffffffc0205290:	6a08                	ld	a0,16(a2)
ffffffffc0205292:	6e0c                	ld	a1,24(a2)
ffffffffc0205294:	01173023          	sd	a7,0(a4)
ffffffffc0205298:	01073423          	sd	a6,8(a4)
ffffffffc020529c:	eb08                	sd	a0,16(a4)
ffffffffc020529e:	ef0c                	sd	a1,24(a4)
ffffffffc02052a0:	02060613          	addi	a2,a2,32
ffffffffc02052a4:	02070713          	addi	a4,a4,32
ffffffffc02052a8:	fe6610e3          	bne	a2,t1,ffffffffc0205288 <do_fork+0xb8>
    proc->tf->gpr.a0 = 0;
ffffffffc02052ac:	0407b823          	sd	zero,80(a5)
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf - 4 : esp;
ffffffffc02052b0:	12090a63          	beqz	s2,ffffffffc02053e4 <do_fork+0x214>
ffffffffc02052b4:	0127b823          	sd	s2,16(a5)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc02052b8:	00000717          	auipc	a4,0x0
ffffffffc02052bc:	d1670713          	addi	a4,a4,-746 # ffffffffc0204fce <forkret>
ffffffffc02052c0:	f818                	sd	a4,48(s0)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc02052c2:	fc1c                	sd	a5,56(s0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02052c4:	100027f3          	csrr	a5,sstatus
ffffffffc02052c8:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02052ca:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02052cc:	12079e63          	bnez	a5,ffffffffc0205408 <do_fork+0x238>
    if (++ last_pid >= MAX_PID) {
ffffffffc02052d0:	0009c797          	auipc	a5,0x9c
ffffffffc02052d4:	d8078793          	addi	a5,a5,-640 # ffffffffc02a1050 <last_pid.1705>
ffffffffc02052d8:	439c                	lw	a5,0(a5)
ffffffffc02052da:	6709                	lui	a4,0x2
ffffffffc02052dc:	0017851b          	addiw	a0,a5,1
ffffffffc02052e0:	0009c697          	auipc	a3,0x9c
ffffffffc02052e4:	d6a6a823          	sw	a0,-656(a3) # ffffffffc02a1050 <last_pid.1705>
ffffffffc02052e8:	14e55163          	ble	a4,a0,ffffffffc020542a <do_fork+0x25a>
    if (last_pid >= next_safe) {
ffffffffc02052ec:	0009c797          	auipc	a5,0x9c
ffffffffc02052f0:	d6878793          	addi	a5,a5,-664 # ffffffffc02a1054 <next_safe.1704>
ffffffffc02052f4:	439c                	lw	a5,0(a5)
ffffffffc02052f6:	000a7497          	auipc	s1,0xa7
ffffffffc02052fa:	2da48493          	addi	s1,s1,730 # ffffffffc02ac5d0 <proc_list>
ffffffffc02052fe:	06f54063          	blt	a0,a5,ffffffffc020535e <do_fork+0x18e>
        next_safe = MAX_PID;
ffffffffc0205302:	6789                	lui	a5,0x2
ffffffffc0205304:	0009c717          	auipc	a4,0x9c
ffffffffc0205308:	d4f72823          	sw	a5,-688(a4) # ffffffffc02a1054 <next_safe.1704>
ffffffffc020530c:	4581                	li	a1,0
ffffffffc020530e:	87aa                	mv	a5,a0
ffffffffc0205310:	000a7497          	auipc	s1,0xa7
ffffffffc0205314:	2c048493          	addi	s1,s1,704 # ffffffffc02ac5d0 <proc_list>
    repeat:
ffffffffc0205318:	6889                	lui	a7,0x2
ffffffffc020531a:	882e                	mv	a6,a1
ffffffffc020531c:	6609                	lui	a2,0x2
        le = list;
ffffffffc020531e:	000a7697          	auipc	a3,0xa7
ffffffffc0205322:	2b268693          	addi	a3,a3,690 # ffffffffc02ac5d0 <proc_list>
ffffffffc0205326:	6694                	ld	a3,8(a3)
        while ((le = list_next(le)) != list) {
ffffffffc0205328:	00968f63          	beq	a3,s1,ffffffffc0205346 <do_fork+0x176>
            if (proc->pid == last_pid) {
ffffffffc020532c:	f3c6a703          	lw	a4,-196(a3)
ffffffffc0205330:	0ae78563          	beq	a5,a4,ffffffffc02053da <do_fork+0x20a>
            else if (proc->pid > last_pid && next_safe > proc->pid) {
ffffffffc0205334:	fee7d9e3          	ble	a4,a5,ffffffffc0205326 <do_fork+0x156>
ffffffffc0205338:	fec757e3          	ble	a2,a4,ffffffffc0205326 <do_fork+0x156>
ffffffffc020533c:	6694                	ld	a3,8(a3)
ffffffffc020533e:	863a                	mv	a2,a4
ffffffffc0205340:	4805                	li	a6,1
        while ((le = list_next(le)) != list) {
ffffffffc0205342:	fe9695e3          	bne	a3,s1,ffffffffc020532c <do_fork+0x15c>
ffffffffc0205346:	c591                	beqz	a1,ffffffffc0205352 <do_fork+0x182>
ffffffffc0205348:	0009c717          	auipc	a4,0x9c
ffffffffc020534c:	d0f72423          	sw	a5,-760(a4) # ffffffffc02a1050 <last_pid.1705>
ffffffffc0205350:	853e                	mv	a0,a5
ffffffffc0205352:	00080663          	beqz	a6,ffffffffc020535e <do_fork+0x18e>
ffffffffc0205356:	0009c797          	auipc	a5,0x9c
ffffffffc020535a:	cec7af23          	sw	a2,-770(a5) # ffffffffc02a1054 <next_safe.1704>
        proc->pid = get_pid();
ffffffffc020535e:	c048                	sw	a0,4(s0)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc0205360:	45a9                	li	a1,10
ffffffffc0205362:	2501                	sext.w	a0,a0
ffffffffc0205364:	751000ef          	jal	ra,ffffffffc02062b4 <hash32>
ffffffffc0205368:	1502                	slli	a0,a0,0x20
ffffffffc020536a:	000a3797          	auipc	a5,0xa3
ffffffffc020536e:	0ee78793          	addi	a5,a5,238 # ffffffffc02a8458 <hash_list>
ffffffffc0205372:	8171                	srli	a0,a0,0x1c
ffffffffc0205374:	953e                	add	a0,a0,a5
    __list_add(elm, listelm, listelm->next);
ffffffffc0205376:	650c                	ld	a1,8(a0)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc0205378:	7014                	ld	a3,32(s0)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc020537a:	0d840793          	addi	a5,s0,216
    prev->next = next->prev = elm;
ffffffffc020537e:	e19c                	sd	a5,0(a1)
    __list_add(elm, listelm, listelm->next);
ffffffffc0205380:	6490                	ld	a2,8(s1)
    prev->next = next->prev = elm;
ffffffffc0205382:	e51c                	sd	a5,8(a0)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc0205384:	7af8                	ld	a4,240(a3)
    list_add(&proc_list, &(proc->list_link));
ffffffffc0205386:	0c840793          	addi	a5,s0,200
    elm->next = next;
ffffffffc020538a:	f06c                	sd	a1,224(s0)
    elm->prev = prev;
ffffffffc020538c:	ec68                	sd	a0,216(s0)
    prev->next = next->prev = elm;
ffffffffc020538e:	e21c                	sd	a5,0(a2)
ffffffffc0205390:	000a7597          	auipc	a1,0xa7
ffffffffc0205394:	24f5b423          	sd	a5,584(a1) # ffffffffc02ac5d8 <proc_list+0x8>
    elm->next = next;
ffffffffc0205398:	e870                	sd	a2,208(s0)
    elm->prev = prev;
ffffffffc020539a:	e464                	sd	s1,200(s0)
    proc->yptr = NULL;
ffffffffc020539c:	0e043c23          	sd	zero,248(s0)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc02053a0:	10e43023          	sd	a4,256(s0)
ffffffffc02053a4:	c311                	beqz	a4,ffffffffc02053a8 <do_fork+0x1d8>
        proc->optr->yptr = proc;
ffffffffc02053a6:	ff60                	sd	s0,248(a4)
    nr_process ++;
ffffffffc02053a8:	0009a783          	lw	a5,0(s3)
    proc->parent->cptr = proc;
ffffffffc02053ac:	fae0                	sd	s0,240(a3)
    nr_process ++;
ffffffffc02053ae:	2785                	addiw	a5,a5,1
ffffffffc02053b0:	000a7717          	auipc	a4,0xa7
ffffffffc02053b4:	0ef72c23          	sw	a5,248(a4) # ffffffffc02ac4a8 <nr_process>
    if (flag) {
ffffffffc02053b8:	08091063          	bnez	s2,ffffffffc0205438 <do_fork+0x268>
    wakeup_proc(proc);
ffffffffc02053bc:	8522                	mv	a0,s0
ffffffffc02053be:	505000ef          	jal	ra,ffffffffc02060c2 <wakeup_proc>
    ret = proc->pid;
ffffffffc02053c2:	4048                	lw	a0,4(s0)
}
ffffffffc02053c4:	60a6                	ld	ra,72(sp)
ffffffffc02053c6:	6406                	ld	s0,64(sp)
ffffffffc02053c8:	74e2                	ld	s1,56(sp)
ffffffffc02053ca:	7942                	ld	s2,48(sp)
ffffffffc02053cc:	79a2                	ld	s3,40(sp)
ffffffffc02053ce:	7a02                	ld	s4,32(sp)
ffffffffc02053d0:	6ae2                	ld	s5,24(sp)
ffffffffc02053d2:	6b42                	ld	s6,16(sp)
ffffffffc02053d4:	6ba2                	ld	s7,8(sp)
ffffffffc02053d6:	6161                	addi	sp,sp,80
ffffffffc02053d8:	8082                	ret
                if (++ last_pid >= next_safe) {
ffffffffc02053da:	2785                	addiw	a5,a5,1
ffffffffc02053dc:	06c7d163          	ble	a2,a5,ffffffffc020543e <do_fork+0x26e>
ffffffffc02053e0:	4585                	li	a1,1
ffffffffc02053e2:	b791                	j	ffffffffc0205326 <do_fork+0x156>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf - 4 : esp;
ffffffffc02053e4:	6909                	lui	s2,0x2
ffffffffc02053e6:	edc90913          	addi	s2,s2,-292 # 1edc <_binary_obj___user_faultread_out_size-0x7694>
ffffffffc02053ea:	9936                	add	s2,s2,a3
ffffffffc02053ec:	0127b823          	sd	s2,16(a5)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc02053f0:	00000717          	auipc	a4,0x0
ffffffffc02053f4:	bde70713          	addi	a4,a4,-1058 # ffffffffc0204fce <forkret>
ffffffffc02053f8:	f818                	sd	a4,48(s0)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc02053fa:	fc1c                	sd	a5,56(s0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02053fc:	100027f3          	csrr	a5,sstatus
ffffffffc0205400:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0205402:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205404:	ec0786e3          	beqz	a5,ffffffffc02052d0 <do_fork+0x100>
        intr_disable();
ffffffffc0205408:	a52fb0ef          	jal	ra,ffffffffc020065a <intr_disable>
    if (++ last_pid >= MAX_PID) {
ffffffffc020540c:	0009c797          	auipc	a5,0x9c
ffffffffc0205410:	c4478793          	addi	a5,a5,-956 # ffffffffc02a1050 <last_pid.1705>
ffffffffc0205414:	439c                	lw	a5,0(a5)
ffffffffc0205416:	6709                	lui	a4,0x2
        return 1;
ffffffffc0205418:	4905                	li	s2,1
ffffffffc020541a:	0017851b          	addiw	a0,a5,1
ffffffffc020541e:	0009c697          	auipc	a3,0x9c
ffffffffc0205422:	c2a6a923          	sw	a0,-974(a3) # ffffffffc02a1050 <last_pid.1705>
ffffffffc0205426:	ece543e3          	blt	a0,a4,ffffffffc02052ec <do_fork+0x11c>
        last_pid = 1;
ffffffffc020542a:	4785                	li	a5,1
ffffffffc020542c:	0009c717          	auipc	a4,0x9c
ffffffffc0205430:	c2f72223          	sw	a5,-988(a4) # ffffffffc02a1050 <last_pid.1705>
ffffffffc0205434:	4505                	li	a0,1
ffffffffc0205436:	b5f1                	j	ffffffffc0205302 <do_fork+0x132>
        intr_enable();
ffffffffc0205438:	a1cfb0ef          	jal	ra,ffffffffc0200654 <intr_enable>
ffffffffc020543c:	b741                	j	ffffffffc02053bc <do_fork+0x1ec>
                    if (last_pid >= MAX_PID) {
ffffffffc020543e:	0117c363          	blt	a5,a7,ffffffffc0205444 <do_fork+0x274>
                        last_pid = 1;
ffffffffc0205442:	4785                	li	a5,1
                    goto repeat;
ffffffffc0205444:	4585                	li	a1,1
ffffffffc0205446:	bdd1                	j	ffffffffc020531a <do_fork+0x14a>
    return pa2page(PADDR(kva));
ffffffffc0205448:	c02007b7          	lui	a5,0xc0200
ffffffffc020544c:	08f6e363          	bltu	a3,a5,ffffffffc02054d2 <do_fork+0x302>
ffffffffc0205450:	000ab783          	ld	a5,0(s5)
    if (PPN(pa) >= npage) {
ffffffffc0205454:	000bb703          	ld	a4,0(s7)
    return pa2page(PADDR(kva));
ffffffffc0205458:	40f687b3          	sub	a5,a3,a5
    if (PPN(pa) >= npage) {
ffffffffc020545c:	83b1                	srli	a5,a5,0xc
ffffffffc020545e:	04e7fe63          	bleu	a4,a5,ffffffffc02054ba <do_fork+0x2ea>
    return &pages[PPN(pa) - nbase];
ffffffffc0205462:	000b3503          	ld	a0,0(s6)
ffffffffc0205466:	414787b3          	sub	a5,a5,s4
ffffffffc020546a:	079a                	slli	a5,a5,0x6
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc020546c:	4589                	li	a1,2
ffffffffc020546e:	953e                	add	a0,a0,a5
ffffffffc0205470:	fbdfc0ef          	jal	ra,ffffffffc020242c <free_pages>
    kfree(proc);
ffffffffc0205474:	8522                	mv	a0,s0
ffffffffc0205476:	deffc0ef          	jal	ra,ffffffffc0202264 <kfree>
    ret = -E_NO_MEM;
ffffffffc020547a:	5571                	li	a0,-4
    return ret;
ffffffffc020547c:	b7a1                	j	ffffffffc02053c4 <do_fork+0x1f4>
    int ret = -E_NO_FREE_PROC;
ffffffffc020547e:	556d                	li	a0,-5
ffffffffc0205480:	b791                	j	ffffffffc02053c4 <do_fork+0x1f4>
    assert(current->wait_state == 0);
ffffffffc0205482:	00003697          	auipc	a3,0x3
ffffffffc0205486:	2de68693          	addi	a3,a3,734 # ffffffffc0208760 <default_pmm_manager+0x1108>
ffffffffc020548a:	00002617          	auipc	a2,0x2
ffffffffc020548e:	8f660613          	addi	a2,a2,-1802 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0205492:	1b500593          	li	a1,437
ffffffffc0205496:	00003517          	auipc	a0,0x3
ffffffffc020549a:	53250513          	addi	a0,a0,1330 # ffffffffc02089c8 <default_pmm_manager+0x1370>
ffffffffc020549e:	fe7fa0ef          	jal	ra,ffffffffc0200484 <__panic>
    return KADDR(page2pa(page));
ffffffffc02054a2:	00002617          	auipc	a2,0x2
ffffffffc02054a6:	c9660613          	addi	a2,a2,-874 # ffffffffc0207138 <commands+0x878>
ffffffffc02054aa:	06a00593          	li	a1,106
ffffffffc02054ae:	00002517          	auipc	a0,0x2
ffffffffc02054b2:	d9a50513          	addi	a0,a0,-614 # ffffffffc0207248 <commands+0x988>
ffffffffc02054b6:	fcffa0ef          	jal	ra,ffffffffc0200484 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02054ba:	00002617          	auipc	a2,0x2
ffffffffc02054be:	d6e60613          	addi	a2,a2,-658 # ffffffffc0207228 <commands+0x968>
ffffffffc02054c2:	06300593          	li	a1,99
ffffffffc02054c6:	00002517          	auipc	a0,0x2
ffffffffc02054ca:	d8250513          	addi	a0,a0,-638 # ffffffffc0207248 <commands+0x988>
ffffffffc02054ce:	fb7fa0ef          	jal	ra,ffffffffc0200484 <__panic>
    return pa2page(PADDR(kva));
ffffffffc02054d2:	00002617          	auipc	a2,0x2
ffffffffc02054d6:	cb660613          	addi	a2,a2,-842 # ffffffffc0207188 <commands+0x8c8>
ffffffffc02054da:	06f00593          	li	a1,111
ffffffffc02054de:	00002517          	auipc	a0,0x2
ffffffffc02054e2:	d6a50513          	addi	a0,a0,-662 # ffffffffc0207248 <commands+0x988>
ffffffffc02054e6:	f9ffa0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc02054ea <kernel_thread>:
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc02054ea:	7129                	addi	sp,sp,-320
ffffffffc02054ec:	fa22                	sd	s0,304(sp)
ffffffffc02054ee:	f626                	sd	s1,296(sp)
ffffffffc02054f0:	f24a                	sd	s2,288(sp)
ffffffffc02054f2:	84ae                	mv	s1,a1
ffffffffc02054f4:	892a                	mv	s2,a0
ffffffffc02054f6:	8432                	mv	s0,a2
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc02054f8:	4581                	li	a1,0
ffffffffc02054fa:	12000613          	li	a2,288
ffffffffc02054fe:	850a                	mv	a0,sp
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc0205500:	fe06                	sd	ra,312(sp)
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc0205502:	260010ef          	jal	ra,ffffffffc0206762 <memset>
    tf.gpr.s0 = (uintptr_t)fn;
ffffffffc0205506:	e0ca                	sd	s2,64(sp)
    tf.gpr.s1 = (uintptr_t)arg;
ffffffffc0205508:	e4a6                	sd	s1,72(sp)
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
ffffffffc020550a:	100027f3          	csrr	a5,sstatus
ffffffffc020550e:	edd7f793          	andi	a5,a5,-291
ffffffffc0205512:	1207e793          	ori	a5,a5,288
ffffffffc0205516:	e23e                	sd	a5,256(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0205518:	860a                	mv	a2,sp
ffffffffc020551a:	10046513          	ori	a0,s0,256
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc020551e:	00000797          	auipc	a5,0x0
ffffffffc0205522:	a3478793          	addi	a5,a5,-1484 # ffffffffc0204f52 <kernel_thread_entry>
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0205526:	4581                	li	a1,0
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc0205528:	e63e                	sd	a5,264(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc020552a:	ca7ff0ef          	jal	ra,ffffffffc02051d0 <do_fork>
}
ffffffffc020552e:	70f2                	ld	ra,312(sp)
ffffffffc0205530:	7452                	ld	s0,304(sp)
ffffffffc0205532:	74b2                	ld	s1,296(sp)
ffffffffc0205534:	7912                	ld	s2,288(sp)
ffffffffc0205536:	6131                	addi	sp,sp,320
ffffffffc0205538:	8082                	ret

ffffffffc020553a <do_exit>:
do_exit(int error_code) {
ffffffffc020553a:	7179                	addi	sp,sp,-48
ffffffffc020553c:	e84a                	sd	s2,16(sp)
    if (current == idleproc) {
ffffffffc020553e:	000a7717          	auipc	a4,0xa7
ffffffffc0205542:	f5a70713          	addi	a4,a4,-166 # ffffffffc02ac498 <idleproc>
ffffffffc0205546:	000a7917          	auipc	s2,0xa7
ffffffffc020554a:	f4a90913          	addi	s2,s2,-182 # ffffffffc02ac490 <current>
ffffffffc020554e:	00093783          	ld	a5,0(s2)
ffffffffc0205552:	6318                	ld	a4,0(a4)
do_exit(int error_code) {
ffffffffc0205554:	f406                	sd	ra,40(sp)
ffffffffc0205556:	f022                	sd	s0,32(sp)
ffffffffc0205558:	ec26                	sd	s1,24(sp)
ffffffffc020555a:	e44e                	sd	s3,8(sp)
ffffffffc020555c:	e052                	sd	s4,0(sp)
    if (current == idleproc) {
ffffffffc020555e:	0ce78c63          	beq	a5,a4,ffffffffc0205636 <do_exit+0xfc>
    if (current == initproc) {
ffffffffc0205562:	000a7417          	auipc	s0,0xa7
ffffffffc0205566:	f3e40413          	addi	s0,s0,-194 # ffffffffc02ac4a0 <initproc>
ffffffffc020556a:	6018                	ld	a4,0(s0)
ffffffffc020556c:	0ee78b63          	beq	a5,a4,ffffffffc0205662 <do_exit+0x128>
    struct mm_struct *mm = current->mm;
ffffffffc0205570:	7784                	ld	s1,40(a5)
ffffffffc0205572:	89aa                	mv	s3,a0
    if (mm != NULL) {
ffffffffc0205574:	c48d                	beqz	s1,ffffffffc020559e <do_exit+0x64>
        lcr3(boot_cr3);
ffffffffc0205576:	000a7797          	auipc	a5,0xa7
ffffffffc020557a:	f6a78793          	addi	a5,a5,-150 # ffffffffc02ac4e0 <boot_cr3>
ffffffffc020557e:	639c                	ld	a5,0(a5)
ffffffffc0205580:	577d                	li	a4,-1
ffffffffc0205582:	177e                	slli	a4,a4,0x3f
ffffffffc0205584:	83b1                	srli	a5,a5,0xc
ffffffffc0205586:	8fd9                	or	a5,a5,a4
ffffffffc0205588:	18079073          	csrw	satp,a5
    mm->mm_count -= 1;
ffffffffc020558c:	589c                	lw	a5,48(s1)
ffffffffc020558e:	fff7871b          	addiw	a4,a5,-1
ffffffffc0205592:	d898                	sw	a4,48(s1)
        if (mm_count_dec(mm) == 0) {
ffffffffc0205594:	cf4d                	beqz	a4,ffffffffc020564e <do_exit+0x114>
        current->mm = NULL;
ffffffffc0205596:	00093783          	ld	a5,0(s2)
ffffffffc020559a:	0207b423          	sd	zero,40(a5)
    current->state = PROC_ZOMBIE;
ffffffffc020559e:	00093783          	ld	a5,0(s2)
ffffffffc02055a2:	470d                	li	a4,3
ffffffffc02055a4:	c398                	sw	a4,0(a5)
    current->exit_code = error_code;
ffffffffc02055a6:	0f37a423          	sw	s3,232(a5)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02055aa:	100027f3          	csrr	a5,sstatus
ffffffffc02055ae:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02055b0:	4a01                	li	s4,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02055b2:	e7e1                	bnez	a5,ffffffffc020567a <do_exit+0x140>
        proc = current->parent;
ffffffffc02055b4:	00093703          	ld	a4,0(s2)
        if (proc->wait_state == WT_CHILD) {
ffffffffc02055b8:	800007b7          	lui	a5,0x80000
ffffffffc02055bc:	0785                	addi	a5,a5,1
        proc = current->parent;
ffffffffc02055be:	7308                	ld	a0,32(a4)
        if (proc->wait_state == WT_CHILD) {
ffffffffc02055c0:	0ec52703          	lw	a4,236(a0)
ffffffffc02055c4:	0af70f63          	beq	a4,a5,ffffffffc0205682 <do_exit+0x148>
ffffffffc02055c8:	00093683          	ld	a3,0(s2)
                if (initproc->wait_state == WT_CHILD) {
ffffffffc02055cc:	800009b7          	lui	s3,0x80000
            if (proc->state == PROC_ZOMBIE) {
ffffffffc02055d0:	448d                	li	s1,3
                if (initproc->wait_state == WT_CHILD) {
ffffffffc02055d2:	0985                	addi	s3,s3,1
        while (current->cptr != NULL) {
ffffffffc02055d4:	7afc                	ld	a5,240(a3)
ffffffffc02055d6:	cb95                	beqz	a5,ffffffffc020560a <do_exit+0xd0>
            current->cptr = proc->optr;
ffffffffc02055d8:	1007b703          	ld	a4,256(a5) # ffffffff80000100 <_binary_obj___user_exit_out_size+0xffffffff7fff5680>
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc02055dc:	6008                	ld	a0,0(s0)
            current->cptr = proc->optr;
ffffffffc02055de:	faf8                	sd	a4,240(a3)
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc02055e0:	7978                	ld	a4,240(a0)
            proc->yptr = NULL;
ffffffffc02055e2:	0e07bc23          	sd	zero,248(a5)
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc02055e6:	10e7b023          	sd	a4,256(a5)
ffffffffc02055ea:	c311                	beqz	a4,ffffffffc02055ee <do_exit+0xb4>
                initproc->cptr->yptr = proc;
ffffffffc02055ec:	ff7c                	sd	a5,248(a4)
            if (proc->state == PROC_ZOMBIE) {
ffffffffc02055ee:	4398                	lw	a4,0(a5)
            proc->parent = initproc;
ffffffffc02055f0:	f388                	sd	a0,32(a5)
            initproc->cptr = proc;
ffffffffc02055f2:	f97c                	sd	a5,240(a0)
            if (proc->state == PROC_ZOMBIE) {
ffffffffc02055f4:	fe9710e3          	bne	a4,s1,ffffffffc02055d4 <do_exit+0x9a>
                if (initproc->wait_state == WT_CHILD) {
ffffffffc02055f8:	0ec52783          	lw	a5,236(a0)
ffffffffc02055fc:	fd379ce3          	bne	a5,s3,ffffffffc02055d4 <do_exit+0x9a>
                    wakeup_proc(initproc);
ffffffffc0205600:	2c3000ef          	jal	ra,ffffffffc02060c2 <wakeup_proc>
ffffffffc0205604:	00093683          	ld	a3,0(s2)
ffffffffc0205608:	b7f1                	j	ffffffffc02055d4 <do_exit+0x9a>
    if (flag) {
ffffffffc020560a:	020a1363          	bnez	s4,ffffffffc0205630 <do_exit+0xf6>
    schedule();
ffffffffc020560e:	331000ef          	jal	ra,ffffffffc020613e <schedule>
    panic("do_exit will not return!! %d.\n", current->pid);
ffffffffc0205612:	00093783          	ld	a5,0(s2)
ffffffffc0205616:	00003617          	auipc	a2,0x3
ffffffffc020561a:	12a60613          	addi	a2,a2,298 # ffffffffc0208740 <default_pmm_manager+0x10e8>
ffffffffc020561e:	20800593          	li	a1,520
ffffffffc0205622:	43d4                	lw	a3,4(a5)
ffffffffc0205624:	00003517          	auipc	a0,0x3
ffffffffc0205628:	3a450513          	addi	a0,a0,932 # ffffffffc02089c8 <default_pmm_manager+0x1370>
ffffffffc020562c:	e59fa0ef          	jal	ra,ffffffffc0200484 <__panic>
        intr_enable();
ffffffffc0205630:	824fb0ef          	jal	ra,ffffffffc0200654 <intr_enable>
ffffffffc0205634:	bfe9                	j	ffffffffc020560e <do_exit+0xd4>
        panic("idleproc exit.\n");
ffffffffc0205636:	00003617          	auipc	a2,0x3
ffffffffc020563a:	0ea60613          	addi	a2,a2,234 # ffffffffc0208720 <default_pmm_manager+0x10c8>
ffffffffc020563e:	1dc00593          	li	a1,476
ffffffffc0205642:	00003517          	auipc	a0,0x3
ffffffffc0205646:	38650513          	addi	a0,a0,902 # ffffffffc02089c8 <default_pmm_manager+0x1370>
ffffffffc020564a:	e3bfa0ef          	jal	ra,ffffffffc0200484 <__panic>
            exit_mmap(mm);
ffffffffc020564e:	8526                	mv	a0,s1
ffffffffc0205650:	81eff0ef          	jal	ra,ffffffffc020466e <exit_mmap>
            put_pgdir(mm);
ffffffffc0205654:	8526                	mv	a0,s1
ffffffffc0205656:	a0bff0ef          	jal	ra,ffffffffc0205060 <put_pgdir>
            mm_destroy(mm);
ffffffffc020565a:	8526                	mv	a0,s1
ffffffffc020565c:	f0ffe0ef          	jal	ra,ffffffffc020456a <mm_destroy>
ffffffffc0205660:	bf1d                	j	ffffffffc0205596 <do_exit+0x5c>
        panic("initproc exit.\n");
ffffffffc0205662:	00003617          	auipc	a2,0x3
ffffffffc0205666:	0ce60613          	addi	a2,a2,206 # ffffffffc0208730 <default_pmm_manager+0x10d8>
ffffffffc020566a:	1df00593          	li	a1,479
ffffffffc020566e:	00003517          	auipc	a0,0x3
ffffffffc0205672:	35a50513          	addi	a0,a0,858 # ffffffffc02089c8 <default_pmm_manager+0x1370>
ffffffffc0205676:	e0ffa0ef          	jal	ra,ffffffffc0200484 <__panic>
        intr_disable();
ffffffffc020567a:	fe1fa0ef          	jal	ra,ffffffffc020065a <intr_disable>
        return 1;
ffffffffc020567e:	4a05                	li	s4,1
ffffffffc0205680:	bf15                	j	ffffffffc02055b4 <do_exit+0x7a>
            wakeup_proc(proc);
ffffffffc0205682:	241000ef          	jal	ra,ffffffffc02060c2 <wakeup_proc>
ffffffffc0205686:	b789                	j	ffffffffc02055c8 <do_exit+0x8e>

ffffffffc0205688 <do_wait.part.1>:
do_wait(int pid, int *code_store) {
ffffffffc0205688:	7139                	addi	sp,sp,-64
ffffffffc020568a:	e852                	sd	s4,16(sp)
        current->wait_state = WT_CHILD;
ffffffffc020568c:	80000a37          	lui	s4,0x80000
do_wait(int pid, int *code_store) {
ffffffffc0205690:	f426                	sd	s1,40(sp)
ffffffffc0205692:	f04a                	sd	s2,32(sp)
ffffffffc0205694:	ec4e                	sd	s3,24(sp)
ffffffffc0205696:	e456                	sd	s5,8(sp)
ffffffffc0205698:	e05a                	sd	s6,0(sp)
ffffffffc020569a:	fc06                	sd	ra,56(sp)
ffffffffc020569c:	f822                	sd	s0,48(sp)
ffffffffc020569e:	89aa                	mv	s3,a0
ffffffffc02056a0:	8b2e                	mv	s6,a1
        proc = current->cptr;
ffffffffc02056a2:	000a7917          	auipc	s2,0xa7
ffffffffc02056a6:	dee90913          	addi	s2,s2,-530 # ffffffffc02ac490 <current>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc02056aa:	448d                	li	s1,3
        current->state = PROC_SLEEPING;
ffffffffc02056ac:	4a85                	li	s5,1
        current->wait_state = WT_CHILD;
ffffffffc02056ae:	2a05                	addiw	s4,s4,1
    if (pid != 0) {
ffffffffc02056b0:	02098f63          	beqz	s3,ffffffffc02056ee <do_wait.part.1+0x66>
        proc = find_proc(pid);
ffffffffc02056b4:	854e                	mv	a0,s3
ffffffffc02056b6:	abfff0ef          	jal	ra,ffffffffc0205174 <find_proc>
ffffffffc02056ba:	842a                	mv	s0,a0
        if (proc != NULL && proc->parent == current) {
ffffffffc02056bc:	12050063          	beqz	a0,ffffffffc02057dc <do_wait.part.1+0x154>
ffffffffc02056c0:	00093703          	ld	a4,0(s2)
ffffffffc02056c4:	711c                	ld	a5,32(a0)
ffffffffc02056c6:	10e79b63          	bne	a5,a4,ffffffffc02057dc <do_wait.part.1+0x154>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc02056ca:	411c                	lw	a5,0(a0)
ffffffffc02056cc:	02978c63          	beq	a5,s1,ffffffffc0205704 <do_wait.part.1+0x7c>
        current->state = PROC_SLEEPING;
ffffffffc02056d0:	01572023          	sw	s5,0(a4)
        current->wait_state = WT_CHILD;
ffffffffc02056d4:	0f472623          	sw	s4,236(a4)
        schedule();
ffffffffc02056d8:	267000ef          	jal	ra,ffffffffc020613e <schedule>
        if (current->flags & PF_EXITING) {
ffffffffc02056dc:	00093783          	ld	a5,0(s2)
ffffffffc02056e0:	0b07a783          	lw	a5,176(a5)
ffffffffc02056e4:	8b85                	andi	a5,a5,1
ffffffffc02056e6:	d7e9                	beqz	a5,ffffffffc02056b0 <do_wait.part.1+0x28>
            do_exit(-E_KILLED);
ffffffffc02056e8:	555d                	li	a0,-9
ffffffffc02056ea:	e51ff0ef          	jal	ra,ffffffffc020553a <do_exit>
        proc = current->cptr;
ffffffffc02056ee:	00093703          	ld	a4,0(s2)
ffffffffc02056f2:	7b60                	ld	s0,240(a4)
        for (; proc != NULL; proc = proc->optr) {
ffffffffc02056f4:	e409                	bnez	s0,ffffffffc02056fe <do_wait.part.1+0x76>
ffffffffc02056f6:	a0dd                	j	ffffffffc02057dc <do_wait.part.1+0x154>
ffffffffc02056f8:	10043403          	ld	s0,256(s0)
ffffffffc02056fc:	d871                	beqz	s0,ffffffffc02056d0 <do_wait.part.1+0x48>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc02056fe:	401c                	lw	a5,0(s0)
ffffffffc0205700:	fe979ce3          	bne	a5,s1,ffffffffc02056f8 <do_wait.part.1+0x70>
    if (proc == idleproc || proc == initproc) {
ffffffffc0205704:	000a7797          	auipc	a5,0xa7
ffffffffc0205708:	d9478793          	addi	a5,a5,-620 # ffffffffc02ac498 <idleproc>
ffffffffc020570c:	639c                	ld	a5,0(a5)
ffffffffc020570e:	0c878d63          	beq	a5,s0,ffffffffc02057e8 <do_wait.part.1+0x160>
ffffffffc0205712:	000a7797          	auipc	a5,0xa7
ffffffffc0205716:	d8e78793          	addi	a5,a5,-626 # ffffffffc02ac4a0 <initproc>
ffffffffc020571a:	639c                	ld	a5,0(a5)
ffffffffc020571c:	0cf40663          	beq	s0,a5,ffffffffc02057e8 <do_wait.part.1+0x160>
    if (code_store != NULL) {
ffffffffc0205720:	000b0663          	beqz	s6,ffffffffc020572c <do_wait.part.1+0xa4>
        *code_store = proc->exit_code;
ffffffffc0205724:	0e842783          	lw	a5,232(s0)
ffffffffc0205728:	00fb2023          	sw	a5,0(s6)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020572c:	100027f3          	csrr	a5,sstatus
ffffffffc0205730:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0205732:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205734:	e7d5                	bnez	a5,ffffffffc02057e0 <do_wait.part.1+0x158>
    __list_del(listelm->prev, listelm->next);
ffffffffc0205736:	6c70                	ld	a2,216(s0)
ffffffffc0205738:	7074                	ld	a3,224(s0)
    if (proc->optr != NULL) {
ffffffffc020573a:	10043703          	ld	a4,256(s0)
ffffffffc020573e:	7c7c                	ld	a5,248(s0)
    prev->next = next;
ffffffffc0205740:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc0205742:	e290                	sd	a2,0(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc0205744:	6470                	ld	a2,200(s0)
ffffffffc0205746:	6874                	ld	a3,208(s0)
    prev->next = next;
ffffffffc0205748:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc020574a:	e290                	sd	a2,0(a3)
ffffffffc020574c:	c319                	beqz	a4,ffffffffc0205752 <do_wait.part.1+0xca>
        proc->optr->yptr = proc->yptr;
ffffffffc020574e:	ff7c                	sd	a5,248(a4)
ffffffffc0205750:	7c7c                	ld	a5,248(s0)
    if (proc->yptr != NULL) {
ffffffffc0205752:	c3d1                	beqz	a5,ffffffffc02057d6 <do_wait.part.1+0x14e>
        proc->yptr->optr = proc->optr;
ffffffffc0205754:	10e7b023          	sd	a4,256(a5)
    nr_process --;
ffffffffc0205758:	000a7797          	auipc	a5,0xa7
ffffffffc020575c:	d5078793          	addi	a5,a5,-688 # ffffffffc02ac4a8 <nr_process>
ffffffffc0205760:	439c                	lw	a5,0(a5)
ffffffffc0205762:	37fd                	addiw	a5,a5,-1
ffffffffc0205764:	000a7717          	auipc	a4,0xa7
ffffffffc0205768:	d4f72223          	sw	a5,-700(a4) # ffffffffc02ac4a8 <nr_process>
    if (flag) {
ffffffffc020576c:	e1b5                	bnez	a1,ffffffffc02057d0 <do_wait.part.1+0x148>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc020576e:	6814                	ld	a3,16(s0)
ffffffffc0205770:	c02007b7          	lui	a5,0xc0200
ffffffffc0205774:	0af6e263          	bltu	a3,a5,ffffffffc0205818 <do_wait.part.1+0x190>
ffffffffc0205778:	000a7797          	auipc	a5,0xa7
ffffffffc020577c:	d6078793          	addi	a5,a5,-672 # ffffffffc02ac4d8 <va_pa_offset>
ffffffffc0205780:	6398                	ld	a4,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0205782:	000a7797          	auipc	a5,0xa7
ffffffffc0205786:	cf678793          	addi	a5,a5,-778 # ffffffffc02ac478 <npage>
ffffffffc020578a:	639c                	ld	a5,0(a5)
    return pa2page(PADDR(kva));
ffffffffc020578c:	8e99                	sub	a3,a3,a4
    if (PPN(pa) >= npage) {
ffffffffc020578e:	82b1                	srli	a3,a3,0xc
ffffffffc0205790:	06f6f863          	bleu	a5,a3,ffffffffc0205800 <do_wait.part.1+0x178>
    return &pages[PPN(pa) - nbase];
ffffffffc0205794:	00003797          	auipc	a5,0x3
ffffffffc0205798:	6fc78793          	addi	a5,a5,1788 # ffffffffc0208e90 <nbase>
ffffffffc020579c:	639c                	ld	a5,0(a5)
ffffffffc020579e:	000a7717          	auipc	a4,0xa7
ffffffffc02057a2:	d4a70713          	addi	a4,a4,-694 # ffffffffc02ac4e8 <pages>
ffffffffc02057a6:	6308                	ld	a0,0(a4)
ffffffffc02057a8:	8e9d                	sub	a3,a3,a5
ffffffffc02057aa:	069a                	slli	a3,a3,0x6
ffffffffc02057ac:	9536                	add	a0,a0,a3
ffffffffc02057ae:	4589                	li	a1,2
ffffffffc02057b0:	c7dfc0ef          	jal	ra,ffffffffc020242c <free_pages>
    kfree(proc);
ffffffffc02057b4:	8522                	mv	a0,s0
ffffffffc02057b6:	aaffc0ef          	jal	ra,ffffffffc0202264 <kfree>
    return 0;
ffffffffc02057ba:	4501                	li	a0,0
}
ffffffffc02057bc:	70e2                	ld	ra,56(sp)
ffffffffc02057be:	7442                	ld	s0,48(sp)
ffffffffc02057c0:	74a2                	ld	s1,40(sp)
ffffffffc02057c2:	7902                	ld	s2,32(sp)
ffffffffc02057c4:	69e2                	ld	s3,24(sp)
ffffffffc02057c6:	6a42                	ld	s4,16(sp)
ffffffffc02057c8:	6aa2                	ld	s5,8(sp)
ffffffffc02057ca:	6b02                	ld	s6,0(sp)
ffffffffc02057cc:	6121                	addi	sp,sp,64
ffffffffc02057ce:	8082                	ret
        intr_enable();
ffffffffc02057d0:	e85fa0ef          	jal	ra,ffffffffc0200654 <intr_enable>
ffffffffc02057d4:	bf69                	j	ffffffffc020576e <do_wait.part.1+0xe6>
       proc->parent->cptr = proc->optr;
ffffffffc02057d6:	701c                	ld	a5,32(s0)
ffffffffc02057d8:	fbf8                	sd	a4,240(a5)
ffffffffc02057da:	bfbd                	j	ffffffffc0205758 <do_wait.part.1+0xd0>
    return -E_BAD_PROC;
ffffffffc02057dc:	5579                	li	a0,-2
ffffffffc02057de:	bff9                	j	ffffffffc02057bc <do_wait.part.1+0x134>
        intr_disable();
ffffffffc02057e0:	e7bfa0ef          	jal	ra,ffffffffc020065a <intr_disable>
        return 1;
ffffffffc02057e4:	4585                	li	a1,1
ffffffffc02057e6:	bf81                	j	ffffffffc0205736 <do_wait.part.1+0xae>
        panic("wait idleproc or initproc.\n");
ffffffffc02057e8:	00003617          	auipc	a2,0x3
ffffffffc02057ec:	f9860613          	addi	a2,a2,-104 # ffffffffc0208780 <default_pmm_manager+0x1128>
ffffffffc02057f0:	30300593          	li	a1,771
ffffffffc02057f4:	00003517          	auipc	a0,0x3
ffffffffc02057f8:	1d450513          	addi	a0,a0,468 # ffffffffc02089c8 <default_pmm_manager+0x1370>
ffffffffc02057fc:	c89fa0ef          	jal	ra,ffffffffc0200484 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0205800:	00002617          	auipc	a2,0x2
ffffffffc0205804:	a2860613          	addi	a2,a2,-1496 # ffffffffc0207228 <commands+0x968>
ffffffffc0205808:	06300593          	li	a1,99
ffffffffc020580c:	00002517          	auipc	a0,0x2
ffffffffc0205810:	a3c50513          	addi	a0,a0,-1476 # ffffffffc0207248 <commands+0x988>
ffffffffc0205814:	c71fa0ef          	jal	ra,ffffffffc0200484 <__panic>
    return pa2page(PADDR(kva));
ffffffffc0205818:	00002617          	auipc	a2,0x2
ffffffffc020581c:	97060613          	addi	a2,a2,-1680 # ffffffffc0207188 <commands+0x8c8>
ffffffffc0205820:	06f00593          	li	a1,111
ffffffffc0205824:	00002517          	auipc	a0,0x2
ffffffffc0205828:	a2450513          	addi	a0,a0,-1500 # ffffffffc0207248 <commands+0x988>
ffffffffc020582c:	c59fa0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0205830 <init_main>:
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg) {
ffffffffc0205830:	1141                	addi	sp,sp,-16
ffffffffc0205832:	e406                	sd	ra,8(sp)
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0205834:	c3ffc0ef          	jal	ra,ffffffffc0202472 <nr_free_pages>
    size_t kernel_allocated_store = kallocated();
ffffffffc0205838:	96dfc0ef          	jal	ra,ffffffffc02021a4 <kallocated>

    int pid = kernel_thread(user_main, NULL, 0);
ffffffffc020583c:	4601                	li	a2,0
ffffffffc020583e:	4581                	li	a1,0
ffffffffc0205840:	fffff517          	auipc	a0,0xfffff
ffffffffc0205844:	79e50513          	addi	a0,a0,1950 # ffffffffc0204fde <user_main>
ffffffffc0205848:	ca3ff0ef          	jal	ra,ffffffffc02054ea <kernel_thread>
    if (pid <= 0) {
ffffffffc020584c:	00a04563          	bgtz	a0,ffffffffc0205856 <init_main+0x26>
ffffffffc0205850:	a841                	j	ffffffffc02058e0 <init_main+0xb0>
        panic("create user_main failed.\n");
    }

    while (do_wait(0, NULL) == 0) {
        schedule();
ffffffffc0205852:	0ed000ef          	jal	ra,ffffffffc020613e <schedule>
    if (code_store != NULL) {
ffffffffc0205856:	4581                	li	a1,0
ffffffffc0205858:	4501                	li	a0,0
ffffffffc020585a:	e2fff0ef          	jal	ra,ffffffffc0205688 <do_wait.part.1>
    while (do_wait(0, NULL) == 0) {
ffffffffc020585e:	d975                	beqz	a0,ffffffffc0205852 <init_main+0x22>
    }

    cprintf("all user-mode processes have quit.\n");
ffffffffc0205860:	00003517          	auipc	a0,0x3
ffffffffc0205864:	f6050513          	addi	a0,a0,-160 # ffffffffc02087c0 <default_pmm_manager+0x1168>
ffffffffc0205868:	927fa0ef          	jal	ra,ffffffffc020018e <cprintf>
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc020586c:	000a7797          	auipc	a5,0xa7
ffffffffc0205870:	c3478793          	addi	a5,a5,-972 # ffffffffc02ac4a0 <initproc>
ffffffffc0205874:	639c                	ld	a5,0(a5)
ffffffffc0205876:	7bf8                	ld	a4,240(a5)
ffffffffc0205878:	e721                	bnez	a4,ffffffffc02058c0 <init_main+0x90>
ffffffffc020587a:	7ff8                	ld	a4,248(a5)
ffffffffc020587c:	e331                	bnez	a4,ffffffffc02058c0 <init_main+0x90>
ffffffffc020587e:	1007b703          	ld	a4,256(a5)
ffffffffc0205882:	ef1d                	bnez	a4,ffffffffc02058c0 <init_main+0x90>
    assert(nr_process == 2);
ffffffffc0205884:	000a7717          	auipc	a4,0xa7
ffffffffc0205888:	c2470713          	addi	a4,a4,-988 # ffffffffc02ac4a8 <nr_process>
ffffffffc020588c:	4314                	lw	a3,0(a4)
ffffffffc020588e:	4709                	li	a4,2
ffffffffc0205890:	0ae69463          	bne	a3,a4,ffffffffc0205938 <init_main+0x108>
    return listelm->next;
ffffffffc0205894:	000a7697          	auipc	a3,0xa7
ffffffffc0205898:	d3c68693          	addi	a3,a3,-708 # ffffffffc02ac5d0 <proc_list>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc020589c:	6698                	ld	a4,8(a3)
ffffffffc020589e:	0c878793          	addi	a5,a5,200
ffffffffc02058a2:	06f71b63          	bne	a4,a5,ffffffffc0205918 <init_main+0xe8>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc02058a6:	629c                	ld	a5,0(a3)
ffffffffc02058a8:	04f71863          	bne	a4,a5,ffffffffc02058f8 <init_main+0xc8>

    cprintf("init check memory pass.\n");
ffffffffc02058ac:	00003517          	auipc	a0,0x3
ffffffffc02058b0:	ffc50513          	addi	a0,a0,-4 # ffffffffc02088a8 <default_pmm_manager+0x1250>
ffffffffc02058b4:	8dbfa0ef          	jal	ra,ffffffffc020018e <cprintf>
    return 0;
}
ffffffffc02058b8:	60a2                	ld	ra,8(sp)
ffffffffc02058ba:	4501                	li	a0,0
ffffffffc02058bc:	0141                	addi	sp,sp,16
ffffffffc02058be:	8082                	ret
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc02058c0:	00003697          	auipc	a3,0x3
ffffffffc02058c4:	f2868693          	addi	a3,a3,-216 # ffffffffc02087e8 <default_pmm_manager+0x1190>
ffffffffc02058c8:	00001617          	auipc	a2,0x1
ffffffffc02058cc:	4b860613          	addi	a2,a2,1208 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc02058d0:	36800593          	li	a1,872
ffffffffc02058d4:	00003517          	auipc	a0,0x3
ffffffffc02058d8:	0f450513          	addi	a0,a0,244 # ffffffffc02089c8 <default_pmm_manager+0x1370>
ffffffffc02058dc:	ba9fa0ef          	jal	ra,ffffffffc0200484 <__panic>
        panic("create user_main failed.\n");
ffffffffc02058e0:	00003617          	auipc	a2,0x3
ffffffffc02058e4:	ec060613          	addi	a2,a2,-320 # ffffffffc02087a0 <default_pmm_manager+0x1148>
ffffffffc02058e8:	36000593          	li	a1,864
ffffffffc02058ec:	00003517          	auipc	a0,0x3
ffffffffc02058f0:	0dc50513          	addi	a0,a0,220 # ffffffffc02089c8 <default_pmm_manager+0x1370>
ffffffffc02058f4:	b91fa0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc02058f8:	00003697          	auipc	a3,0x3
ffffffffc02058fc:	f8068693          	addi	a3,a3,-128 # ffffffffc0208878 <default_pmm_manager+0x1220>
ffffffffc0205900:	00001617          	auipc	a2,0x1
ffffffffc0205904:	48060613          	addi	a2,a2,1152 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0205908:	36b00593          	li	a1,875
ffffffffc020590c:	00003517          	auipc	a0,0x3
ffffffffc0205910:	0bc50513          	addi	a0,a0,188 # ffffffffc02089c8 <default_pmm_manager+0x1370>
ffffffffc0205914:	b71fa0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc0205918:	00003697          	auipc	a3,0x3
ffffffffc020591c:	f3068693          	addi	a3,a3,-208 # ffffffffc0208848 <default_pmm_manager+0x11f0>
ffffffffc0205920:	00001617          	auipc	a2,0x1
ffffffffc0205924:	46060613          	addi	a2,a2,1120 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0205928:	36a00593          	li	a1,874
ffffffffc020592c:	00003517          	auipc	a0,0x3
ffffffffc0205930:	09c50513          	addi	a0,a0,156 # ffffffffc02089c8 <default_pmm_manager+0x1370>
ffffffffc0205934:	b51fa0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(nr_process == 2);
ffffffffc0205938:	00003697          	auipc	a3,0x3
ffffffffc020593c:	f0068693          	addi	a3,a3,-256 # ffffffffc0208838 <default_pmm_manager+0x11e0>
ffffffffc0205940:	00001617          	auipc	a2,0x1
ffffffffc0205944:	44060613          	addi	a2,a2,1088 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0205948:	36900593          	li	a1,873
ffffffffc020594c:	00003517          	auipc	a0,0x3
ffffffffc0205950:	07c50513          	addi	a0,a0,124 # ffffffffc02089c8 <default_pmm_manager+0x1370>
ffffffffc0205954:	b31fa0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0205958 <do_execve>:
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc0205958:	7171                	addi	sp,sp,-176
ffffffffc020595a:	fcd6                	sd	s5,120(sp)
    struct mm_struct *mm = current->mm;
ffffffffc020595c:	000a7a97          	auipc	s5,0xa7
ffffffffc0205960:	b34a8a93          	addi	s5,s5,-1228 # ffffffffc02ac490 <current>
ffffffffc0205964:	000ab783          	ld	a5,0(s5)
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc0205968:	ed26                	sd	s1,152(sp)
ffffffffc020596a:	f122                	sd	s0,160(sp)
    struct mm_struct *mm = current->mm;
ffffffffc020596c:	7784                	ld	s1,40(a5)
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc020596e:	e54e                	sd	s3,136(sp)
ffffffffc0205970:	f4de                	sd	s7,104(sp)
ffffffffc0205972:	89aa                	mv	s3,a0
ffffffffc0205974:	842e                	mv	s0,a1
ffffffffc0205976:	8bb2                	mv	s7,a2
    if (!user_mem_check(mm, (uintptr_t)name, len, 0)) {
ffffffffc0205978:	4681                	li	a3,0
ffffffffc020597a:	862e                	mv	a2,a1
ffffffffc020597c:	85aa                	mv	a1,a0
ffffffffc020597e:	8526                	mv	a0,s1
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc0205980:	f506                	sd	ra,168(sp)
ffffffffc0205982:	e94a                	sd	s2,144(sp)
ffffffffc0205984:	e152                	sd	s4,128(sp)
ffffffffc0205986:	f8da                	sd	s6,112(sp)
ffffffffc0205988:	f0e2                	sd	s8,96(sp)
ffffffffc020598a:	ece6                	sd	s9,88(sp)
ffffffffc020598c:	e8ea                	sd	s10,80(sp)
ffffffffc020598e:	e4ee                	sd	s11,72(sp)
    if (!user_mem_check(mm, (uintptr_t)name, len, 0)) {
ffffffffc0205990:	bc6ff0ef          	jal	ra,ffffffffc0204d56 <user_mem_check>
ffffffffc0205994:	40050463          	beqz	a0,ffffffffc0205d9c <do_execve+0x444>
    memset(local_name, 0, sizeof(local_name));
ffffffffc0205998:	4641                	li	a2,16
ffffffffc020599a:	4581                	li	a1,0
ffffffffc020599c:	1808                	addi	a0,sp,48
ffffffffc020599e:	5c5000ef          	jal	ra,ffffffffc0206762 <memset>
    memcpy(local_name, name, len);
ffffffffc02059a2:	47bd                	li	a5,15
ffffffffc02059a4:	8622                	mv	a2,s0
ffffffffc02059a6:	1c87e663          	bltu	a5,s0,ffffffffc0205b72 <do_execve+0x21a>
ffffffffc02059aa:	85ce                	mv	a1,s3
ffffffffc02059ac:	1808                	addi	a0,sp,48
ffffffffc02059ae:	5c7000ef          	jal	ra,ffffffffc0206774 <memcpy>
    if (mm != NULL) {
ffffffffc02059b2:	1c048763          	beqz	s1,ffffffffc0205b80 <do_execve+0x228>
        cputs("mm != NULL");
ffffffffc02059b6:	00002517          	auipc	a0,0x2
ffffffffc02059ba:	37250513          	addi	a0,a0,882 # ffffffffc0207d28 <default_pmm_manager+0x6d0>
ffffffffc02059be:	809fa0ef          	jal	ra,ffffffffc02001c6 <cputs>
        lcr3(boot_cr3);
ffffffffc02059c2:	000a7797          	auipc	a5,0xa7
ffffffffc02059c6:	b1e78793          	addi	a5,a5,-1250 # ffffffffc02ac4e0 <boot_cr3>
ffffffffc02059ca:	639c                	ld	a5,0(a5)
ffffffffc02059cc:	577d                	li	a4,-1
ffffffffc02059ce:	177e                	slli	a4,a4,0x3f
ffffffffc02059d0:	83b1                	srli	a5,a5,0xc
ffffffffc02059d2:	8fd9                	or	a5,a5,a4
ffffffffc02059d4:	18079073          	csrw	satp,a5
ffffffffc02059d8:	589c                	lw	a5,48(s1)
ffffffffc02059da:	fff7871b          	addiw	a4,a5,-1
ffffffffc02059de:	d898                	sw	a4,48(s1)
        if (mm_count_dec(mm) == 0) {
ffffffffc02059e0:	2a070863          	beqz	a4,ffffffffc0205c90 <do_execve+0x338>
        current->mm = NULL;
ffffffffc02059e4:	000ab783          	ld	a5,0(s5)
ffffffffc02059e8:	0207b423          	sd	zero,40(a5)
    if ((mm = mm_create()) == NULL) {
ffffffffc02059ec:	9f9fe0ef          	jal	ra,ffffffffc02043e4 <mm_create>
ffffffffc02059f0:	84aa                	mv	s1,a0
ffffffffc02059f2:	1c050263          	beqz	a0,ffffffffc0205bb6 <do_execve+0x25e>
    if ((page = alloc_page()) == NULL) {
ffffffffc02059f6:	4505                	li	a0,1
ffffffffc02059f8:	9adfc0ef          	jal	ra,ffffffffc02023a4 <alloc_pages>
ffffffffc02059fc:	3a050263          	beqz	a0,ffffffffc0205da0 <do_execve+0x448>
    return page - pages + nbase;
ffffffffc0205a00:	000a7c17          	auipc	s8,0xa7
ffffffffc0205a04:	ae8c0c13          	addi	s8,s8,-1304 # ffffffffc02ac4e8 <pages>
ffffffffc0205a08:	000c3683          	ld	a3,0(s8)
ffffffffc0205a0c:	00003797          	auipc	a5,0x3
ffffffffc0205a10:	48478793          	addi	a5,a5,1156 # ffffffffc0208e90 <nbase>
ffffffffc0205a14:	6398                	ld	a4,0(a5)
ffffffffc0205a16:	40d506b3          	sub	a3,a0,a3
    return KADDR(page2pa(page));
ffffffffc0205a1a:	000a7c97          	auipc	s9,0xa7
ffffffffc0205a1e:	a5ec8c93          	addi	s9,s9,-1442 # ffffffffc02ac478 <npage>
    return page - pages + nbase;
ffffffffc0205a22:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0205a24:	5a7d                	li	s4,-1
ffffffffc0205a26:	000cb783          	ld	a5,0(s9)
    return page - pages + nbase;
ffffffffc0205a2a:	96ba                	add	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc0205a2c:	00ca5a13          	srli	s4,s4,0xc
    return page - pages + nbase;
ffffffffc0205a30:	e43a                	sd	a4,8(sp)
    return KADDR(page2pa(page));
ffffffffc0205a32:	0146f733          	and	a4,a3,s4
    return page2ppn(page) << PGSHIFT;
ffffffffc0205a36:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205a38:	36f77863          	bleu	a5,a4,ffffffffc0205da8 <do_execve+0x450>
ffffffffc0205a3c:	000a7997          	auipc	s3,0xa7
ffffffffc0205a40:	a9c98993          	addi	s3,s3,-1380 # ffffffffc02ac4d8 <va_pa_offset>
ffffffffc0205a44:	0009b403          	ld	s0,0(s3)
    memcpy(pgdir, boot_pgdir, PGSIZE);
ffffffffc0205a48:	000a7797          	auipc	a5,0xa7
ffffffffc0205a4c:	a2878793          	addi	a5,a5,-1496 # ffffffffc02ac470 <boot_pgdir>
ffffffffc0205a50:	638c                	ld	a1,0(a5)
ffffffffc0205a52:	9436                	add	s0,s0,a3
ffffffffc0205a54:	6605                	lui	a2,0x1
ffffffffc0205a56:	8522                	mv	a0,s0
ffffffffc0205a58:	51d000ef          	jal	ra,ffffffffc0206774 <memcpy>
    if (elf->e_magic != ELF_MAGIC) {
ffffffffc0205a5c:	000ba703          	lw	a4,0(s7)
ffffffffc0205a60:	464c47b7          	lui	a5,0x464c4
    mm->pgdir = pgdir;
ffffffffc0205a64:	ec80                	sd	s0,24(s1)
    if (elf->e_magic != ELF_MAGIC) {
ffffffffc0205a66:	57f78793          	addi	a5,a5,1407 # 464c457f <_binary_obj___user_exit_out_size+0x464b9aff>
ffffffffc0205a6a:	12f71c63          	bne	a4,a5,ffffffffc0205ba2 <do_execve+0x24a>
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0205a6e:	038bd703          	lhu	a4,56(s7)
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc0205a72:	020bb403          	ld	s0,32(s7)
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0205a76:	00371793          	slli	a5,a4,0x3
ffffffffc0205a7a:	8f99                	sub	a5,a5,a4
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc0205a7c:	945e                	add	s0,s0,s7
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0205a7e:	078e                	slli	a5,a5,0x3
ffffffffc0205a80:	97a2                	add	a5,a5,s0
ffffffffc0205a82:	f43e                	sd	a5,40(sp)
    for (; ph < ph_end; ph ++) {
ffffffffc0205a84:	00f47c63          	bleu	a5,s0,ffffffffc0205a9c <do_execve+0x144>
ffffffffc0205a88:	ec52                	sd	s4,24(sp)
        if (ph->p_type != ELF_PT_LOAD) {
ffffffffc0205a8a:	401c                	lw	a5,0(s0)
ffffffffc0205a8c:	4705                	li	a4,1
ffffffffc0205a8e:	12e78663          	beq	a5,a4,ffffffffc0205bba <do_execve+0x262>
    for (; ph < ph_end; ph ++) {
ffffffffc0205a92:	77a2                	ld	a5,40(sp)
ffffffffc0205a94:	03840413          	addi	s0,s0,56
ffffffffc0205a98:	fef469e3          	bltu	s0,a5,ffffffffc0205a8a <do_execve+0x132>
    if ((ret = mm_map(mm, USTACKTOP - USTACKSIZE, USTACKSIZE, vm_flags, NULL)) != 0) {
ffffffffc0205a9c:	4701                	li	a4,0
ffffffffc0205a9e:	46ad                	li	a3,11
ffffffffc0205aa0:	00100637          	lui	a2,0x100
ffffffffc0205aa4:	7ff005b7          	lui	a1,0x7ff00
ffffffffc0205aa8:	8526                	mv	a0,s1
ffffffffc0205aaa:	b13fe0ef          	jal	ra,ffffffffc02045bc <mm_map>
ffffffffc0205aae:	8a2a                	mv	s4,a0
ffffffffc0205ab0:	1c051663          	bnez	a0,ffffffffc0205c7c <do_execve+0x324>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
ffffffffc0205ab4:	6c88                	ld	a0,24(s1)
ffffffffc0205ab6:	467d                	li	a2,31
ffffffffc0205ab8:	7ffff5b7          	lui	a1,0x7ffff
ffffffffc0205abc:	b5bfd0ef          	jal	ra,ffffffffc0203616 <pgdir_alloc_page>
ffffffffc0205ac0:	36050c63          	beqz	a0,ffffffffc0205e38 <do_execve+0x4e0>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
ffffffffc0205ac4:	6c88                	ld	a0,24(s1)
ffffffffc0205ac6:	467d                	li	a2,31
ffffffffc0205ac8:	7fffe5b7          	lui	a1,0x7fffe
ffffffffc0205acc:	b4bfd0ef          	jal	ra,ffffffffc0203616 <pgdir_alloc_page>
ffffffffc0205ad0:	34050463          	beqz	a0,ffffffffc0205e18 <do_execve+0x4c0>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
ffffffffc0205ad4:	6c88                	ld	a0,24(s1)
ffffffffc0205ad6:	467d                	li	a2,31
ffffffffc0205ad8:	7fffd5b7          	lui	a1,0x7fffd
ffffffffc0205adc:	b3bfd0ef          	jal	ra,ffffffffc0203616 <pgdir_alloc_page>
ffffffffc0205ae0:	30050c63          	beqz	a0,ffffffffc0205df8 <do_execve+0x4a0>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
ffffffffc0205ae4:	6c88                	ld	a0,24(s1)
ffffffffc0205ae6:	467d                	li	a2,31
ffffffffc0205ae8:	7fffc5b7          	lui	a1,0x7fffc
ffffffffc0205aec:	b2bfd0ef          	jal	ra,ffffffffc0203616 <pgdir_alloc_page>
ffffffffc0205af0:	2e050463          	beqz	a0,ffffffffc0205dd8 <do_execve+0x480>
    mm->mm_count += 1;
ffffffffc0205af4:	589c                	lw	a5,48(s1)
    current->mm = mm;
ffffffffc0205af6:	000ab603          	ld	a2,0(s5)
    current->cr3 = PADDR(mm->pgdir);
ffffffffc0205afa:	6c94                	ld	a3,24(s1)
ffffffffc0205afc:	2785                	addiw	a5,a5,1
ffffffffc0205afe:	d89c                	sw	a5,48(s1)
    current->mm = mm;
ffffffffc0205b00:	f604                	sd	s1,40(a2)
    current->cr3 = PADDR(mm->pgdir);
ffffffffc0205b02:	c02007b7          	lui	a5,0xc0200
ffffffffc0205b06:	2af6ed63          	bltu	a3,a5,ffffffffc0205dc0 <do_execve+0x468>
ffffffffc0205b0a:	0009b783          	ld	a5,0(s3)
ffffffffc0205b0e:	577d                	li	a4,-1
ffffffffc0205b10:	177e                	slli	a4,a4,0x3f
ffffffffc0205b12:	8e9d                	sub	a3,a3,a5
ffffffffc0205b14:	00c6d793          	srli	a5,a3,0xc
ffffffffc0205b18:	f654                	sd	a3,168(a2)
ffffffffc0205b1a:	8fd9                	or	a5,a5,a4
ffffffffc0205b1c:	18079073          	csrw	satp,a5
    struct trapframe *tf = current->tf;
ffffffffc0205b20:	7240                	ld	s0,160(a2)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc0205b22:	4581                	li	a1,0
ffffffffc0205b24:	12000613          	li	a2,288
ffffffffc0205b28:	8522                	mv	a0,s0
    uintptr_t sstatus = tf->status;
ffffffffc0205b2a:	10043483          	ld	s1,256(s0)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc0205b2e:	435000ef          	jal	ra,ffffffffc0206762 <memset>
    tf->epc = elf->e_entry;
ffffffffc0205b32:	018bb703          	ld	a4,24(s7)
    tf->gpr.sp = USTACKTOP;
ffffffffc0205b36:	4785                	li	a5,1
    set_proc_name(current, local_name);
ffffffffc0205b38:	000ab503          	ld	a0,0(s5)
    tf->status = sstatus & ~(SSTATUS_SPP | SSTATUS_SPIE);
ffffffffc0205b3c:	edf4f493          	andi	s1,s1,-289
    tf->gpr.sp = USTACKTOP;
ffffffffc0205b40:	07fe                	slli	a5,a5,0x1f
ffffffffc0205b42:	e81c                	sd	a5,16(s0)
    tf->epc = elf->e_entry;
ffffffffc0205b44:	10e43423          	sd	a4,264(s0)
    tf->status = sstatus & ~(SSTATUS_SPP | SSTATUS_SPIE);
ffffffffc0205b48:	10943023          	sd	s1,256(s0)
    set_proc_name(current, local_name);
ffffffffc0205b4c:	180c                	addi	a1,sp,48
ffffffffc0205b4e:	d90ff0ef          	jal	ra,ffffffffc02050de <set_proc_name>
}
ffffffffc0205b52:	70aa                	ld	ra,168(sp)
ffffffffc0205b54:	740a                	ld	s0,160(sp)
ffffffffc0205b56:	8552                	mv	a0,s4
ffffffffc0205b58:	64ea                	ld	s1,152(sp)
ffffffffc0205b5a:	694a                	ld	s2,144(sp)
ffffffffc0205b5c:	69aa                	ld	s3,136(sp)
ffffffffc0205b5e:	6a0a                	ld	s4,128(sp)
ffffffffc0205b60:	7ae6                	ld	s5,120(sp)
ffffffffc0205b62:	7b46                	ld	s6,112(sp)
ffffffffc0205b64:	7ba6                	ld	s7,104(sp)
ffffffffc0205b66:	7c06                	ld	s8,96(sp)
ffffffffc0205b68:	6ce6                	ld	s9,88(sp)
ffffffffc0205b6a:	6d46                	ld	s10,80(sp)
ffffffffc0205b6c:	6da6                	ld	s11,72(sp)
ffffffffc0205b6e:	614d                	addi	sp,sp,176
ffffffffc0205b70:	8082                	ret
    memcpy(local_name, name, len);
ffffffffc0205b72:	463d                	li	a2,15
ffffffffc0205b74:	85ce                	mv	a1,s3
ffffffffc0205b76:	1808                	addi	a0,sp,48
ffffffffc0205b78:	3fd000ef          	jal	ra,ffffffffc0206774 <memcpy>
    if (mm != NULL) {
ffffffffc0205b7c:	e2049de3          	bnez	s1,ffffffffc02059b6 <do_execve+0x5e>
    if (current->mm != NULL) {
ffffffffc0205b80:	000ab783          	ld	a5,0(s5)
ffffffffc0205b84:	779c                	ld	a5,40(a5)
ffffffffc0205b86:	e60783e3          	beqz	a5,ffffffffc02059ec <do_execve+0x94>
        panic("load_icode: current->mm must be empty.\n");
ffffffffc0205b8a:	00003617          	auipc	a2,0x3
ffffffffc0205b8e:	a0e60613          	addi	a2,a2,-1522 # ffffffffc0208598 <default_pmm_manager+0xf40>
ffffffffc0205b92:	21200593          	li	a1,530
ffffffffc0205b96:	00003517          	auipc	a0,0x3
ffffffffc0205b9a:	e3250513          	addi	a0,a0,-462 # ffffffffc02089c8 <default_pmm_manager+0x1370>
ffffffffc0205b9e:	8e7fa0ef          	jal	ra,ffffffffc0200484 <__panic>
    put_pgdir(mm);
ffffffffc0205ba2:	8526                	mv	a0,s1
ffffffffc0205ba4:	cbcff0ef          	jal	ra,ffffffffc0205060 <put_pgdir>
    mm_destroy(mm);
ffffffffc0205ba8:	8526                	mv	a0,s1
ffffffffc0205baa:	9c1fe0ef          	jal	ra,ffffffffc020456a <mm_destroy>
        ret = -E_INVAL_ELF;
ffffffffc0205bae:	5a61                	li	s4,-8
    do_exit(ret);
ffffffffc0205bb0:	8552                	mv	a0,s4
ffffffffc0205bb2:	989ff0ef          	jal	ra,ffffffffc020553a <do_exit>
    int ret = -E_NO_MEM;
ffffffffc0205bb6:	5a71                	li	s4,-4
ffffffffc0205bb8:	bfe5                	j	ffffffffc0205bb0 <do_execve+0x258>
        if (ph->p_filesz > ph->p_memsz) {
ffffffffc0205bba:	7410                	ld	a2,40(s0)
ffffffffc0205bbc:	701c                	ld	a5,32(s0)
ffffffffc0205bbe:	1ef66363          	bltu	a2,a5,ffffffffc0205da4 <do_execve+0x44c>
        if (ph->p_flags & ELF_PF_X) vm_flags |= VM_EXEC;
ffffffffc0205bc2:	405c                	lw	a5,4(s0)
ffffffffc0205bc4:	0017f693          	andi	a3,a5,1
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205bc8:	0027f713          	andi	a4,a5,2
        if (ph->p_flags & ELF_PF_X) vm_flags |= VM_EXEC;
ffffffffc0205bcc:	068a                	slli	a3,a3,0x2
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205bce:	eb79                	bnez	a4,ffffffffc0205ca4 <do_execve+0x34c>
        vm_flags = 0, perm = PTE_U | PTE_V;
ffffffffc0205bd0:	4745                	li	a4,17
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205bd2:	8b91                	andi	a5,a5,4
        vm_flags = 0, perm = PTE_U | PTE_V;
ffffffffc0205bd4:	e83a                	sd	a4,16(sp)
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205bd6:	c789                	beqz	a5,ffffffffc0205be0 <do_execve+0x288>
        if (vm_flags & VM_READ) perm |= PTE_R;
ffffffffc0205bd8:	47cd                	li	a5,19
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205bda:	0016e693          	ori	a3,a3,1
        if (vm_flags & VM_READ) perm |= PTE_R;
ffffffffc0205bde:	e83e                	sd	a5,16(sp)
        if (vm_flags & VM_WRITE) perm |= (PTE_W | PTE_R);
ffffffffc0205be0:	0026f793          	andi	a5,a3,2
ffffffffc0205be4:	e7e9                	bnez	a5,ffffffffc0205cae <do_execve+0x356>
        if (vm_flags & VM_EXEC) perm |= PTE_X;
ffffffffc0205be6:	0046f793          	andi	a5,a3,4
ffffffffc0205bea:	c789                	beqz	a5,ffffffffc0205bf4 <do_execve+0x29c>
ffffffffc0205bec:	67c2                	ld	a5,16(sp)
ffffffffc0205bee:	0087e793          	ori	a5,a5,8
ffffffffc0205bf2:	e83e                	sd	a5,16(sp)
        if ((ret = mm_map(mm, ph->p_va, ph->p_memsz, vm_flags, NULL)) != 0) {
ffffffffc0205bf4:	680c                	ld	a1,16(s0)
ffffffffc0205bf6:	4701                	li	a4,0
ffffffffc0205bf8:	8526                	mv	a0,s1
ffffffffc0205bfa:	9c3fe0ef          	jal	ra,ffffffffc02045bc <mm_map>
ffffffffc0205bfe:	8a2a                	mv	s4,a0
ffffffffc0205c00:	ed35                	bnez	a0,ffffffffc0205c7c <do_execve+0x324>
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0205c02:	01043d83          	ld	s11,16(s0)
        end = ph->p_va + ph->p_filesz;
ffffffffc0205c06:	02043a03          	ld	s4,32(s0)
        unsigned char *from = binary + ph->p_offset;
ffffffffc0205c0a:	00843b03          	ld	s6,8(s0)
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0205c0e:	77fd                	lui	a5,0xfffff
        end = ph->p_va + ph->p_filesz;
ffffffffc0205c10:	9a6e                	add	s4,s4,s11
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0205c12:	00fdfd33          	and	s10,s11,a5
        unsigned char *from = binary + ph->p_offset;
ffffffffc0205c16:	9b5e                	add	s6,s6,s7
        while (start < end) {
ffffffffc0205c18:	054dea63          	bltu	s11,s4,ffffffffc0205c6c <do_execve+0x314>
ffffffffc0205c1c:	aab5                	j	ffffffffc0205d98 <do_execve+0x440>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0205c1e:	6785                	lui	a5,0x1
ffffffffc0205c20:	41ad8533          	sub	a0,s11,s10
ffffffffc0205c24:	9d3e                	add	s10,s10,a5
ffffffffc0205c26:	41bd0833          	sub	a6,s10,s11
            if (end < la) {
ffffffffc0205c2a:	01aa7463          	bleu	s10,s4,ffffffffc0205c32 <do_execve+0x2da>
                size -= la - end;
ffffffffc0205c2e:	41ba0833          	sub	a6,s4,s11
    return page - pages + nbase;
ffffffffc0205c32:	000c3683          	ld	a3,0(s8)
ffffffffc0205c36:	67a2                	ld	a5,8(sp)
    return KADDR(page2pa(page));
ffffffffc0205c38:	000cb603          	ld	a2,0(s9)
    return page - pages + nbase;
ffffffffc0205c3c:	40d906b3          	sub	a3,s2,a3
ffffffffc0205c40:	8699                	srai	a3,a3,0x6
ffffffffc0205c42:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0205c44:	67e2                	ld	a5,24(sp)
ffffffffc0205c46:	00f6f5b3          	and	a1,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205c4a:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205c4c:	14c5fe63          	bleu	a2,a1,ffffffffc0205da8 <do_execve+0x450>
ffffffffc0205c50:	0009b883          	ld	a7,0(s3)
            memcpy(page2kva(page) + off, from, size);
ffffffffc0205c54:	85da                	mv	a1,s6
ffffffffc0205c56:	8642                	mv	a2,a6
ffffffffc0205c58:	96c6                	add	a3,a3,a7
ffffffffc0205c5a:	9536                	add	a0,a0,a3
            start += size, from += size;
ffffffffc0205c5c:	9dc2                	add	s11,s11,a6
ffffffffc0205c5e:	f042                	sd	a6,32(sp)
            memcpy(page2kva(page) + off, from, size);
ffffffffc0205c60:	315000ef          	jal	ra,ffffffffc0206774 <memcpy>
            start += size, from += size;
ffffffffc0205c64:	7802                	ld	a6,32(sp)
ffffffffc0205c66:	9b42                	add	s6,s6,a6
        while (start < end) {
ffffffffc0205c68:	054df663          	bleu	s4,s11,ffffffffc0205cb4 <do_execve+0x35c>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
ffffffffc0205c6c:	6c88                	ld	a0,24(s1)
ffffffffc0205c6e:	6642                	ld	a2,16(sp)
ffffffffc0205c70:	85ea                	mv	a1,s10
ffffffffc0205c72:	9a5fd0ef          	jal	ra,ffffffffc0203616 <pgdir_alloc_page>
ffffffffc0205c76:	892a                	mv	s2,a0
ffffffffc0205c78:	f15d                	bnez	a0,ffffffffc0205c1e <do_execve+0x2c6>
        ret = -E_NO_MEM;
ffffffffc0205c7a:	5a71                	li	s4,-4
    exit_mmap(mm);
ffffffffc0205c7c:	8526                	mv	a0,s1
ffffffffc0205c7e:	9f1fe0ef          	jal	ra,ffffffffc020466e <exit_mmap>
    put_pgdir(mm);
ffffffffc0205c82:	8526                	mv	a0,s1
ffffffffc0205c84:	bdcff0ef          	jal	ra,ffffffffc0205060 <put_pgdir>
    mm_destroy(mm);
ffffffffc0205c88:	8526                	mv	a0,s1
ffffffffc0205c8a:	8e1fe0ef          	jal	ra,ffffffffc020456a <mm_destroy>
    return ret;
ffffffffc0205c8e:	b70d                	j	ffffffffc0205bb0 <do_execve+0x258>
            exit_mmap(mm);
ffffffffc0205c90:	8526                	mv	a0,s1
ffffffffc0205c92:	9ddfe0ef          	jal	ra,ffffffffc020466e <exit_mmap>
            put_pgdir(mm);
ffffffffc0205c96:	8526                	mv	a0,s1
ffffffffc0205c98:	bc8ff0ef          	jal	ra,ffffffffc0205060 <put_pgdir>
            mm_destroy(mm);
ffffffffc0205c9c:	8526                	mv	a0,s1
ffffffffc0205c9e:	8cdfe0ef          	jal	ra,ffffffffc020456a <mm_destroy>
ffffffffc0205ca2:	b389                	j	ffffffffc02059e4 <do_execve+0x8c>
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205ca4:	0026e693          	ori	a3,a3,2
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205ca8:	8b91                	andi	a5,a5,4
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205caa:	2681                	sext.w	a3,a3
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205cac:	f795                	bnez	a5,ffffffffc0205bd8 <do_execve+0x280>
        if (vm_flags & VM_WRITE) perm |= (PTE_W | PTE_R);
ffffffffc0205cae:	47dd                	li	a5,23
ffffffffc0205cb0:	e83e                	sd	a5,16(sp)
ffffffffc0205cb2:	bf15                	j	ffffffffc0205be6 <do_execve+0x28e>
ffffffffc0205cb4:	01043a03          	ld	s4,16(s0)
        end = ph->p_va + ph->p_memsz;
ffffffffc0205cb8:	7414                	ld	a3,40(s0)
ffffffffc0205cba:	9a36                	add	s4,s4,a3
        if (start < la) {
ffffffffc0205cbc:	07adfd63          	bleu	s10,s11,ffffffffc0205d36 <do_execve+0x3de>
            if (start == end) {
ffffffffc0205cc0:	ddba09e3          	beq	s4,s11,ffffffffc0205a92 <do_execve+0x13a>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0205cc4:	6785                	lui	a5,0x1
ffffffffc0205cc6:	00fd8533          	add	a0,s11,a5
ffffffffc0205cca:	41a50533          	sub	a0,a0,s10
                size -= la - end;
ffffffffc0205cce:	41ba0b33          	sub	s6,s4,s11
            if (end < la) {
ffffffffc0205cd2:	0daa7063          	bleu	s10,s4,ffffffffc0205d92 <do_execve+0x43a>
    return page - pages + nbase;
ffffffffc0205cd6:	000c3683          	ld	a3,0(s8)
ffffffffc0205cda:	67a2                	ld	a5,8(sp)
    return KADDR(page2pa(page));
ffffffffc0205cdc:	000cb603          	ld	a2,0(s9)
    return page - pages + nbase;
ffffffffc0205ce0:	40d906b3          	sub	a3,s2,a3
ffffffffc0205ce4:	8699                	srai	a3,a3,0x6
ffffffffc0205ce6:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0205ce8:	67e2                	ld	a5,24(sp)
ffffffffc0205cea:	00f6f5b3          	and	a1,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205cee:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205cf0:	0ac5fc63          	bleu	a2,a1,ffffffffc0205da8 <do_execve+0x450>
ffffffffc0205cf4:	0009b803          	ld	a6,0(s3)
            memset(page2kva(page) + off, 0, size);
ffffffffc0205cf8:	865a                	mv	a2,s6
ffffffffc0205cfa:	4581                	li	a1,0
ffffffffc0205cfc:	96c2                	add	a3,a3,a6
ffffffffc0205cfe:	9536                	add	a0,a0,a3
ffffffffc0205d00:	263000ef          	jal	ra,ffffffffc0206762 <memset>
            start += size;
ffffffffc0205d04:	01bb07b3          	add	a5,s6,s11
            assert((end < la && start == end) || (end >= la && start == la));
ffffffffc0205d08:	03aa7463          	bleu	s10,s4,ffffffffc0205d30 <do_execve+0x3d8>
ffffffffc0205d0c:	d8fa03e3          	beq	s4,a5,ffffffffc0205a92 <do_execve+0x13a>
ffffffffc0205d10:	00003697          	auipc	a3,0x3
ffffffffc0205d14:	8b068693          	addi	a3,a3,-1872 # ffffffffc02085c0 <default_pmm_manager+0xf68>
ffffffffc0205d18:	00001617          	auipc	a2,0x1
ffffffffc0205d1c:	06860613          	addi	a2,a2,104 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0205d20:	26700593          	li	a1,615
ffffffffc0205d24:	00003517          	auipc	a0,0x3
ffffffffc0205d28:	ca450513          	addi	a0,a0,-860 # ffffffffc02089c8 <default_pmm_manager+0x1370>
ffffffffc0205d2c:	f58fa0ef          	jal	ra,ffffffffc0200484 <__panic>
ffffffffc0205d30:	ffa790e3          	bne	a5,s10,ffffffffc0205d10 <do_execve+0x3b8>
ffffffffc0205d34:	8dea                	mv	s11,s10
        while (start < end) {
ffffffffc0205d36:	054de663          	bltu	s11,s4,ffffffffc0205d82 <do_execve+0x42a>
ffffffffc0205d3a:	bba1                	j	ffffffffc0205a92 <do_execve+0x13a>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0205d3c:	6785                	lui	a5,0x1
ffffffffc0205d3e:	41ad8533          	sub	a0,s11,s10
ffffffffc0205d42:	9d3e                	add	s10,s10,a5
ffffffffc0205d44:	41bd0633          	sub	a2,s10,s11
            if (end < la) {
ffffffffc0205d48:	01aa7463          	bleu	s10,s4,ffffffffc0205d50 <do_execve+0x3f8>
                size -= la - end;
ffffffffc0205d4c:	41ba0633          	sub	a2,s4,s11
    return page - pages + nbase;
ffffffffc0205d50:	000c3683          	ld	a3,0(s8)
ffffffffc0205d54:	67a2                	ld	a5,8(sp)
    return KADDR(page2pa(page));
ffffffffc0205d56:	000cb583          	ld	a1,0(s9)
    return page - pages + nbase;
ffffffffc0205d5a:	40d906b3          	sub	a3,s2,a3
ffffffffc0205d5e:	8699                	srai	a3,a3,0x6
ffffffffc0205d60:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0205d62:	67e2                	ld	a5,24(sp)
ffffffffc0205d64:	00f6f833          	and	a6,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205d68:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205d6a:	02b87f63          	bleu	a1,a6,ffffffffc0205da8 <do_execve+0x450>
ffffffffc0205d6e:	0009b803          	ld	a6,0(s3)
            start += size;
ffffffffc0205d72:	9db2                	add	s11,s11,a2
            memset(page2kva(page) + off, 0, size);
ffffffffc0205d74:	4581                	li	a1,0
ffffffffc0205d76:	96c2                	add	a3,a3,a6
ffffffffc0205d78:	9536                	add	a0,a0,a3
ffffffffc0205d7a:	1e9000ef          	jal	ra,ffffffffc0206762 <memset>
        while (start < end) {
ffffffffc0205d7e:	d14dfae3          	bleu	s4,s11,ffffffffc0205a92 <do_execve+0x13a>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
ffffffffc0205d82:	6c88                	ld	a0,24(s1)
ffffffffc0205d84:	6642                	ld	a2,16(sp)
ffffffffc0205d86:	85ea                	mv	a1,s10
ffffffffc0205d88:	88ffd0ef          	jal	ra,ffffffffc0203616 <pgdir_alloc_page>
ffffffffc0205d8c:	892a                	mv	s2,a0
ffffffffc0205d8e:	f55d                	bnez	a0,ffffffffc0205d3c <do_execve+0x3e4>
ffffffffc0205d90:	b5ed                	j	ffffffffc0205c7a <do_execve+0x322>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0205d92:	41bd0b33          	sub	s6,s10,s11
ffffffffc0205d96:	b781                	j	ffffffffc0205cd6 <do_execve+0x37e>
        while (start < end) {
ffffffffc0205d98:	8a6e                	mv	s4,s11
ffffffffc0205d9a:	bf39                	j	ffffffffc0205cb8 <do_execve+0x360>
        return -E_INVAL;
ffffffffc0205d9c:	5a75                	li	s4,-3
ffffffffc0205d9e:	bb55                	j	ffffffffc0205b52 <do_execve+0x1fa>
    int ret = -E_NO_MEM;
ffffffffc0205da0:	5a71                	li	s4,-4
ffffffffc0205da2:	b5dd                	j	ffffffffc0205c88 <do_execve+0x330>
            ret = -E_INVAL_ELF;
ffffffffc0205da4:	5a61                	li	s4,-8
ffffffffc0205da6:	bdd9                	j	ffffffffc0205c7c <do_execve+0x324>
ffffffffc0205da8:	00001617          	auipc	a2,0x1
ffffffffc0205dac:	39060613          	addi	a2,a2,912 # ffffffffc0207138 <commands+0x878>
ffffffffc0205db0:	06a00593          	li	a1,106
ffffffffc0205db4:	00001517          	auipc	a0,0x1
ffffffffc0205db8:	49450513          	addi	a0,a0,1172 # ffffffffc0207248 <commands+0x988>
ffffffffc0205dbc:	ec8fa0ef          	jal	ra,ffffffffc0200484 <__panic>
    current->cr3 = PADDR(mm->pgdir);
ffffffffc0205dc0:	00001617          	auipc	a2,0x1
ffffffffc0205dc4:	3c860613          	addi	a2,a2,968 # ffffffffc0207188 <commands+0x8c8>
ffffffffc0205dc8:	28200593          	li	a1,642
ffffffffc0205dcc:	00003517          	auipc	a0,0x3
ffffffffc0205dd0:	bfc50513          	addi	a0,a0,-1028 # ffffffffc02089c8 <default_pmm_manager+0x1370>
ffffffffc0205dd4:	eb0fa0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
ffffffffc0205dd8:	00003697          	auipc	a3,0x3
ffffffffc0205ddc:	90068693          	addi	a3,a3,-1792 # ffffffffc02086d8 <default_pmm_manager+0x1080>
ffffffffc0205de0:	00001617          	auipc	a2,0x1
ffffffffc0205de4:	fa060613          	addi	a2,a2,-96 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0205de8:	27d00593          	li	a1,637
ffffffffc0205dec:	00003517          	auipc	a0,0x3
ffffffffc0205df0:	bdc50513          	addi	a0,a0,-1060 # ffffffffc02089c8 <default_pmm_manager+0x1370>
ffffffffc0205df4:	e90fa0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
ffffffffc0205df8:	00003697          	auipc	a3,0x3
ffffffffc0205dfc:	89868693          	addi	a3,a3,-1896 # ffffffffc0208690 <default_pmm_manager+0x1038>
ffffffffc0205e00:	00001617          	auipc	a2,0x1
ffffffffc0205e04:	f8060613          	addi	a2,a2,-128 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0205e08:	27c00593          	li	a1,636
ffffffffc0205e0c:	00003517          	auipc	a0,0x3
ffffffffc0205e10:	bbc50513          	addi	a0,a0,-1092 # ffffffffc02089c8 <default_pmm_manager+0x1370>
ffffffffc0205e14:	e70fa0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
ffffffffc0205e18:	00003697          	auipc	a3,0x3
ffffffffc0205e1c:	83068693          	addi	a3,a3,-2000 # ffffffffc0208648 <default_pmm_manager+0xff0>
ffffffffc0205e20:	00001617          	auipc	a2,0x1
ffffffffc0205e24:	f6060613          	addi	a2,a2,-160 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0205e28:	27b00593          	li	a1,635
ffffffffc0205e2c:	00003517          	auipc	a0,0x3
ffffffffc0205e30:	b9c50513          	addi	a0,a0,-1124 # ffffffffc02089c8 <default_pmm_manager+0x1370>
ffffffffc0205e34:	e50fa0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
ffffffffc0205e38:	00002697          	auipc	a3,0x2
ffffffffc0205e3c:	7c868693          	addi	a3,a3,1992 # ffffffffc0208600 <default_pmm_manager+0xfa8>
ffffffffc0205e40:	00001617          	auipc	a2,0x1
ffffffffc0205e44:	f4060613          	addi	a2,a2,-192 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0205e48:	27a00593          	li	a1,634
ffffffffc0205e4c:	00003517          	auipc	a0,0x3
ffffffffc0205e50:	b7c50513          	addi	a0,a0,-1156 # ffffffffc02089c8 <default_pmm_manager+0x1370>
ffffffffc0205e54:	e30fa0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc0205e58 <do_yield>:
    current->need_resched = 1;
ffffffffc0205e58:	000a6797          	auipc	a5,0xa6
ffffffffc0205e5c:	63878793          	addi	a5,a5,1592 # ffffffffc02ac490 <current>
ffffffffc0205e60:	639c                	ld	a5,0(a5)
ffffffffc0205e62:	4705                	li	a4,1
}
ffffffffc0205e64:	4501                	li	a0,0
    current->need_resched = 1;
ffffffffc0205e66:	ef98                	sd	a4,24(a5)
}
ffffffffc0205e68:	8082                	ret

ffffffffc0205e6a <do_wait>:
do_wait(int pid, int *code_store) {
ffffffffc0205e6a:	1101                	addi	sp,sp,-32
ffffffffc0205e6c:	e822                	sd	s0,16(sp)
ffffffffc0205e6e:	e426                	sd	s1,8(sp)
ffffffffc0205e70:	ec06                	sd	ra,24(sp)
ffffffffc0205e72:	842e                	mv	s0,a1
ffffffffc0205e74:	84aa                	mv	s1,a0
    if (code_store != NULL) {
ffffffffc0205e76:	cd81                	beqz	a1,ffffffffc0205e8e <do_wait+0x24>
    struct mm_struct *mm = current->mm;
ffffffffc0205e78:	000a6797          	auipc	a5,0xa6
ffffffffc0205e7c:	61878793          	addi	a5,a5,1560 # ffffffffc02ac490 <current>
ffffffffc0205e80:	639c                	ld	a5,0(a5)
        if (!user_mem_check(mm, (uintptr_t)code_store, sizeof(int), 1)) {
ffffffffc0205e82:	4685                	li	a3,1
ffffffffc0205e84:	4611                	li	a2,4
ffffffffc0205e86:	7788                	ld	a0,40(a5)
ffffffffc0205e88:	ecffe0ef          	jal	ra,ffffffffc0204d56 <user_mem_check>
ffffffffc0205e8c:	c909                	beqz	a0,ffffffffc0205e9e <do_wait+0x34>
ffffffffc0205e8e:	85a2                	mv	a1,s0
}
ffffffffc0205e90:	6442                	ld	s0,16(sp)
ffffffffc0205e92:	60e2                	ld	ra,24(sp)
ffffffffc0205e94:	8526                	mv	a0,s1
ffffffffc0205e96:	64a2                	ld	s1,8(sp)
ffffffffc0205e98:	6105                	addi	sp,sp,32
ffffffffc0205e9a:	feeff06f          	j	ffffffffc0205688 <do_wait.part.1>
ffffffffc0205e9e:	60e2                	ld	ra,24(sp)
ffffffffc0205ea0:	6442                	ld	s0,16(sp)
ffffffffc0205ea2:	64a2                	ld	s1,8(sp)
ffffffffc0205ea4:	5575                	li	a0,-3
ffffffffc0205ea6:	6105                	addi	sp,sp,32
ffffffffc0205ea8:	8082                	ret

ffffffffc0205eaa <do_kill>:
do_kill(int pid) {
ffffffffc0205eaa:	1141                	addi	sp,sp,-16
ffffffffc0205eac:	e406                	sd	ra,8(sp)
ffffffffc0205eae:	e022                	sd	s0,0(sp)
    if ((proc = find_proc(pid)) != NULL) {
ffffffffc0205eb0:	ac4ff0ef          	jal	ra,ffffffffc0205174 <find_proc>
ffffffffc0205eb4:	cd0d                	beqz	a0,ffffffffc0205eee <do_kill+0x44>
        if (!(proc->flags & PF_EXITING)) {
ffffffffc0205eb6:	0b052703          	lw	a4,176(a0)
ffffffffc0205eba:	00177693          	andi	a3,a4,1
ffffffffc0205ebe:	e695                	bnez	a3,ffffffffc0205eea <do_kill+0x40>
            if (proc->wait_state & WT_INTERRUPTED) {
ffffffffc0205ec0:	0ec52683          	lw	a3,236(a0)
            proc->flags |= PF_EXITING;
ffffffffc0205ec4:	00176713          	ori	a4,a4,1
ffffffffc0205ec8:	0ae52823          	sw	a4,176(a0)
            return 0;
ffffffffc0205ecc:	4401                	li	s0,0
            if (proc->wait_state & WT_INTERRUPTED) {
ffffffffc0205ece:	0006c763          	bltz	a3,ffffffffc0205edc <do_kill+0x32>
}
ffffffffc0205ed2:	8522                	mv	a0,s0
ffffffffc0205ed4:	60a2                	ld	ra,8(sp)
ffffffffc0205ed6:	6402                	ld	s0,0(sp)
ffffffffc0205ed8:	0141                	addi	sp,sp,16
ffffffffc0205eda:	8082                	ret
                wakeup_proc(proc);
ffffffffc0205edc:	1e6000ef          	jal	ra,ffffffffc02060c2 <wakeup_proc>
}
ffffffffc0205ee0:	8522                	mv	a0,s0
ffffffffc0205ee2:	60a2                	ld	ra,8(sp)
ffffffffc0205ee4:	6402                	ld	s0,0(sp)
ffffffffc0205ee6:	0141                	addi	sp,sp,16
ffffffffc0205ee8:	8082                	ret
        return -E_KILLED;
ffffffffc0205eea:	545d                	li	s0,-9
ffffffffc0205eec:	b7dd                	j	ffffffffc0205ed2 <do_kill+0x28>
    return -E_INVAL;
ffffffffc0205eee:	5475                	li	s0,-3
ffffffffc0205ef0:	b7cd                	j	ffffffffc0205ed2 <do_kill+0x28>

ffffffffc0205ef2 <proc_init>:
    elm->prev = elm->next = elm;
ffffffffc0205ef2:	000a6797          	auipc	a5,0xa6
ffffffffc0205ef6:	6de78793          	addi	a5,a5,1758 # ffffffffc02ac5d0 <proc_list>

// proc_init - set up the first kernel thread idleproc "idle" by itself and 
//           - create the second kernel thread init_main
void
proc_init(void) {
ffffffffc0205efa:	1101                	addi	sp,sp,-32
ffffffffc0205efc:	000a6717          	auipc	a4,0xa6
ffffffffc0205f00:	6cf73e23          	sd	a5,1756(a4) # ffffffffc02ac5d8 <proc_list+0x8>
ffffffffc0205f04:	000a6717          	auipc	a4,0xa6
ffffffffc0205f08:	6cf73623          	sd	a5,1740(a4) # ffffffffc02ac5d0 <proc_list>
ffffffffc0205f0c:	ec06                	sd	ra,24(sp)
ffffffffc0205f0e:	e822                	sd	s0,16(sp)
ffffffffc0205f10:	e426                	sd	s1,8(sp)
ffffffffc0205f12:	000a2797          	auipc	a5,0xa2
ffffffffc0205f16:	54678793          	addi	a5,a5,1350 # ffffffffc02a8458 <hash_list>
ffffffffc0205f1a:	000a6717          	auipc	a4,0xa6
ffffffffc0205f1e:	53e70713          	addi	a4,a4,1342 # ffffffffc02ac458 <is_panic>
ffffffffc0205f22:	e79c                	sd	a5,8(a5)
ffffffffc0205f24:	e39c                	sd	a5,0(a5)
ffffffffc0205f26:	07c1                	addi	a5,a5,16
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
ffffffffc0205f28:	fee79de3          	bne	a5,a4,ffffffffc0205f22 <proc_init+0x30>
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL) {
ffffffffc0205f2c:	82eff0ef          	jal	ra,ffffffffc0204f5a <alloc_proc>
ffffffffc0205f30:	000a6717          	auipc	a4,0xa6
ffffffffc0205f34:	56a73423          	sd	a0,1384(a4) # ffffffffc02ac498 <idleproc>
ffffffffc0205f38:	000a6497          	auipc	s1,0xa6
ffffffffc0205f3c:	56048493          	addi	s1,s1,1376 # ffffffffc02ac498 <idleproc>
ffffffffc0205f40:	c559                	beqz	a0,ffffffffc0205fce <proc_init+0xdc>
        panic("cannot alloc idleproc.\n");
    }

    idleproc->pid = 0;
    idleproc->state = PROC_RUNNABLE;
ffffffffc0205f42:	4709                	li	a4,2
ffffffffc0205f44:	e118                	sd	a4,0(a0)
    idleproc->kstack = (uintptr_t)bootstack;
    idleproc->need_resched = 1;
ffffffffc0205f46:	4405                	li	s0,1
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0205f48:	00003717          	auipc	a4,0x3
ffffffffc0205f4c:	0b870713          	addi	a4,a4,184 # ffffffffc0209000 <bootstack>
    set_proc_name(idleproc, "idle");
ffffffffc0205f50:	00003597          	auipc	a1,0x3
ffffffffc0205f54:	99058593          	addi	a1,a1,-1648 # ffffffffc02088e0 <default_pmm_manager+0x1288>
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0205f58:	e918                	sd	a4,16(a0)
    idleproc->need_resched = 1;
ffffffffc0205f5a:	ed00                	sd	s0,24(a0)
    set_proc_name(idleproc, "idle");
ffffffffc0205f5c:	982ff0ef          	jal	ra,ffffffffc02050de <set_proc_name>
    nr_process ++;
ffffffffc0205f60:	000a6797          	auipc	a5,0xa6
ffffffffc0205f64:	54878793          	addi	a5,a5,1352 # ffffffffc02ac4a8 <nr_process>
ffffffffc0205f68:	439c                	lw	a5,0(a5)

    current = idleproc;
ffffffffc0205f6a:	6098                	ld	a4,0(s1)

    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205f6c:	4601                	li	a2,0
    nr_process ++;
ffffffffc0205f6e:	2785                	addiw	a5,a5,1
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205f70:	4581                	li	a1,0
ffffffffc0205f72:	00000517          	auipc	a0,0x0
ffffffffc0205f76:	8be50513          	addi	a0,a0,-1858 # ffffffffc0205830 <init_main>
    nr_process ++;
ffffffffc0205f7a:	000a6697          	auipc	a3,0xa6
ffffffffc0205f7e:	52f6a723          	sw	a5,1326(a3) # ffffffffc02ac4a8 <nr_process>
    current = idleproc;
ffffffffc0205f82:	000a6797          	auipc	a5,0xa6
ffffffffc0205f86:	50e7b723          	sd	a4,1294(a5) # ffffffffc02ac490 <current>
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205f8a:	d60ff0ef          	jal	ra,ffffffffc02054ea <kernel_thread>
    if (pid <= 0) {
ffffffffc0205f8e:	08a05c63          	blez	a0,ffffffffc0206026 <proc_init+0x134>
        panic("create init_main failed.\n");
    }

    initproc = find_proc(pid);
ffffffffc0205f92:	9e2ff0ef          	jal	ra,ffffffffc0205174 <find_proc>
    set_proc_name(initproc, "init");
ffffffffc0205f96:	00003597          	auipc	a1,0x3
ffffffffc0205f9a:	97258593          	addi	a1,a1,-1678 # ffffffffc0208908 <default_pmm_manager+0x12b0>
    initproc = find_proc(pid);
ffffffffc0205f9e:	000a6797          	auipc	a5,0xa6
ffffffffc0205fa2:	50a7b123          	sd	a0,1282(a5) # ffffffffc02ac4a0 <initproc>
    set_proc_name(initproc, "init");
ffffffffc0205fa6:	938ff0ef          	jal	ra,ffffffffc02050de <set_proc_name>

    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0205faa:	609c                	ld	a5,0(s1)
ffffffffc0205fac:	cfa9                	beqz	a5,ffffffffc0206006 <proc_init+0x114>
ffffffffc0205fae:	43dc                	lw	a5,4(a5)
ffffffffc0205fb0:	ebb9                	bnez	a5,ffffffffc0206006 <proc_init+0x114>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0205fb2:	000a6797          	auipc	a5,0xa6
ffffffffc0205fb6:	4ee78793          	addi	a5,a5,1262 # ffffffffc02ac4a0 <initproc>
ffffffffc0205fba:	639c                	ld	a5,0(a5)
ffffffffc0205fbc:	c78d                	beqz	a5,ffffffffc0205fe6 <proc_init+0xf4>
ffffffffc0205fbe:	43dc                	lw	a5,4(a5)
ffffffffc0205fc0:	02879363          	bne	a5,s0,ffffffffc0205fe6 <proc_init+0xf4>
}
ffffffffc0205fc4:	60e2                	ld	ra,24(sp)
ffffffffc0205fc6:	6442                	ld	s0,16(sp)
ffffffffc0205fc8:	64a2                	ld	s1,8(sp)
ffffffffc0205fca:	6105                	addi	sp,sp,32
ffffffffc0205fcc:	8082                	ret
        panic("cannot alloc idleproc.\n");
ffffffffc0205fce:	00003617          	auipc	a2,0x3
ffffffffc0205fd2:	8fa60613          	addi	a2,a2,-1798 # ffffffffc02088c8 <default_pmm_manager+0x1270>
ffffffffc0205fd6:	37d00593          	li	a1,893
ffffffffc0205fda:	00003517          	auipc	a0,0x3
ffffffffc0205fde:	9ee50513          	addi	a0,a0,-1554 # ffffffffc02089c8 <default_pmm_manager+0x1370>
ffffffffc0205fe2:	ca2fa0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0205fe6:	00003697          	auipc	a3,0x3
ffffffffc0205fea:	95268693          	addi	a3,a3,-1710 # ffffffffc0208938 <default_pmm_manager+0x12e0>
ffffffffc0205fee:	00001617          	auipc	a2,0x1
ffffffffc0205ff2:	d9260613          	addi	a2,a2,-622 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0205ff6:	39200593          	li	a1,914
ffffffffc0205ffa:	00003517          	auipc	a0,0x3
ffffffffc0205ffe:	9ce50513          	addi	a0,a0,-1586 # ffffffffc02089c8 <default_pmm_manager+0x1370>
ffffffffc0206002:	c82fa0ef          	jal	ra,ffffffffc0200484 <__panic>
    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0206006:	00003697          	auipc	a3,0x3
ffffffffc020600a:	90a68693          	addi	a3,a3,-1782 # ffffffffc0208910 <default_pmm_manager+0x12b8>
ffffffffc020600e:	00001617          	auipc	a2,0x1
ffffffffc0206012:	d7260613          	addi	a2,a2,-654 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0206016:	39100593          	li	a1,913
ffffffffc020601a:	00003517          	auipc	a0,0x3
ffffffffc020601e:	9ae50513          	addi	a0,a0,-1618 # ffffffffc02089c8 <default_pmm_manager+0x1370>
ffffffffc0206022:	c62fa0ef          	jal	ra,ffffffffc0200484 <__panic>
        panic("create init_main failed.\n");
ffffffffc0206026:	00003617          	auipc	a2,0x3
ffffffffc020602a:	8c260613          	addi	a2,a2,-1854 # ffffffffc02088e8 <default_pmm_manager+0x1290>
ffffffffc020602e:	38b00593          	li	a1,907
ffffffffc0206032:	00003517          	auipc	a0,0x3
ffffffffc0206036:	99650513          	addi	a0,a0,-1642 # ffffffffc02089c8 <default_pmm_manager+0x1370>
ffffffffc020603a:	c4afa0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc020603e <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void
cpu_idle(void) {
ffffffffc020603e:	1141                	addi	sp,sp,-16
ffffffffc0206040:	e022                	sd	s0,0(sp)
ffffffffc0206042:	e406                	sd	ra,8(sp)
ffffffffc0206044:	000a6417          	auipc	s0,0xa6
ffffffffc0206048:	44c40413          	addi	s0,s0,1100 # ffffffffc02ac490 <current>
    while (1) {
        if (current->need_resched) {
ffffffffc020604c:	6018                	ld	a4,0(s0)
ffffffffc020604e:	6f1c                	ld	a5,24(a4)
ffffffffc0206050:	dffd                	beqz	a5,ffffffffc020604e <cpu_idle+0x10>
            schedule();
ffffffffc0206052:	0ec000ef          	jal	ra,ffffffffc020613e <schedule>
ffffffffc0206056:	bfdd                	j	ffffffffc020604c <cpu_idle+0xe>

ffffffffc0206058 <switch_to>:
.text
# void switch_to(struct proc_struct* from, struct proc_struct* to)
.globl switch_to
switch_to:
    # save from's registers
    STORE ra, 0*REGBYTES(a0)
ffffffffc0206058:	00153023          	sd	ra,0(a0)
    STORE sp, 1*REGBYTES(a0)
ffffffffc020605c:	00253423          	sd	sp,8(a0)
    STORE s0, 2*REGBYTES(a0)
ffffffffc0206060:	e900                	sd	s0,16(a0)
    STORE s1, 3*REGBYTES(a0)
ffffffffc0206062:	ed04                	sd	s1,24(a0)
    STORE s2, 4*REGBYTES(a0)
ffffffffc0206064:	03253023          	sd	s2,32(a0)
    STORE s3, 5*REGBYTES(a0)
ffffffffc0206068:	03353423          	sd	s3,40(a0)
    STORE s4, 6*REGBYTES(a0)
ffffffffc020606c:	03453823          	sd	s4,48(a0)
    STORE s5, 7*REGBYTES(a0)
ffffffffc0206070:	03553c23          	sd	s5,56(a0)
    STORE s6, 8*REGBYTES(a0)
ffffffffc0206074:	05653023          	sd	s6,64(a0)
    STORE s7, 9*REGBYTES(a0)
ffffffffc0206078:	05753423          	sd	s7,72(a0)
    STORE s8, 10*REGBYTES(a0)
ffffffffc020607c:	05853823          	sd	s8,80(a0)
    STORE s9, 11*REGBYTES(a0)
ffffffffc0206080:	05953c23          	sd	s9,88(a0)
    STORE s10, 12*REGBYTES(a0)
ffffffffc0206084:	07a53023          	sd	s10,96(a0)
    STORE s11, 13*REGBYTES(a0)
ffffffffc0206088:	07b53423          	sd	s11,104(a0)

    # restore to's registers
    LOAD ra, 0*REGBYTES(a1)
ffffffffc020608c:	0005b083          	ld	ra,0(a1)
    LOAD sp, 1*REGBYTES(a1)
ffffffffc0206090:	0085b103          	ld	sp,8(a1)
    LOAD s0, 2*REGBYTES(a1)
ffffffffc0206094:	6980                	ld	s0,16(a1)
    LOAD s1, 3*REGBYTES(a1)
ffffffffc0206096:	6d84                	ld	s1,24(a1)
    LOAD s2, 4*REGBYTES(a1)
ffffffffc0206098:	0205b903          	ld	s2,32(a1)
    LOAD s3, 5*REGBYTES(a1)
ffffffffc020609c:	0285b983          	ld	s3,40(a1)
    LOAD s4, 6*REGBYTES(a1)
ffffffffc02060a0:	0305ba03          	ld	s4,48(a1)
    LOAD s5, 7*REGBYTES(a1)
ffffffffc02060a4:	0385ba83          	ld	s5,56(a1)
    LOAD s6, 8*REGBYTES(a1)
ffffffffc02060a8:	0405bb03          	ld	s6,64(a1)
    LOAD s7, 9*REGBYTES(a1)
ffffffffc02060ac:	0485bb83          	ld	s7,72(a1)
    LOAD s8, 10*REGBYTES(a1)
ffffffffc02060b0:	0505bc03          	ld	s8,80(a1)
    LOAD s9, 11*REGBYTES(a1)
ffffffffc02060b4:	0585bc83          	ld	s9,88(a1)
    LOAD s10, 12*REGBYTES(a1)
ffffffffc02060b8:	0605bd03          	ld	s10,96(a1)
    LOAD s11, 13*REGBYTES(a1)
ffffffffc02060bc:	0685bd83          	ld	s11,104(a1)

    ret
ffffffffc02060c0:	8082                	ret

ffffffffc02060c2 <wakeup_proc>:
#include <sched.h>
#include <assert.h>

void
wakeup_proc(struct proc_struct *proc) {
    assert(proc->state != PROC_ZOMBIE);
ffffffffc02060c2:	4118                	lw	a4,0(a0)
wakeup_proc(struct proc_struct *proc) {
ffffffffc02060c4:	1101                	addi	sp,sp,-32
ffffffffc02060c6:	ec06                	sd	ra,24(sp)
ffffffffc02060c8:	e822                	sd	s0,16(sp)
    assert(proc->state != PROC_ZOMBIE);
ffffffffc02060ca:	478d                	li	a5,3
ffffffffc02060cc:	04f70a63          	beq	a4,a5,ffffffffc0206120 <wakeup_proc+0x5e>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02060d0:	100027f3          	csrr	a5,sstatus
ffffffffc02060d4:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02060d6:	4401                	li	s0,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02060d8:	ef8d                	bnez	a5,ffffffffc0206112 <wakeup_proc+0x50>
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        if (proc->state != PROC_RUNNABLE) {
ffffffffc02060da:	4789                	li	a5,2
ffffffffc02060dc:	00f70f63          	beq	a4,a5,ffffffffc02060fa <wakeup_proc+0x38>
            proc->state = PROC_RUNNABLE;
ffffffffc02060e0:	c11c                	sw	a5,0(a0)
            proc->wait_state = 0;
ffffffffc02060e2:	0e052623          	sw	zero,236(a0)
    if (flag) {
ffffffffc02060e6:	e409                	bnez	s0,ffffffffc02060f0 <wakeup_proc+0x2e>
        else {
            warn("wakeup runnable process.\n");
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc02060e8:	60e2                	ld	ra,24(sp)
ffffffffc02060ea:	6442                	ld	s0,16(sp)
ffffffffc02060ec:	6105                	addi	sp,sp,32
ffffffffc02060ee:	8082                	ret
ffffffffc02060f0:	6442                	ld	s0,16(sp)
ffffffffc02060f2:	60e2                	ld	ra,24(sp)
ffffffffc02060f4:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc02060f6:	d5efa06f          	j	ffffffffc0200654 <intr_enable>
            warn("wakeup runnable process.\n");
ffffffffc02060fa:	00003617          	auipc	a2,0x3
ffffffffc02060fe:	91e60613          	addi	a2,a2,-1762 # ffffffffc0208a18 <default_pmm_manager+0x13c0>
ffffffffc0206102:	45c9                	li	a1,18
ffffffffc0206104:	00003517          	auipc	a0,0x3
ffffffffc0206108:	8fc50513          	addi	a0,a0,-1796 # ffffffffc0208a00 <default_pmm_manager+0x13a8>
ffffffffc020610c:	be4fa0ef          	jal	ra,ffffffffc02004f0 <__warn>
ffffffffc0206110:	bfd9                	j	ffffffffc02060e6 <wakeup_proc+0x24>
ffffffffc0206112:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0206114:	d46fa0ef          	jal	ra,ffffffffc020065a <intr_disable>
        return 1;
ffffffffc0206118:	6522                	ld	a0,8(sp)
ffffffffc020611a:	4405                	li	s0,1
ffffffffc020611c:	4118                	lw	a4,0(a0)
ffffffffc020611e:	bf75                	j	ffffffffc02060da <wakeup_proc+0x18>
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0206120:	00003697          	auipc	a3,0x3
ffffffffc0206124:	8c068693          	addi	a3,a3,-1856 # ffffffffc02089e0 <default_pmm_manager+0x1388>
ffffffffc0206128:	00001617          	auipc	a2,0x1
ffffffffc020612c:	c5860613          	addi	a2,a2,-936 # ffffffffc0206d80 <commands+0x4c0>
ffffffffc0206130:	45a5                	li	a1,9
ffffffffc0206132:	00003517          	auipc	a0,0x3
ffffffffc0206136:	8ce50513          	addi	a0,a0,-1842 # ffffffffc0208a00 <default_pmm_manager+0x13a8>
ffffffffc020613a:	b4afa0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc020613e <schedule>:

void
schedule(void) {
ffffffffc020613e:	1141                	addi	sp,sp,-16
ffffffffc0206140:	e406                	sd	ra,8(sp)
ffffffffc0206142:	e022                	sd	s0,0(sp)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0206144:	100027f3          	csrr	a5,sstatus
ffffffffc0206148:	8b89                	andi	a5,a5,2
ffffffffc020614a:	4401                	li	s0,0
ffffffffc020614c:	e3d1                	bnez	a5,ffffffffc02061d0 <schedule+0x92>
    bool intr_flag;
    list_entry_t *le, *last;
    struct proc_struct *next = NULL;
    local_intr_save(intr_flag);
    {
        current->need_resched = 0;
ffffffffc020614e:	000a6797          	auipc	a5,0xa6
ffffffffc0206152:	34278793          	addi	a5,a5,834 # ffffffffc02ac490 <current>
ffffffffc0206156:	0007b883          	ld	a7,0(a5)
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc020615a:	000a6797          	auipc	a5,0xa6
ffffffffc020615e:	33e78793          	addi	a5,a5,830 # ffffffffc02ac498 <idleproc>
ffffffffc0206162:	6388                	ld	a0,0(a5)
        current->need_resched = 0;
ffffffffc0206164:	0008bc23          	sd	zero,24(a7) # 2018 <_binary_obj___user_faultread_out_size-0x7558>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0206168:	04a88e63          	beq	a7,a0,ffffffffc02061c4 <schedule+0x86>
ffffffffc020616c:	0c888693          	addi	a3,a7,200
ffffffffc0206170:	000a6617          	auipc	a2,0xa6
ffffffffc0206174:	46060613          	addi	a2,a2,1120 # ffffffffc02ac5d0 <proc_list>
        le = last;
ffffffffc0206178:	87b6                	mv	a5,a3
    struct proc_struct *next = NULL;
ffffffffc020617a:	4581                	li	a1,0
        do {
            if ((le = list_next(le)) != &proc_list) {
                next = le2proc(le, list_link);
                if (next->state == PROC_RUNNABLE) {
ffffffffc020617c:	4809                	li	a6,2
    return listelm->next;
ffffffffc020617e:	679c                	ld	a5,8(a5)
            if ((le = list_next(le)) != &proc_list) {
ffffffffc0206180:	00c78863          	beq	a5,a2,ffffffffc0206190 <schedule+0x52>
                if (next->state == PROC_RUNNABLE) {
ffffffffc0206184:	f387a703          	lw	a4,-200(a5)
                next = le2proc(le, list_link);
ffffffffc0206188:	f3878593          	addi	a1,a5,-200
                if (next->state == PROC_RUNNABLE) {
ffffffffc020618c:	01070463          	beq	a4,a6,ffffffffc0206194 <schedule+0x56>
                    break;
                }
            }
        } while (le != last);
ffffffffc0206190:	fef697e3          	bne	a3,a5,ffffffffc020617e <schedule+0x40>
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc0206194:	c589                	beqz	a1,ffffffffc020619e <schedule+0x60>
ffffffffc0206196:	4198                	lw	a4,0(a1)
ffffffffc0206198:	4789                	li	a5,2
ffffffffc020619a:	00f70e63          	beq	a4,a5,ffffffffc02061b6 <schedule+0x78>
            next = idleproc;
        }
        next->runs ++;
ffffffffc020619e:	451c                	lw	a5,8(a0)
ffffffffc02061a0:	2785                	addiw	a5,a5,1
ffffffffc02061a2:	c51c                	sw	a5,8(a0)
        if (next != current) {
ffffffffc02061a4:	00a88463          	beq	a7,a0,ffffffffc02061ac <schedule+0x6e>
            proc_run(next);
ffffffffc02061a8:	f61fe0ef          	jal	ra,ffffffffc0205108 <proc_run>
    if (flag) {
ffffffffc02061ac:	e419                	bnez	s0,ffffffffc02061ba <schedule+0x7c>
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc02061ae:	60a2                	ld	ra,8(sp)
ffffffffc02061b0:	6402                	ld	s0,0(sp)
ffffffffc02061b2:	0141                	addi	sp,sp,16
ffffffffc02061b4:	8082                	ret
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc02061b6:	852e                	mv	a0,a1
ffffffffc02061b8:	b7dd                	j	ffffffffc020619e <schedule+0x60>
}
ffffffffc02061ba:	6402                	ld	s0,0(sp)
ffffffffc02061bc:	60a2                	ld	ra,8(sp)
ffffffffc02061be:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc02061c0:	c94fa06f          	j	ffffffffc0200654 <intr_enable>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc02061c4:	000a6617          	auipc	a2,0xa6
ffffffffc02061c8:	40c60613          	addi	a2,a2,1036 # ffffffffc02ac5d0 <proc_list>
ffffffffc02061cc:	86b2                	mv	a3,a2
ffffffffc02061ce:	b76d                	j	ffffffffc0206178 <schedule+0x3a>
        intr_disable();
ffffffffc02061d0:	c8afa0ef          	jal	ra,ffffffffc020065a <intr_disable>
        return 1;
ffffffffc02061d4:	4405                	li	s0,1
ffffffffc02061d6:	bfa5                	j	ffffffffc020614e <schedule+0x10>

ffffffffc02061d8 <sys_getpid>:
    return do_kill(pid);
}

static int
sys_getpid(uint64_t arg[]) {
    return current->pid;
ffffffffc02061d8:	000a6797          	auipc	a5,0xa6
ffffffffc02061dc:	2b878793          	addi	a5,a5,696 # ffffffffc02ac490 <current>
ffffffffc02061e0:	639c                	ld	a5,0(a5)
}
ffffffffc02061e2:	43c8                	lw	a0,4(a5)
ffffffffc02061e4:	8082                	ret

ffffffffc02061e6 <sys_pgdir>:

static int
sys_pgdir(uint64_t arg[]) {
    //print_pgdir();
    return 0;
}
ffffffffc02061e6:	4501                	li	a0,0
ffffffffc02061e8:	8082                	ret

ffffffffc02061ea <sys_putc>:
    cputchar(c);
ffffffffc02061ea:	4108                	lw	a0,0(a0)
sys_putc(uint64_t arg[]) {
ffffffffc02061ec:	1141                	addi	sp,sp,-16
ffffffffc02061ee:	e406                	sd	ra,8(sp)
    cputchar(c);
ffffffffc02061f0:	fd3f90ef          	jal	ra,ffffffffc02001c2 <cputchar>
}
ffffffffc02061f4:	60a2                	ld	ra,8(sp)
ffffffffc02061f6:	4501                	li	a0,0
ffffffffc02061f8:	0141                	addi	sp,sp,16
ffffffffc02061fa:	8082                	ret

ffffffffc02061fc <sys_kill>:
    return do_kill(pid);
ffffffffc02061fc:	4108                	lw	a0,0(a0)
ffffffffc02061fe:	cadff06f          	j	ffffffffc0205eaa <do_kill>

ffffffffc0206202 <sys_yield>:
    return do_yield();
ffffffffc0206202:	c57ff06f          	j	ffffffffc0205e58 <do_yield>

ffffffffc0206206 <sys_exec>:
    return do_execve(name, len, binary, size);
ffffffffc0206206:	6d14                	ld	a3,24(a0)
ffffffffc0206208:	6910                	ld	a2,16(a0)
ffffffffc020620a:	650c                	ld	a1,8(a0)
ffffffffc020620c:	6108                	ld	a0,0(a0)
ffffffffc020620e:	f4aff06f          	j	ffffffffc0205958 <do_execve>

ffffffffc0206212 <sys_wait>:
    return do_wait(pid, store);
ffffffffc0206212:	650c                	ld	a1,8(a0)
ffffffffc0206214:	4108                	lw	a0,0(a0)
ffffffffc0206216:	c55ff06f          	j	ffffffffc0205e6a <do_wait>

ffffffffc020621a <sys_fork>:
    struct trapframe *tf = current->tf;
ffffffffc020621a:	000a6797          	auipc	a5,0xa6
ffffffffc020621e:	27678793          	addi	a5,a5,630 # ffffffffc02ac490 <current>
ffffffffc0206222:	639c                	ld	a5,0(a5)
    return do_fork(0, stack, tf);
ffffffffc0206224:	4501                	li	a0,0
    struct trapframe *tf = current->tf;
ffffffffc0206226:	73d0                	ld	a2,160(a5)
    return do_fork(0, stack, tf);
ffffffffc0206228:	6a0c                	ld	a1,16(a2)
ffffffffc020622a:	fa7fe06f          	j	ffffffffc02051d0 <do_fork>

ffffffffc020622e <sys_exit>:
    return do_exit(error_code);
ffffffffc020622e:	4108                	lw	a0,0(a0)
ffffffffc0206230:	b0aff06f          	j	ffffffffc020553a <do_exit>

ffffffffc0206234 <syscall>:
};

#define NUM_SYSCALLS        ((sizeof(syscalls)) / (sizeof(syscalls[0])))

void
syscall(void) {
ffffffffc0206234:	715d                	addi	sp,sp,-80
ffffffffc0206236:	fc26                	sd	s1,56(sp)
    struct trapframe *tf = current->tf;
ffffffffc0206238:	000a6497          	auipc	s1,0xa6
ffffffffc020623c:	25848493          	addi	s1,s1,600 # ffffffffc02ac490 <current>
ffffffffc0206240:	6098                	ld	a4,0(s1)
syscall(void) {
ffffffffc0206242:	e0a2                	sd	s0,64(sp)
ffffffffc0206244:	f84a                	sd	s2,48(sp)
    struct trapframe *tf = current->tf;
ffffffffc0206246:	7340                	ld	s0,160(a4)
syscall(void) {
ffffffffc0206248:	e486                	sd	ra,72(sp)
    uint64_t arg[5];
    int num = tf->gpr.a0;
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc020624a:	47fd                	li	a5,31
    int num = tf->gpr.a0;
ffffffffc020624c:	05042903          	lw	s2,80(s0)
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc0206250:	0327ee63          	bltu	a5,s2,ffffffffc020628c <syscall+0x58>
        if (syscalls[num] != NULL) {
ffffffffc0206254:	00391713          	slli	a4,s2,0x3
ffffffffc0206258:	00003797          	auipc	a5,0x3
ffffffffc020625c:	82878793          	addi	a5,a5,-2008 # ffffffffc0208a80 <syscalls>
ffffffffc0206260:	97ba                	add	a5,a5,a4
ffffffffc0206262:	639c                	ld	a5,0(a5)
ffffffffc0206264:	c785                	beqz	a5,ffffffffc020628c <syscall+0x58>
            arg[0] = tf->gpr.a1;
ffffffffc0206266:	6c28                	ld	a0,88(s0)
            arg[1] = tf->gpr.a2;
ffffffffc0206268:	702c                	ld	a1,96(s0)
            arg[2] = tf->gpr.a3;
ffffffffc020626a:	7430                	ld	a2,104(s0)
            arg[3] = tf->gpr.a4;
ffffffffc020626c:	7834                	ld	a3,112(s0)
            arg[4] = tf->gpr.a5;
ffffffffc020626e:	7c38                	ld	a4,120(s0)
            arg[0] = tf->gpr.a1;
ffffffffc0206270:	e42a                	sd	a0,8(sp)
            arg[1] = tf->gpr.a2;
ffffffffc0206272:	e82e                	sd	a1,16(sp)
            arg[2] = tf->gpr.a3;
ffffffffc0206274:	ec32                	sd	a2,24(sp)
            arg[3] = tf->gpr.a4;
ffffffffc0206276:	f036                	sd	a3,32(sp)
            arg[4] = tf->gpr.a5;
ffffffffc0206278:	f43a                	sd	a4,40(sp)
            tf->gpr.a0 = syscalls[num](arg);
ffffffffc020627a:	0028                	addi	a0,sp,8
ffffffffc020627c:	9782                	jalr	a5
ffffffffc020627e:	e828                	sd	a0,80(s0)
        }
    }
    print_trapframe(tf);
    panic("undefined syscall %d, pid = %d, name = %s.\n",
            num, current->pid, current->name);
}
ffffffffc0206280:	60a6                	ld	ra,72(sp)
ffffffffc0206282:	6406                	ld	s0,64(sp)
ffffffffc0206284:	74e2                	ld	s1,56(sp)
ffffffffc0206286:	7942                	ld	s2,48(sp)
ffffffffc0206288:	6161                	addi	sp,sp,80
ffffffffc020628a:	8082                	ret
    print_trapframe(tf);
ffffffffc020628c:	8522                	mv	a0,s0
ffffffffc020628e:	dbcfa0ef          	jal	ra,ffffffffc020084a <print_trapframe>
    panic("undefined syscall %d, pid = %d, name = %s.\n",
ffffffffc0206292:	609c                	ld	a5,0(s1)
ffffffffc0206294:	86ca                	mv	a3,s2
ffffffffc0206296:	00002617          	auipc	a2,0x2
ffffffffc020629a:	7a260613          	addi	a2,a2,1954 # ffffffffc0208a38 <default_pmm_manager+0x13e0>
ffffffffc020629e:	43d8                	lw	a4,4(a5)
ffffffffc02062a0:	06300593          	li	a1,99
ffffffffc02062a4:	0b478793          	addi	a5,a5,180
ffffffffc02062a8:	00002517          	auipc	a0,0x2
ffffffffc02062ac:	7c050513          	addi	a0,a0,1984 # ffffffffc0208a68 <default_pmm_manager+0x1410>
ffffffffc02062b0:	9d4fa0ef          	jal	ra,ffffffffc0200484 <__panic>

ffffffffc02062b4 <hash32>:
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
ffffffffc02062b4:	9e3707b7          	lui	a5,0x9e370
ffffffffc02062b8:	2785                	addiw	a5,a5,1
ffffffffc02062ba:	02f5053b          	mulw	a0,a0,a5
    return (hash >> (32 - bits));
ffffffffc02062be:	02000793          	li	a5,32
ffffffffc02062c2:	40b785bb          	subw	a1,a5,a1
}
ffffffffc02062c6:	00b5553b          	srlw	a0,a0,a1
ffffffffc02062ca:	8082                	ret

ffffffffc02062cc <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc02062cc:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02062d0:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc02062d2:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02062d6:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc02062d8:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02062dc:	f022                	sd	s0,32(sp)
ffffffffc02062de:	ec26                	sd	s1,24(sp)
ffffffffc02062e0:	e84a                	sd	s2,16(sp)
ffffffffc02062e2:	f406                	sd	ra,40(sp)
ffffffffc02062e4:	e44e                	sd	s3,8(sp)
ffffffffc02062e6:	84aa                	mv	s1,a0
ffffffffc02062e8:	892e                	mv	s2,a1
ffffffffc02062ea:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc02062ee:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
ffffffffc02062f0:	03067e63          	bleu	a6,a2,ffffffffc020632c <printnum+0x60>
ffffffffc02062f4:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc02062f6:	00805763          	blez	s0,ffffffffc0206304 <printnum+0x38>
ffffffffc02062fa:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc02062fc:	85ca                	mv	a1,s2
ffffffffc02062fe:	854e                	mv	a0,s3
ffffffffc0206300:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0206302:	fc65                	bnez	s0,ffffffffc02062fa <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0206304:	1a02                	slli	s4,s4,0x20
ffffffffc0206306:	020a5a13          	srli	s4,s4,0x20
ffffffffc020630a:	00003797          	auipc	a5,0x3
ffffffffc020630e:	a9678793          	addi	a5,a5,-1386 # ffffffffc0208da0 <error_string+0xc8>
ffffffffc0206312:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
ffffffffc0206314:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0206316:	000a4503          	lbu	a0,0(s4) # ffffffff80000000 <_binary_obj___user_exit_out_size+0xffffffff7fff5580>
}
ffffffffc020631a:	70a2                	ld	ra,40(sp)
ffffffffc020631c:	69a2                	ld	s3,8(sp)
ffffffffc020631e:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0206320:	85ca                	mv	a1,s2
ffffffffc0206322:	8326                	mv	t1,s1
}
ffffffffc0206324:	6942                	ld	s2,16(sp)
ffffffffc0206326:	64e2                	ld	s1,24(sp)
ffffffffc0206328:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020632a:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc020632c:	03065633          	divu	a2,a2,a6
ffffffffc0206330:	8722                	mv	a4,s0
ffffffffc0206332:	f9bff0ef          	jal	ra,ffffffffc02062cc <printnum>
ffffffffc0206336:	b7f9                	j	ffffffffc0206304 <printnum+0x38>

ffffffffc0206338 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0206338:	7119                	addi	sp,sp,-128
ffffffffc020633a:	f4a6                	sd	s1,104(sp)
ffffffffc020633c:	f0ca                	sd	s2,96(sp)
ffffffffc020633e:	e8d2                	sd	s4,80(sp)
ffffffffc0206340:	e4d6                	sd	s5,72(sp)
ffffffffc0206342:	e0da                	sd	s6,64(sp)
ffffffffc0206344:	fc5e                	sd	s7,56(sp)
ffffffffc0206346:	f862                	sd	s8,48(sp)
ffffffffc0206348:	f06a                	sd	s10,32(sp)
ffffffffc020634a:	fc86                	sd	ra,120(sp)
ffffffffc020634c:	f8a2                	sd	s0,112(sp)
ffffffffc020634e:	ecce                	sd	s3,88(sp)
ffffffffc0206350:	f466                	sd	s9,40(sp)
ffffffffc0206352:	ec6e                	sd	s11,24(sp)
ffffffffc0206354:	892a                	mv	s2,a0
ffffffffc0206356:	84ae                	mv	s1,a1
ffffffffc0206358:	8d32                	mv	s10,a2
ffffffffc020635a:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc020635c:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020635e:	00003a17          	auipc	s4,0x3
ffffffffc0206362:	822a0a13          	addi	s4,s4,-2014 # ffffffffc0208b80 <syscalls+0x100>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0206366:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020636a:	00003c17          	auipc	s8,0x3
ffffffffc020636e:	96ec0c13          	addi	s8,s8,-1682 # ffffffffc0208cd8 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0206372:	000d4503          	lbu	a0,0(s10) # 1000 <_binary_obj___user_faultread_out_size-0x8570>
ffffffffc0206376:	02500793          	li	a5,37
ffffffffc020637a:	001d0413          	addi	s0,s10,1
ffffffffc020637e:	00f50e63          	beq	a0,a5,ffffffffc020639a <vprintfmt+0x62>
            if (ch == '\0') {
ffffffffc0206382:	c521                	beqz	a0,ffffffffc02063ca <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0206384:	02500993          	li	s3,37
ffffffffc0206388:	a011                	j	ffffffffc020638c <vprintfmt+0x54>
            if (ch == '\0') {
ffffffffc020638a:	c121                	beqz	a0,ffffffffc02063ca <vprintfmt+0x92>
            putch(ch, putdat);
ffffffffc020638c:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020638e:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0206390:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0206392:	fff44503          	lbu	a0,-1(s0)
ffffffffc0206396:	ff351ae3          	bne	a0,s3,ffffffffc020638a <vprintfmt+0x52>
ffffffffc020639a:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc020639e:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc02063a2:	4981                	li	s3,0
ffffffffc02063a4:	4801                	li	a6,0
        width = precision = -1;
ffffffffc02063a6:	5cfd                	li	s9,-1
ffffffffc02063a8:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02063aa:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
ffffffffc02063ae:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02063b0:	fdd6069b          	addiw	a3,a2,-35
ffffffffc02063b4:	0ff6f693          	andi	a3,a3,255
ffffffffc02063b8:	00140d13          	addi	s10,s0,1
ffffffffc02063bc:	20d5e563          	bltu	a1,a3,ffffffffc02065c6 <vprintfmt+0x28e>
ffffffffc02063c0:	068a                	slli	a3,a3,0x2
ffffffffc02063c2:	96d2                	add	a3,a3,s4
ffffffffc02063c4:	4294                	lw	a3,0(a3)
ffffffffc02063c6:	96d2                	add	a3,a3,s4
ffffffffc02063c8:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc02063ca:	70e6                	ld	ra,120(sp)
ffffffffc02063cc:	7446                	ld	s0,112(sp)
ffffffffc02063ce:	74a6                	ld	s1,104(sp)
ffffffffc02063d0:	7906                	ld	s2,96(sp)
ffffffffc02063d2:	69e6                	ld	s3,88(sp)
ffffffffc02063d4:	6a46                	ld	s4,80(sp)
ffffffffc02063d6:	6aa6                	ld	s5,72(sp)
ffffffffc02063d8:	6b06                	ld	s6,64(sp)
ffffffffc02063da:	7be2                	ld	s7,56(sp)
ffffffffc02063dc:	7c42                	ld	s8,48(sp)
ffffffffc02063de:	7ca2                	ld	s9,40(sp)
ffffffffc02063e0:	7d02                	ld	s10,32(sp)
ffffffffc02063e2:	6de2                	ld	s11,24(sp)
ffffffffc02063e4:	6109                	addi	sp,sp,128
ffffffffc02063e6:	8082                	ret
    if (lflag >= 2) {
ffffffffc02063e8:	4705                	li	a4,1
ffffffffc02063ea:	008a8593          	addi	a1,s5,8
ffffffffc02063ee:	01074463          	blt	a4,a6,ffffffffc02063f6 <vprintfmt+0xbe>
    else if (lflag) {
ffffffffc02063f2:	26080363          	beqz	a6,ffffffffc0206658 <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
ffffffffc02063f6:	000ab603          	ld	a2,0(s5)
ffffffffc02063fa:	46c1                	li	a3,16
ffffffffc02063fc:	8aae                	mv	s5,a1
ffffffffc02063fe:	a06d                	j	ffffffffc02064a8 <vprintfmt+0x170>
            goto reswitch;
ffffffffc0206400:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0206404:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206406:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0206408:	b765                	j	ffffffffc02063b0 <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
ffffffffc020640a:	000aa503          	lw	a0,0(s5)
ffffffffc020640e:	85a6                	mv	a1,s1
ffffffffc0206410:	0aa1                	addi	s5,s5,8
ffffffffc0206412:	9902                	jalr	s2
            break;
ffffffffc0206414:	bfb9                	j	ffffffffc0206372 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0206416:	4705                	li	a4,1
ffffffffc0206418:	008a8993          	addi	s3,s5,8
ffffffffc020641c:	01074463          	blt	a4,a6,ffffffffc0206424 <vprintfmt+0xec>
    else if (lflag) {
ffffffffc0206420:	22080463          	beqz	a6,ffffffffc0206648 <vprintfmt+0x310>
        return va_arg(*ap, long);
ffffffffc0206424:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
ffffffffc0206428:	24044463          	bltz	s0,ffffffffc0206670 <vprintfmt+0x338>
            num = getint(&ap, lflag);
ffffffffc020642c:	8622                	mv	a2,s0
ffffffffc020642e:	8ace                	mv	s5,s3
ffffffffc0206430:	46a9                	li	a3,10
ffffffffc0206432:	a89d                	j	ffffffffc02064a8 <vprintfmt+0x170>
            err = va_arg(ap, int);
ffffffffc0206434:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0206438:	4761                	li	a4,24
            err = va_arg(ap, int);
ffffffffc020643a:	0aa1                	addi	s5,s5,8
            if (err < 0) {
ffffffffc020643c:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0206440:	8fb5                	xor	a5,a5,a3
ffffffffc0206442:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0206446:	1ad74363          	blt	a4,a3,ffffffffc02065ec <vprintfmt+0x2b4>
ffffffffc020644a:	00369793          	slli	a5,a3,0x3
ffffffffc020644e:	97e2                	add	a5,a5,s8
ffffffffc0206450:	639c                	ld	a5,0(a5)
ffffffffc0206452:	18078d63          	beqz	a5,ffffffffc02065ec <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
ffffffffc0206456:	86be                	mv	a3,a5
ffffffffc0206458:	00000617          	auipc	a2,0x0
ffffffffc020645c:	36060613          	addi	a2,a2,864 # ffffffffc02067b8 <etext+0x2c>
ffffffffc0206460:	85a6                	mv	a1,s1
ffffffffc0206462:	854a                	mv	a0,s2
ffffffffc0206464:	240000ef          	jal	ra,ffffffffc02066a4 <printfmt>
ffffffffc0206468:	b729                	j	ffffffffc0206372 <vprintfmt+0x3a>
            lflag ++;
ffffffffc020646a:	00144603          	lbu	a2,1(s0)
ffffffffc020646e:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206470:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0206472:	bf3d                	j	ffffffffc02063b0 <vprintfmt+0x78>
    if (lflag >= 2) {
ffffffffc0206474:	4705                	li	a4,1
ffffffffc0206476:	008a8593          	addi	a1,s5,8
ffffffffc020647a:	01074463          	blt	a4,a6,ffffffffc0206482 <vprintfmt+0x14a>
    else if (lflag) {
ffffffffc020647e:	1e080263          	beqz	a6,ffffffffc0206662 <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
ffffffffc0206482:	000ab603          	ld	a2,0(s5)
ffffffffc0206486:	46a1                	li	a3,8
ffffffffc0206488:	8aae                	mv	s5,a1
ffffffffc020648a:	a839                	j	ffffffffc02064a8 <vprintfmt+0x170>
            putch('0', putdat);
ffffffffc020648c:	03000513          	li	a0,48
ffffffffc0206490:	85a6                	mv	a1,s1
ffffffffc0206492:	e03e                	sd	a5,0(sp)
ffffffffc0206494:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0206496:	85a6                	mv	a1,s1
ffffffffc0206498:	07800513          	li	a0,120
ffffffffc020649c:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc020649e:	0aa1                	addi	s5,s5,8
ffffffffc02064a0:	ff8ab603          	ld	a2,-8(s5)
            goto number;
ffffffffc02064a4:	6782                	ld	a5,0(sp)
ffffffffc02064a6:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
ffffffffc02064a8:	876e                	mv	a4,s11
ffffffffc02064aa:	85a6                	mv	a1,s1
ffffffffc02064ac:	854a                	mv	a0,s2
ffffffffc02064ae:	e1fff0ef          	jal	ra,ffffffffc02062cc <printnum>
            break;
ffffffffc02064b2:	b5c1                	j	ffffffffc0206372 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02064b4:	000ab603          	ld	a2,0(s5)
ffffffffc02064b8:	0aa1                	addi	s5,s5,8
ffffffffc02064ba:	1c060663          	beqz	a2,ffffffffc0206686 <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
ffffffffc02064be:	00160413          	addi	s0,a2,1
ffffffffc02064c2:	17b05c63          	blez	s11,ffffffffc020663a <vprintfmt+0x302>
ffffffffc02064c6:	02d00593          	li	a1,45
ffffffffc02064ca:	14b79263          	bne	a5,a1,ffffffffc020660e <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02064ce:	00064783          	lbu	a5,0(a2)
ffffffffc02064d2:	0007851b          	sext.w	a0,a5
ffffffffc02064d6:	c905                	beqz	a0,ffffffffc0206506 <vprintfmt+0x1ce>
ffffffffc02064d8:	000cc563          	bltz	s9,ffffffffc02064e2 <vprintfmt+0x1aa>
ffffffffc02064dc:	3cfd                	addiw	s9,s9,-1
ffffffffc02064de:	036c8263          	beq	s9,s6,ffffffffc0206502 <vprintfmt+0x1ca>
                    putch('?', putdat);
ffffffffc02064e2:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02064e4:	18098463          	beqz	s3,ffffffffc020666c <vprintfmt+0x334>
ffffffffc02064e8:	3781                	addiw	a5,a5,-32
ffffffffc02064ea:	18fbf163          	bleu	a5,s7,ffffffffc020666c <vprintfmt+0x334>
                    putch('?', putdat);
ffffffffc02064ee:	03f00513          	li	a0,63
ffffffffc02064f2:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02064f4:	0405                	addi	s0,s0,1
ffffffffc02064f6:	fff44783          	lbu	a5,-1(s0)
ffffffffc02064fa:	3dfd                	addiw	s11,s11,-1
ffffffffc02064fc:	0007851b          	sext.w	a0,a5
ffffffffc0206500:	fd61                	bnez	a0,ffffffffc02064d8 <vprintfmt+0x1a0>
            for (; width > 0; width --) {
ffffffffc0206502:	e7b058e3          	blez	s11,ffffffffc0206372 <vprintfmt+0x3a>
ffffffffc0206506:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0206508:	85a6                	mv	a1,s1
ffffffffc020650a:	02000513          	li	a0,32
ffffffffc020650e:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0206510:	e60d81e3          	beqz	s11,ffffffffc0206372 <vprintfmt+0x3a>
ffffffffc0206514:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0206516:	85a6                	mv	a1,s1
ffffffffc0206518:	02000513          	li	a0,32
ffffffffc020651c:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc020651e:	fe0d94e3          	bnez	s11,ffffffffc0206506 <vprintfmt+0x1ce>
ffffffffc0206522:	bd81                	j	ffffffffc0206372 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0206524:	4705                	li	a4,1
ffffffffc0206526:	008a8593          	addi	a1,s5,8
ffffffffc020652a:	01074463          	blt	a4,a6,ffffffffc0206532 <vprintfmt+0x1fa>
    else if (lflag) {
ffffffffc020652e:	12080063          	beqz	a6,ffffffffc020664e <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
ffffffffc0206532:	000ab603          	ld	a2,0(s5)
ffffffffc0206536:	46a9                	li	a3,10
ffffffffc0206538:	8aae                	mv	s5,a1
ffffffffc020653a:	b7bd                	j	ffffffffc02064a8 <vprintfmt+0x170>
ffffffffc020653c:	00144603          	lbu	a2,1(s0)
            padc = '-';
ffffffffc0206540:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206544:	846a                	mv	s0,s10
ffffffffc0206546:	b5ad                	j	ffffffffc02063b0 <vprintfmt+0x78>
            putch(ch, putdat);
ffffffffc0206548:	85a6                	mv	a1,s1
ffffffffc020654a:	02500513          	li	a0,37
ffffffffc020654e:	9902                	jalr	s2
            break;
ffffffffc0206550:	b50d                	j	ffffffffc0206372 <vprintfmt+0x3a>
            precision = va_arg(ap, int);
ffffffffc0206552:	000aac83          	lw	s9,0(s5)
            goto process_precision;
ffffffffc0206556:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc020655a:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020655c:	846a                	mv	s0,s10
            if (width < 0)
ffffffffc020655e:	e40dd9e3          	bgez	s11,ffffffffc02063b0 <vprintfmt+0x78>
                width = precision, precision = -1;
ffffffffc0206562:	8de6                	mv	s11,s9
ffffffffc0206564:	5cfd                	li	s9,-1
ffffffffc0206566:	b5a9                	j	ffffffffc02063b0 <vprintfmt+0x78>
            goto reswitch;
ffffffffc0206568:	00144603          	lbu	a2,1(s0)
            padc = '0';
ffffffffc020656c:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206570:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0206572:	bd3d                	j	ffffffffc02063b0 <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
ffffffffc0206574:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
ffffffffc0206578:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020657c:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc020657e:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0206582:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0206586:	fcd56ce3          	bltu	a0,a3,ffffffffc020655e <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
ffffffffc020658a:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc020658c:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
ffffffffc0206590:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0206594:	0196873b          	addw	a4,a3,s9
ffffffffc0206598:	0017171b          	slliw	a4,a4,0x1
ffffffffc020659c:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
ffffffffc02065a0:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
ffffffffc02065a4:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc02065a8:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc02065ac:	fcd57fe3          	bleu	a3,a0,ffffffffc020658a <vprintfmt+0x252>
ffffffffc02065b0:	b77d                	j	ffffffffc020655e <vprintfmt+0x226>
            if (width < 0)
ffffffffc02065b2:	fffdc693          	not	a3,s11
ffffffffc02065b6:	96fd                	srai	a3,a3,0x3f
ffffffffc02065b8:	00ddfdb3          	and	s11,s11,a3
ffffffffc02065bc:	00144603          	lbu	a2,1(s0)
ffffffffc02065c0:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02065c2:	846a                	mv	s0,s10
ffffffffc02065c4:	b3f5                	j	ffffffffc02063b0 <vprintfmt+0x78>
            putch('%', putdat);
ffffffffc02065c6:	85a6                	mv	a1,s1
ffffffffc02065c8:	02500513          	li	a0,37
ffffffffc02065cc:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc02065ce:	fff44703          	lbu	a4,-1(s0)
ffffffffc02065d2:	02500793          	li	a5,37
ffffffffc02065d6:	8d22                	mv	s10,s0
ffffffffc02065d8:	d8f70de3          	beq	a4,a5,ffffffffc0206372 <vprintfmt+0x3a>
ffffffffc02065dc:	02500713          	li	a4,37
ffffffffc02065e0:	1d7d                	addi	s10,s10,-1
ffffffffc02065e2:	fffd4783          	lbu	a5,-1(s10)
ffffffffc02065e6:	fee79de3          	bne	a5,a4,ffffffffc02065e0 <vprintfmt+0x2a8>
ffffffffc02065ea:	b361                	j	ffffffffc0206372 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc02065ec:	00003617          	auipc	a2,0x3
ffffffffc02065f0:	89460613          	addi	a2,a2,-1900 # ffffffffc0208e80 <error_string+0x1a8>
ffffffffc02065f4:	85a6                	mv	a1,s1
ffffffffc02065f6:	854a                	mv	a0,s2
ffffffffc02065f8:	0ac000ef          	jal	ra,ffffffffc02066a4 <printfmt>
ffffffffc02065fc:	bb9d                	j	ffffffffc0206372 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc02065fe:	00003617          	auipc	a2,0x3
ffffffffc0206602:	87a60613          	addi	a2,a2,-1926 # ffffffffc0208e78 <error_string+0x1a0>
            if (width > 0 && padc != '-') {
ffffffffc0206606:	00003417          	auipc	s0,0x3
ffffffffc020660a:	87340413          	addi	s0,s0,-1933 # ffffffffc0208e79 <error_string+0x1a1>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020660e:	8532                	mv	a0,a2
ffffffffc0206610:	85e6                	mv	a1,s9
ffffffffc0206612:	e032                	sd	a2,0(sp)
ffffffffc0206614:	e43e                	sd	a5,8(sp)
ffffffffc0206616:	0cc000ef          	jal	ra,ffffffffc02066e2 <strnlen>
ffffffffc020661a:	40ad8dbb          	subw	s11,s11,a0
ffffffffc020661e:	6602                	ld	a2,0(sp)
ffffffffc0206620:	01b05d63          	blez	s11,ffffffffc020663a <vprintfmt+0x302>
ffffffffc0206624:	67a2                	ld	a5,8(sp)
ffffffffc0206626:	2781                	sext.w	a5,a5
ffffffffc0206628:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
ffffffffc020662a:	6522                	ld	a0,8(sp)
ffffffffc020662c:	85a6                	mv	a1,s1
ffffffffc020662e:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0206630:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0206632:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0206634:	6602                	ld	a2,0(sp)
ffffffffc0206636:	fe0d9ae3          	bnez	s11,ffffffffc020662a <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020663a:	00064783          	lbu	a5,0(a2)
ffffffffc020663e:	0007851b          	sext.w	a0,a5
ffffffffc0206642:	e8051be3          	bnez	a0,ffffffffc02064d8 <vprintfmt+0x1a0>
ffffffffc0206646:	b335                	j	ffffffffc0206372 <vprintfmt+0x3a>
        return va_arg(*ap, int);
ffffffffc0206648:	000aa403          	lw	s0,0(s5)
ffffffffc020664c:	bbf1                	j	ffffffffc0206428 <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
ffffffffc020664e:	000ae603          	lwu	a2,0(s5)
ffffffffc0206652:	46a9                	li	a3,10
ffffffffc0206654:	8aae                	mv	s5,a1
ffffffffc0206656:	bd89                	j	ffffffffc02064a8 <vprintfmt+0x170>
ffffffffc0206658:	000ae603          	lwu	a2,0(s5)
ffffffffc020665c:	46c1                	li	a3,16
ffffffffc020665e:	8aae                	mv	s5,a1
ffffffffc0206660:	b5a1                	j	ffffffffc02064a8 <vprintfmt+0x170>
ffffffffc0206662:	000ae603          	lwu	a2,0(s5)
ffffffffc0206666:	46a1                	li	a3,8
ffffffffc0206668:	8aae                	mv	s5,a1
ffffffffc020666a:	bd3d                	j	ffffffffc02064a8 <vprintfmt+0x170>
                    putch(ch, putdat);
ffffffffc020666c:	9902                	jalr	s2
ffffffffc020666e:	b559                	j	ffffffffc02064f4 <vprintfmt+0x1bc>
                putch('-', putdat);
ffffffffc0206670:	85a6                	mv	a1,s1
ffffffffc0206672:	02d00513          	li	a0,45
ffffffffc0206676:	e03e                	sd	a5,0(sp)
ffffffffc0206678:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc020667a:	8ace                	mv	s5,s3
ffffffffc020667c:	40800633          	neg	a2,s0
ffffffffc0206680:	46a9                	li	a3,10
ffffffffc0206682:	6782                	ld	a5,0(sp)
ffffffffc0206684:	b515                	j	ffffffffc02064a8 <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
ffffffffc0206686:	01b05663          	blez	s11,ffffffffc0206692 <vprintfmt+0x35a>
ffffffffc020668a:	02d00693          	li	a3,45
ffffffffc020668e:	f6d798e3          	bne	a5,a3,ffffffffc02065fe <vprintfmt+0x2c6>
ffffffffc0206692:	00002417          	auipc	s0,0x2
ffffffffc0206696:	7e740413          	addi	s0,s0,2023 # ffffffffc0208e79 <error_string+0x1a1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020669a:	02800513          	li	a0,40
ffffffffc020669e:	02800793          	li	a5,40
ffffffffc02066a2:	bd1d                	j	ffffffffc02064d8 <vprintfmt+0x1a0>

ffffffffc02066a4 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02066a4:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc02066a6:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02066aa:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02066ac:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02066ae:	ec06                	sd	ra,24(sp)
ffffffffc02066b0:	f83a                	sd	a4,48(sp)
ffffffffc02066b2:	fc3e                	sd	a5,56(sp)
ffffffffc02066b4:	e0c2                	sd	a6,64(sp)
ffffffffc02066b6:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc02066b8:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02066ba:	c7fff0ef          	jal	ra,ffffffffc0206338 <vprintfmt>
}
ffffffffc02066be:	60e2                	ld	ra,24(sp)
ffffffffc02066c0:	6161                	addi	sp,sp,80
ffffffffc02066c2:	8082                	ret

ffffffffc02066c4 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc02066c4:	00054783          	lbu	a5,0(a0)
ffffffffc02066c8:	cb91                	beqz	a5,ffffffffc02066dc <strlen+0x18>
    size_t cnt = 0;
ffffffffc02066ca:	4781                	li	a5,0
        cnt ++;
ffffffffc02066cc:	0785                	addi	a5,a5,1
    while (*s ++ != '\0') {
ffffffffc02066ce:	00f50733          	add	a4,a0,a5
ffffffffc02066d2:	00074703          	lbu	a4,0(a4)
ffffffffc02066d6:	fb7d                	bnez	a4,ffffffffc02066cc <strlen+0x8>
    }
    return cnt;
}
ffffffffc02066d8:	853e                	mv	a0,a5
ffffffffc02066da:	8082                	ret
    size_t cnt = 0;
ffffffffc02066dc:	4781                	li	a5,0
}
ffffffffc02066de:	853e                	mv	a0,a5
ffffffffc02066e0:	8082                	ret

ffffffffc02066e2 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
ffffffffc02066e2:	c185                	beqz	a1,ffffffffc0206702 <strnlen+0x20>
ffffffffc02066e4:	00054783          	lbu	a5,0(a0)
ffffffffc02066e8:	cf89                	beqz	a5,ffffffffc0206702 <strnlen+0x20>
    size_t cnt = 0;
ffffffffc02066ea:	4781                	li	a5,0
ffffffffc02066ec:	a021                	j	ffffffffc02066f4 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
ffffffffc02066ee:	00074703          	lbu	a4,0(a4)
ffffffffc02066f2:	c711                	beqz	a4,ffffffffc02066fe <strnlen+0x1c>
        cnt ++;
ffffffffc02066f4:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc02066f6:	00f50733          	add	a4,a0,a5
ffffffffc02066fa:	fef59ae3          	bne	a1,a5,ffffffffc02066ee <strnlen+0xc>
    }
    return cnt;
}
ffffffffc02066fe:	853e                	mv	a0,a5
ffffffffc0206700:	8082                	ret
    size_t cnt = 0;
ffffffffc0206702:	4781                	li	a5,0
}
ffffffffc0206704:	853e                	mv	a0,a5
ffffffffc0206706:	8082                	ret

ffffffffc0206708 <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc0206708:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc020670a:	0585                	addi	a1,a1,1
ffffffffc020670c:	fff5c703          	lbu	a4,-1(a1)
ffffffffc0206710:	0785                	addi	a5,a5,1
ffffffffc0206712:	fee78fa3          	sb	a4,-1(a5)
ffffffffc0206716:	fb75                	bnez	a4,ffffffffc020670a <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc0206718:	8082                	ret

ffffffffc020671a <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020671a:	00054783          	lbu	a5,0(a0)
ffffffffc020671e:	0005c703          	lbu	a4,0(a1)
ffffffffc0206722:	cb91                	beqz	a5,ffffffffc0206736 <strcmp+0x1c>
ffffffffc0206724:	00e79c63          	bne	a5,a4,ffffffffc020673c <strcmp+0x22>
        s1 ++, s2 ++;
ffffffffc0206728:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020672a:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
ffffffffc020672e:	0585                	addi	a1,a1,1
ffffffffc0206730:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0206734:	fbe5                	bnez	a5,ffffffffc0206724 <strcmp+0xa>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0206736:	4501                	li	a0,0
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0206738:	9d19                	subw	a0,a0,a4
ffffffffc020673a:	8082                	ret
ffffffffc020673c:	0007851b          	sext.w	a0,a5
ffffffffc0206740:	9d19                	subw	a0,a0,a4
ffffffffc0206742:	8082                	ret

ffffffffc0206744 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0206744:	00054783          	lbu	a5,0(a0)
ffffffffc0206748:	cb91                	beqz	a5,ffffffffc020675c <strchr+0x18>
        if (*s == c) {
ffffffffc020674a:	00b79563          	bne	a5,a1,ffffffffc0206754 <strchr+0x10>
ffffffffc020674e:	a809                	j	ffffffffc0206760 <strchr+0x1c>
ffffffffc0206750:	00b78763          	beq	a5,a1,ffffffffc020675e <strchr+0x1a>
            return (char *)s;
        }
        s ++;
ffffffffc0206754:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0206756:	00054783          	lbu	a5,0(a0)
ffffffffc020675a:	fbfd                	bnez	a5,ffffffffc0206750 <strchr+0xc>
    }
    return NULL;
ffffffffc020675c:	4501                	li	a0,0
}
ffffffffc020675e:	8082                	ret
ffffffffc0206760:	8082                	ret

ffffffffc0206762 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0206762:	ca01                	beqz	a2,ffffffffc0206772 <memset+0x10>
ffffffffc0206764:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0206766:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0206768:	0785                	addi	a5,a5,1
ffffffffc020676a:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc020676e:	fec79de3          	bne	a5,a2,ffffffffc0206768 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0206772:	8082                	ret

ffffffffc0206774 <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc0206774:	ca19                	beqz	a2,ffffffffc020678a <memcpy+0x16>
ffffffffc0206776:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc0206778:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc020677a:	0585                	addi	a1,a1,1
ffffffffc020677c:	fff5c703          	lbu	a4,-1(a1)
ffffffffc0206780:	0785                	addi	a5,a5,1
ffffffffc0206782:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc0206786:	fec59ae3          	bne	a1,a2,ffffffffc020677a <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc020678a:	8082                	ret
