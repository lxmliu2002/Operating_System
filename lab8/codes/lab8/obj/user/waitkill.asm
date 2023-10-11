
obj/__user_waitkill.out：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000000800020 <open>:
  800020:	1582                	slli	a1,a1,0x20
  800022:	9181                	srli	a1,a1,0x20
  800024:	17a0006f          	j	80019e <sys_open>

0000000000800028 <close>:
  800028:	1820006f          	j	8001aa <sys_close>

000000000080002c <dup2>:
  80002c:	1880006f          	j	8001b4 <sys_dup>

0000000000800030 <_start>:
  800030:	1fe000ef          	jal	ra,80022e <umain>
  800034:	a001                	j	800034 <_start+0x4>

0000000000800036 <__panic>:
  800036:	715d                	addi	sp,sp,-80
  800038:	e822                	sd	s0,16(sp)
  80003a:	fc3e                	sd	a5,56(sp)
  80003c:	8432                	mv	s0,a2
  80003e:	103c                	addi	a5,sp,40
  800040:	862e                	mv	a2,a1
  800042:	85aa                	mv	a1,a0
  800044:	00000517          	auipc	a0,0x0
  800048:	7ec50513          	addi	a0,a0,2028 # 800830 <main+0xb8>
  80004c:	ec06                	sd	ra,24(sp)
  80004e:	f436                	sd	a3,40(sp)
  800050:	f83a                	sd	a4,48(sp)
  800052:	e0c2                	sd	a6,64(sp)
  800054:	e4c6                	sd	a7,72(sp)
  800056:	e43e                	sd	a5,8(sp)
  800058:	0a0000ef          	jal	ra,8000f8 <cprintf>
  80005c:	65a2                	ld	a1,8(sp)
  80005e:	8522                	mv	a0,s0
  800060:	072000ef          	jal	ra,8000d2 <vcprintf>
  800064:	00001517          	auipc	a0,0x1
  800068:	cc450513          	addi	a0,a0,-828 # 800d28 <error_string+0x2e0>
  80006c:	08c000ef          	jal	ra,8000f8 <cprintf>
  800070:	5559                	li	a0,-10
  800072:	14e000ef          	jal	ra,8001c0 <exit>

0000000000800076 <__warn>:
  800076:	715d                	addi	sp,sp,-80
  800078:	e822                	sd	s0,16(sp)
  80007a:	fc3e                	sd	a5,56(sp)
  80007c:	8432                	mv	s0,a2
  80007e:	103c                	addi	a5,sp,40
  800080:	862e                	mv	a2,a1
  800082:	85aa                	mv	a1,a0
  800084:	00000517          	auipc	a0,0x0
  800088:	7cc50513          	addi	a0,a0,1996 # 800850 <main+0xd8>
  80008c:	ec06                	sd	ra,24(sp)
  80008e:	f436                	sd	a3,40(sp)
  800090:	f83a                	sd	a4,48(sp)
  800092:	e0c2                	sd	a6,64(sp)
  800094:	e4c6                	sd	a7,72(sp)
  800096:	e43e                	sd	a5,8(sp)
  800098:	060000ef          	jal	ra,8000f8 <cprintf>
  80009c:	65a2                	ld	a1,8(sp)
  80009e:	8522                	mv	a0,s0
  8000a0:	032000ef          	jal	ra,8000d2 <vcprintf>
  8000a4:	00001517          	auipc	a0,0x1
  8000a8:	c8450513          	addi	a0,a0,-892 # 800d28 <error_string+0x2e0>
  8000ac:	04c000ef          	jal	ra,8000f8 <cprintf>
  8000b0:	60e2                	ld	ra,24(sp)
  8000b2:	6442                	ld	s0,16(sp)
  8000b4:	6161                	addi	sp,sp,80
  8000b6:	8082                	ret

00000000008000b8 <cputch>:
  8000b8:	1141                	addi	sp,sp,-16
  8000ba:	e022                	sd	s0,0(sp)
  8000bc:	e406                	sd	ra,8(sp)
  8000be:	842e                	mv	s0,a1
  8000c0:	0d6000ef          	jal	ra,800196 <sys_putc>
  8000c4:	401c                	lw	a5,0(s0)
  8000c6:	60a2                	ld	ra,8(sp)
  8000c8:	2785                	addiw	a5,a5,1
  8000ca:	c01c                	sw	a5,0(s0)
  8000cc:	6402                	ld	s0,0(sp)
  8000ce:	0141                	addi	sp,sp,16
  8000d0:	8082                	ret

00000000008000d2 <vcprintf>:
  8000d2:	1101                	addi	sp,sp,-32
  8000d4:	872e                	mv	a4,a1
  8000d6:	75dd                	lui	a1,0xffff7
  8000d8:	86aa                	mv	a3,a0
  8000da:	0070                	addi	a2,sp,12
  8000dc:	00000517          	auipc	a0,0x0
  8000e0:	fdc50513          	addi	a0,a0,-36 # 8000b8 <cputch>
  8000e4:	ad958593          	addi	a1,a1,-1319 # ffffffffffff6ad9 <pid1+0xffffffffff7f5ad1>
  8000e8:	ec06                	sd	ra,24(sp)
  8000ea:	c602                	sw	zero,12(sp)
  8000ec:	22c000ef          	jal	ra,800318 <vprintfmt>
  8000f0:	60e2                	ld	ra,24(sp)
  8000f2:	4532                	lw	a0,12(sp)
  8000f4:	6105                	addi	sp,sp,32
  8000f6:	8082                	ret

00000000008000f8 <cprintf>:
  8000f8:	711d                	addi	sp,sp,-96
  8000fa:	02810313          	addi	t1,sp,40
  8000fe:	f42e                	sd	a1,40(sp)
  800100:	75dd                	lui	a1,0xffff7
  800102:	f832                	sd	a2,48(sp)
  800104:	fc36                	sd	a3,56(sp)
  800106:	e0ba                	sd	a4,64(sp)
  800108:	86aa                	mv	a3,a0
  80010a:	0050                	addi	a2,sp,4
  80010c:	00000517          	auipc	a0,0x0
  800110:	fac50513          	addi	a0,a0,-84 # 8000b8 <cputch>
  800114:	871a                	mv	a4,t1
  800116:	ad958593          	addi	a1,a1,-1319 # ffffffffffff6ad9 <pid1+0xffffffffff7f5ad1>
  80011a:	ec06                	sd	ra,24(sp)
  80011c:	e4be                	sd	a5,72(sp)
  80011e:	e8c2                	sd	a6,80(sp)
  800120:	ecc6                	sd	a7,88(sp)
  800122:	e41a                	sd	t1,8(sp)
  800124:	c202                	sw	zero,4(sp)
  800126:	1f2000ef          	jal	ra,800318 <vprintfmt>
  80012a:	60e2                	ld	ra,24(sp)
  80012c:	4512                	lw	a0,4(sp)
  80012e:	6125                	addi	sp,sp,96
  800130:	8082                	ret

0000000000800132 <syscall>:
  800132:	7175                	addi	sp,sp,-144
  800134:	f8ba                	sd	a4,112(sp)
  800136:	e0ba                	sd	a4,64(sp)
  800138:	0118                	addi	a4,sp,128
  80013a:	e42a                	sd	a0,8(sp)
  80013c:	ecae                	sd	a1,88(sp)
  80013e:	f0b2                	sd	a2,96(sp)
  800140:	f4b6                	sd	a3,104(sp)
  800142:	fcbe                	sd	a5,120(sp)
  800144:	e142                	sd	a6,128(sp)
  800146:	e546                	sd	a7,136(sp)
  800148:	f42e                	sd	a1,40(sp)
  80014a:	f832                	sd	a2,48(sp)
  80014c:	fc36                	sd	a3,56(sp)
  80014e:	f03a                	sd	a4,32(sp)
  800150:	e4be                	sd	a5,72(sp)
  800152:	4522                	lw	a0,8(sp)
  800154:	55a2                	lw	a1,40(sp)
  800156:	5642                	lw	a2,48(sp)
  800158:	56e2                	lw	a3,56(sp)
  80015a:	4706                	lw	a4,64(sp)
  80015c:	47a6                	lw	a5,72(sp)
  80015e:	00000073          	ecall
  800162:	ce2a                	sw	a0,28(sp)
  800164:	4572                	lw	a0,28(sp)
  800166:	6149                	addi	sp,sp,144
  800168:	8082                	ret

000000000080016a <sys_exit>:
  80016a:	85aa                	mv	a1,a0
  80016c:	4505                	li	a0,1
  80016e:	fc5ff06f          	j	800132 <syscall>

0000000000800172 <sys_fork>:
  800172:	4509                	li	a0,2
  800174:	fbfff06f          	j	800132 <syscall>

0000000000800178 <sys_wait>:
  800178:	862e                	mv	a2,a1
  80017a:	85aa                	mv	a1,a0
  80017c:	450d                	li	a0,3
  80017e:	fb5ff06f          	j	800132 <syscall>

0000000000800182 <sys_yield>:
  800182:	4529                	li	a0,10
  800184:	fafff06f          	j	800132 <syscall>

0000000000800188 <sys_kill>:
  800188:	85aa                	mv	a1,a0
  80018a:	4531                	li	a0,12
  80018c:	fa7ff06f          	j	800132 <syscall>

0000000000800190 <sys_getpid>:
  800190:	4549                	li	a0,18
  800192:	fa1ff06f          	j	800132 <syscall>

0000000000800196 <sys_putc>:
  800196:	85aa                	mv	a1,a0
  800198:	4579                	li	a0,30
  80019a:	f99ff06f          	j	800132 <syscall>

000000000080019e <sys_open>:
  80019e:	862e                	mv	a2,a1
  8001a0:	85aa                	mv	a1,a0
  8001a2:	06400513          	li	a0,100
  8001a6:	f8dff06f          	j	800132 <syscall>

00000000008001aa <sys_close>:
  8001aa:	85aa                	mv	a1,a0
  8001ac:	06500513          	li	a0,101
  8001b0:	f83ff06f          	j	800132 <syscall>

00000000008001b4 <sys_dup>:
  8001b4:	862e                	mv	a2,a1
  8001b6:	85aa                	mv	a1,a0
  8001b8:	08200513          	li	a0,130
  8001bc:	f77ff06f          	j	800132 <syscall>

00000000008001c0 <exit>:
  8001c0:	1141                	addi	sp,sp,-16
  8001c2:	e406                	sd	ra,8(sp)
  8001c4:	fa7ff0ef          	jal	ra,80016a <sys_exit>
  8001c8:	00000517          	auipc	a0,0x0
  8001cc:	6a850513          	addi	a0,a0,1704 # 800870 <main+0xf8>
  8001d0:	f29ff0ef          	jal	ra,8000f8 <cprintf>
  8001d4:	a001                	j	8001d4 <exit+0x14>

00000000008001d6 <fork>:
  8001d6:	f9dff06f          	j	800172 <sys_fork>

00000000008001da <waitpid>:
  8001da:	f9fff06f          	j	800178 <sys_wait>

00000000008001de <yield>:
  8001de:	fa5ff06f          	j	800182 <sys_yield>

00000000008001e2 <kill>:
  8001e2:	fa7ff06f          	j	800188 <sys_kill>

00000000008001e6 <getpid>:
  8001e6:	fabff06f          	j	800190 <sys_getpid>

00000000008001ea <initfd>:
  8001ea:	1101                	addi	sp,sp,-32
  8001ec:	87ae                	mv	a5,a1
  8001ee:	e426                	sd	s1,8(sp)
  8001f0:	85b2                	mv	a1,a2
  8001f2:	84aa                	mv	s1,a0
  8001f4:	853e                	mv	a0,a5
  8001f6:	e822                	sd	s0,16(sp)
  8001f8:	ec06                	sd	ra,24(sp)
  8001fa:	e27ff0ef          	jal	ra,800020 <open>
  8001fe:	842a                	mv	s0,a0
  800200:	00054463          	bltz	a0,800208 <initfd+0x1e>
  800204:	00951863          	bne	a0,s1,800214 <initfd+0x2a>
  800208:	8522                	mv	a0,s0
  80020a:	60e2                	ld	ra,24(sp)
  80020c:	6442                	ld	s0,16(sp)
  80020e:	64a2                	ld	s1,8(sp)
  800210:	6105                	addi	sp,sp,32
  800212:	8082                	ret
  800214:	8526                	mv	a0,s1
  800216:	e13ff0ef          	jal	ra,800028 <close>
  80021a:	85a6                	mv	a1,s1
  80021c:	8522                	mv	a0,s0
  80021e:	e0fff0ef          	jal	ra,80002c <dup2>
  800222:	84aa                	mv	s1,a0
  800224:	8522                	mv	a0,s0
  800226:	e03ff0ef          	jal	ra,800028 <close>
  80022a:	8426                	mv	s0,s1
  80022c:	bff1                	j	800208 <initfd+0x1e>

000000000080022e <umain>:
  80022e:	1101                	addi	sp,sp,-32
  800230:	e822                	sd	s0,16(sp)
  800232:	e426                	sd	s1,8(sp)
  800234:	842a                	mv	s0,a0
  800236:	84ae                	mv	s1,a1
  800238:	4601                	li	a2,0
  80023a:	00000597          	auipc	a1,0x0
  80023e:	64e58593          	addi	a1,a1,1614 # 800888 <main+0x110>
  800242:	4501                	li	a0,0
  800244:	ec06                	sd	ra,24(sp)
  800246:	fa5ff0ef          	jal	ra,8001ea <initfd>
  80024a:	02054263          	bltz	a0,80026e <umain+0x40>
  80024e:	4605                	li	a2,1
  800250:	00000597          	auipc	a1,0x0
  800254:	67858593          	addi	a1,a1,1656 # 8008c8 <main+0x150>
  800258:	4505                	li	a0,1
  80025a:	f91ff0ef          	jal	ra,8001ea <initfd>
  80025e:	02054563          	bltz	a0,800288 <umain+0x5a>
  800262:	85a6                	mv	a1,s1
  800264:	8522                	mv	a0,s0
  800266:	512000ef          	jal	ra,800778 <main>
  80026a:	f57ff0ef          	jal	ra,8001c0 <exit>
  80026e:	86aa                	mv	a3,a0
  800270:	00000617          	auipc	a2,0x0
  800274:	62060613          	addi	a2,a2,1568 # 800890 <main+0x118>
  800278:	45e9                	li	a1,26
  80027a:	00000517          	auipc	a0,0x0
  80027e:	63650513          	addi	a0,a0,1590 # 8008b0 <main+0x138>
  800282:	df5ff0ef          	jal	ra,800076 <__warn>
  800286:	b7e1                	j	80024e <umain+0x20>
  800288:	86aa                	mv	a3,a0
  80028a:	00000617          	auipc	a2,0x0
  80028e:	64660613          	addi	a2,a2,1606 # 8008d0 <main+0x158>
  800292:	45f5                	li	a1,29
  800294:	00000517          	auipc	a0,0x0
  800298:	61c50513          	addi	a0,a0,1564 # 8008b0 <main+0x138>
  80029c:	ddbff0ef          	jal	ra,800076 <__warn>
  8002a0:	b7c9                	j	800262 <umain+0x34>

00000000008002a2 <printnum>:
  8002a2:	02071893          	slli	a7,a4,0x20
  8002a6:	7139                	addi	sp,sp,-64
  8002a8:	0208d893          	srli	a7,a7,0x20
  8002ac:	e456                	sd	s5,8(sp)
  8002ae:	0316fab3          	remu	s5,a3,a7
  8002b2:	f822                	sd	s0,48(sp)
  8002b4:	f426                	sd	s1,40(sp)
  8002b6:	f04a                	sd	s2,32(sp)
  8002b8:	ec4e                	sd	s3,24(sp)
  8002ba:	fc06                	sd	ra,56(sp)
  8002bc:	e852                	sd	s4,16(sp)
  8002be:	84aa                	mv	s1,a0
  8002c0:	89ae                	mv	s3,a1
  8002c2:	8932                	mv	s2,a2
  8002c4:	fff7841b          	addiw	s0,a5,-1
  8002c8:	2a81                	sext.w	s5,s5
  8002ca:	0516f163          	bleu	a7,a3,80030c <printnum+0x6a>
  8002ce:	8a42                	mv	s4,a6
  8002d0:	00805863          	blez	s0,8002e0 <printnum+0x3e>
  8002d4:	347d                	addiw	s0,s0,-1
  8002d6:	864e                	mv	a2,s3
  8002d8:	85ca                	mv	a1,s2
  8002da:	8552                	mv	a0,s4
  8002dc:	9482                	jalr	s1
  8002de:	f87d                	bnez	s0,8002d4 <printnum+0x32>
  8002e0:	1a82                	slli	s5,s5,0x20
  8002e2:	020ada93          	srli	s5,s5,0x20
  8002e6:	00001797          	auipc	a5,0x1
  8002ea:	82a78793          	addi	a5,a5,-2006 # 800b10 <error_string+0xc8>
  8002ee:	9abe                	add	s5,s5,a5
  8002f0:	7442                	ld	s0,48(sp)
  8002f2:	000ac503          	lbu	a0,0(s5)
  8002f6:	70e2                	ld	ra,56(sp)
  8002f8:	6a42                	ld	s4,16(sp)
  8002fa:	6aa2                	ld	s5,8(sp)
  8002fc:	864e                	mv	a2,s3
  8002fe:	85ca                	mv	a1,s2
  800300:	69e2                	ld	s3,24(sp)
  800302:	7902                	ld	s2,32(sp)
  800304:	8326                	mv	t1,s1
  800306:	74a2                	ld	s1,40(sp)
  800308:	6121                	addi	sp,sp,64
  80030a:	8302                	jr	t1
  80030c:	0316d6b3          	divu	a3,a3,a7
  800310:	87a2                	mv	a5,s0
  800312:	f91ff0ef          	jal	ra,8002a2 <printnum>
  800316:	b7e9                	j	8002e0 <printnum+0x3e>

0000000000800318 <vprintfmt>:
  800318:	7119                	addi	sp,sp,-128
  80031a:	f4a6                	sd	s1,104(sp)
  80031c:	f0ca                	sd	s2,96(sp)
  80031e:	ecce                	sd	s3,88(sp)
  800320:	e4d6                	sd	s5,72(sp)
  800322:	e0da                	sd	s6,64(sp)
  800324:	fc5e                	sd	s7,56(sp)
  800326:	f862                	sd	s8,48(sp)
  800328:	ec6e                	sd	s11,24(sp)
  80032a:	fc86                	sd	ra,120(sp)
  80032c:	f8a2                	sd	s0,112(sp)
  80032e:	e8d2                	sd	s4,80(sp)
  800330:	f466                	sd	s9,40(sp)
  800332:	f06a                	sd	s10,32(sp)
  800334:	89aa                	mv	s3,a0
  800336:	892e                	mv	s2,a1
  800338:	84b2                	mv	s1,a2
  80033a:	8db6                	mv	s11,a3
  80033c:	8b3a                	mv	s6,a4
  80033e:	5bfd                	li	s7,-1
  800340:	00000a97          	auipc	s5,0x0
  800344:	5aca8a93          	addi	s5,s5,1452 # 8008ec <main+0x174>
  800348:	05e00c13          	li	s8,94
  80034c:	000dc503          	lbu	a0,0(s11)
  800350:	02500793          	li	a5,37
  800354:	001d8413          	addi	s0,s11,1
  800358:	00f50f63          	beq	a0,a5,800376 <vprintfmt+0x5e>
  80035c:	c529                	beqz	a0,8003a6 <vprintfmt+0x8e>
  80035e:	02500a13          	li	s4,37
  800362:	a011                	j	800366 <vprintfmt+0x4e>
  800364:	c129                	beqz	a0,8003a6 <vprintfmt+0x8e>
  800366:	864a                	mv	a2,s2
  800368:	85a6                	mv	a1,s1
  80036a:	0405                	addi	s0,s0,1
  80036c:	9982                	jalr	s3
  80036e:	fff44503          	lbu	a0,-1(s0)
  800372:	ff4519e3          	bne	a0,s4,800364 <vprintfmt+0x4c>
  800376:	00044603          	lbu	a2,0(s0)
  80037a:	02000813          	li	a6,32
  80037e:	4a01                	li	s4,0
  800380:	4881                	li	a7,0
  800382:	5d7d                	li	s10,-1
  800384:	5cfd                	li	s9,-1
  800386:	05500593          	li	a1,85
  80038a:	4525                	li	a0,9
  80038c:	fdd6071b          	addiw	a4,a2,-35
  800390:	0ff77713          	andi	a4,a4,255
  800394:	00140d93          	addi	s11,s0,1
  800398:	22e5e363          	bltu	a1,a4,8005be <vprintfmt+0x2a6>
  80039c:	070a                	slli	a4,a4,0x2
  80039e:	9756                	add	a4,a4,s5
  8003a0:	4318                	lw	a4,0(a4)
  8003a2:	9756                	add	a4,a4,s5
  8003a4:	8702                	jr	a4
  8003a6:	70e6                	ld	ra,120(sp)
  8003a8:	7446                	ld	s0,112(sp)
  8003aa:	74a6                	ld	s1,104(sp)
  8003ac:	7906                	ld	s2,96(sp)
  8003ae:	69e6                	ld	s3,88(sp)
  8003b0:	6a46                	ld	s4,80(sp)
  8003b2:	6aa6                	ld	s5,72(sp)
  8003b4:	6b06                	ld	s6,64(sp)
  8003b6:	7be2                	ld	s7,56(sp)
  8003b8:	7c42                	ld	s8,48(sp)
  8003ba:	7ca2                	ld	s9,40(sp)
  8003bc:	7d02                	ld	s10,32(sp)
  8003be:	6de2                	ld	s11,24(sp)
  8003c0:	6109                	addi	sp,sp,128
  8003c2:	8082                	ret
  8003c4:	4705                	li	a4,1
  8003c6:	008b0613          	addi	a2,s6,8
  8003ca:	01174463          	blt	a4,a7,8003d2 <vprintfmt+0xba>
  8003ce:	28088563          	beqz	a7,800658 <vprintfmt+0x340>
  8003d2:	000b3683          	ld	a3,0(s6)
  8003d6:	4741                	li	a4,16
  8003d8:	8b32                	mv	s6,a2
  8003da:	a86d                	j	800494 <vprintfmt+0x17c>
  8003dc:	00144603          	lbu	a2,1(s0)
  8003e0:	4a05                	li	s4,1
  8003e2:	846e                	mv	s0,s11
  8003e4:	b765                	j	80038c <vprintfmt+0x74>
  8003e6:	000b2503          	lw	a0,0(s6)
  8003ea:	864a                	mv	a2,s2
  8003ec:	85a6                	mv	a1,s1
  8003ee:	0b21                	addi	s6,s6,8
  8003f0:	9982                	jalr	s3
  8003f2:	bfa9                	j	80034c <vprintfmt+0x34>
  8003f4:	4705                	li	a4,1
  8003f6:	008b0a13          	addi	s4,s6,8
  8003fa:	01174463          	blt	a4,a7,800402 <vprintfmt+0xea>
  8003fe:	24088563          	beqz	a7,800648 <vprintfmt+0x330>
  800402:	000b3403          	ld	s0,0(s6)
  800406:	26044563          	bltz	s0,800670 <vprintfmt+0x358>
  80040a:	86a2                	mv	a3,s0
  80040c:	8b52                	mv	s6,s4
  80040e:	4729                	li	a4,10
  800410:	a051                	j	800494 <vprintfmt+0x17c>
  800412:	000b2783          	lw	a5,0(s6)
  800416:	46e1                	li	a3,24
  800418:	0b21                	addi	s6,s6,8
  80041a:	41f7d71b          	sraiw	a4,a5,0x1f
  80041e:	8fb9                	xor	a5,a5,a4
  800420:	40e7873b          	subw	a4,a5,a4
  800424:	1ce6c163          	blt	a3,a4,8005e6 <vprintfmt+0x2ce>
  800428:	00371793          	slli	a5,a4,0x3
  80042c:	00000697          	auipc	a3,0x0
  800430:	61c68693          	addi	a3,a3,1564 # 800a48 <error_string>
  800434:	97b6                	add	a5,a5,a3
  800436:	639c                	ld	a5,0(a5)
  800438:	1a078763          	beqz	a5,8005e6 <vprintfmt+0x2ce>
  80043c:	873e                	mv	a4,a5
  80043e:	00001697          	auipc	a3,0x1
  800442:	8da68693          	addi	a3,a3,-1830 # 800d18 <error_string+0x2d0>
  800446:	8626                	mv	a2,s1
  800448:	85ca                	mv	a1,s2
  80044a:	854e                	mv	a0,s3
  80044c:	25a000ef          	jal	ra,8006a6 <printfmt>
  800450:	bdf5                	j	80034c <vprintfmt+0x34>
  800452:	00144603          	lbu	a2,1(s0)
  800456:	2885                	addiw	a7,a7,1
  800458:	846e                	mv	s0,s11
  80045a:	bf0d                	j	80038c <vprintfmt+0x74>
  80045c:	4705                	li	a4,1
  80045e:	008b0613          	addi	a2,s6,8
  800462:	01174463          	blt	a4,a7,80046a <vprintfmt+0x152>
  800466:	1e088e63          	beqz	a7,800662 <vprintfmt+0x34a>
  80046a:	000b3683          	ld	a3,0(s6)
  80046e:	4721                	li	a4,8
  800470:	8b32                	mv	s6,a2
  800472:	a00d                	j	800494 <vprintfmt+0x17c>
  800474:	03000513          	li	a0,48
  800478:	864a                	mv	a2,s2
  80047a:	85a6                	mv	a1,s1
  80047c:	e042                	sd	a6,0(sp)
  80047e:	9982                	jalr	s3
  800480:	864a                	mv	a2,s2
  800482:	85a6                	mv	a1,s1
  800484:	07800513          	li	a0,120
  800488:	9982                	jalr	s3
  80048a:	0b21                	addi	s6,s6,8
  80048c:	ff8b3683          	ld	a3,-8(s6)
  800490:	6802                	ld	a6,0(sp)
  800492:	4741                	li	a4,16
  800494:	87e6                	mv	a5,s9
  800496:	8626                	mv	a2,s1
  800498:	85ca                	mv	a1,s2
  80049a:	854e                	mv	a0,s3
  80049c:	e07ff0ef          	jal	ra,8002a2 <printnum>
  8004a0:	b575                	j	80034c <vprintfmt+0x34>
  8004a2:	000b3703          	ld	a4,0(s6)
  8004a6:	0b21                	addi	s6,s6,8
  8004a8:	1e070063          	beqz	a4,800688 <vprintfmt+0x370>
  8004ac:	00170413          	addi	s0,a4,1
  8004b0:	19905563          	blez	s9,80063a <vprintfmt+0x322>
  8004b4:	02d00613          	li	a2,45
  8004b8:	14c81963          	bne	a6,a2,80060a <vprintfmt+0x2f2>
  8004bc:	00074703          	lbu	a4,0(a4)
  8004c0:	0007051b          	sext.w	a0,a4
  8004c4:	c90d                	beqz	a0,8004f6 <vprintfmt+0x1de>
  8004c6:	000d4563          	bltz	s10,8004d0 <vprintfmt+0x1b8>
  8004ca:	3d7d                	addiw	s10,s10,-1
  8004cc:	037d0363          	beq	s10,s7,8004f2 <vprintfmt+0x1da>
  8004d0:	864a                	mv	a2,s2
  8004d2:	85a6                	mv	a1,s1
  8004d4:	180a0c63          	beqz	s4,80066c <vprintfmt+0x354>
  8004d8:	3701                	addiw	a4,a4,-32
  8004da:	18ec7963          	bleu	a4,s8,80066c <vprintfmt+0x354>
  8004de:	03f00513          	li	a0,63
  8004e2:	9982                	jalr	s3
  8004e4:	0405                	addi	s0,s0,1
  8004e6:	fff44703          	lbu	a4,-1(s0)
  8004ea:	3cfd                	addiw	s9,s9,-1
  8004ec:	0007051b          	sext.w	a0,a4
  8004f0:	f979                	bnez	a0,8004c6 <vprintfmt+0x1ae>
  8004f2:	e5905de3          	blez	s9,80034c <vprintfmt+0x34>
  8004f6:	3cfd                	addiw	s9,s9,-1
  8004f8:	864a                	mv	a2,s2
  8004fa:	85a6                	mv	a1,s1
  8004fc:	02000513          	li	a0,32
  800500:	9982                	jalr	s3
  800502:	e40c85e3          	beqz	s9,80034c <vprintfmt+0x34>
  800506:	3cfd                	addiw	s9,s9,-1
  800508:	864a                	mv	a2,s2
  80050a:	85a6                	mv	a1,s1
  80050c:	02000513          	li	a0,32
  800510:	9982                	jalr	s3
  800512:	fe0c92e3          	bnez	s9,8004f6 <vprintfmt+0x1de>
  800516:	bd1d                	j	80034c <vprintfmt+0x34>
  800518:	4705                	li	a4,1
  80051a:	008b0613          	addi	a2,s6,8
  80051e:	01174463          	blt	a4,a7,800526 <vprintfmt+0x20e>
  800522:	12088663          	beqz	a7,80064e <vprintfmt+0x336>
  800526:	000b3683          	ld	a3,0(s6)
  80052a:	4729                	li	a4,10
  80052c:	8b32                	mv	s6,a2
  80052e:	b79d                	j	800494 <vprintfmt+0x17c>
  800530:	00144603          	lbu	a2,1(s0)
  800534:	02d00813          	li	a6,45
  800538:	846e                	mv	s0,s11
  80053a:	bd89                	j	80038c <vprintfmt+0x74>
  80053c:	864a                	mv	a2,s2
  80053e:	85a6                	mv	a1,s1
  800540:	02500513          	li	a0,37
  800544:	9982                	jalr	s3
  800546:	b519                	j	80034c <vprintfmt+0x34>
  800548:	000b2d03          	lw	s10,0(s6)
  80054c:	00144603          	lbu	a2,1(s0)
  800550:	0b21                	addi	s6,s6,8
  800552:	846e                	mv	s0,s11
  800554:	e20cdce3          	bgez	s9,80038c <vprintfmt+0x74>
  800558:	8cea                	mv	s9,s10
  80055a:	5d7d                	li	s10,-1
  80055c:	bd05                	j	80038c <vprintfmt+0x74>
  80055e:	00144603          	lbu	a2,1(s0)
  800562:	03000813          	li	a6,48
  800566:	846e                	mv	s0,s11
  800568:	b515                	j	80038c <vprintfmt+0x74>
  80056a:	fd060d1b          	addiw	s10,a2,-48
  80056e:	00144603          	lbu	a2,1(s0)
  800572:	846e                	mv	s0,s11
  800574:	fd06071b          	addiw	a4,a2,-48
  800578:	0006031b          	sext.w	t1,a2
  80057c:	fce56ce3          	bltu	a0,a4,800554 <vprintfmt+0x23c>
  800580:	0405                	addi	s0,s0,1
  800582:	002d171b          	slliw	a4,s10,0x2
  800586:	00044603          	lbu	a2,0(s0)
  80058a:	01a706bb          	addw	a3,a4,s10
  80058e:	0016969b          	slliw	a3,a3,0x1
  800592:	006686bb          	addw	a3,a3,t1
  800596:	fd06071b          	addiw	a4,a2,-48
  80059a:	fd068d1b          	addiw	s10,a3,-48
  80059e:	0006031b          	sext.w	t1,a2
  8005a2:	fce57fe3          	bleu	a4,a0,800580 <vprintfmt+0x268>
  8005a6:	b77d                	j	800554 <vprintfmt+0x23c>
  8005a8:	fffcc713          	not	a4,s9
  8005ac:	977d                	srai	a4,a4,0x3f
  8005ae:	00ecf7b3          	and	a5,s9,a4
  8005b2:	00144603          	lbu	a2,1(s0)
  8005b6:	00078c9b          	sext.w	s9,a5
  8005ba:	846e                	mv	s0,s11
  8005bc:	bbc1                	j	80038c <vprintfmt+0x74>
  8005be:	864a                	mv	a2,s2
  8005c0:	85a6                	mv	a1,s1
  8005c2:	02500513          	li	a0,37
  8005c6:	9982                	jalr	s3
  8005c8:	fff44703          	lbu	a4,-1(s0)
  8005cc:	02500793          	li	a5,37
  8005d0:	8da2                	mv	s11,s0
  8005d2:	d6f70de3          	beq	a4,a5,80034c <vprintfmt+0x34>
  8005d6:	02500713          	li	a4,37
  8005da:	1dfd                	addi	s11,s11,-1
  8005dc:	fffdc783          	lbu	a5,-1(s11)
  8005e0:	fee79de3          	bne	a5,a4,8005da <vprintfmt+0x2c2>
  8005e4:	b3a5                	j	80034c <vprintfmt+0x34>
  8005e6:	00000697          	auipc	a3,0x0
  8005ea:	72268693          	addi	a3,a3,1826 # 800d08 <error_string+0x2c0>
  8005ee:	8626                	mv	a2,s1
  8005f0:	85ca                	mv	a1,s2
  8005f2:	854e                	mv	a0,s3
  8005f4:	0b2000ef          	jal	ra,8006a6 <printfmt>
  8005f8:	bb91                	j	80034c <vprintfmt+0x34>
  8005fa:	00000717          	auipc	a4,0x0
  8005fe:	70670713          	addi	a4,a4,1798 # 800d00 <error_string+0x2b8>
  800602:	00000417          	auipc	s0,0x0
  800606:	6ff40413          	addi	s0,s0,1791 # 800d01 <error_string+0x2b9>
  80060a:	853a                	mv	a0,a4
  80060c:	85ea                	mv	a1,s10
  80060e:	e03a                	sd	a4,0(sp)
  800610:	e442                	sd	a6,8(sp)
  800612:	0b2000ef          	jal	ra,8006c4 <strnlen>
  800616:	40ac8cbb          	subw	s9,s9,a0
  80061a:	6702                	ld	a4,0(sp)
  80061c:	01905f63          	blez	s9,80063a <vprintfmt+0x322>
  800620:	6822                	ld	a6,8(sp)
  800622:	0008079b          	sext.w	a5,a6
  800626:	e43e                	sd	a5,8(sp)
  800628:	6522                	ld	a0,8(sp)
  80062a:	864a                	mv	a2,s2
  80062c:	85a6                	mv	a1,s1
  80062e:	e03a                	sd	a4,0(sp)
  800630:	3cfd                	addiw	s9,s9,-1
  800632:	9982                	jalr	s3
  800634:	6702                	ld	a4,0(sp)
  800636:	fe0c99e3          	bnez	s9,800628 <vprintfmt+0x310>
  80063a:	00074703          	lbu	a4,0(a4)
  80063e:	0007051b          	sext.w	a0,a4
  800642:	e80512e3          	bnez	a0,8004c6 <vprintfmt+0x1ae>
  800646:	b319                	j	80034c <vprintfmt+0x34>
  800648:	000b2403          	lw	s0,0(s6)
  80064c:	bb6d                	j	800406 <vprintfmt+0xee>
  80064e:	000b6683          	lwu	a3,0(s6)
  800652:	4729                	li	a4,10
  800654:	8b32                	mv	s6,a2
  800656:	bd3d                	j	800494 <vprintfmt+0x17c>
  800658:	000b6683          	lwu	a3,0(s6)
  80065c:	4741                	li	a4,16
  80065e:	8b32                	mv	s6,a2
  800660:	bd15                	j	800494 <vprintfmt+0x17c>
  800662:	000b6683          	lwu	a3,0(s6)
  800666:	4721                	li	a4,8
  800668:	8b32                	mv	s6,a2
  80066a:	b52d                	j	800494 <vprintfmt+0x17c>
  80066c:	9982                	jalr	s3
  80066e:	bd9d                	j	8004e4 <vprintfmt+0x1cc>
  800670:	864a                	mv	a2,s2
  800672:	85a6                	mv	a1,s1
  800674:	02d00513          	li	a0,45
  800678:	e042                	sd	a6,0(sp)
  80067a:	9982                	jalr	s3
  80067c:	8b52                	mv	s6,s4
  80067e:	408006b3          	neg	a3,s0
  800682:	4729                	li	a4,10
  800684:	6802                	ld	a6,0(sp)
  800686:	b539                	j	800494 <vprintfmt+0x17c>
  800688:	01905663          	blez	s9,800694 <vprintfmt+0x37c>
  80068c:	02d00713          	li	a4,45
  800690:	f6e815e3          	bne	a6,a4,8005fa <vprintfmt+0x2e2>
  800694:	00000417          	auipc	s0,0x0
  800698:	66d40413          	addi	s0,s0,1645 # 800d01 <error_string+0x2b9>
  80069c:	02800513          	li	a0,40
  8006a0:	02800713          	li	a4,40
  8006a4:	b50d                	j	8004c6 <vprintfmt+0x1ae>

00000000008006a6 <printfmt>:
  8006a6:	7139                	addi	sp,sp,-64
  8006a8:	02010313          	addi	t1,sp,32
  8006ac:	f03a                	sd	a4,32(sp)
  8006ae:	871a                	mv	a4,t1
  8006b0:	ec06                	sd	ra,24(sp)
  8006b2:	f43e                	sd	a5,40(sp)
  8006b4:	f842                	sd	a6,48(sp)
  8006b6:	fc46                	sd	a7,56(sp)
  8006b8:	e41a                	sd	t1,8(sp)
  8006ba:	c5fff0ef          	jal	ra,800318 <vprintfmt>
  8006be:	60e2                	ld	ra,24(sp)
  8006c0:	6121                	addi	sp,sp,64
  8006c2:	8082                	ret

00000000008006c4 <strnlen>:
  8006c4:	c185                	beqz	a1,8006e4 <strnlen+0x20>
  8006c6:	00054783          	lbu	a5,0(a0)
  8006ca:	cf89                	beqz	a5,8006e4 <strnlen+0x20>
  8006cc:	4781                	li	a5,0
  8006ce:	a021                	j	8006d6 <strnlen+0x12>
  8006d0:	00074703          	lbu	a4,0(a4)
  8006d4:	c711                	beqz	a4,8006e0 <strnlen+0x1c>
  8006d6:	0785                	addi	a5,a5,1
  8006d8:	00f50733          	add	a4,a0,a5
  8006dc:	fef59ae3          	bne	a1,a5,8006d0 <strnlen+0xc>
  8006e0:	853e                	mv	a0,a5
  8006e2:	8082                	ret
  8006e4:	4781                	li	a5,0
  8006e6:	853e                	mv	a0,a5
  8006e8:	8082                	ret

00000000008006ea <do_yield>:
  8006ea:	1141                	addi	sp,sp,-16
  8006ec:	e406                	sd	ra,8(sp)
  8006ee:	af1ff0ef          	jal	ra,8001de <yield>
  8006f2:	aedff0ef          	jal	ra,8001de <yield>
  8006f6:	ae9ff0ef          	jal	ra,8001de <yield>
  8006fa:	ae5ff0ef          	jal	ra,8001de <yield>
  8006fe:	ae1ff0ef          	jal	ra,8001de <yield>
  800702:	60a2                	ld	ra,8(sp)
  800704:	0141                	addi	sp,sp,16
  800706:	ad9ff06f          	j	8001de <yield>

000000000080070a <loop>:
  80070a:	1141                	addi	sp,sp,-16
  80070c:	00000517          	auipc	a0,0x0
  800710:	61450513          	addi	a0,a0,1556 # 800d20 <error_string+0x2d8>
  800714:	e406                	sd	ra,8(sp)
  800716:	9e3ff0ef          	jal	ra,8000f8 <cprintf>
  80071a:	a001                	j	80071a <loop+0x10>

000000000080071c <work>:
  80071c:	1141                	addi	sp,sp,-16
  80071e:	00000517          	auipc	a0,0x0
  800722:	68250513          	addi	a0,a0,1666 # 800da0 <error_string+0x358>
  800726:	e406                	sd	ra,8(sp)
  800728:	9d1ff0ef          	jal	ra,8000f8 <cprintf>
  80072c:	fbfff0ef          	jal	ra,8006ea <do_yield>
  800730:	00001797          	auipc	a5,0x1
  800734:	8d078793          	addi	a5,a5,-1840 # 801000 <parent>
  800738:	4388                	lw	a0,0(a5)
  80073a:	aa9ff0ef          	jal	ra,8001e2 <kill>
  80073e:	e10d                	bnez	a0,800760 <work+0x44>
  800740:	00000517          	auipc	a0,0x0
  800744:	67050513          	addi	a0,a0,1648 # 800db0 <error_string+0x368>
  800748:	9b1ff0ef          	jal	ra,8000f8 <cprintf>
  80074c:	f9fff0ef          	jal	ra,8006ea <do_yield>
  800750:	00001797          	auipc	a5,0x1
  800754:	8b878793          	addi	a5,a5,-1864 # 801008 <pid1>
  800758:	4388                	lw	a0,0(a5)
  80075a:	a89ff0ef          	jal	ra,8001e2 <kill>
  80075e:	c501                	beqz	a0,800766 <work+0x4a>
  800760:	557d                	li	a0,-1
  800762:	a5fff0ef          	jal	ra,8001c0 <exit>
  800766:	00000517          	auipc	a0,0x0
  80076a:	66250513          	addi	a0,a0,1634 # 800dc8 <error_string+0x380>
  80076e:	98bff0ef          	jal	ra,8000f8 <cprintf>
  800772:	4501                	li	a0,0
  800774:	a4dff0ef          	jal	ra,8001c0 <exit>

0000000000800778 <main>:
  800778:	1141                	addi	sp,sp,-16
  80077a:	e406                	sd	ra,8(sp)
  80077c:	e022                	sd	s0,0(sp)
  80077e:	a69ff0ef          	jal	ra,8001e6 <getpid>
  800782:	00001797          	auipc	a5,0x1
  800786:	86a7af23          	sw	a0,-1922(a5) # 801000 <parent>
  80078a:	a4dff0ef          	jal	ra,8001d6 <fork>
  80078e:	00001797          	auipc	a5,0x1
  800792:	86a7ad23          	sw	a0,-1926(a5) # 801008 <pid1>
  800796:	c53d                	beqz	a0,800804 <main+0x8c>
  800798:	04a05663          	blez	a0,8007e4 <main+0x6c>
  80079c:	a3bff0ef          	jal	ra,8001d6 <fork>
  8007a0:	00001797          	auipc	a5,0x1
  8007a4:	86a7a223          	sw	a0,-1948(a5) # 801004 <pid2>
  8007a8:	cd3d                	beqz	a0,800826 <main+0xae>
  8007aa:	00001417          	auipc	s0,0x1
  8007ae:	85e40413          	addi	s0,s0,-1954 # 801008 <pid1>
  8007b2:	04a05b63          	blez	a0,800808 <main+0x90>
  8007b6:	00000517          	auipc	a0,0x0
  8007ba:	5b250513          	addi	a0,a0,1458 # 800d68 <error_string+0x320>
  8007be:	93bff0ef          	jal	ra,8000f8 <cprintf>
  8007c2:	4008                	lw	a0,0(s0)
  8007c4:	4581                	li	a1,0
  8007c6:	a15ff0ef          	jal	ra,8001da <waitpid>
  8007ca:	4014                	lw	a3,0(s0)
  8007cc:	00000617          	auipc	a2,0x0
  8007d0:	5ac60613          	addi	a2,a2,1452 # 800d78 <error_string+0x330>
  8007d4:	03400593          	li	a1,52
  8007d8:	00000517          	auipc	a0,0x0
  8007dc:	58050513          	addi	a0,a0,1408 # 800d58 <error_string+0x310>
  8007e0:	857ff0ef          	jal	ra,800036 <__panic>
  8007e4:	00000697          	auipc	a3,0x0
  8007e8:	54c68693          	addi	a3,a3,1356 # 800d30 <error_string+0x2e8>
  8007ec:	00000617          	auipc	a2,0x0
  8007f0:	55460613          	addi	a2,a2,1364 # 800d40 <error_string+0x2f8>
  8007f4:	02c00593          	li	a1,44
  8007f8:	00000517          	auipc	a0,0x0
  8007fc:	56050513          	addi	a0,a0,1376 # 800d58 <error_string+0x310>
  800800:	837ff0ef          	jal	ra,800036 <__panic>
  800804:	f07ff0ef          	jal	ra,80070a <loop>
  800808:	4008                	lw	a0,0(s0)
  80080a:	9d9ff0ef          	jal	ra,8001e2 <kill>
  80080e:	00000617          	auipc	a2,0x0
  800812:	58260613          	addi	a2,a2,1410 # 800d90 <error_string+0x348>
  800816:	03900593          	li	a1,57
  80081a:	00000517          	auipc	a0,0x0
  80081e:	53e50513          	addi	a0,a0,1342 # 800d58 <error_string+0x310>
  800822:	815ff0ef          	jal	ra,800036 <__panic>
  800826:	ef7ff0ef          	jal	ra,80071c <work>
