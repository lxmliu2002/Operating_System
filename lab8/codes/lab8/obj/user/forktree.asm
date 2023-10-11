
obj/__user_forktree.out：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000000800020 <open>:
  800020:	1582                	slli	a1,a1,0x20
  800022:	9181                	srli	a1,a1,0x20
  800024:	1280006f          	j	80014c <sys_open>

0000000000800028 <close>:
  800028:	1300006f          	j	800158 <sys_close>

000000000080002c <dup2>:
  80002c:	1360006f          	j	800162 <sys_dup>

0000000000800030 <_start>:
  800030:	1a4000ef          	jal	ra,8001d4 <umain>
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
  800048:	79c50513          	addi	a0,a0,1948 # 8007e0 <main+0x3a>
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
  800068:	7d450513          	addi	a0,a0,2004 # 800838 <main+0x92>
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
  800080:	0c4000ef          	jal	ra,800144 <sys_putc>
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
  8000a4:	ad958593          	addi	a1,a1,-1319 # ffffffffffff6ad9 <error_string+0xffffffffff7f6101>
  8000a8:	ec06                	sd	ra,24(sp)
  8000aa:	c602                	sw	zero,12(sp)
  8000ac:	22c000ef          	jal	ra,8002d8 <vprintfmt>
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
  8000d6:	ad958593          	addi	a1,a1,-1319 # ffffffffffff6ad9 <error_string+0xffffffffff7f6101>
  8000da:	ec06                	sd	ra,24(sp)
  8000dc:	e4be                	sd	a5,72(sp)
  8000de:	e8c2                	sd	a6,80(sp)
  8000e0:	ecc6                	sd	a7,88(sp)
  8000e2:	e41a                	sd	t1,8(sp)
  8000e4:	c202                	sw	zero,4(sp)
  8000e6:	1f2000ef          	jal	ra,8002d8 <vprintfmt>
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

0000000000800132 <sys_fork>:
  800132:	4509                	li	a0,2
  800134:	fbfff06f          	j	8000f2 <syscall>

0000000000800138 <sys_yield>:
  800138:	4529                	li	a0,10
  80013a:	fb9ff06f          	j	8000f2 <syscall>

000000000080013e <sys_getpid>:
  80013e:	4549                	li	a0,18
  800140:	fb3ff06f          	j	8000f2 <syscall>

0000000000800144 <sys_putc>:
  800144:	85aa                	mv	a1,a0
  800146:	4579                	li	a0,30
  800148:	fabff06f          	j	8000f2 <syscall>

000000000080014c <sys_open>:
  80014c:	862e                	mv	a2,a1
  80014e:	85aa                	mv	a1,a0
  800150:	06400513          	li	a0,100
  800154:	f9fff06f          	j	8000f2 <syscall>

0000000000800158 <sys_close>:
  800158:	85aa                	mv	a1,a0
  80015a:	06500513          	li	a0,101
  80015e:	f95ff06f          	j	8000f2 <syscall>

0000000000800162 <sys_dup>:
  800162:	862e                	mv	a2,a1
  800164:	85aa                	mv	a1,a0
  800166:	08200513          	li	a0,130
  80016a:	f89ff06f          	j	8000f2 <syscall>

000000000080016e <exit>:
  80016e:	1141                	addi	sp,sp,-16
  800170:	e406                	sd	ra,8(sp)
  800172:	fb9ff0ef          	jal	ra,80012a <sys_exit>
  800176:	00000517          	auipc	a0,0x0
  80017a:	68a50513          	addi	a0,a0,1674 # 800800 <main+0x5a>
  80017e:	f3bff0ef          	jal	ra,8000b8 <cprintf>
  800182:	a001                	j	800182 <exit+0x14>

0000000000800184 <fork>:
  800184:	fafff06f          	j	800132 <sys_fork>

0000000000800188 <yield>:
  800188:	fb1ff06f          	j	800138 <sys_yield>

000000000080018c <getpid>:
  80018c:	fb3ff06f          	j	80013e <sys_getpid>

0000000000800190 <initfd>:
  800190:	1101                	addi	sp,sp,-32
  800192:	87ae                	mv	a5,a1
  800194:	e426                	sd	s1,8(sp)
  800196:	85b2                	mv	a1,a2
  800198:	84aa                	mv	s1,a0
  80019a:	853e                	mv	a0,a5
  80019c:	e822                	sd	s0,16(sp)
  80019e:	ec06                	sd	ra,24(sp)
  8001a0:	e81ff0ef          	jal	ra,800020 <open>
  8001a4:	842a                	mv	s0,a0
  8001a6:	00054463          	bltz	a0,8001ae <initfd+0x1e>
  8001aa:	00951863          	bne	a0,s1,8001ba <initfd+0x2a>
  8001ae:	8522                	mv	a0,s0
  8001b0:	60e2                	ld	ra,24(sp)
  8001b2:	6442                	ld	s0,16(sp)
  8001b4:	64a2                	ld	s1,8(sp)
  8001b6:	6105                	addi	sp,sp,32
  8001b8:	8082                	ret
  8001ba:	8526                	mv	a0,s1
  8001bc:	e6dff0ef          	jal	ra,800028 <close>
  8001c0:	85a6                	mv	a1,s1
  8001c2:	8522                	mv	a0,s0
  8001c4:	e69ff0ef          	jal	ra,80002c <dup2>
  8001c8:	84aa                	mv	s1,a0
  8001ca:	8522                	mv	a0,s0
  8001cc:	e5dff0ef          	jal	ra,800028 <close>
  8001d0:	8426                	mv	s0,s1
  8001d2:	bff1                	j	8001ae <initfd+0x1e>

00000000008001d4 <umain>:
  8001d4:	1101                	addi	sp,sp,-32
  8001d6:	e822                	sd	s0,16(sp)
  8001d8:	e426                	sd	s1,8(sp)
  8001da:	842a                	mv	s0,a0
  8001dc:	84ae                	mv	s1,a1
  8001de:	4601                	li	a2,0
  8001e0:	00000597          	auipc	a1,0x0
  8001e4:	63858593          	addi	a1,a1,1592 # 800818 <main+0x72>
  8001e8:	4501                	li	a0,0
  8001ea:	ec06                	sd	ra,24(sp)
  8001ec:	fa5ff0ef          	jal	ra,800190 <initfd>
  8001f0:	02054263          	bltz	a0,800214 <umain+0x40>
  8001f4:	4605                	li	a2,1
  8001f6:	00000597          	auipc	a1,0x0
  8001fa:	66258593          	addi	a1,a1,1634 # 800858 <main+0xb2>
  8001fe:	4505                	li	a0,1
  800200:	f91ff0ef          	jal	ra,800190 <initfd>
  800204:	02054563          	bltz	a0,80022e <umain+0x5a>
  800208:	85a6                	mv	a1,s1
  80020a:	8522                	mv	a0,s0
  80020c:	59a000ef          	jal	ra,8007a6 <main>
  800210:	f5fff0ef          	jal	ra,80016e <exit>
  800214:	86aa                	mv	a3,a0
  800216:	00000617          	auipc	a2,0x0
  80021a:	60a60613          	addi	a2,a2,1546 # 800820 <main+0x7a>
  80021e:	45e9                	li	a1,26
  800220:	00000517          	auipc	a0,0x0
  800224:	62050513          	addi	a0,a0,1568 # 800840 <main+0x9a>
  800228:	e0fff0ef          	jal	ra,800036 <__warn>
  80022c:	b7e1                	j	8001f4 <umain+0x20>
  80022e:	86aa                	mv	a3,a0
  800230:	00000617          	auipc	a2,0x0
  800234:	63060613          	addi	a2,a2,1584 # 800860 <main+0xba>
  800238:	45f5                	li	a1,29
  80023a:	00000517          	auipc	a0,0x0
  80023e:	60650513          	addi	a0,a0,1542 # 800840 <main+0x9a>
  800242:	df5ff0ef          	jal	ra,800036 <__warn>
  800246:	b7c9                	j	800208 <umain+0x34>

0000000000800248 <printnum>:
  800248:	02071893          	slli	a7,a4,0x20
  80024c:	7139                	addi	sp,sp,-64
  80024e:	0208d893          	srli	a7,a7,0x20
  800252:	e456                	sd	s5,8(sp)
  800254:	0316fab3          	remu	s5,a3,a7
  800258:	f822                	sd	s0,48(sp)
  80025a:	f426                	sd	s1,40(sp)
  80025c:	f04a                	sd	s2,32(sp)
  80025e:	ec4e                	sd	s3,24(sp)
  800260:	fc06                	sd	ra,56(sp)
  800262:	e852                	sd	s4,16(sp)
  800264:	84aa                	mv	s1,a0
  800266:	89ae                	mv	s3,a1
  800268:	8932                	mv	s2,a2
  80026a:	fff7841b          	addiw	s0,a5,-1
  80026e:	2a81                	sext.w	s5,s5
  800270:	0516f163          	bleu	a7,a3,8002b2 <printnum+0x6a>
  800274:	8a42                	mv	s4,a6
  800276:	00805863          	blez	s0,800286 <printnum+0x3e>
  80027a:	347d                	addiw	s0,s0,-1
  80027c:	864e                	mv	a2,s3
  80027e:	85ca                	mv	a1,s2
  800280:	8552                	mv	a0,s4
  800282:	9482                	jalr	s1
  800284:	f87d                	bnez	s0,80027a <printnum+0x32>
  800286:	1a82                	slli	s5,s5,0x20
  800288:	020ada93          	srli	s5,s5,0x20
  80028c:	00001797          	auipc	a5,0x1
  800290:	81478793          	addi	a5,a5,-2028 # 800aa0 <error_string+0xc8>
  800294:	9abe                	add	s5,s5,a5
  800296:	7442                	ld	s0,48(sp)
  800298:	000ac503          	lbu	a0,0(s5)
  80029c:	70e2                	ld	ra,56(sp)
  80029e:	6a42                	ld	s4,16(sp)
  8002a0:	6aa2                	ld	s5,8(sp)
  8002a2:	864e                	mv	a2,s3
  8002a4:	85ca                	mv	a1,s2
  8002a6:	69e2                	ld	s3,24(sp)
  8002a8:	7902                	ld	s2,32(sp)
  8002aa:	8326                	mv	t1,s1
  8002ac:	74a2                	ld	s1,40(sp)
  8002ae:	6121                	addi	sp,sp,64
  8002b0:	8302                	jr	t1
  8002b2:	0316d6b3          	divu	a3,a3,a7
  8002b6:	87a2                	mv	a5,s0
  8002b8:	f91ff0ef          	jal	ra,800248 <printnum>
  8002bc:	b7e9                	j	800286 <printnum+0x3e>

00000000008002be <sprintputch>:
  8002be:	499c                	lw	a5,16(a1)
  8002c0:	6198                	ld	a4,0(a1)
  8002c2:	6594                	ld	a3,8(a1)
  8002c4:	2785                	addiw	a5,a5,1
  8002c6:	c99c                	sw	a5,16(a1)
  8002c8:	00d77763          	bleu	a3,a4,8002d6 <sprintputch+0x18>
  8002cc:	00170793          	addi	a5,a4,1
  8002d0:	e19c                	sd	a5,0(a1)
  8002d2:	00a70023          	sb	a0,0(a4)
  8002d6:	8082                	ret

00000000008002d8 <vprintfmt>:
  8002d8:	7119                	addi	sp,sp,-128
  8002da:	f4a6                	sd	s1,104(sp)
  8002dc:	f0ca                	sd	s2,96(sp)
  8002de:	ecce                	sd	s3,88(sp)
  8002e0:	e4d6                	sd	s5,72(sp)
  8002e2:	e0da                	sd	s6,64(sp)
  8002e4:	fc5e                	sd	s7,56(sp)
  8002e6:	f862                	sd	s8,48(sp)
  8002e8:	ec6e                	sd	s11,24(sp)
  8002ea:	fc86                	sd	ra,120(sp)
  8002ec:	f8a2                	sd	s0,112(sp)
  8002ee:	e8d2                	sd	s4,80(sp)
  8002f0:	f466                	sd	s9,40(sp)
  8002f2:	f06a                	sd	s10,32(sp)
  8002f4:	89aa                	mv	s3,a0
  8002f6:	892e                	mv	s2,a1
  8002f8:	84b2                	mv	s1,a2
  8002fa:	8db6                	mv	s11,a3
  8002fc:	8b3a                	mv	s6,a4
  8002fe:	5bfd                	li	s7,-1
  800300:	00000a97          	auipc	s5,0x0
  800304:	57ca8a93          	addi	s5,s5,1404 # 80087c <main+0xd6>
  800308:	05e00c13          	li	s8,94
  80030c:	000dc503          	lbu	a0,0(s11)
  800310:	02500793          	li	a5,37
  800314:	001d8413          	addi	s0,s11,1
  800318:	00f50f63          	beq	a0,a5,800336 <vprintfmt+0x5e>
  80031c:	c529                	beqz	a0,800366 <vprintfmt+0x8e>
  80031e:	02500a13          	li	s4,37
  800322:	a011                	j	800326 <vprintfmt+0x4e>
  800324:	c129                	beqz	a0,800366 <vprintfmt+0x8e>
  800326:	864a                	mv	a2,s2
  800328:	85a6                	mv	a1,s1
  80032a:	0405                	addi	s0,s0,1
  80032c:	9982                	jalr	s3
  80032e:	fff44503          	lbu	a0,-1(s0)
  800332:	ff4519e3          	bne	a0,s4,800324 <vprintfmt+0x4c>
  800336:	00044603          	lbu	a2,0(s0)
  80033a:	02000813          	li	a6,32
  80033e:	4a01                	li	s4,0
  800340:	4881                	li	a7,0
  800342:	5d7d                	li	s10,-1
  800344:	5cfd                	li	s9,-1
  800346:	05500593          	li	a1,85
  80034a:	4525                	li	a0,9
  80034c:	fdd6071b          	addiw	a4,a2,-35
  800350:	0ff77713          	andi	a4,a4,255
  800354:	00140d93          	addi	s11,s0,1
  800358:	22e5e363          	bltu	a1,a4,80057e <vprintfmt+0x2a6>
  80035c:	070a                	slli	a4,a4,0x2
  80035e:	9756                	add	a4,a4,s5
  800360:	4318                	lw	a4,0(a4)
  800362:	9756                	add	a4,a4,s5
  800364:	8702                	jr	a4
  800366:	70e6                	ld	ra,120(sp)
  800368:	7446                	ld	s0,112(sp)
  80036a:	74a6                	ld	s1,104(sp)
  80036c:	7906                	ld	s2,96(sp)
  80036e:	69e6                	ld	s3,88(sp)
  800370:	6a46                	ld	s4,80(sp)
  800372:	6aa6                	ld	s5,72(sp)
  800374:	6b06                	ld	s6,64(sp)
  800376:	7be2                	ld	s7,56(sp)
  800378:	7c42                	ld	s8,48(sp)
  80037a:	7ca2                	ld	s9,40(sp)
  80037c:	7d02                	ld	s10,32(sp)
  80037e:	6de2                	ld	s11,24(sp)
  800380:	6109                	addi	sp,sp,128
  800382:	8082                	ret
  800384:	4705                	li	a4,1
  800386:	008b0613          	addi	a2,s6,8
  80038a:	01174463          	blt	a4,a7,800392 <vprintfmt+0xba>
  80038e:	28088563          	beqz	a7,800618 <vprintfmt+0x340>
  800392:	000b3683          	ld	a3,0(s6)
  800396:	4741                	li	a4,16
  800398:	8b32                	mv	s6,a2
  80039a:	a86d                	j	800454 <vprintfmt+0x17c>
  80039c:	00144603          	lbu	a2,1(s0)
  8003a0:	4a05                	li	s4,1
  8003a2:	846e                	mv	s0,s11
  8003a4:	b765                	j	80034c <vprintfmt+0x74>
  8003a6:	000b2503          	lw	a0,0(s6)
  8003aa:	864a                	mv	a2,s2
  8003ac:	85a6                	mv	a1,s1
  8003ae:	0b21                	addi	s6,s6,8
  8003b0:	9982                	jalr	s3
  8003b2:	bfa9                	j	80030c <vprintfmt+0x34>
  8003b4:	4705                	li	a4,1
  8003b6:	008b0a13          	addi	s4,s6,8
  8003ba:	01174463          	blt	a4,a7,8003c2 <vprintfmt+0xea>
  8003be:	24088563          	beqz	a7,800608 <vprintfmt+0x330>
  8003c2:	000b3403          	ld	s0,0(s6)
  8003c6:	26044563          	bltz	s0,800630 <vprintfmt+0x358>
  8003ca:	86a2                	mv	a3,s0
  8003cc:	8b52                	mv	s6,s4
  8003ce:	4729                	li	a4,10
  8003d0:	a051                	j	800454 <vprintfmt+0x17c>
  8003d2:	000b2783          	lw	a5,0(s6)
  8003d6:	46e1                	li	a3,24
  8003d8:	0b21                	addi	s6,s6,8
  8003da:	41f7d71b          	sraiw	a4,a5,0x1f
  8003de:	8fb9                	xor	a5,a5,a4
  8003e0:	40e7873b          	subw	a4,a5,a4
  8003e4:	1ce6c163          	blt	a3,a4,8005a6 <vprintfmt+0x2ce>
  8003e8:	00371793          	slli	a5,a4,0x3
  8003ec:	00000697          	auipc	a3,0x0
  8003f0:	5ec68693          	addi	a3,a3,1516 # 8009d8 <error_string>
  8003f4:	97b6                	add	a5,a5,a3
  8003f6:	639c                	ld	a5,0(a5)
  8003f8:	1a078763          	beqz	a5,8005a6 <vprintfmt+0x2ce>
  8003fc:	873e                	mv	a4,a5
  8003fe:	00001697          	auipc	a3,0x1
  800402:	8aa68693          	addi	a3,a3,-1878 # 800ca8 <error_string+0x2d0>
  800406:	8626                	mv	a2,s1
  800408:	85ca                	mv	a1,s2
  80040a:	854e                	mv	a0,s3
  80040c:	25a000ef          	jal	ra,800666 <printfmt>
  800410:	bdf5                	j	80030c <vprintfmt+0x34>
  800412:	00144603          	lbu	a2,1(s0)
  800416:	2885                	addiw	a7,a7,1
  800418:	846e                	mv	s0,s11
  80041a:	bf0d                	j	80034c <vprintfmt+0x74>
  80041c:	4705                	li	a4,1
  80041e:	008b0613          	addi	a2,s6,8
  800422:	01174463          	blt	a4,a7,80042a <vprintfmt+0x152>
  800426:	1e088e63          	beqz	a7,800622 <vprintfmt+0x34a>
  80042a:	000b3683          	ld	a3,0(s6)
  80042e:	4721                	li	a4,8
  800430:	8b32                	mv	s6,a2
  800432:	a00d                	j	800454 <vprintfmt+0x17c>
  800434:	03000513          	li	a0,48
  800438:	864a                	mv	a2,s2
  80043a:	85a6                	mv	a1,s1
  80043c:	e042                	sd	a6,0(sp)
  80043e:	9982                	jalr	s3
  800440:	864a                	mv	a2,s2
  800442:	85a6                	mv	a1,s1
  800444:	07800513          	li	a0,120
  800448:	9982                	jalr	s3
  80044a:	0b21                	addi	s6,s6,8
  80044c:	ff8b3683          	ld	a3,-8(s6)
  800450:	6802                	ld	a6,0(sp)
  800452:	4741                	li	a4,16
  800454:	87e6                	mv	a5,s9
  800456:	8626                	mv	a2,s1
  800458:	85ca                	mv	a1,s2
  80045a:	854e                	mv	a0,s3
  80045c:	dedff0ef          	jal	ra,800248 <printnum>
  800460:	b575                	j	80030c <vprintfmt+0x34>
  800462:	000b3703          	ld	a4,0(s6)
  800466:	0b21                	addi	s6,s6,8
  800468:	1e070063          	beqz	a4,800648 <vprintfmt+0x370>
  80046c:	00170413          	addi	s0,a4,1
  800470:	19905563          	blez	s9,8005fa <vprintfmt+0x322>
  800474:	02d00613          	li	a2,45
  800478:	14c81963          	bne	a6,a2,8005ca <vprintfmt+0x2f2>
  80047c:	00074703          	lbu	a4,0(a4)
  800480:	0007051b          	sext.w	a0,a4
  800484:	c90d                	beqz	a0,8004b6 <vprintfmt+0x1de>
  800486:	000d4563          	bltz	s10,800490 <vprintfmt+0x1b8>
  80048a:	3d7d                	addiw	s10,s10,-1
  80048c:	037d0363          	beq	s10,s7,8004b2 <vprintfmt+0x1da>
  800490:	864a                	mv	a2,s2
  800492:	85a6                	mv	a1,s1
  800494:	180a0c63          	beqz	s4,80062c <vprintfmt+0x354>
  800498:	3701                	addiw	a4,a4,-32
  80049a:	18ec7963          	bleu	a4,s8,80062c <vprintfmt+0x354>
  80049e:	03f00513          	li	a0,63
  8004a2:	9982                	jalr	s3
  8004a4:	0405                	addi	s0,s0,1
  8004a6:	fff44703          	lbu	a4,-1(s0)
  8004aa:	3cfd                	addiw	s9,s9,-1
  8004ac:	0007051b          	sext.w	a0,a4
  8004b0:	f979                	bnez	a0,800486 <vprintfmt+0x1ae>
  8004b2:	e5905de3          	blez	s9,80030c <vprintfmt+0x34>
  8004b6:	3cfd                	addiw	s9,s9,-1
  8004b8:	864a                	mv	a2,s2
  8004ba:	85a6                	mv	a1,s1
  8004bc:	02000513          	li	a0,32
  8004c0:	9982                	jalr	s3
  8004c2:	e40c85e3          	beqz	s9,80030c <vprintfmt+0x34>
  8004c6:	3cfd                	addiw	s9,s9,-1
  8004c8:	864a                	mv	a2,s2
  8004ca:	85a6                	mv	a1,s1
  8004cc:	02000513          	li	a0,32
  8004d0:	9982                	jalr	s3
  8004d2:	fe0c92e3          	bnez	s9,8004b6 <vprintfmt+0x1de>
  8004d6:	bd1d                	j	80030c <vprintfmt+0x34>
  8004d8:	4705                	li	a4,1
  8004da:	008b0613          	addi	a2,s6,8
  8004de:	01174463          	blt	a4,a7,8004e6 <vprintfmt+0x20e>
  8004e2:	12088663          	beqz	a7,80060e <vprintfmt+0x336>
  8004e6:	000b3683          	ld	a3,0(s6)
  8004ea:	4729                	li	a4,10
  8004ec:	8b32                	mv	s6,a2
  8004ee:	b79d                	j	800454 <vprintfmt+0x17c>
  8004f0:	00144603          	lbu	a2,1(s0)
  8004f4:	02d00813          	li	a6,45
  8004f8:	846e                	mv	s0,s11
  8004fa:	bd89                	j	80034c <vprintfmt+0x74>
  8004fc:	864a                	mv	a2,s2
  8004fe:	85a6                	mv	a1,s1
  800500:	02500513          	li	a0,37
  800504:	9982                	jalr	s3
  800506:	b519                	j	80030c <vprintfmt+0x34>
  800508:	000b2d03          	lw	s10,0(s6)
  80050c:	00144603          	lbu	a2,1(s0)
  800510:	0b21                	addi	s6,s6,8
  800512:	846e                	mv	s0,s11
  800514:	e20cdce3          	bgez	s9,80034c <vprintfmt+0x74>
  800518:	8cea                	mv	s9,s10
  80051a:	5d7d                	li	s10,-1
  80051c:	bd05                	j	80034c <vprintfmt+0x74>
  80051e:	00144603          	lbu	a2,1(s0)
  800522:	03000813          	li	a6,48
  800526:	846e                	mv	s0,s11
  800528:	b515                	j	80034c <vprintfmt+0x74>
  80052a:	fd060d1b          	addiw	s10,a2,-48
  80052e:	00144603          	lbu	a2,1(s0)
  800532:	846e                	mv	s0,s11
  800534:	fd06071b          	addiw	a4,a2,-48
  800538:	0006031b          	sext.w	t1,a2
  80053c:	fce56ce3          	bltu	a0,a4,800514 <vprintfmt+0x23c>
  800540:	0405                	addi	s0,s0,1
  800542:	002d171b          	slliw	a4,s10,0x2
  800546:	00044603          	lbu	a2,0(s0)
  80054a:	01a706bb          	addw	a3,a4,s10
  80054e:	0016969b          	slliw	a3,a3,0x1
  800552:	006686bb          	addw	a3,a3,t1
  800556:	fd06071b          	addiw	a4,a2,-48
  80055a:	fd068d1b          	addiw	s10,a3,-48
  80055e:	0006031b          	sext.w	t1,a2
  800562:	fce57fe3          	bleu	a4,a0,800540 <vprintfmt+0x268>
  800566:	b77d                	j	800514 <vprintfmt+0x23c>
  800568:	fffcc713          	not	a4,s9
  80056c:	977d                	srai	a4,a4,0x3f
  80056e:	00ecf7b3          	and	a5,s9,a4
  800572:	00144603          	lbu	a2,1(s0)
  800576:	00078c9b          	sext.w	s9,a5
  80057a:	846e                	mv	s0,s11
  80057c:	bbc1                	j	80034c <vprintfmt+0x74>
  80057e:	864a                	mv	a2,s2
  800580:	85a6                	mv	a1,s1
  800582:	02500513          	li	a0,37
  800586:	9982                	jalr	s3
  800588:	fff44703          	lbu	a4,-1(s0)
  80058c:	02500793          	li	a5,37
  800590:	8da2                	mv	s11,s0
  800592:	d6f70de3          	beq	a4,a5,80030c <vprintfmt+0x34>
  800596:	02500713          	li	a4,37
  80059a:	1dfd                	addi	s11,s11,-1
  80059c:	fffdc783          	lbu	a5,-1(s11)
  8005a0:	fee79de3          	bne	a5,a4,80059a <vprintfmt+0x2c2>
  8005a4:	b3a5                	j	80030c <vprintfmt+0x34>
  8005a6:	00000697          	auipc	a3,0x0
  8005aa:	6f268693          	addi	a3,a3,1778 # 800c98 <error_string+0x2c0>
  8005ae:	8626                	mv	a2,s1
  8005b0:	85ca                	mv	a1,s2
  8005b2:	854e                	mv	a0,s3
  8005b4:	0b2000ef          	jal	ra,800666 <printfmt>
  8005b8:	bb91                	j	80030c <vprintfmt+0x34>
  8005ba:	00000717          	auipc	a4,0x0
  8005be:	6d670713          	addi	a4,a4,1750 # 800c90 <error_string+0x2b8>
  8005c2:	00000417          	auipc	s0,0x0
  8005c6:	6cf40413          	addi	s0,s0,1743 # 800c91 <error_string+0x2b9>
  8005ca:	853a                	mv	a0,a4
  8005cc:	85ea                	mv	a1,s10
  8005ce:	e03a                	sd	a4,0(sp)
  8005d0:	e442                	sd	a6,8(sp)
  8005d2:	12e000ef          	jal	ra,800700 <strnlen>
  8005d6:	40ac8cbb          	subw	s9,s9,a0
  8005da:	6702                	ld	a4,0(sp)
  8005dc:	01905f63          	blez	s9,8005fa <vprintfmt+0x322>
  8005e0:	6822                	ld	a6,8(sp)
  8005e2:	0008079b          	sext.w	a5,a6
  8005e6:	e43e                	sd	a5,8(sp)
  8005e8:	6522                	ld	a0,8(sp)
  8005ea:	864a                	mv	a2,s2
  8005ec:	85a6                	mv	a1,s1
  8005ee:	e03a                	sd	a4,0(sp)
  8005f0:	3cfd                	addiw	s9,s9,-1
  8005f2:	9982                	jalr	s3
  8005f4:	6702                	ld	a4,0(sp)
  8005f6:	fe0c99e3          	bnez	s9,8005e8 <vprintfmt+0x310>
  8005fa:	00074703          	lbu	a4,0(a4)
  8005fe:	0007051b          	sext.w	a0,a4
  800602:	e80512e3          	bnez	a0,800486 <vprintfmt+0x1ae>
  800606:	b319                	j	80030c <vprintfmt+0x34>
  800608:	000b2403          	lw	s0,0(s6)
  80060c:	bb6d                	j	8003c6 <vprintfmt+0xee>
  80060e:	000b6683          	lwu	a3,0(s6)
  800612:	4729                	li	a4,10
  800614:	8b32                	mv	s6,a2
  800616:	bd3d                	j	800454 <vprintfmt+0x17c>
  800618:	000b6683          	lwu	a3,0(s6)
  80061c:	4741                	li	a4,16
  80061e:	8b32                	mv	s6,a2
  800620:	bd15                	j	800454 <vprintfmt+0x17c>
  800622:	000b6683          	lwu	a3,0(s6)
  800626:	4721                	li	a4,8
  800628:	8b32                	mv	s6,a2
  80062a:	b52d                	j	800454 <vprintfmt+0x17c>
  80062c:	9982                	jalr	s3
  80062e:	bd9d                	j	8004a4 <vprintfmt+0x1cc>
  800630:	864a                	mv	a2,s2
  800632:	85a6                	mv	a1,s1
  800634:	02d00513          	li	a0,45
  800638:	e042                	sd	a6,0(sp)
  80063a:	9982                	jalr	s3
  80063c:	8b52                	mv	s6,s4
  80063e:	408006b3          	neg	a3,s0
  800642:	4729                	li	a4,10
  800644:	6802                	ld	a6,0(sp)
  800646:	b539                	j	800454 <vprintfmt+0x17c>
  800648:	01905663          	blez	s9,800654 <vprintfmt+0x37c>
  80064c:	02d00713          	li	a4,45
  800650:	f6e815e3          	bne	a6,a4,8005ba <vprintfmt+0x2e2>
  800654:	00000417          	auipc	s0,0x0
  800658:	63d40413          	addi	s0,s0,1597 # 800c91 <error_string+0x2b9>
  80065c:	02800513          	li	a0,40
  800660:	02800713          	li	a4,40
  800664:	b50d                	j	800486 <vprintfmt+0x1ae>

0000000000800666 <printfmt>:
  800666:	7139                	addi	sp,sp,-64
  800668:	02010313          	addi	t1,sp,32
  80066c:	f03a                	sd	a4,32(sp)
  80066e:	871a                	mv	a4,t1
  800670:	ec06                	sd	ra,24(sp)
  800672:	f43e                	sd	a5,40(sp)
  800674:	f842                	sd	a6,48(sp)
  800676:	fc46                	sd	a7,56(sp)
  800678:	e41a                	sd	t1,8(sp)
  80067a:	c5fff0ef          	jal	ra,8002d8 <vprintfmt>
  80067e:	60e2                	ld	ra,24(sp)
  800680:	6121                	addi	sp,sp,64
  800682:	8082                	ret

0000000000800684 <vsnprintf>:
  800684:	15fd                	addi	a1,a1,-1
  800686:	7179                	addi	sp,sp,-48
  800688:	95aa                	add	a1,a1,a0
  80068a:	f406                	sd	ra,40(sp)
  80068c:	e42a                	sd	a0,8(sp)
  80068e:	e82e                	sd	a1,16(sp)
  800690:	cc02                	sw	zero,24(sp)
  800692:	c515                	beqz	a0,8006be <vsnprintf+0x3a>
  800694:	02a5e563          	bltu	a1,a0,8006be <vsnprintf+0x3a>
  800698:	75dd                	lui	a1,0xffff7
  80069a:	8736                	mv	a4,a3
  80069c:	00000517          	auipc	a0,0x0
  8006a0:	c2250513          	addi	a0,a0,-990 # 8002be <sprintputch>
  8006a4:	86b2                	mv	a3,a2
  8006a6:	ad958593          	addi	a1,a1,-1319 # ffffffffffff6ad9 <error_string+0xffffffffff7f6101>
  8006aa:	0030                	addi	a2,sp,8
  8006ac:	c2dff0ef          	jal	ra,8002d8 <vprintfmt>
  8006b0:	67a2                	ld	a5,8(sp)
  8006b2:	00078023          	sb	zero,0(a5)
  8006b6:	4562                	lw	a0,24(sp)
  8006b8:	70a2                	ld	ra,40(sp)
  8006ba:	6145                	addi	sp,sp,48
  8006bc:	8082                	ret
  8006be:	5575                	li	a0,-3
  8006c0:	bfe5                	j	8006b8 <vsnprintf+0x34>

00000000008006c2 <snprintf>:
  8006c2:	715d                	addi	sp,sp,-80
  8006c4:	02810313          	addi	t1,sp,40
  8006c8:	f436                	sd	a3,40(sp)
  8006ca:	869a                	mv	a3,t1
  8006cc:	ec06                	sd	ra,24(sp)
  8006ce:	f83a                	sd	a4,48(sp)
  8006d0:	fc3e                	sd	a5,56(sp)
  8006d2:	e0c2                	sd	a6,64(sp)
  8006d4:	e4c6                	sd	a7,72(sp)
  8006d6:	e41a                	sd	t1,8(sp)
  8006d8:	fadff0ef          	jal	ra,800684 <vsnprintf>
  8006dc:	60e2                	ld	ra,24(sp)
  8006de:	6161                	addi	sp,sp,80
  8006e0:	8082                	ret

00000000008006e2 <strlen>:
  8006e2:	00054783          	lbu	a5,0(a0)
  8006e6:	cb91                	beqz	a5,8006fa <strlen+0x18>
  8006e8:	4781                	li	a5,0
  8006ea:	0785                	addi	a5,a5,1
  8006ec:	00f50733          	add	a4,a0,a5
  8006f0:	00074703          	lbu	a4,0(a4)
  8006f4:	fb7d                	bnez	a4,8006ea <strlen+0x8>
  8006f6:	853e                	mv	a0,a5
  8006f8:	8082                	ret
  8006fa:	4781                	li	a5,0
  8006fc:	853e                	mv	a0,a5
  8006fe:	8082                	ret

0000000000800700 <strnlen>:
  800700:	c185                	beqz	a1,800720 <strnlen+0x20>
  800702:	00054783          	lbu	a5,0(a0)
  800706:	cf89                	beqz	a5,800720 <strnlen+0x20>
  800708:	4781                	li	a5,0
  80070a:	a021                	j	800712 <strnlen+0x12>
  80070c:	00074703          	lbu	a4,0(a4)
  800710:	c711                	beqz	a4,80071c <strnlen+0x1c>
  800712:	0785                	addi	a5,a5,1
  800714:	00f50733          	add	a4,a0,a5
  800718:	fef59ae3          	bne	a1,a5,80070c <strnlen+0xc>
  80071c:	853e                	mv	a0,a5
  80071e:	8082                	ret
  800720:	4781                	li	a5,0
  800722:	853e                	mv	a0,a5
  800724:	8082                	ret

0000000000800726 <forktree>:
  800726:	1141                	addi	sp,sp,-16
  800728:	e406                	sd	ra,8(sp)
  80072a:	e022                	sd	s0,0(sp)
  80072c:	842a                	mv	s0,a0
  80072e:	a5fff0ef          	jal	ra,80018c <getpid>
  800732:	8622                	mv	a2,s0
  800734:	85aa                	mv	a1,a0
  800736:	00000517          	auipc	a0,0x0
  80073a:	58250513          	addi	a0,a0,1410 # 800cb8 <error_string+0x2e0>
  80073e:	97bff0ef          	jal	ra,8000b8 <cprintf>
  800742:	8522                	mv	a0,s0
  800744:	03000593          	li	a1,48
  800748:	014000ef          	jal	ra,80075c <forkchild>
  80074c:	8522                	mv	a0,s0
  80074e:	6402                	ld	s0,0(sp)
  800750:	60a2                	ld	ra,8(sp)
  800752:	03100593          	li	a1,49
  800756:	0141                	addi	sp,sp,16
  800758:	0040006f          	j	80075c <forkchild>

000000000080075c <forkchild>:
  80075c:	7179                	addi	sp,sp,-48
  80075e:	f022                	sd	s0,32(sp)
  800760:	ec26                	sd	s1,24(sp)
  800762:	f406                	sd	ra,40(sp)
  800764:	842a                	mv	s0,a0
  800766:	84ae                	mv	s1,a1
  800768:	f7bff0ef          	jal	ra,8006e2 <strlen>
  80076c:	4789                	li	a5,2
  80076e:	00a7f763          	bleu	a0,a5,80077c <forkchild+0x20>
  800772:	70a2                	ld	ra,40(sp)
  800774:	7402                	ld	s0,32(sp)
  800776:	64e2                	ld	s1,24(sp)
  800778:	6145                	addi	sp,sp,48
  80077a:	8082                	ret
  80077c:	8726                	mv	a4,s1
  80077e:	86a2                	mv	a3,s0
  800780:	00000617          	auipc	a2,0x0
  800784:	53060613          	addi	a2,a2,1328 # 800cb0 <error_string+0x2d8>
  800788:	4591                	li	a1,4
  80078a:	0028                	addi	a0,sp,8
  80078c:	f37ff0ef          	jal	ra,8006c2 <snprintf>
  800790:	9f5ff0ef          	jal	ra,800184 <fork>
  800794:	fd79                	bnez	a0,800772 <forkchild+0x16>
  800796:	0028                	addi	a0,sp,8
  800798:	f8fff0ef          	jal	ra,800726 <forktree>
  80079c:	9edff0ef          	jal	ra,800188 <yield>
  8007a0:	4501                	li	a0,0
  8007a2:	9cdff0ef          	jal	ra,80016e <exit>

00000000008007a6 <main>:
  8007a6:	1141                	addi	sp,sp,-16
  8007a8:	00000517          	auipc	a0,0x0
  8007ac:	52050513          	addi	a0,a0,1312 # 800cc8 <error_string+0x2f0>
  8007b0:	e406                	sd	ra,8(sp)
  8007b2:	f75ff0ef          	jal	ra,800726 <forktree>
  8007b6:	60a2                	ld	ra,8(sp)
  8007b8:	4501                	li	a0,0
  8007ba:	0141                	addi	sp,sp,16
  8007bc:	8082                	ret
