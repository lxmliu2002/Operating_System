
obj/__user_sleepkill.out：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000000800020 <open>:
  800020:	1582                	slli	a1,a1,0x20
  800022:	9181                	srli	a1,a1,0x20
  800024:	16c0006f          	j	800190 <sys_open>

0000000000800028 <close>:
  800028:	1740006f          	j	80019c <sys_close>

000000000080002c <dup2>:
  80002c:	17a0006f          	j	8001a6 <sys_dup>

0000000000800030 <_start>:
  800030:	1ec000ef          	jal	ra,80021c <umain>
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
  800048:	71c50513          	addi	a0,a0,1820 # 800760 <main+0x88>
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
  800068:	77450513          	addi	a0,a0,1908 # 8007d8 <main+0x100>
  80006c:	08c000ef          	jal	ra,8000f8 <cprintf>
  800070:	5559                	li	a0,-10
  800072:	140000ef          	jal	ra,8001b2 <exit>

0000000000800076 <__warn>:
  800076:	715d                	addi	sp,sp,-80
  800078:	e822                	sd	s0,16(sp)
  80007a:	fc3e                	sd	a5,56(sp)
  80007c:	8432                	mv	s0,a2
  80007e:	103c                	addi	a5,sp,40
  800080:	862e                	mv	a2,a1
  800082:	85aa                	mv	a1,a0
  800084:	00000517          	auipc	a0,0x0
  800088:	6fc50513          	addi	a0,a0,1788 # 800780 <main+0xa8>
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
  8000a8:	73450513          	addi	a0,a0,1844 # 8007d8 <main+0x100>
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
  8000c0:	0c0000ef          	jal	ra,800180 <sys_putc>
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
  8000e4:	ad958593          	addi	a1,a1,-1319 # ffffffffffff6ad9 <error_string+0xffffffffff7f6161>
  8000e8:	ec06                	sd	ra,24(sp)
  8000ea:	c602                	sw	zero,12(sp)
  8000ec:	21a000ef          	jal	ra,800306 <vprintfmt>
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
  800116:	ad958593          	addi	a1,a1,-1319 # ffffffffffff6ad9 <error_string+0xffffffffff7f6161>
  80011a:	ec06                	sd	ra,24(sp)
  80011c:	e4be                	sd	a5,72(sp)
  80011e:	e8c2                	sd	a6,80(sp)
  800120:	ecc6                	sd	a7,88(sp)
  800122:	e41a                	sd	t1,8(sp)
  800124:	c202                	sw	zero,4(sp)
  800126:	1e0000ef          	jal	ra,800306 <vprintfmt>
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

0000000000800178 <sys_kill>:
  800178:	85aa                	mv	a1,a0
  80017a:	4531                	li	a0,12
  80017c:	fb7ff06f          	j	800132 <syscall>

0000000000800180 <sys_putc>:
  800180:	85aa                	mv	a1,a0
  800182:	4579                	li	a0,30
  800184:	fafff06f          	j	800132 <syscall>

0000000000800188 <sys_sleep>:
  800188:	85aa                	mv	a1,a0
  80018a:	452d                	li	a0,11
  80018c:	fa7ff06f          	j	800132 <syscall>

0000000000800190 <sys_open>:
  800190:	862e                	mv	a2,a1
  800192:	85aa                	mv	a1,a0
  800194:	06400513          	li	a0,100
  800198:	f9bff06f          	j	800132 <syscall>

000000000080019c <sys_close>:
  80019c:	85aa                	mv	a1,a0
  80019e:	06500513          	li	a0,101
  8001a2:	f91ff06f          	j	800132 <syscall>

00000000008001a6 <sys_dup>:
  8001a6:	862e                	mv	a2,a1
  8001a8:	85aa                	mv	a1,a0
  8001aa:	08200513          	li	a0,130
  8001ae:	f85ff06f          	j	800132 <syscall>

00000000008001b2 <exit>:
  8001b2:	1141                	addi	sp,sp,-16
  8001b4:	e406                	sd	ra,8(sp)
  8001b6:	fb5ff0ef          	jal	ra,80016a <sys_exit>
  8001ba:	00000517          	auipc	a0,0x0
  8001be:	5e650513          	addi	a0,a0,1510 # 8007a0 <main+0xc8>
  8001c2:	f37ff0ef          	jal	ra,8000f8 <cprintf>
  8001c6:	a001                	j	8001c6 <exit+0x14>

00000000008001c8 <fork>:
  8001c8:	fabff06f          	j	800172 <sys_fork>

00000000008001cc <kill>:
  8001cc:	fadff06f          	j	800178 <sys_kill>

00000000008001d0 <sleep>:
  8001d0:	1502                	slli	a0,a0,0x20
  8001d2:	9101                	srli	a0,a0,0x20
  8001d4:	fb5ff06f          	j	800188 <sys_sleep>

00000000008001d8 <initfd>:
  8001d8:	1101                	addi	sp,sp,-32
  8001da:	87ae                	mv	a5,a1
  8001dc:	e426                	sd	s1,8(sp)
  8001de:	85b2                	mv	a1,a2
  8001e0:	84aa                	mv	s1,a0
  8001e2:	853e                	mv	a0,a5
  8001e4:	e822                	sd	s0,16(sp)
  8001e6:	ec06                	sd	ra,24(sp)
  8001e8:	e39ff0ef          	jal	ra,800020 <open>
  8001ec:	842a                	mv	s0,a0
  8001ee:	00054463          	bltz	a0,8001f6 <initfd+0x1e>
  8001f2:	00951863          	bne	a0,s1,800202 <initfd+0x2a>
  8001f6:	8522                	mv	a0,s0
  8001f8:	60e2                	ld	ra,24(sp)
  8001fa:	6442                	ld	s0,16(sp)
  8001fc:	64a2                	ld	s1,8(sp)
  8001fe:	6105                	addi	sp,sp,32
  800200:	8082                	ret
  800202:	8526                	mv	a0,s1
  800204:	e25ff0ef          	jal	ra,800028 <close>
  800208:	85a6                	mv	a1,s1
  80020a:	8522                	mv	a0,s0
  80020c:	e21ff0ef          	jal	ra,80002c <dup2>
  800210:	84aa                	mv	s1,a0
  800212:	8522                	mv	a0,s0
  800214:	e15ff0ef          	jal	ra,800028 <close>
  800218:	8426                	mv	s0,s1
  80021a:	bff1                	j	8001f6 <initfd+0x1e>

000000000080021c <umain>:
  80021c:	1101                	addi	sp,sp,-32
  80021e:	e822                	sd	s0,16(sp)
  800220:	e426                	sd	s1,8(sp)
  800222:	842a                	mv	s0,a0
  800224:	84ae                	mv	s1,a1
  800226:	4601                	li	a2,0
  800228:	00000597          	auipc	a1,0x0
  80022c:	59058593          	addi	a1,a1,1424 # 8007b8 <main+0xe0>
  800230:	4501                	li	a0,0
  800232:	ec06                	sd	ra,24(sp)
  800234:	fa5ff0ef          	jal	ra,8001d8 <initfd>
  800238:	02054263          	bltz	a0,80025c <umain+0x40>
  80023c:	4605                	li	a2,1
  80023e:	00000597          	auipc	a1,0x0
  800242:	5ba58593          	addi	a1,a1,1466 # 8007f8 <main+0x120>
  800246:	4505                	li	a0,1
  800248:	f91ff0ef          	jal	ra,8001d8 <initfd>
  80024c:	02054563          	bltz	a0,800276 <umain+0x5a>
  800250:	85a6                	mv	a1,s1
  800252:	8522                	mv	a0,s0
  800254:	484000ef          	jal	ra,8006d8 <main>
  800258:	f5bff0ef          	jal	ra,8001b2 <exit>
  80025c:	86aa                	mv	a3,a0
  80025e:	00000617          	auipc	a2,0x0
  800262:	56260613          	addi	a2,a2,1378 # 8007c0 <main+0xe8>
  800266:	45e9                	li	a1,26
  800268:	00000517          	auipc	a0,0x0
  80026c:	57850513          	addi	a0,a0,1400 # 8007e0 <main+0x108>
  800270:	e07ff0ef          	jal	ra,800076 <__warn>
  800274:	b7e1                	j	80023c <umain+0x20>
  800276:	86aa                	mv	a3,a0
  800278:	00000617          	auipc	a2,0x0
  80027c:	58860613          	addi	a2,a2,1416 # 800800 <main+0x128>
  800280:	45f5                	li	a1,29
  800282:	00000517          	auipc	a0,0x0
  800286:	55e50513          	addi	a0,a0,1374 # 8007e0 <main+0x108>
  80028a:	dedff0ef          	jal	ra,800076 <__warn>
  80028e:	b7c9                	j	800250 <umain+0x34>

0000000000800290 <printnum>:
  800290:	02071893          	slli	a7,a4,0x20
  800294:	7139                	addi	sp,sp,-64
  800296:	0208d893          	srli	a7,a7,0x20
  80029a:	e456                	sd	s5,8(sp)
  80029c:	0316fab3          	remu	s5,a3,a7
  8002a0:	f822                	sd	s0,48(sp)
  8002a2:	f426                	sd	s1,40(sp)
  8002a4:	f04a                	sd	s2,32(sp)
  8002a6:	ec4e                	sd	s3,24(sp)
  8002a8:	fc06                	sd	ra,56(sp)
  8002aa:	e852                	sd	s4,16(sp)
  8002ac:	84aa                	mv	s1,a0
  8002ae:	89ae                	mv	s3,a1
  8002b0:	8932                	mv	s2,a2
  8002b2:	fff7841b          	addiw	s0,a5,-1
  8002b6:	2a81                	sext.w	s5,s5
  8002b8:	0516f163          	bleu	a7,a3,8002fa <printnum+0x6a>
  8002bc:	8a42                	mv	s4,a6
  8002be:	00805863          	blez	s0,8002ce <printnum+0x3e>
  8002c2:	347d                	addiw	s0,s0,-1
  8002c4:	864e                	mv	a2,s3
  8002c6:	85ca                	mv	a1,s2
  8002c8:	8552                	mv	a0,s4
  8002ca:	9482                	jalr	s1
  8002cc:	f87d                	bnez	s0,8002c2 <printnum+0x32>
  8002ce:	1a82                	slli	s5,s5,0x20
  8002d0:	020ada93          	srli	s5,s5,0x20
  8002d4:	00000797          	auipc	a5,0x0
  8002d8:	76c78793          	addi	a5,a5,1900 # 800a40 <error_string+0xc8>
  8002dc:	9abe                	add	s5,s5,a5
  8002de:	7442                	ld	s0,48(sp)
  8002e0:	000ac503          	lbu	a0,0(s5)
  8002e4:	70e2                	ld	ra,56(sp)
  8002e6:	6a42                	ld	s4,16(sp)
  8002e8:	6aa2                	ld	s5,8(sp)
  8002ea:	864e                	mv	a2,s3
  8002ec:	85ca                	mv	a1,s2
  8002ee:	69e2                	ld	s3,24(sp)
  8002f0:	7902                	ld	s2,32(sp)
  8002f2:	8326                	mv	t1,s1
  8002f4:	74a2                	ld	s1,40(sp)
  8002f6:	6121                	addi	sp,sp,64
  8002f8:	8302                	jr	t1
  8002fa:	0316d6b3          	divu	a3,a3,a7
  8002fe:	87a2                	mv	a5,s0
  800300:	f91ff0ef          	jal	ra,800290 <printnum>
  800304:	b7e9                	j	8002ce <printnum+0x3e>

0000000000800306 <vprintfmt>:
  800306:	7119                	addi	sp,sp,-128
  800308:	f4a6                	sd	s1,104(sp)
  80030a:	f0ca                	sd	s2,96(sp)
  80030c:	ecce                	sd	s3,88(sp)
  80030e:	e4d6                	sd	s5,72(sp)
  800310:	e0da                	sd	s6,64(sp)
  800312:	fc5e                	sd	s7,56(sp)
  800314:	f862                	sd	s8,48(sp)
  800316:	ec6e                	sd	s11,24(sp)
  800318:	fc86                	sd	ra,120(sp)
  80031a:	f8a2                	sd	s0,112(sp)
  80031c:	e8d2                	sd	s4,80(sp)
  80031e:	f466                	sd	s9,40(sp)
  800320:	f06a                	sd	s10,32(sp)
  800322:	89aa                	mv	s3,a0
  800324:	892e                	mv	s2,a1
  800326:	84b2                	mv	s1,a2
  800328:	8db6                	mv	s11,a3
  80032a:	8b3a                	mv	s6,a4
  80032c:	5bfd                	li	s7,-1
  80032e:	00000a97          	auipc	s5,0x0
  800332:	4eea8a93          	addi	s5,s5,1262 # 80081c <main+0x144>
  800336:	05e00c13          	li	s8,94
  80033a:	000dc503          	lbu	a0,0(s11)
  80033e:	02500793          	li	a5,37
  800342:	001d8413          	addi	s0,s11,1
  800346:	00f50f63          	beq	a0,a5,800364 <vprintfmt+0x5e>
  80034a:	c529                	beqz	a0,800394 <vprintfmt+0x8e>
  80034c:	02500a13          	li	s4,37
  800350:	a011                	j	800354 <vprintfmt+0x4e>
  800352:	c129                	beqz	a0,800394 <vprintfmt+0x8e>
  800354:	864a                	mv	a2,s2
  800356:	85a6                	mv	a1,s1
  800358:	0405                	addi	s0,s0,1
  80035a:	9982                	jalr	s3
  80035c:	fff44503          	lbu	a0,-1(s0)
  800360:	ff4519e3          	bne	a0,s4,800352 <vprintfmt+0x4c>
  800364:	00044603          	lbu	a2,0(s0)
  800368:	02000813          	li	a6,32
  80036c:	4a01                	li	s4,0
  80036e:	4881                	li	a7,0
  800370:	5d7d                	li	s10,-1
  800372:	5cfd                	li	s9,-1
  800374:	05500593          	li	a1,85
  800378:	4525                	li	a0,9
  80037a:	fdd6071b          	addiw	a4,a2,-35
  80037e:	0ff77713          	andi	a4,a4,255
  800382:	00140d93          	addi	s11,s0,1
  800386:	22e5e363          	bltu	a1,a4,8005ac <vprintfmt+0x2a6>
  80038a:	070a                	slli	a4,a4,0x2
  80038c:	9756                	add	a4,a4,s5
  80038e:	4318                	lw	a4,0(a4)
  800390:	9756                	add	a4,a4,s5
  800392:	8702                	jr	a4
  800394:	70e6                	ld	ra,120(sp)
  800396:	7446                	ld	s0,112(sp)
  800398:	74a6                	ld	s1,104(sp)
  80039a:	7906                	ld	s2,96(sp)
  80039c:	69e6                	ld	s3,88(sp)
  80039e:	6a46                	ld	s4,80(sp)
  8003a0:	6aa6                	ld	s5,72(sp)
  8003a2:	6b06                	ld	s6,64(sp)
  8003a4:	7be2                	ld	s7,56(sp)
  8003a6:	7c42                	ld	s8,48(sp)
  8003a8:	7ca2                	ld	s9,40(sp)
  8003aa:	7d02                	ld	s10,32(sp)
  8003ac:	6de2                	ld	s11,24(sp)
  8003ae:	6109                	addi	sp,sp,128
  8003b0:	8082                	ret
  8003b2:	4705                	li	a4,1
  8003b4:	008b0613          	addi	a2,s6,8
  8003b8:	01174463          	blt	a4,a7,8003c0 <vprintfmt+0xba>
  8003bc:	28088563          	beqz	a7,800646 <vprintfmt+0x340>
  8003c0:	000b3683          	ld	a3,0(s6)
  8003c4:	4741                	li	a4,16
  8003c6:	8b32                	mv	s6,a2
  8003c8:	a86d                	j	800482 <vprintfmt+0x17c>
  8003ca:	00144603          	lbu	a2,1(s0)
  8003ce:	4a05                	li	s4,1
  8003d0:	846e                	mv	s0,s11
  8003d2:	b765                	j	80037a <vprintfmt+0x74>
  8003d4:	000b2503          	lw	a0,0(s6)
  8003d8:	864a                	mv	a2,s2
  8003da:	85a6                	mv	a1,s1
  8003dc:	0b21                	addi	s6,s6,8
  8003de:	9982                	jalr	s3
  8003e0:	bfa9                	j	80033a <vprintfmt+0x34>
  8003e2:	4705                	li	a4,1
  8003e4:	008b0a13          	addi	s4,s6,8
  8003e8:	01174463          	blt	a4,a7,8003f0 <vprintfmt+0xea>
  8003ec:	24088563          	beqz	a7,800636 <vprintfmt+0x330>
  8003f0:	000b3403          	ld	s0,0(s6)
  8003f4:	26044563          	bltz	s0,80065e <vprintfmt+0x358>
  8003f8:	86a2                	mv	a3,s0
  8003fa:	8b52                	mv	s6,s4
  8003fc:	4729                	li	a4,10
  8003fe:	a051                	j	800482 <vprintfmt+0x17c>
  800400:	000b2783          	lw	a5,0(s6)
  800404:	46e1                	li	a3,24
  800406:	0b21                	addi	s6,s6,8
  800408:	41f7d71b          	sraiw	a4,a5,0x1f
  80040c:	8fb9                	xor	a5,a5,a4
  80040e:	40e7873b          	subw	a4,a5,a4
  800412:	1ce6c163          	blt	a3,a4,8005d4 <vprintfmt+0x2ce>
  800416:	00371793          	slli	a5,a4,0x3
  80041a:	00000697          	auipc	a3,0x0
  80041e:	55e68693          	addi	a3,a3,1374 # 800978 <error_string>
  800422:	97b6                	add	a5,a5,a3
  800424:	639c                	ld	a5,0(a5)
  800426:	1a078763          	beqz	a5,8005d4 <vprintfmt+0x2ce>
  80042a:	873e                	mv	a4,a5
  80042c:	00001697          	auipc	a3,0x1
  800430:	81c68693          	addi	a3,a3,-2020 # 800c48 <error_string+0x2d0>
  800434:	8626                	mv	a2,s1
  800436:	85ca                	mv	a1,s2
  800438:	854e                	mv	a0,s3
  80043a:	25a000ef          	jal	ra,800694 <printfmt>
  80043e:	bdf5                	j	80033a <vprintfmt+0x34>
  800440:	00144603          	lbu	a2,1(s0)
  800444:	2885                	addiw	a7,a7,1
  800446:	846e                	mv	s0,s11
  800448:	bf0d                	j	80037a <vprintfmt+0x74>
  80044a:	4705                	li	a4,1
  80044c:	008b0613          	addi	a2,s6,8
  800450:	01174463          	blt	a4,a7,800458 <vprintfmt+0x152>
  800454:	1e088e63          	beqz	a7,800650 <vprintfmt+0x34a>
  800458:	000b3683          	ld	a3,0(s6)
  80045c:	4721                	li	a4,8
  80045e:	8b32                	mv	s6,a2
  800460:	a00d                	j	800482 <vprintfmt+0x17c>
  800462:	03000513          	li	a0,48
  800466:	864a                	mv	a2,s2
  800468:	85a6                	mv	a1,s1
  80046a:	e042                	sd	a6,0(sp)
  80046c:	9982                	jalr	s3
  80046e:	864a                	mv	a2,s2
  800470:	85a6                	mv	a1,s1
  800472:	07800513          	li	a0,120
  800476:	9982                	jalr	s3
  800478:	0b21                	addi	s6,s6,8
  80047a:	ff8b3683          	ld	a3,-8(s6)
  80047e:	6802                	ld	a6,0(sp)
  800480:	4741                	li	a4,16
  800482:	87e6                	mv	a5,s9
  800484:	8626                	mv	a2,s1
  800486:	85ca                	mv	a1,s2
  800488:	854e                	mv	a0,s3
  80048a:	e07ff0ef          	jal	ra,800290 <printnum>
  80048e:	b575                	j	80033a <vprintfmt+0x34>
  800490:	000b3703          	ld	a4,0(s6)
  800494:	0b21                	addi	s6,s6,8
  800496:	1e070063          	beqz	a4,800676 <vprintfmt+0x370>
  80049a:	00170413          	addi	s0,a4,1
  80049e:	19905563          	blez	s9,800628 <vprintfmt+0x322>
  8004a2:	02d00613          	li	a2,45
  8004a6:	14c81963          	bne	a6,a2,8005f8 <vprintfmt+0x2f2>
  8004aa:	00074703          	lbu	a4,0(a4)
  8004ae:	0007051b          	sext.w	a0,a4
  8004b2:	c90d                	beqz	a0,8004e4 <vprintfmt+0x1de>
  8004b4:	000d4563          	bltz	s10,8004be <vprintfmt+0x1b8>
  8004b8:	3d7d                	addiw	s10,s10,-1
  8004ba:	037d0363          	beq	s10,s7,8004e0 <vprintfmt+0x1da>
  8004be:	864a                	mv	a2,s2
  8004c0:	85a6                	mv	a1,s1
  8004c2:	180a0c63          	beqz	s4,80065a <vprintfmt+0x354>
  8004c6:	3701                	addiw	a4,a4,-32
  8004c8:	18ec7963          	bleu	a4,s8,80065a <vprintfmt+0x354>
  8004cc:	03f00513          	li	a0,63
  8004d0:	9982                	jalr	s3
  8004d2:	0405                	addi	s0,s0,1
  8004d4:	fff44703          	lbu	a4,-1(s0)
  8004d8:	3cfd                	addiw	s9,s9,-1
  8004da:	0007051b          	sext.w	a0,a4
  8004de:	f979                	bnez	a0,8004b4 <vprintfmt+0x1ae>
  8004e0:	e5905de3          	blez	s9,80033a <vprintfmt+0x34>
  8004e4:	3cfd                	addiw	s9,s9,-1
  8004e6:	864a                	mv	a2,s2
  8004e8:	85a6                	mv	a1,s1
  8004ea:	02000513          	li	a0,32
  8004ee:	9982                	jalr	s3
  8004f0:	e40c85e3          	beqz	s9,80033a <vprintfmt+0x34>
  8004f4:	3cfd                	addiw	s9,s9,-1
  8004f6:	864a                	mv	a2,s2
  8004f8:	85a6                	mv	a1,s1
  8004fa:	02000513          	li	a0,32
  8004fe:	9982                	jalr	s3
  800500:	fe0c92e3          	bnez	s9,8004e4 <vprintfmt+0x1de>
  800504:	bd1d                	j	80033a <vprintfmt+0x34>
  800506:	4705                	li	a4,1
  800508:	008b0613          	addi	a2,s6,8
  80050c:	01174463          	blt	a4,a7,800514 <vprintfmt+0x20e>
  800510:	12088663          	beqz	a7,80063c <vprintfmt+0x336>
  800514:	000b3683          	ld	a3,0(s6)
  800518:	4729                	li	a4,10
  80051a:	8b32                	mv	s6,a2
  80051c:	b79d                	j	800482 <vprintfmt+0x17c>
  80051e:	00144603          	lbu	a2,1(s0)
  800522:	02d00813          	li	a6,45
  800526:	846e                	mv	s0,s11
  800528:	bd89                	j	80037a <vprintfmt+0x74>
  80052a:	864a                	mv	a2,s2
  80052c:	85a6                	mv	a1,s1
  80052e:	02500513          	li	a0,37
  800532:	9982                	jalr	s3
  800534:	b519                	j	80033a <vprintfmt+0x34>
  800536:	000b2d03          	lw	s10,0(s6)
  80053a:	00144603          	lbu	a2,1(s0)
  80053e:	0b21                	addi	s6,s6,8
  800540:	846e                	mv	s0,s11
  800542:	e20cdce3          	bgez	s9,80037a <vprintfmt+0x74>
  800546:	8cea                	mv	s9,s10
  800548:	5d7d                	li	s10,-1
  80054a:	bd05                	j	80037a <vprintfmt+0x74>
  80054c:	00144603          	lbu	a2,1(s0)
  800550:	03000813          	li	a6,48
  800554:	846e                	mv	s0,s11
  800556:	b515                	j	80037a <vprintfmt+0x74>
  800558:	fd060d1b          	addiw	s10,a2,-48
  80055c:	00144603          	lbu	a2,1(s0)
  800560:	846e                	mv	s0,s11
  800562:	fd06071b          	addiw	a4,a2,-48
  800566:	0006031b          	sext.w	t1,a2
  80056a:	fce56ce3          	bltu	a0,a4,800542 <vprintfmt+0x23c>
  80056e:	0405                	addi	s0,s0,1
  800570:	002d171b          	slliw	a4,s10,0x2
  800574:	00044603          	lbu	a2,0(s0)
  800578:	01a706bb          	addw	a3,a4,s10
  80057c:	0016969b          	slliw	a3,a3,0x1
  800580:	006686bb          	addw	a3,a3,t1
  800584:	fd06071b          	addiw	a4,a2,-48
  800588:	fd068d1b          	addiw	s10,a3,-48
  80058c:	0006031b          	sext.w	t1,a2
  800590:	fce57fe3          	bleu	a4,a0,80056e <vprintfmt+0x268>
  800594:	b77d                	j	800542 <vprintfmt+0x23c>
  800596:	fffcc713          	not	a4,s9
  80059a:	977d                	srai	a4,a4,0x3f
  80059c:	00ecf7b3          	and	a5,s9,a4
  8005a0:	00144603          	lbu	a2,1(s0)
  8005a4:	00078c9b          	sext.w	s9,a5
  8005a8:	846e                	mv	s0,s11
  8005aa:	bbc1                	j	80037a <vprintfmt+0x74>
  8005ac:	864a                	mv	a2,s2
  8005ae:	85a6                	mv	a1,s1
  8005b0:	02500513          	li	a0,37
  8005b4:	9982                	jalr	s3
  8005b6:	fff44703          	lbu	a4,-1(s0)
  8005ba:	02500793          	li	a5,37
  8005be:	8da2                	mv	s11,s0
  8005c0:	d6f70de3          	beq	a4,a5,80033a <vprintfmt+0x34>
  8005c4:	02500713          	li	a4,37
  8005c8:	1dfd                	addi	s11,s11,-1
  8005ca:	fffdc783          	lbu	a5,-1(s11)
  8005ce:	fee79de3          	bne	a5,a4,8005c8 <vprintfmt+0x2c2>
  8005d2:	b3a5                	j	80033a <vprintfmt+0x34>
  8005d4:	00000697          	auipc	a3,0x0
  8005d8:	66468693          	addi	a3,a3,1636 # 800c38 <error_string+0x2c0>
  8005dc:	8626                	mv	a2,s1
  8005de:	85ca                	mv	a1,s2
  8005e0:	854e                	mv	a0,s3
  8005e2:	0b2000ef          	jal	ra,800694 <printfmt>
  8005e6:	bb91                	j	80033a <vprintfmt+0x34>
  8005e8:	00000717          	auipc	a4,0x0
  8005ec:	64870713          	addi	a4,a4,1608 # 800c30 <error_string+0x2b8>
  8005f0:	00000417          	auipc	s0,0x0
  8005f4:	64140413          	addi	s0,s0,1601 # 800c31 <error_string+0x2b9>
  8005f8:	853a                	mv	a0,a4
  8005fa:	85ea                	mv	a1,s10
  8005fc:	e03a                	sd	a4,0(sp)
  8005fe:	e442                	sd	a6,8(sp)
  800600:	0b2000ef          	jal	ra,8006b2 <strnlen>
  800604:	40ac8cbb          	subw	s9,s9,a0
  800608:	6702                	ld	a4,0(sp)
  80060a:	01905f63          	blez	s9,800628 <vprintfmt+0x322>
  80060e:	6822                	ld	a6,8(sp)
  800610:	0008079b          	sext.w	a5,a6
  800614:	e43e                	sd	a5,8(sp)
  800616:	6522                	ld	a0,8(sp)
  800618:	864a                	mv	a2,s2
  80061a:	85a6                	mv	a1,s1
  80061c:	e03a                	sd	a4,0(sp)
  80061e:	3cfd                	addiw	s9,s9,-1
  800620:	9982                	jalr	s3
  800622:	6702                	ld	a4,0(sp)
  800624:	fe0c99e3          	bnez	s9,800616 <vprintfmt+0x310>
  800628:	00074703          	lbu	a4,0(a4)
  80062c:	0007051b          	sext.w	a0,a4
  800630:	e80512e3          	bnez	a0,8004b4 <vprintfmt+0x1ae>
  800634:	b319                	j	80033a <vprintfmt+0x34>
  800636:	000b2403          	lw	s0,0(s6)
  80063a:	bb6d                	j	8003f4 <vprintfmt+0xee>
  80063c:	000b6683          	lwu	a3,0(s6)
  800640:	4729                	li	a4,10
  800642:	8b32                	mv	s6,a2
  800644:	bd3d                	j	800482 <vprintfmt+0x17c>
  800646:	000b6683          	lwu	a3,0(s6)
  80064a:	4741                	li	a4,16
  80064c:	8b32                	mv	s6,a2
  80064e:	bd15                	j	800482 <vprintfmt+0x17c>
  800650:	000b6683          	lwu	a3,0(s6)
  800654:	4721                	li	a4,8
  800656:	8b32                	mv	s6,a2
  800658:	b52d                	j	800482 <vprintfmt+0x17c>
  80065a:	9982                	jalr	s3
  80065c:	bd9d                	j	8004d2 <vprintfmt+0x1cc>
  80065e:	864a                	mv	a2,s2
  800660:	85a6                	mv	a1,s1
  800662:	02d00513          	li	a0,45
  800666:	e042                	sd	a6,0(sp)
  800668:	9982                	jalr	s3
  80066a:	8b52                	mv	s6,s4
  80066c:	408006b3          	neg	a3,s0
  800670:	4729                	li	a4,10
  800672:	6802                	ld	a6,0(sp)
  800674:	b539                	j	800482 <vprintfmt+0x17c>
  800676:	01905663          	blez	s9,800682 <vprintfmt+0x37c>
  80067a:	02d00713          	li	a4,45
  80067e:	f6e815e3          	bne	a6,a4,8005e8 <vprintfmt+0x2e2>
  800682:	00000417          	auipc	s0,0x0
  800686:	5af40413          	addi	s0,s0,1455 # 800c31 <error_string+0x2b9>
  80068a:	02800513          	li	a0,40
  80068e:	02800713          	li	a4,40
  800692:	b50d                	j	8004b4 <vprintfmt+0x1ae>

0000000000800694 <printfmt>:
  800694:	7139                	addi	sp,sp,-64
  800696:	02010313          	addi	t1,sp,32
  80069a:	f03a                	sd	a4,32(sp)
  80069c:	871a                	mv	a4,t1
  80069e:	ec06                	sd	ra,24(sp)
  8006a0:	f43e                	sd	a5,40(sp)
  8006a2:	f842                	sd	a6,48(sp)
  8006a4:	fc46                	sd	a7,56(sp)
  8006a6:	e41a                	sd	t1,8(sp)
  8006a8:	c5fff0ef          	jal	ra,800306 <vprintfmt>
  8006ac:	60e2                	ld	ra,24(sp)
  8006ae:	6121                	addi	sp,sp,64
  8006b0:	8082                	ret

00000000008006b2 <strnlen>:
  8006b2:	c185                	beqz	a1,8006d2 <strnlen+0x20>
  8006b4:	00054783          	lbu	a5,0(a0)
  8006b8:	cf89                	beqz	a5,8006d2 <strnlen+0x20>
  8006ba:	4781                	li	a5,0
  8006bc:	a021                	j	8006c4 <strnlen+0x12>
  8006be:	00074703          	lbu	a4,0(a4)
  8006c2:	c711                	beqz	a4,8006ce <strnlen+0x1c>
  8006c4:	0785                	addi	a5,a5,1
  8006c6:	00f50733          	add	a4,a0,a5
  8006ca:	fef59ae3          	bne	a1,a5,8006be <strnlen+0xc>
  8006ce:	853e                	mv	a0,a5
  8006d0:	8082                	ret
  8006d2:	4781                	li	a5,0
  8006d4:	853e                	mv	a0,a5
  8006d6:	8082                	ret

00000000008006d8 <main>:
  8006d8:	1141                	addi	sp,sp,-16
  8006da:	e406                	sd	ra,8(sp)
  8006dc:	e022                	sd	s0,0(sp)
  8006de:	aebff0ef          	jal	ra,8001c8 <fork>
  8006e2:	c51d                	beqz	a0,800710 <main+0x38>
  8006e4:	842a                	mv	s0,a0
  8006e6:	04a05c63          	blez	a0,80073e <main+0x66>
  8006ea:	06400513          	li	a0,100
  8006ee:	ae3ff0ef          	jal	ra,8001d0 <sleep>
  8006f2:	8522                	mv	a0,s0
  8006f4:	ad9ff0ef          	jal	ra,8001cc <kill>
  8006f8:	e505                	bnez	a0,800720 <main+0x48>
  8006fa:	00000517          	auipc	a0,0x0
  8006fe:	59e50513          	addi	a0,a0,1438 # 800c98 <error_string+0x320>
  800702:	9f7ff0ef          	jal	ra,8000f8 <cprintf>
  800706:	60a2                	ld	ra,8(sp)
  800708:	6402                	ld	s0,0(sp)
  80070a:	4501                	li	a0,0
  80070c:	0141                	addi	sp,sp,16
  80070e:	8082                	ret
  800710:	557d                	li	a0,-1
  800712:	abfff0ef          	jal	ra,8001d0 <sleep>
  800716:	6539                	lui	a0,0xe
  800718:	ead50513          	addi	a0,a0,-339 # dead <open-0x7f2173>
  80071c:	a97ff0ef          	jal	ra,8001b2 <exit>
  800720:	00000697          	auipc	a3,0x0
  800724:	56868693          	addi	a3,a3,1384 # 800c88 <error_string+0x310>
  800728:	00000617          	auipc	a2,0x0
  80072c:	53060613          	addi	a2,a2,1328 # 800c58 <error_string+0x2e0>
  800730:	45b9                	li	a1,14
  800732:	00000517          	auipc	a0,0x0
  800736:	53e50513          	addi	a0,a0,1342 # 800c70 <error_string+0x2f8>
  80073a:	8fdff0ef          	jal	ra,800036 <__panic>
  80073e:	00000697          	auipc	a3,0x0
  800742:	51268693          	addi	a3,a3,1298 # 800c50 <error_string+0x2d8>
  800746:	00000617          	auipc	a2,0x0
  80074a:	51260613          	addi	a2,a2,1298 # 800c58 <error_string+0x2e0>
  80074e:	45ad                	li	a1,11
  800750:	00000517          	auipc	a0,0x0
  800754:	52050513          	addi	a0,a0,1312 # 800c70 <error_string+0x2f8>
  800758:	8dfff0ef          	jal	ra,800036 <__panic>
