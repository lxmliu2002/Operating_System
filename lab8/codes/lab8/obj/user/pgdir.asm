
obj/__user_pgdir.out：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000000800020 <open>:
  800020:	1582                	slli	a1,a1,0x20
  800022:	9181                	srli	a1,a1,0x20
  800024:	1220006f          	j	800146 <sys_open>

0000000000800028 <close>:
  800028:	12a0006f          	j	800152 <sys_close>

000000000080002c <dup2>:
  80002c:	1300006f          	j	80015c <sys_dup>

0000000000800030 <_start>:
  800030:	19a000ef          	jal	ra,8001ca <umain>
  800034:	a001                	j	800034 <_start+0x4>

0000000000800036 <__warn>:
  800036:	715d                	addi	sp,sp,-80
  800038:	e822                	sd	s0,16(sp)
  80003a:	fc3e                	sd	a5,56(sp)
  80003c:	8432                	mv	s0,a2
  80003e:	103c                	addi	a5,sp,40
  800040:	862e                	mv	a2,a1
  800042:	85aa                	mv	a1,a0
  800044:	00000517          	auipc	a0,0x0
  800048:	69450513          	addi	a0,a0,1684 # 8006d8 <main+0x52>
  80004c:	ec06                	sd	ra,24(sp)
  80004e:	f436                	sd	a3,40(sp)
  800050:	f83a                	sd	a4,48(sp)
  800052:	e0c2                	sd	a6,64(sp)
  800054:	e4c6                	sd	a7,72(sp)
  800056:	e43e                	sd	a5,8(sp)
  800058:	060000ef          	jal	ra,8000b8 <cprintf>
  80005c:	65a2                	ld	a1,8(sp)
  80005e:	8522                	mv	a0,s0
  800060:	032000ef          	jal	ra,800092 <vcprintf>
  800064:	00000517          	auipc	a0,0x0
  800068:	6cc50513          	addi	a0,a0,1740 # 800730 <main+0xaa>
  80006c:	04c000ef          	jal	ra,8000b8 <cprintf>
  800070:	60e2                	ld	ra,24(sp)
  800072:	6442                	ld	s0,16(sp)
  800074:	6161                	addi	sp,sp,80
  800076:	8082                	ret

0000000000800078 <cputch>:
  800078:	1141                	addi	sp,sp,-16
  80007a:	e022                	sd	s0,0(sp)
  80007c:	e406                	sd	ra,8(sp)
  80007e:	842e                	mv	s0,a1
  800080:	0b8000ef          	jal	ra,800138 <sys_putc>
  800084:	401c                	lw	a5,0(s0)
  800086:	60a2                	ld	ra,8(sp)
  800088:	2785                	addiw	a5,a5,1
  80008a:	c01c                	sw	a5,0(s0)
  80008c:	6402                	ld	s0,0(sp)
  80008e:	0141                	addi	sp,sp,16
  800090:	8082                	ret

0000000000800092 <vcprintf>:
  800092:	1101                	addi	sp,sp,-32
  800094:	872e                	mv	a4,a1
  800096:	75dd                	lui	a1,0xffff7
  800098:	86aa                	mv	a3,a0
  80009a:	0070                	addi	a2,sp,12
  80009c:	00000517          	auipc	a0,0x0
  8000a0:	fdc50513          	addi	a0,a0,-36 # 800078 <cputch>
  8000a4:	ad958593          	addi	a1,a1,-1319 # ffffffffffff6ad9 <error_string+0xffffffffff7f6209>
  8000a8:	ec06                	sd	ra,24(sp)
  8000aa:	c602                	sw	zero,12(sp)
  8000ac:	208000ef          	jal	ra,8002b4 <vprintfmt>
  8000b0:	60e2                	ld	ra,24(sp)
  8000b2:	4532                	lw	a0,12(sp)
  8000b4:	6105                	addi	sp,sp,32
  8000b6:	8082                	ret

00000000008000b8 <cprintf>:
  8000b8:	711d                	addi	sp,sp,-96
  8000ba:	02810313          	addi	t1,sp,40
  8000be:	f42e                	sd	a1,40(sp)
  8000c0:	75dd                	lui	a1,0xffff7
  8000c2:	f832                	sd	a2,48(sp)
  8000c4:	fc36                	sd	a3,56(sp)
  8000c6:	e0ba                	sd	a4,64(sp)
  8000c8:	86aa                	mv	a3,a0
  8000ca:	0050                	addi	a2,sp,4
  8000cc:	00000517          	auipc	a0,0x0
  8000d0:	fac50513          	addi	a0,a0,-84 # 800078 <cputch>
  8000d4:	871a                	mv	a4,t1
  8000d6:	ad958593          	addi	a1,a1,-1319 # ffffffffffff6ad9 <error_string+0xffffffffff7f6209>
  8000da:	ec06                	sd	ra,24(sp)
  8000dc:	e4be                	sd	a5,72(sp)
  8000de:	e8c2                	sd	a6,80(sp)
  8000e0:	ecc6                	sd	a7,88(sp)
  8000e2:	e41a                	sd	t1,8(sp)
  8000e4:	c202                	sw	zero,4(sp)
  8000e6:	1ce000ef          	jal	ra,8002b4 <vprintfmt>
  8000ea:	60e2                	ld	ra,24(sp)
  8000ec:	4512                	lw	a0,4(sp)
  8000ee:	6125                	addi	sp,sp,96
  8000f0:	8082                	ret

00000000008000f2 <syscall>:
  8000f2:	7175                	addi	sp,sp,-144
  8000f4:	f8ba                	sd	a4,112(sp)
  8000f6:	e0ba                	sd	a4,64(sp)
  8000f8:	0118                	addi	a4,sp,128
  8000fa:	e42a                	sd	a0,8(sp)
  8000fc:	ecae                	sd	a1,88(sp)
  8000fe:	f0b2                	sd	a2,96(sp)
  800100:	f4b6                	sd	a3,104(sp)
  800102:	fcbe                	sd	a5,120(sp)
  800104:	e142                	sd	a6,128(sp)
  800106:	e546                	sd	a7,136(sp)
  800108:	f42e                	sd	a1,40(sp)
  80010a:	f832                	sd	a2,48(sp)
  80010c:	fc36                	sd	a3,56(sp)
  80010e:	f03a                	sd	a4,32(sp)
  800110:	e4be                	sd	a5,72(sp)
  800112:	4522                	lw	a0,8(sp)
  800114:	55a2                	lw	a1,40(sp)
  800116:	5642                	lw	a2,48(sp)
  800118:	56e2                	lw	a3,56(sp)
  80011a:	4706                	lw	a4,64(sp)
  80011c:	47a6                	lw	a5,72(sp)
  80011e:	00000073          	ecall
  800122:	ce2a                	sw	a0,28(sp)
  800124:	4572                	lw	a0,28(sp)
  800126:	6149                	addi	sp,sp,144
  800128:	8082                	ret

000000000080012a <sys_exit>:
  80012a:	85aa                	mv	a1,a0
  80012c:	4505                	li	a0,1
  80012e:	fc5ff06f          	j	8000f2 <syscall>

0000000000800132 <sys_getpid>:
  800132:	4549                	li	a0,18
  800134:	fbfff06f          	j	8000f2 <syscall>

0000000000800138 <sys_putc>:
  800138:	85aa                	mv	a1,a0
  80013a:	4579                	li	a0,30
  80013c:	fb7ff06f          	j	8000f2 <syscall>

0000000000800140 <sys_pgdir>:
  800140:	457d                	li	a0,31
  800142:	fb1ff06f          	j	8000f2 <syscall>

0000000000800146 <sys_open>:
  800146:	862e                	mv	a2,a1
  800148:	85aa                	mv	a1,a0
  80014a:	06400513          	li	a0,100
  80014e:	fa5ff06f          	j	8000f2 <syscall>

0000000000800152 <sys_close>:
  800152:	85aa                	mv	a1,a0
  800154:	06500513          	li	a0,101
  800158:	f9bff06f          	j	8000f2 <syscall>

000000000080015c <sys_dup>:
  80015c:	862e                	mv	a2,a1
  80015e:	85aa                	mv	a1,a0
  800160:	08200513          	li	a0,130
  800164:	f8fff06f          	j	8000f2 <syscall>

0000000000800168 <exit>:
  800168:	1141                	addi	sp,sp,-16
  80016a:	e406                	sd	ra,8(sp)
  80016c:	fbfff0ef          	jal	ra,80012a <sys_exit>
  800170:	00000517          	auipc	a0,0x0
  800174:	58850513          	addi	a0,a0,1416 # 8006f8 <main+0x72>
  800178:	f41ff0ef          	jal	ra,8000b8 <cprintf>
  80017c:	a001                	j	80017c <exit+0x14>

000000000080017e <getpid>:
  80017e:	fb5ff06f          	j	800132 <sys_getpid>

0000000000800182 <print_pgdir>:
  800182:	fbfff06f          	j	800140 <sys_pgdir>

0000000000800186 <initfd>:
  800186:	1101                	addi	sp,sp,-32
  800188:	87ae                	mv	a5,a1
  80018a:	e426                	sd	s1,8(sp)
  80018c:	85b2                	mv	a1,a2
  80018e:	84aa                	mv	s1,a0
  800190:	853e                	mv	a0,a5
  800192:	e822                	sd	s0,16(sp)
  800194:	ec06                	sd	ra,24(sp)
  800196:	e8bff0ef          	jal	ra,800020 <open>
  80019a:	842a                	mv	s0,a0
  80019c:	00054463          	bltz	a0,8001a4 <initfd+0x1e>
  8001a0:	00951863          	bne	a0,s1,8001b0 <initfd+0x2a>
  8001a4:	8522                	mv	a0,s0
  8001a6:	60e2                	ld	ra,24(sp)
  8001a8:	6442                	ld	s0,16(sp)
  8001aa:	64a2                	ld	s1,8(sp)
  8001ac:	6105                	addi	sp,sp,32
  8001ae:	8082                	ret
  8001b0:	8526                	mv	a0,s1
  8001b2:	e77ff0ef          	jal	ra,800028 <close>
  8001b6:	85a6                	mv	a1,s1
  8001b8:	8522                	mv	a0,s0
  8001ba:	e73ff0ef          	jal	ra,80002c <dup2>
  8001be:	84aa                	mv	s1,a0
  8001c0:	8522                	mv	a0,s0
  8001c2:	e67ff0ef          	jal	ra,800028 <close>
  8001c6:	8426                	mv	s0,s1
  8001c8:	bff1                	j	8001a4 <initfd+0x1e>

00000000008001ca <umain>:
  8001ca:	1101                	addi	sp,sp,-32
  8001cc:	e822                	sd	s0,16(sp)
  8001ce:	e426                	sd	s1,8(sp)
  8001d0:	842a                	mv	s0,a0
  8001d2:	84ae                	mv	s1,a1
  8001d4:	4601                	li	a2,0
  8001d6:	00000597          	auipc	a1,0x0
  8001da:	53a58593          	addi	a1,a1,1338 # 800710 <main+0x8a>
  8001de:	4501                	li	a0,0
  8001e0:	ec06                	sd	ra,24(sp)
  8001e2:	fa5ff0ef          	jal	ra,800186 <initfd>
  8001e6:	02054263          	bltz	a0,80020a <umain+0x40>
  8001ea:	4605                	li	a2,1
  8001ec:	00000597          	auipc	a1,0x0
  8001f0:	56458593          	addi	a1,a1,1380 # 800750 <main+0xca>
  8001f4:	4505                	li	a0,1
  8001f6:	f91ff0ef          	jal	ra,800186 <initfd>
  8001fa:	02054563          	bltz	a0,800224 <umain+0x5a>
  8001fe:	85a6                	mv	a1,s1
  800200:	8522                	mv	a0,s0
  800202:	484000ef          	jal	ra,800686 <main>
  800206:	f63ff0ef          	jal	ra,800168 <exit>
  80020a:	86aa                	mv	a3,a0
  80020c:	00000617          	auipc	a2,0x0
  800210:	50c60613          	addi	a2,a2,1292 # 800718 <main+0x92>
  800214:	45e9                	li	a1,26
  800216:	00000517          	auipc	a0,0x0
  80021a:	52250513          	addi	a0,a0,1314 # 800738 <main+0xb2>
  80021e:	e19ff0ef          	jal	ra,800036 <__warn>
  800222:	b7e1                	j	8001ea <umain+0x20>
  800224:	86aa                	mv	a3,a0
  800226:	00000617          	auipc	a2,0x0
  80022a:	53260613          	addi	a2,a2,1330 # 800758 <main+0xd2>
  80022e:	45f5                	li	a1,29
  800230:	00000517          	auipc	a0,0x0
  800234:	50850513          	addi	a0,a0,1288 # 800738 <main+0xb2>
  800238:	dffff0ef          	jal	ra,800036 <__warn>
  80023c:	b7c9                	j	8001fe <umain+0x34>

000000000080023e <printnum>:
  80023e:	02071893          	slli	a7,a4,0x20
  800242:	7139                	addi	sp,sp,-64
  800244:	0208d893          	srli	a7,a7,0x20
  800248:	e456                	sd	s5,8(sp)
  80024a:	0316fab3          	remu	s5,a3,a7
  80024e:	f822                	sd	s0,48(sp)
  800250:	f426                	sd	s1,40(sp)
  800252:	f04a                	sd	s2,32(sp)
  800254:	ec4e                	sd	s3,24(sp)
  800256:	fc06                	sd	ra,56(sp)
  800258:	e852                	sd	s4,16(sp)
  80025a:	84aa                	mv	s1,a0
  80025c:	89ae                	mv	s3,a1
  80025e:	8932                	mv	s2,a2
  800260:	fff7841b          	addiw	s0,a5,-1
  800264:	2a81                	sext.w	s5,s5
  800266:	0516f163          	bleu	a7,a3,8002a8 <printnum+0x6a>
  80026a:	8a42                	mv	s4,a6
  80026c:	00805863          	blez	s0,80027c <printnum+0x3e>
  800270:	347d                	addiw	s0,s0,-1
  800272:	864e                	mv	a2,s3
  800274:	85ca                	mv	a1,s2
  800276:	8552                	mv	a0,s4
  800278:	9482                	jalr	s1
  80027a:	f87d                	bnez	s0,800270 <printnum+0x32>
  80027c:	1a82                	slli	s5,s5,0x20
  80027e:	020ada93          	srli	s5,s5,0x20
  800282:	00000797          	auipc	a5,0x0
  800286:	71678793          	addi	a5,a5,1814 # 800998 <error_string+0xc8>
  80028a:	9abe                	add	s5,s5,a5
  80028c:	7442                	ld	s0,48(sp)
  80028e:	000ac503          	lbu	a0,0(s5)
  800292:	70e2                	ld	ra,56(sp)
  800294:	6a42                	ld	s4,16(sp)
  800296:	6aa2                	ld	s5,8(sp)
  800298:	864e                	mv	a2,s3
  80029a:	85ca                	mv	a1,s2
  80029c:	69e2                	ld	s3,24(sp)
  80029e:	7902                	ld	s2,32(sp)
  8002a0:	8326                	mv	t1,s1
  8002a2:	74a2                	ld	s1,40(sp)
  8002a4:	6121                	addi	sp,sp,64
  8002a6:	8302                	jr	t1
  8002a8:	0316d6b3          	divu	a3,a3,a7
  8002ac:	87a2                	mv	a5,s0
  8002ae:	f91ff0ef          	jal	ra,80023e <printnum>
  8002b2:	b7e9                	j	80027c <printnum+0x3e>

00000000008002b4 <vprintfmt>:
  8002b4:	7119                	addi	sp,sp,-128
  8002b6:	f4a6                	sd	s1,104(sp)
  8002b8:	f0ca                	sd	s2,96(sp)
  8002ba:	ecce                	sd	s3,88(sp)
  8002bc:	e4d6                	sd	s5,72(sp)
  8002be:	e0da                	sd	s6,64(sp)
  8002c0:	fc5e                	sd	s7,56(sp)
  8002c2:	f862                	sd	s8,48(sp)
  8002c4:	ec6e                	sd	s11,24(sp)
  8002c6:	fc86                	sd	ra,120(sp)
  8002c8:	f8a2                	sd	s0,112(sp)
  8002ca:	e8d2                	sd	s4,80(sp)
  8002cc:	f466                	sd	s9,40(sp)
  8002ce:	f06a                	sd	s10,32(sp)
  8002d0:	89aa                	mv	s3,a0
  8002d2:	892e                	mv	s2,a1
  8002d4:	84b2                	mv	s1,a2
  8002d6:	8db6                	mv	s11,a3
  8002d8:	8b3a                	mv	s6,a4
  8002da:	5bfd                	li	s7,-1
  8002dc:	00000a97          	auipc	s5,0x0
  8002e0:	498a8a93          	addi	s5,s5,1176 # 800774 <main+0xee>
  8002e4:	05e00c13          	li	s8,94
  8002e8:	000dc503          	lbu	a0,0(s11)
  8002ec:	02500793          	li	a5,37
  8002f0:	001d8413          	addi	s0,s11,1
  8002f4:	00f50f63          	beq	a0,a5,800312 <vprintfmt+0x5e>
  8002f8:	c529                	beqz	a0,800342 <vprintfmt+0x8e>
  8002fa:	02500a13          	li	s4,37
  8002fe:	a011                	j	800302 <vprintfmt+0x4e>
  800300:	c129                	beqz	a0,800342 <vprintfmt+0x8e>
  800302:	864a                	mv	a2,s2
  800304:	85a6                	mv	a1,s1
  800306:	0405                	addi	s0,s0,1
  800308:	9982                	jalr	s3
  80030a:	fff44503          	lbu	a0,-1(s0)
  80030e:	ff4519e3          	bne	a0,s4,800300 <vprintfmt+0x4c>
  800312:	00044603          	lbu	a2,0(s0)
  800316:	02000813          	li	a6,32
  80031a:	4a01                	li	s4,0
  80031c:	4881                	li	a7,0
  80031e:	5d7d                	li	s10,-1
  800320:	5cfd                	li	s9,-1
  800322:	05500593          	li	a1,85
  800326:	4525                	li	a0,9
  800328:	fdd6071b          	addiw	a4,a2,-35
  80032c:	0ff77713          	andi	a4,a4,255
  800330:	00140d93          	addi	s11,s0,1
  800334:	22e5e363          	bltu	a1,a4,80055a <vprintfmt+0x2a6>
  800338:	070a                	slli	a4,a4,0x2
  80033a:	9756                	add	a4,a4,s5
  80033c:	4318                	lw	a4,0(a4)
  80033e:	9756                	add	a4,a4,s5
  800340:	8702                	jr	a4
  800342:	70e6                	ld	ra,120(sp)
  800344:	7446                	ld	s0,112(sp)
  800346:	74a6                	ld	s1,104(sp)
  800348:	7906                	ld	s2,96(sp)
  80034a:	69e6                	ld	s3,88(sp)
  80034c:	6a46                	ld	s4,80(sp)
  80034e:	6aa6                	ld	s5,72(sp)
  800350:	6b06                	ld	s6,64(sp)
  800352:	7be2                	ld	s7,56(sp)
  800354:	7c42                	ld	s8,48(sp)
  800356:	7ca2                	ld	s9,40(sp)
  800358:	7d02                	ld	s10,32(sp)
  80035a:	6de2                	ld	s11,24(sp)
  80035c:	6109                	addi	sp,sp,128
  80035e:	8082                	ret
  800360:	4705                	li	a4,1
  800362:	008b0613          	addi	a2,s6,8
  800366:	01174463          	blt	a4,a7,80036e <vprintfmt+0xba>
  80036a:	28088563          	beqz	a7,8005f4 <vprintfmt+0x340>
  80036e:	000b3683          	ld	a3,0(s6)
  800372:	4741                	li	a4,16
  800374:	8b32                	mv	s6,a2
  800376:	a86d                	j	800430 <vprintfmt+0x17c>
  800378:	00144603          	lbu	a2,1(s0)
  80037c:	4a05                	li	s4,1
  80037e:	846e                	mv	s0,s11
  800380:	b765                	j	800328 <vprintfmt+0x74>
  800382:	000b2503          	lw	a0,0(s6)
  800386:	864a                	mv	a2,s2
  800388:	85a6                	mv	a1,s1
  80038a:	0b21                	addi	s6,s6,8
  80038c:	9982                	jalr	s3
  80038e:	bfa9                	j	8002e8 <vprintfmt+0x34>
  800390:	4705                	li	a4,1
  800392:	008b0a13          	addi	s4,s6,8
  800396:	01174463          	blt	a4,a7,80039e <vprintfmt+0xea>
  80039a:	24088563          	beqz	a7,8005e4 <vprintfmt+0x330>
  80039e:	000b3403          	ld	s0,0(s6)
  8003a2:	26044563          	bltz	s0,80060c <vprintfmt+0x358>
  8003a6:	86a2                	mv	a3,s0
  8003a8:	8b52                	mv	s6,s4
  8003aa:	4729                	li	a4,10
  8003ac:	a051                	j	800430 <vprintfmt+0x17c>
  8003ae:	000b2783          	lw	a5,0(s6)
  8003b2:	46e1                	li	a3,24
  8003b4:	0b21                	addi	s6,s6,8
  8003b6:	41f7d71b          	sraiw	a4,a5,0x1f
  8003ba:	8fb9                	xor	a5,a5,a4
  8003bc:	40e7873b          	subw	a4,a5,a4
  8003c0:	1ce6c163          	blt	a3,a4,800582 <vprintfmt+0x2ce>
  8003c4:	00371793          	slli	a5,a4,0x3
  8003c8:	00000697          	auipc	a3,0x0
  8003cc:	50868693          	addi	a3,a3,1288 # 8008d0 <error_string>
  8003d0:	97b6                	add	a5,a5,a3
  8003d2:	639c                	ld	a5,0(a5)
  8003d4:	1a078763          	beqz	a5,800582 <vprintfmt+0x2ce>
  8003d8:	873e                	mv	a4,a5
  8003da:	00000697          	auipc	a3,0x0
  8003de:	7c668693          	addi	a3,a3,1990 # 800ba0 <error_string+0x2d0>
  8003e2:	8626                	mv	a2,s1
  8003e4:	85ca                	mv	a1,s2
  8003e6:	854e                	mv	a0,s3
  8003e8:	25a000ef          	jal	ra,800642 <printfmt>
  8003ec:	bdf5                	j	8002e8 <vprintfmt+0x34>
  8003ee:	00144603          	lbu	a2,1(s0)
  8003f2:	2885                	addiw	a7,a7,1
  8003f4:	846e                	mv	s0,s11
  8003f6:	bf0d                	j	800328 <vprintfmt+0x74>
  8003f8:	4705                	li	a4,1
  8003fa:	008b0613          	addi	a2,s6,8
  8003fe:	01174463          	blt	a4,a7,800406 <vprintfmt+0x152>
  800402:	1e088e63          	beqz	a7,8005fe <vprintfmt+0x34a>
  800406:	000b3683          	ld	a3,0(s6)
  80040a:	4721                	li	a4,8
  80040c:	8b32                	mv	s6,a2
  80040e:	a00d                	j	800430 <vprintfmt+0x17c>
  800410:	03000513          	li	a0,48
  800414:	864a                	mv	a2,s2
  800416:	85a6                	mv	a1,s1
  800418:	e042                	sd	a6,0(sp)
  80041a:	9982                	jalr	s3
  80041c:	864a                	mv	a2,s2
  80041e:	85a6                	mv	a1,s1
  800420:	07800513          	li	a0,120
  800424:	9982                	jalr	s3
  800426:	0b21                	addi	s6,s6,8
  800428:	ff8b3683          	ld	a3,-8(s6)
  80042c:	6802                	ld	a6,0(sp)
  80042e:	4741                	li	a4,16
  800430:	87e6                	mv	a5,s9
  800432:	8626                	mv	a2,s1
  800434:	85ca                	mv	a1,s2
  800436:	854e                	mv	a0,s3
  800438:	e07ff0ef          	jal	ra,80023e <printnum>
  80043c:	b575                	j	8002e8 <vprintfmt+0x34>
  80043e:	000b3703          	ld	a4,0(s6)
  800442:	0b21                	addi	s6,s6,8
  800444:	1e070063          	beqz	a4,800624 <vprintfmt+0x370>
  800448:	00170413          	addi	s0,a4,1
  80044c:	19905563          	blez	s9,8005d6 <vprintfmt+0x322>
  800450:	02d00613          	li	a2,45
  800454:	14c81963          	bne	a6,a2,8005a6 <vprintfmt+0x2f2>
  800458:	00074703          	lbu	a4,0(a4)
  80045c:	0007051b          	sext.w	a0,a4
  800460:	c90d                	beqz	a0,800492 <vprintfmt+0x1de>
  800462:	000d4563          	bltz	s10,80046c <vprintfmt+0x1b8>
  800466:	3d7d                	addiw	s10,s10,-1
  800468:	037d0363          	beq	s10,s7,80048e <vprintfmt+0x1da>
  80046c:	864a                	mv	a2,s2
  80046e:	85a6                	mv	a1,s1
  800470:	180a0c63          	beqz	s4,800608 <vprintfmt+0x354>
  800474:	3701                	addiw	a4,a4,-32
  800476:	18ec7963          	bleu	a4,s8,800608 <vprintfmt+0x354>
  80047a:	03f00513          	li	a0,63
  80047e:	9982                	jalr	s3
  800480:	0405                	addi	s0,s0,1
  800482:	fff44703          	lbu	a4,-1(s0)
  800486:	3cfd                	addiw	s9,s9,-1
  800488:	0007051b          	sext.w	a0,a4
  80048c:	f979                	bnez	a0,800462 <vprintfmt+0x1ae>
  80048e:	e5905de3          	blez	s9,8002e8 <vprintfmt+0x34>
  800492:	3cfd                	addiw	s9,s9,-1
  800494:	864a                	mv	a2,s2
  800496:	85a6                	mv	a1,s1
  800498:	02000513          	li	a0,32
  80049c:	9982                	jalr	s3
  80049e:	e40c85e3          	beqz	s9,8002e8 <vprintfmt+0x34>
  8004a2:	3cfd                	addiw	s9,s9,-1
  8004a4:	864a                	mv	a2,s2
  8004a6:	85a6                	mv	a1,s1
  8004a8:	02000513          	li	a0,32
  8004ac:	9982                	jalr	s3
  8004ae:	fe0c92e3          	bnez	s9,800492 <vprintfmt+0x1de>
  8004b2:	bd1d                	j	8002e8 <vprintfmt+0x34>
  8004b4:	4705                	li	a4,1
  8004b6:	008b0613          	addi	a2,s6,8
  8004ba:	01174463          	blt	a4,a7,8004c2 <vprintfmt+0x20e>
  8004be:	12088663          	beqz	a7,8005ea <vprintfmt+0x336>
  8004c2:	000b3683          	ld	a3,0(s6)
  8004c6:	4729                	li	a4,10
  8004c8:	8b32                	mv	s6,a2
  8004ca:	b79d                	j	800430 <vprintfmt+0x17c>
  8004cc:	00144603          	lbu	a2,1(s0)
  8004d0:	02d00813          	li	a6,45
  8004d4:	846e                	mv	s0,s11
  8004d6:	bd89                	j	800328 <vprintfmt+0x74>
  8004d8:	864a                	mv	a2,s2
  8004da:	85a6                	mv	a1,s1
  8004dc:	02500513          	li	a0,37
  8004e0:	9982                	jalr	s3
  8004e2:	b519                	j	8002e8 <vprintfmt+0x34>
  8004e4:	000b2d03          	lw	s10,0(s6)
  8004e8:	00144603          	lbu	a2,1(s0)
  8004ec:	0b21                	addi	s6,s6,8
  8004ee:	846e                	mv	s0,s11
  8004f0:	e20cdce3          	bgez	s9,800328 <vprintfmt+0x74>
  8004f4:	8cea                	mv	s9,s10
  8004f6:	5d7d                	li	s10,-1
  8004f8:	bd05                	j	800328 <vprintfmt+0x74>
  8004fa:	00144603          	lbu	a2,1(s0)
  8004fe:	03000813          	li	a6,48
  800502:	846e                	mv	s0,s11
  800504:	b515                	j	800328 <vprintfmt+0x74>
  800506:	fd060d1b          	addiw	s10,a2,-48
  80050a:	00144603          	lbu	a2,1(s0)
  80050e:	846e                	mv	s0,s11
  800510:	fd06071b          	addiw	a4,a2,-48
  800514:	0006031b          	sext.w	t1,a2
  800518:	fce56ce3          	bltu	a0,a4,8004f0 <vprintfmt+0x23c>
  80051c:	0405                	addi	s0,s0,1
  80051e:	002d171b          	slliw	a4,s10,0x2
  800522:	00044603          	lbu	a2,0(s0)
  800526:	01a706bb          	addw	a3,a4,s10
  80052a:	0016969b          	slliw	a3,a3,0x1
  80052e:	006686bb          	addw	a3,a3,t1
  800532:	fd06071b          	addiw	a4,a2,-48
  800536:	fd068d1b          	addiw	s10,a3,-48
  80053a:	0006031b          	sext.w	t1,a2
  80053e:	fce57fe3          	bleu	a4,a0,80051c <vprintfmt+0x268>
  800542:	b77d                	j	8004f0 <vprintfmt+0x23c>
  800544:	fffcc713          	not	a4,s9
  800548:	977d                	srai	a4,a4,0x3f
  80054a:	00ecf7b3          	and	a5,s9,a4
  80054e:	00144603          	lbu	a2,1(s0)
  800552:	00078c9b          	sext.w	s9,a5
  800556:	846e                	mv	s0,s11
  800558:	bbc1                	j	800328 <vprintfmt+0x74>
  80055a:	864a                	mv	a2,s2
  80055c:	85a6                	mv	a1,s1
  80055e:	02500513          	li	a0,37
  800562:	9982                	jalr	s3
  800564:	fff44703          	lbu	a4,-1(s0)
  800568:	02500793          	li	a5,37
  80056c:	8da2                	mv	s11,s0
  80056e:	d6f70de3          	beq	a4,a5,8002e8 <vprintfmt+0x34>
  800572:	02500713          	li	a4,37
  800576:	1dfd                	addi	s11,s11,-1
  800578:	fffdc783          	lbu	a5,-1(s11)
  80057c:	fee79de3          	bne	a5,a4,800576 <vprintfmt+0x2c2>
  800580:	b3a5                	j	8002e8 <vprintfmt+0x34>
  800582:	00000697          	auipc	a3,0x0
  800586:	60e68693          	addi	a3,a3,1550 # 800b90 <error_string+0x2c0>
  80058a:	8626                	mv	a2,s1
  80058c:	85ca                	mv	a1,s2
  80058e:	854e                	mv	a0,s3
  800590:	0b2000ef          	jal	ra,800642 <printfmt>
  800594:	bb91                	j	8002e8 <vprintfmt+0x34>
  800596:	00000717          	auipc	a4,0x0
  80059a:	5f270713          	addi	a4,a4,1522 # 800b88 <error_string+0x2b8>
  80059e:	00000417          	auipc	s0,0x0
  8005a2:	5eb40413          	addi	s0,s0,1515 # 800b89 <error_string+0x2b9>
  8005a6:	853a                	mv	a0,a4
  8005a8:	85ea                	mv	a1,s10
  8005aa:	e03a                	sd	a4,0(sp)
  8005ac:	e442                	sd	a6,8(sp)
  8005ae:	0b2000ef          	jal	ra,800660 <strnlen>
  8005b2:	40ac8cbb          	subw	s9,s9,a0
  8005b6:	6702                	ld	a4,0(sp)
  8005b8:	01905f63          	blez	s9,8005d6 <vprintfmt+0x322>
  8005bc:	6822                	ld	a6,8(sp)
  8005be:	0008079b          	sext.w	a5,a6
  8005c2:	e43e                	sd	a5,8(sp)
  8005c4:	6522                	ld	a0,8(sp)
  8005c6:	864a                	mv	a2,s2
  8005c8:	85a6                	mv	a1,s1
  8005ca:	e03a                	sd	a4,0(sp)
  8005cc:	3cfd                	addiw	s9,s9,-1
  8005ce:	9982                	jalr	s3
  8005d0:	6702                	ld	a4,0(sp)
  8005d2:	fe0c99e3          	bnez	s9,8005c4 <vprintfmt+0x310>
  8005d6:	00074703          	lbu	a4,0(a4)
  8005da:	0007051b          	sext.w	a0,a4
  8005de:	e80512e3          	bnez	a0,800462 <vprintfmt+0x1ae>
  8005e2:	b319                	j	8002e8 <vprintfmt+0x34>
  8005e4:	000b2403          	lw	s0,0(s6)
  8005e8:	bb6d                	j	8003a2 <vprintfmt+0xee>
  8005ea:	000b6683          	lwu	a3,0(s6)
  8005ee:	4729                	li	a4,10
  8005f0:	8b32                	mv	s6,a2
  8005f2:	bd3d                	j	800430 <vprintfmt+0x17c>
  8005f4:	000b6683          	lwu	a3,0(s6)
  8005f8:	4741                	li	a4,16
  8005fa:	8b32                	mv	s6,a2
  8005fc:	bd15                	j	800430 <vprintfmt+0x17c>
  8005fe:	000b6683          	lwu	a3,0(s6)
  800602:	4721                	li	a4,8
  800604:	8b32                	mv	s6,a2
  800606:	b52d                	j	800430 <vprintfmt+0x17c>
  800608:	9982                	jalr	s3
  80060a:	bd9d                	j	800480 <vprintfmt+0x1cc>
  80060c:	864a                	mv	a2,s2
  80060e:	85a6                	mv	a1,s1
  800610:	02d00513          	li	a0,45
  800614:	e042                	sd	a6,0(sp)
  800616:	9982                	jalr	s3
  800618:	8b52                	mv	s6,s4
  80061a:	408006b3          	neg	a3,s0
  80061e:	4729                	li	a4,10
  800620:	6802                	ld	a6,0(sp)
  800622:	b539                	j	800430 <vprintfmt+0x17c>
  800624:	01905663          	blez	s9,800630 <vprintfmt+0x37c>
  800628:	02d00713          	li	a4,45
  80062c:	f6e815e3          	bne	a6,a4,800596 <vprintfmt+0x2e2>
  800630:	00000417          	auipc	s0,0x0
  800634:	55940413          	addi	s0,s0,1369 # 800b89 <error_string+0x2b9>
  800638:	02800513          	li	a0,40
  80063c:	02800713          	li	a4,40
  800640:	b50d                	j	800462 <vprintfmt+0x1ae>

0000000000800642 <printfmt>:
  800642:	7139                	addi	sp,sp,-64
  800644:	02010313          	addi	t1,sp,32
  800648:	f03a                	sd	a4,32(sp)
  80064a:	871a                	mv	a4,t1
  80064c:	ec06                	sd	ra,24(sp)
  80064e:	f43e                	sd	a5,40(sp)
  800650:	f842                	sd	a6,48(sp)
  800652:	fc46                	sd	a7,56(sp)
  800654:	e41a                	sd	t1,8(sp)
  800656:	c5fff0ef          	jal	ra,8002b4 <vprintfmt>
  80065a:	60e2                	ld	ra,24(sp)
  80065c:	6121                	addi	sp,sp,64
  80065e:	8082                	ret

0000000000800660 <strnlen>:
  800660:	c185                	beqz	a1,800680 <strnlen+0x20>
  800662:	00054783          	lbu	a5,0(a0)
  800666:	cf89                	beqz	a5,800680 <strnlen+0x20>
  800668:	4781                	li	a5,0
  80066a:	a021                	j	800672 <strnlen+0x12>
  80066c:	00074703          	lbu	a4,0(a4)
  800670:	c711                	beqz	a4,80067c <strnlen+0x1c>
  800672:	0785                	addi	a5,a5,1
  800674:	00f50733          	add	a4,a0,a5
  800678:	fef59ae3          	bne	a1,a5,80066c <strnlen+0xc>
  80067c:	853e                	mv	a0,a5
  80067e:	8082                	ret
  800680:	4781                	li	a5,0
  800682:	853e                	mv	a0,a5
  800684:	8082                	ret

0000000000800686 <main>:
  800686:	1141                	addi	sp,sp,-16
  800688:	e406                	sd	ra,8(sp)
  80068a:	af5ff0ef          	jal	ra,80017e <getpid>
  80068e:	85aa                	mv	a1,a0
  800690:	00000517          	auipc	a0,0x0
  800694:	51850513          	addi	a0,a0,1304 # 800ba8 <error_string+0x2d8>
  800698:	a21ff0ef          	jal	ra,8000b8 <cprintf>
  80069c:	ae7ff0ef          	jal	ra,800182 <print_pgdir>
  8006a0:	00000517          	auipc	a0,0x0
  8006a4:	52050513          	addi	a0,a0,1312 # 800bc0 <error_string+0x2f0>
  8006a8:	a11ff0ef          	jal	ra,8000b8 <cprintf>
  8006ac:	60a2                	ld	ra,8(sp)
  8006ae:	4501                	li	a0,0
  8006b0:	0141                	addi	sp,sp,16
  8006b2:	8082                	ret
