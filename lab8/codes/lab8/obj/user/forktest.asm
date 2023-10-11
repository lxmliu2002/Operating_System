
obj/__user_forktest.out：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000000800020 <open>:
  800020:	1582                	slli	a1,a1,0x20
  800022:	9181                	srli	a1,a1,0x20
  800024:	1660006f          	j	80018a <sys_open>

0000000000800028 <close>:
  800028:	16e0006f          	j	800196 <sys_close>

000000000080002c <dup2>:
  80002c:	1740006f          	j	8001a0 <sys_dup>

0000000000800030 <_start>:
  800030:	1e2000ef          	jal	ra,800212 <umain>
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
  800048:	73450513          	addi	a0,a0,1844 # 800778 <main+0xaa>
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
  800064:	00000517          	auipc	a0,0x0
  800068:	78c50513          	addi	a0,a0,1932 # 8007f0 <main+0x122>
  80006c:	08c000ef          	jal	ra,8000f8 <cprintf>
  800070:	5559                	li	a0,-10
  800072:	13a000ef          	jal	ra,8001ac <exit>

0000000000800076 <__warn>:
  800076:	715d                	addi	sp,sp,-80
  800078:	e822                	sd	s0,16(sp)
  80007a:	fc3e                	sd	a5,56(sp)
  80007c:	8432                	mv	s0,a2
  80007e:	103c                	addi	a5,sp,40
  800080:	862e                	mv	a2,a1
  800082:	85aa                	mv	a1,a0
  800084:	00000517          	auipc	a0,0x0
  800088:	71450513          	addi	a0,a0,1812 # 800798 <main+0xca>
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
  8000a4:	00000517          	auipc	a0,0x0
  8000a8:	74c50513          	addi	a0,a0,1868 # 8007f0 <main+0x122>
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
  8000c0:	0c2000ef          	jal	ra,800182 <sys_putc>
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
  8000e4:	ad958593          	addi	a1,a1,-1319 # ffffffffffff6ad9 <error_string+0xffffffffff7f6149>
  8000e8:	ec06                	sd	ra,24(sp)
  8000ea:	c602                	sw	zero,12(sp)
  8000ec:	210000ef          	jal	ra,8002fc <vprintfmt>
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
  800116:	ad958593          	addi	a1,a1,-1319 # ffffffffffff6ad9 <error_string+0xffffffffff7f6149>
  80011a:	ec06                	sd	ra,24(sp)
  80011c:	e4be                	sd	a5,72(sp)
  80011e:	e8c2                	sd	a6,80(sp)
  800120:	ecc6                	sd	a7,88(sp)
  800122:	e41a                	sd	t1,8(sp)
  800124:	c202                	sw	zero,4(sp)
  800126:	1d6000ef          	jal	ra,8002fc <vprintfmt>
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

0000000000800182 <sys_putc>:
  800182:	85aa                	mv	a1,a0
  800184:	4579                	li	a0,30
  800186:	fadff06f          	j	800132 <syscall>

000000000080018a <sys_open>:
  80018a:	862e                	mv	a2,a1
  80018c:	85aa                	mv	a1,a0
  80018e:	06400513          	li	a0,100
  800192:	fa1ff06f          	j	800132 <syscall>

0000000000800196 <sys_close>:
  800196:	85aa                	mv	a1,a0
  800198:	06500513          	li	a0,101
  80019c:	f97ff06f          	j	800132 <syscall>

00000000008001a0 <sys_dup>:
  8001a0:	862e                	mv	a2,a1
  8001a2:	85aa                	mv	a1,a0
  8001a4:	08200513          	li	a0,130
  8001a8:	f8bff06f          	j	800132 <syscall>

00000000008001ac <exit>:
  8001ac:	1141                	addi	sp,sp,-16
  8001ae:	e406                	sd	ra,8(sp)
  8001b0:	fbbff0ef          	jal	ra,80016a <sys_exit>
  8001b4:	00000517          	auipc	a0,0x0
  8001b8:	60450513          	addi	a0,a0,1540 # 8007b8 <main+0xea>
  8001bc:	f3dff0ef          	jal	ra,8000f8 <cprintf>
  8001c0:	a001                	j	8001c0 <exit+0x14>

00000000008001c2 <fork>:
  8001c2:	fb1ff06f          	j	800172 <sys_fork>

00000000008001c6 <wait>:
  8001c6:	4581                	li	a1,0
  8001c8:	4501                	li	a0,0
  8001ca:	fafff06f          	j	800178 <sys_wait>

00000000008001ce <initfd>:
  8001ce:	1101                	addi	sp,sp,-32
  8001d0:	87ae                	mv	a5,a1
  8001d2:	e426                	sd	s1,8(sp)
  8001d4:	85b2                	mv	a1,a2
  8001d6:	84aa                	mv	s1,a0
  8001d8:	853e                	mv	a0,a5
  8001da:	e822                	sd	s0,16(sp)
  8001dc:	ec06                	sd	ra,24(sp)
  8001de:	e43ff0ef          	jal	ra,800020 <open>
  8001e2:	842a                	mv	s0,a0
  8001e4:	00054463          	bltz	a0,8001ec <initfd+0x1e>
  8001e8:	00951863          	bne	a0,s1,8001f8 <initfd+0x2a>
  8001ec:	8522                	mv	a0,s0
  8001ee:	60e2                	ld	ra,24(sp)
  8001f0:	6442                	ld	s0,16(sp)
  8001f2:	64a2                	ld	s1,8(sp)
  8001f4:	6105                	addi	sp,sp,32
  8001f6:	8082                	ret
  8001f8:	8526                	mv	a0,s1
  8001fa:	e2fff0ef          	jal	ra,800028 <close>
  8001fe:	85a6                	mv	a1,s1
  800200:	8522                	mv	a0,s0
  800202:	e2bff0ef          	jal	ra,80002c <dup2>
  800206:	84aa                	mv	s1,a0
  800208:	8522                	mv	a0,s0
  80020a:	e1fff0ef          	jal	ra,800028 <close>
  80020e:	8426                	mv	s0,s1
  800210:	bff1                	j	8001ec <initfd+0x1e>

0000000000800212 <umain>:
  800212:	1101                	addi	sp,sp,-32
  800214:	e822                	sd	s0,16(sp)
  800216:	e426                	sd	s1,8(sp)
  800218:	842a                	mv	s0,a0
  80021a:	84ae                	mv	s1,a1
  80021c:	4601                	li	a2,0
  80021e:	00000597          	auipc	a1,0x0
  800222:	5b258593          	addi	a1,a1,1458 # 8007d0 <main+0x102>
  800226:	4501                	li	a0,0
  800228:	ec06                	sd	ra,24(sp)
  80022a:	fa5ff0ef          	jal	ra,8001ce <initfd>
  80022e:	02054263          	bltz	a0,800252 <umain+0x40>
  800232:	4605                	li	a2,1
  800234:	00000597          	auipc	a1,0x0
  800238:	5dc58593          	addi	a1,a1,1500 # 800810 <main+0x142>
  80023c:	4505                	li	a0,1
  80023e:	f91ff0ef          	jal	ra,8001ce <initfd>
  800242:	02054563          	bltz	a0,80026c <umain+0x5a>
  800246:	85a6                	mv	a1,s1
  800248:	8522                	mv	a0,s0
  80024a:	484000ef          	jal	ra,8006ce <main>
  80024e:	f5fff0ef          	jal	ra,8001ac <exit>
  800252:	86aa                	mv	a3,a0
  800254:	00000617          	auipc	a2,0x0
  800258:	58460613          	addi	a2,a2,1412 # 8007d8 <main+0x10a>
  80025c:	45e9                	li	a1,26
  80025e:	00000517          	auipc	a0,0x0
  800262:	59a50513          	addi	a0,a0,1434 # 8007f8 <main+0x12a>
  800266:	e11ff0ef          	jal	ra,800076 <__warn>
  80026a:	b7e1                	j	800232 <umain+0x20>
  80026c:	86aa                	mv	a3,a0
  80026e:	00000617          	auipc	a2,0x0
  800272:	5aa60613          	addi	a2,a2,1450 # 800818 <main+0x14a>
  800276:	45f5                	li	a1,29
  800278:	00000517          	auipc	a0,0x0
  80027c:	58050513          	addi	a0,a0,1408 # 8007f8 <main+0x12a>
  800280:	df7ff0ef          	jal	ra,800076 <__warn>
  800284:	b7c9                	j	800246 <umain+0x34>

0000000000800286 <printnum>:
  800286:	02071893          	slli	a7,a4,0x20
  80028a:	7139                	addi	sp,sp,-64
  80028c:	0208d893          	srli	a7,a7,0x20
  800290:	e456                	sd	s5,8(sp)
  800292:	0316fab3          	remu	s5,a3,a7
  800296:	f822                	sd	s0,48(sp)
  800298:	f426                	sd	s1,40(sp)
  80029a:	f04a                	sd	s2,32(sp)
  80029c:	ec4e                	sd	s3,24(sp)
  80029e:	fc06                	sd	ra,56(sp)
  8002a0:	e852                	sd	s4,16(sp)
  8002a2:	84aa                	mv	s1,a0
  8002a4:	89ae                	mv	s3,a1
  8002a6:	8932                	mv	s2,a2
  8002a8:	fff7841b          	addiw	s0,a5,-1
  8002ac:	2a81                	sext.w	s5,s5
  8002ae:	0516f163          	bleu	a7,a3,8002f0 <printnum+0x6a>
  8002b2:	8a42                	mv	s4,a6
  8002b4:	00805863          	blez	s0,8002c4 <printnum+0x3e>
  8002b8:	347d                	addiw	s0,s0,-1
  8002ba:	864e                	mv	a2,s3
  8002bc:	85ca                	mv	a1,s2
  8002be:	8552                	mv	a0,s4
  8002c0:	9482                	jalr	s1
  8002c2:	f87d                	bnez	s0,8002b8 <printnum+0x32>
  8002c4:	1a82                	slli	s5,s5,0x20
  8002c6:	020ada93          	srli	s5,s5,0x20
  8002ca:	00000797          	auipc	a5,0x0
  8002ce:	78e78793          	addi	a5,a5,1934 # 800a58 <error_string+0xc8>
  8002d2:	9abe                	add	s5,s5,a5
  8002d4:	7442                	ld	s0,48(sp)
  8002d6:	000ac503          	lbu	a0,0(s5)
  8002da:	70e2                	ld	ra,56(sp)
  8002dc:	6a42                	ld	s4,16(sp)
  8002de:	6aa2                	ld	s5,8(sp)
  8002e0:	864e                	mv	a2,s3
  8002e2:	85ca                	mv	a1,s2
  8002e4:	69e2                	ld	s3,24(sp)
  8002e6:	7902                	ld	s2,32(sp)
  8002e8:	8326                	mv	t1,s1
  8002ea:	74a2                	ld	s1,40(sp)
  8002ec:	6121                	addi	sp,sp,64
  8002ee:	8302                	jr	t1
  8002f0:	0316d6b3          	divu	a3,a3,a7
  8002f4:	87a2                	mv	a5,s0
  8002f6:	f91ff0ef          	jal	ra,800286 <printnum>
  8002fa:	b7e9                	j	8002c4 <printnum+0x3e>

00000000008002fc <vprintfmt>:
  8002fc:	7119                	addi	sp,sp,-128
  8002fe:	f4a6                	sd	s1,104(sp)
  800300:	f0ca                	sd	s2,96(sp)
  800302:	ecce                	sd	s3,88(sp)
  800304:	e4d6                	sd	s5,72(sp)
  800306:	e0da                	sd	s6,64(sp)
  800308:	fc5e                	sd	s7,56(sp)
  80030a:	f862                	sd	s8,48(sp)
  80030c:	ec6e                	sd	s11,24(sp)
  80030e:	fc86                	sd	ra,120(sp)
  800310:	f8a2                	sd	s0,112(sp)
  800312:	e8d2                	sd	s4,80(sp)
  800314:	f466                	sd	s9,40(sp)
  800316:	f06a                	sd	s10,32(sp)
  800318:	89aa                	mv	s3,a0
  80031a:	892e                	mv	s2,a1
  80031c:	84b2                	mv	s1,a2
  80031e:	8db6                	mv	s11,a3
  800320:	8b3a                	mv	s6,a4
  800322:	5bfd                	li	s7,-1
  800324:	00000a97          	auipc	s5,0x0
  800328:	510a8a93          	addi	s5,s5,1296 # 800834 <main+0x166>
  80032c:	05e00c13          	li	s8,94
  800330:	000dc503          	lbu	a0,0(s11)
  800334:	02500793          	li	a5,37
  800338:	001d8413          	addi	s0,s11,1
  80033c:	00f50f63          	beq	a0,a5,80035a <vprintfmt+0x5e>
  800340:	c529                	beqz	a0,80038a <vprintfmt+0x8e>
  800342:	02500a13          	li	s4,37
  800346:	a011                	j	80034a <vprintfmt+0x4e>
  800348:	c129                	beqz	a0,80038a <vprintfmt+0x8e>
  80034a:	864a                	mv	a2,s2
  80034c:	85a6                	mv	a1,s1
  80034e:	0405                	addi	s0,s0,1
  800350:	9982                	jalr	s3
  800352:	fff44503          	lbu	a0,-1(s0)
  800356:	ff4519e3          	bne	a0,s4,800348 <vprintfmt+0x4c>
  80035a:	00044603          	lbu	a2,0(s0)
  80035e:	02000813          	li	a6,32
  800362:	4a01                	li	s4,0
  800364:	4881                	li	a7,0
  800366:	5d7d                	li	s10,-1
  800368:	5cfd                	li	s9,-1
  80036a:	05500593          	li	a1,85
  80036e:	4525                	li	a0,9
  800370:	fdd6071b          	addiw	a4,a2,-35
  800374:	0ff77713          	andi	a4,a4,255
  800378:	00140d93          	addi	s11,s0,1
  80037c:	22e5e363          	bltu	a1,a4,8005a2 <vprintfmt+0x2a6>
  800380:	070a                	slli	a4,a4,0x2
  800382:	9756                	add	a4,a4,s5
  800384:	4318                	lw	a4,0(a4)
  800386:	9756                	add	a4,a4,s5
  800388:	8702                	jr	a4
  80038a:	70e6                	ld	ra,120(sp)
  80038c:	7446                	ld	s0,112(sp)
  80038e:	74a6                	ld	s1,104(sp)
  800390:	7906                	ld	s2,96(sp)
  800392:	69e6                	ld	s3,88(sp)
  800394:	6a46                	ld	s4,80(sp)
  800396:	6aa6                	ld	s5,72(sp)
  800398:	6b06                	ld	s6,64(sp)
  80039a:	7be2                	ld	s7,56(sp)
  80039c:	7c42                	ld	s8,48(sp)
  80039e:	7ca2                	ld	s9,40(sp)
  8003a0:	7d02                	ld	s10,32(sp)
  8003a2:	6de2                	ld	s11,24(sp)
  8003a4:	6109                	addi	sp,sp,128
  8003a6:	8082                	ret
  8003a8:	4705                	li	a4,1
  8003aa:	008b0613          	addi	a2,s6,8
  8003ae:	01174463          	blt	a4,a7,8003b6 <vprintfmt+0xba>
  8003b2:	28088563          	beqz	a7,80063c <vprintfmt+0x340>
  8003b6:	000b3683          	ld	a3,0(s6)
  8003ba:	4741                	li	a4,16
  8003bc:	8b32                	mv	s6,a2
  8003be:	a86d                	j	800478 <vprintfmt+0x17c>
  8003c0:	00144603          	lbu	a2,1(s0)
  8003c4:	4a05                	li	s4,1
  8003c6:	846e                	mv	s0,s11
  8003c8:	b765                	j	800370 <vprintfmt+0x74>
  8003ca:	000b2503          	lw	a0,0(s6)
  8003ce:	864a                	mv	a2,s2
  8003d0:	85a6                	mv	a1,s1
  8003d2:	0b21                	addi	s6,s6,8
  8003d4:	9982                	jalr	s3
  8003d6:	bfa9                	j	800330 <vprintfmt+0x34>
  8003d8:	4705                	li	a4,1
  8003da:	008b0a13          	addi	s4,s6,8
  8003de:	01174463          	blt	a4,a7,8003e6 <vprintfmt+0xea>
  8003e2:	24088563          	beqz	a7,80062c <vprintfmt+0x330>
  8003e6:	000b3403          	ld	s0,0(s6)
  8003ea:	26044563          	bltz	s0,800654 <vprintfmt+0x358>
  8003ee:	86a2                	mv	a3,s0
  8003f0:	8b52                	mv	s6,s4
  8003f2:	4729                	li	a4,10
  8003f4:	a051                	j	800478 <vprintfmt+0x17c>
  8003f6:	000b2783          	lw	a5,0(s6)
  8003fa:	46e1                	li	a3,24
  8003fc:	0b21                	addi	s6,s6,8
  8003fe:	41f7d71b          	sraiw	a4,a5,0x1f
  800402:	8fb9                	xor	a5,a5,a4
  800404:	40e7873b          	subw	a4,a5,a4
  800408:	1ce6c163          	blt	a3,a4,8005ca <vprintfmt+0x2ce>
  80040c:	00371793          	slli	a5,a4,0x3
  800410:	00000697          	auipc	a3,0x0
  800414:	58068693          	addi	a3,a3,1408 # 800990 <error_string>
  800418:	97b6                	add	a5,a5,a3
  80041a:	639c                	ld	a5,0(a5)
  80041c:	1a078763          	beqz	a5,8005ca <vprintfmt+0x2ce>
  800420:	873e                	mv	a4,a5
  800422:	00001697          	auipc	a3,0x1
  800426:	83e68693          	addi	a3,a3,-1986 # 800c60 <error_string+0x2d0>
  80042a:	8626                	mv	a2,s1
  80042c:	85ca                	mv	a1,s2
  80042e:	854e                	mv	a0,s3
  800430:	25a000ef          	jal	ra,80068a <printfmt>
  800434:	bdf5                	j	800330 <vprintfmt+0x34>
  800436:	00144603          	lbu	a2,1(s0)
  80043a:	2885                	addiw	a7,a7,1
  80043c:	846e                	mv	s0,s11
  80043e:	bf0d                	j	800370 <vprintfmt+0x74>
  800440:	4705                	li	a4,1
  800442:	008b0613          	addi	a2,s6,8
  800446:	01174463          	blt	a4,a7,80044e <vprintfmt+0x152>
  80044a:	1e088e63          	beqz	a7,800646 <vprintfmt+0x34a>
  80044e:	000b3683          	ld	a3,0(s6)
  800452:	4721                	li	a4,8
  800454:	8b32                	mv	s6,a2
  800456:	a00d                	j	800478 <vprintfmt+0x17c>
  800458:	03000513          	li	a0,48
  80045c:	864a                	mv	a2,s2
  80045e:	85a6                	mv	a1,s1
  800460:	e042                	sd	a6,0(sp)
  800462:	9982                	jalr	s3
  800464:	864a                	mv	a2,s2
  800466:	85a6                	mv	a1,s1
  800468:	07800513          	li	a0,120
  80046c:	9982                	jalr	s3
  80046e:	0b21                	addi	s6,s6,8
  800470:	ff8b3683          	ld	a3,-8(s6)
  800474:	6802                	ld	a6,0(sp)
  800476:	4741                	li	a4,16
  800478:	87e6                	mv	a5,s9
  80047a:	8626                	mv	a2,s1
  80047c:	85ca                	mv	a1,s2
  80047e:	854e                	mv	a0,s3
  800480:	e07ff0ef          	jal	ra,800286 <printnum>
  800484:	b575                	j	800330 <vprintfmt+0x34>
  800486:	000b3703          	ld	a4,0(s6)
  80048a:	0b21                	addi	s6,s6,8
  80048c:	1e070063          	beqz	a4,80066c <vprintfmt+0x370>
  800490:	00170413          	addi	s0,a4,1
  800494:	19905563          	blez	s9,80061e <vprintfmt+0x322>
  800498:	02d00613          	li	a2,45
  80049c:	14c81963          	bne	a6,a2,8005ee <vprintfmt+0x2f2>
  8004a0:	00074703          	lbu	a4,0(a4)
  8004a4:	0007051b          	sext.w	a0,a4
  8004a8:	c90d                	beqz	a0,8004da <vprintfmt+0x1de>
  8004aa:	000d4563          	bltz	s10,8004b4 <vprintfmt+0x1b8>
  8004ae:	3d7d                	addiw	s10,s10,-1
  8004b0:	037d0363          	beq	s10,s7,8004d6 <vprintfmt+0x1da>
  8004b4:	864a                	mv	a2,s2
  8004b6:	85a6                	mv	a1,s1
  8004b8:	180a0c63          	beqz	s4,800650 <vprintfmt+0x354>
  8004bc:	3701                	addiw	a4,a4,-32
  8004be:	18ec7963          	bleu	a4,s8,800650 <vprintfmt+0x354>
  8004c2:	03f00513          	li	a0,63
  8004c6:	9982                	jalr	s3
  8004c8:	0405                	addi	s0,s0,1
  8004ca:	fff44703          	lbu	a4,-1(s0)
  8004ce:	3cfd                	addiw	s9,s9,-1
  8004d0:	0007051b          	sext.w	a0,a4
  8004d4:	f979                	bnez	a0,8004aa <vprintfmt+0x1ae>
  8004d6:	e5905de3          	blez	s9,800330 <vprintfmt+0x34>
  8004da:	3cfd                	addiw	s9,s9,-1
  8004dc:	864a                	mv	a2,s2
  8004de:	85a6                	mv	a1,s1
  8004e0:	02000513          	li	a0,32
  8004e4:	9982                	jalr	s3
  8004e6:	e40c85e3          	beqz	s9,800330 <vprintfmt+0x34>
  8004ea:	3cfd                	addiw	s9,s9,-1
  8004ec:	864a                	mv	a2,s2
  8004ee:	85a6                	mv	a1,s1
  8004f0:	02000513          	li	a0,32
  8004f4:	9982                	jalr	s3
  8004f6:	fe0c92e3          	bnez	s9,8004da <vprintfmt+0x1de>
  8004fa:	bd1d                	j	800330 <vprintfmt+0x34>
  8004fc:	4705                	li	a4,1
  8004fe:	008b0613          	addi	a2,s6,8
  800502:	01174463          	blt	a4,a7,80050a <vprintfmt+0x20e>
  800506:	12088663          	beqz	a7,800632 <vprintfmt+0x336>
  80050a:	000b3683          	ld	a3,0(s6)
  80050e:	4729                	li	a4,10
  800510:	8b32                	mv	s6,a2
  800512:	b79d                	j	800478 <vprintfmt+0x17c>
  800514:	00144603          	lbu	a2,1(s0)
  800518:	02d00813          	li	a6,45
  80051c:	846e                	mv	s0,s11
  80051e:	bd89                	j	800370 <vprintfmt+0x74>
  800520:	864a                	mv	a2,s2
  800522:	85a6                	mv	a1,s1
  800524:	02500513          	li	a0,37
  800528:	9982                	jalr	s3
  80052a:	b519                	j	800330 <vprintfmt+0x34>
  80052c:	000b2d03          	lw	s10,0(s6)
  800530:	00144603          	lbu	a2,1(s0)
  800534:	0b21                	addi	s6,s6,8
  800536:	846e                	mv	s0,s11
  800538:	e20cdce3          	bgez	s9,800370 <vprintfmt+0x74>
  80053c:	8cea                	mv	s9,s10
  80053e:	5d7d                	li	s10,-1
  800540:	bd05                	j	800370 <vprintfmt+0x74>
  800542:	00144603          	lbu	a2,1(s0)
  800546:	03000813          	li	a6,48
  80054a:	846e                	mv	s0,s11
  80054c:	b515                	j	800370 <vprintfmt+0x74>
  80054e:	fd060d1b          	addiw	s10,a2,-48
  800552:	00144603          	lbu	a2,1(s0)
  800556:	846e                	mv	s0,s11
  800558:	fd06071b          	addiw	a4,a2,-48
  80055c:	0006031b          	sext.w	t1,a2
  800560:	fce56ce3          	bltu	a0,a4,800538 <vprintfmt+0x23c>
  800564:	0405                	addi	s0,s0,1
  800566:	002d171b          	slliw	a4,s10,0x2
  80056a:	00044603          	lbu	a2,0(s0)
  80056e:	01a706bb          	addw	a3,a4,s10
  800572:	0016969b          	slliw	a3,a3,0x1
  800576:	006686bb          	addw	a3,a3,t1
  80057a:	fd06071b          	addiw	a4,a2,-48
  80057e:	fd068d1b          	addiw	s10,a3,-48
  800582:	0006031b          	sext.w	t1,a2
  800586:	fce57fe3          	bleu	a4,a0,800564 <vprintfmt+0x268>
  80058a:	b77d                	j	800538 <vprintfmt+0x23c>
  80058c:	fffcc713          	not	a4,s9
  800590:	977d                	srai	a4,a4,0x3f
  800592:	00ecf7b3          	and	a5,s9,a4
  800596:	00144603          	lbu	a2,1(s0)
  80059a:	00078c9b          	sext.w	s9,a5
  80059e:	846e                	mv	s0,s11
  8005a0:	bbc1                	j	800370 <vprintfmt+0x74>
  8005a2:	864a                	mv	a2,s2
  8005a4:	85a6                	mv	a1,s1
  8005a6:	02500513          	li	a0,37
  8005aa:	9982                	jalr	s3
  8005ac:	fff44703          	lbu	a4,-1(s0)
  8005b0:	02500793          	li	a5,37
  8005b4:	8da2                	mv	s11,s0
  8005b6:	d6f70de3          	beq	a4,a5,800330 <vprintfmt+0x34>
  8005ba:	02500713          	li	a4,37
  8005be:	1dfd                	addi	s11,s11,-1
  8005c0:	fffdc783          	lbu	a5,-1(s11)
  8005c4:	fee79de3          	bne	a5,a4,8005be <vprintfmt+0x2c2>
  8005c8:	b3a5                	j	800330 <vprintfmt+0x34>
  8005ca:	00000697          	auipc	a3,0x0
  8005ce:	68668693          	addi	a3,a3,1670 # 800c50 <error_string+0x2c0>
  8005d2:	8626                	mv	a2,s1
  8005d4:	85ca                	mv	a1,s2
  8005d6:	854e                	mv	a0,s3
  8005d8:	0b2000ef          	jal	ra,80068a <printfmt>
  8005dc:	bb91                	j	800330 <vprintfmt+0x34>
  8005de:	00000717          	auipc	a4,0x0
  8005e2:	66a70713          	addi	a4,a4,1642 # 800c48 <error_string+0x2b8>
  8005e6:	00000417          	auipc	s0,0x0
  8005ea:	66340413          	addi	s0,s0,1635 # 800c49 <error_string+0x2b9>
  8005ee:	853a                	mv	a0,a4
  8005f0:	85ea                	mv	a1,s10
  8005f2:	e03a                	sd	a4,0(sp)
  8005f4:	e442                	sd	a6,8(sp)
  8005f6:	0b2000ef          	jal	ra,8006a8 <strnlen>
  8005fa:	40ac8cbb          	subw	s9,s9,a0
  8005fe:	6702                	ld	a4,0(sp)
  800600:	01905f63          	blez	s9,80061e <vprintfmt+0x322>
  800604:	6822                	ld	a6,8(sp)
  800606:	0008079b          	sext.w	a5,a6
  80060a:	e43e                	sd	a5,8(sp)
  80060c:	6522                	ld	a0,8(sp)
  80060e:	864a                	mv	a2,s2
  800610:	85a6                	mv	a1,s1
  800612:	e03a                	sd	a4,0(sp)
  800614:	3cfd                	addiw	s9,s9,-1
  800616:	9982                	jalr	s3
  800618:	6702                	ld	a4,0(sp)
  80061a:	fe0c99e3          	bnez	s9,80060c <vprintfmt+0x310>
  80061e:	00074703          	lbu	a4,0(a4)
  800622:	0007051b          	sext.w	a0,a4
  800626:	e80512e3          	bnez	a0,8004aa <vprintfmt+0x1ae>
  80062a:	b319                	j	800330 <vprintfmt+0x34>
  80062c:	000b2403          	lw	s0,0(s6)
  800630:	bb6d                	j	8003ea <vprintfmt+0xee>
  800632:	000b6683          	lwu	a3,0(s6)
  800636:	4729                	li	a4,10
  800638:	8b32                	mv	s6,a2
  80063a:	bd3d                	j	800478 <vprintfmt+0x17c>
  80063c:	000b6683          	lwu	a3,0(s6)
  800640:	4741                	li	a4,16
  800642:	8b32                	mv	s6,a2
  800644:	bd15                	j	800478 <vprintfmt+0x17c>
  800646:	000b6683          	lwu	a3,0(s6)
  80064a:	4721                	li	a4,8
  80064c:	8b32                	mv	s6,a2
  80064e:	b52d                	j	800478 <vprintfmt+0x17c>
  800650:	9982                	jalr	s3
  800652:	bd9d                	j	8004c8 <vprintfmt+0x1cc>
  800654:	864a                	mv	a2,s2
  800656:	85a6                	mv	a1,s1
  800658:	02d00513          	li	a0,45
  80065c:	e042                	sd	a6,0(sp)
  80065e:	9982                	jalr	s3
  800660:	8b52                	mv	s6,s4
  800662:	408006b3          	neg	a3,s0
  800666:	4729                	li	a4,10
  800668:	6802                	ld	a6,0(sp)
  80066a:	b539                	j	800478 <vprintfmt+0x17c>
  80066c:	01905663          	blez	s9,800678 <vprintfmt+0x37c>
  800670:	02d00713          	li	a4,45
  800674:	f6e815e3          	bne	a6,a4,8005de <vprintfmt+0x2e2>
  800678:	00000417          	auipc	s0,0x0
  80067c:	5d140413          	addi	s0,s0,1489 # 800c49 <error_string+0x2b9>
  800680:	02800513          	li	a0,40
  800684:	02800713          	li	a4,40
  800688:	b50d                	j	8004aa <vprintfmt+0x1ae>

000000000080068a <printfmt>:
  80068a:	7139                	addi	sp,sp,-64
  80068c:	02010313          	addi	t1,sp,32
  800690:	f03a                	sd	a4,32(sp)
  800692:	871a                	mv	a4,t1
  800694:	ec06                	sd	ra,24(sp)
  800696:	f43e                	sd	a5,40(sp)
  800698:	f842                	sd	a6,48(sp)
  80069a:	fc46                	sd	a7,56(sp)
  80069c:	e41a                	sd	t1,8(sp)
  80069e:	c5fff0ef          	jal	ra,8002fc <vprintfmt>
  8006a2:	60e2                	ld	ra,24(sp)
  8006a4:	6121                	addi	sp,sp,64
  8006a6:	8082                	ret

00000000008006a8 <strnlen>:
  8006a8:	c185                	beqz	a1,8006c8 <strnlen+0x20>
  8006aa:	00054783          	lbu	a5,0(a0)
  8006ae:	cf89                	beqz	a5,8006c8 <strnlen+0x20>
  8006b0:	4781                	li	a5,0
  8006b2:	a021                	j	8006ba <strnlen+0x12>
  8006b4:	00074703          	lbu	a4,0(a4)
  8006b8:	c711                	beqz	a4,8006c4 <strnlen+0x1c>
  8006ba:	0785                	addi	a5,a5,1
  8006bc:	00f50733          	add	a4,a0,a5
  8006c0:	fef59ae3          	bne	a1,a5,8006b4 <strnlen+0xc>
  8006c4:	853e                	mv	a0,a5
  8006c6:	8082                	ret
  8006c8:	4781                	li	a5,0
  8006ca:	853e                	mv	a0,a5
  8006cc:	8082                	ret

00000000008006ce <main>:
  8006ce:	1101                	addi	sp,sp,-32
  8006d0:	e822                	sd	s0,16(sp)
  8006d2:	e426                	sd	s1,8(sp)
  8006d4:	ec06                	sd	ra,24(sp)
  8006d6:	4401                	li	s0,0
  8006d8:	02000493          	li	s1,32
  8006dc:	ae7ff0ef          	jal	ra,8001c2 <fork>
  8006e0:	cd05                	beqz	a0,800718 <main+0x4a>
  8006e2:	06a05063          	blez	a0,800742 <main+0x74>
  8006e6:	2405                	addiw	s0,s0,1
  8006e8:	fe941ae3          	bne	s0,s1,8006dc <main+0xe>
  8006ec:	02000413          	li	s0,32
  8006f0:	ad7ff0ef          	jal	ra,8001c6 <wait>
  8006f4:	ed05                	bnez	a0,80072c <main+0x5e>
  8006f6:	347d                	addiw	s0,s0,-1
  8006f8:	fc65                	bnez	s0,8006f0 <main+0x22>
  8006fa:	acdff0ef          	jal	ra,8001c6 <wait>
  8006fe:	c12d                	beqz	a0,800760 <main+0x92>
  800700:	00000517          	auipc	a0,0x0
  800704:	5d850513          	addi	a0,a0,1496 # 800cd8 <error_string+0x348>
  800708:	9f1ff0ef          	jal	ra,8000f8 <cprintf>
  80070c:	60e2                	ld	ra,24(sp)
  80070e:	6442                	ld	s0,16(sp)
  800710:	64a2                	ld	s1,8(sp)
  800712:	4501                	li	a0,0
  800714:	6105                	addi	sp,sp,32
  800716:	8082                	ret
  800718:	85a2                	mv	a1,s0
  80071a:	00000517          	auipc	a0,0x0
  80071e:	54e50513          	addi	a0,a0,1358 # 800c68 <error_string+0x2d8>
  800722:	9d7ff0ef          	jal	ra,8000f8 <cprintf>
  800726:	4501                	li	a0,0
  800728:	a85ff0ef          	jal	ra,8001ac <exit>
  80072c:	00000617          	auipc	a2,0x0
  800730:	57c60613          	addi	a2,a2,1404 # 800ca8 <error_string+0x318>
  800734:	45dd                	li	a1,23
  800736:	00000517          	auipc	a0,0x0
  80073a:	56250513          	addi	a0,a0,1378 # 800c98 <error_string+0x308>
  80073e:	8f9ff0ef          	jal	ra,800036 <__panic>
  800742:	00000697          	auipc	a3,0x0
  800746:	53668693          	addi	a3,a3,1334 # 800c78 <error_string+0x2e8>
  80074a:	00000617          	auipc	a2,0x0
  80074e:	53660613          	addi	a2,a2,1334 # 800c80 <error_string+0x2f0>
  800752:	45b9                	li	a1,14
  800754:	00000517          	auipc	a0,0x0
  800758:	54450513          	addi	a0,a0,1348 # 800c98 <error_string+0x308>
  80075c:	8dbff0ef          	jal	ra,800036 <__panic>
  800760:	00000617          	auipc	a2,0x0
  800764:	56060613          	addi	a2,a2,1376 # 800cc0 <error_string+0x330>
  800768:	45f1                	li	a1,28
  80076a:	00000517          	auipc	a0,0x0
  80076e:	52e50513          	addi	a0,a0,1326 # 800c98 <error_string+0x308>
  800772:	8c5ff0ef          	jal	ra,800036 <__panic>
