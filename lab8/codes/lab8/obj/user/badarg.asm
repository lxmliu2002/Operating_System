
obj/__user_badarg.out：     文件格式 elf64-littleriscv


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
  800030:	1e8000ef          	jal	ra,800218 <umain>
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
  800048:	77c50513          	addi	a0,a0,1916 # 8007c0 <main+0xec>
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
  800068:	7d450513          	addi	a0,a0,2004 # 800838 <main+0x164>
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
  800088:	75c50513          	addi	a0,a0,1884 # 8007e0 <main+0x10c>
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
  8000a8:	79450513          	addi	a0,a0,1940 # 800838 <main+0x164>
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
  8000c0:	0c8000ef          	jal	ra,800188 <sys_putc>
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
  8000e4:	ad958593          	addi	a1,a1,-1319 # ffffffffffff6ad9 <error_string+0xffffffffff7f6101>
  8000e8:	ec06                	sd	ra,24(sp)
  8000ea:	c602                	sw	zero,12(sp)
  8000ec:	216000ef          	jal	ra,800302 <vprintfmt>
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
  800116:	ad958593          	addi	a1,a1,-1319 # ffffffffffff6ad9 <error_string+0xffffffffff7f6101>
  80011a:	ec06                	sd	ra,24(sp)
  80011c:	e4be                	sd	a5,72(sp)
  80011e:	e8c2                	sd	a6,80(sp)
  800120:	ecc6                	sd	a7,88(sp)
  800122:	e41a                	sd	t1,8(sp)
  800124:	c202                	sw	zero,4(sp)
  800126:	1dc000ef          	jal	ra,800302 <vprintfmt>
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

0000000000800188 <sys_putc>:
  800188:	85aa                	mv	a1,a0
  80018a:	4579                	li	a0,30
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
  8001be:	64650513          	addi	a0,a0,1606 # 800800 <main+0x12c>
  8001c2:	f37ff0ef          	jal	ra,8000f8 <cprintf>
  8001c6:	a001                	j	8001c6 <exit+0x14>

00000000008001c8 <fork>:
  8001c8:	fabff06f          	j	800172 <sys_fork>

00000000008001cc <waitpid>:
  8001cc:	fadff06f          	j	800178 <sys_wait>

00000000008001d0 <yield>:
  8001d0:	fb3ff06f          	j	800182 <sys_yield>

00000000008001d4 <initfd>:
  8001d4:	1101                	addi	sp,sp,-32
  8001d6:	87ae                	mv	a5,a1
  8001d8:	e426                	sd	s1,8(sp)
  8001da:	85b2                	mv	a1,a2
  8001dc:	84aa                	mv	s1,a0
  8001de:	853e                	mv	a0,a5
  8001e0:	e822                	sd	s0,16(sp)
  8001e2:	ec06                	sd	ra,24(sp)
  8001e4:	e3dff0ef          	jal	ra,800020 <open>
  8001e8:	842a                	mv	s0,a0
  8001ea:	00054463          	bltz	a0,8001f2 <initfd+0x1e>
  8001ee:	00951863          	bne	a0,s1,8001fe <initfd+0x2a>
  8001f2:	8522                	mv	a0,s0
  8001f4:	60e2                	ld	ra,24(sp)
  8001f6:	6442                	ld	s0,16(sp)
  8001f8:	64a2                	ld	s1,8(sp)
  8001fa:	6105                	addi	sp,sp,32
  8001fc:	8082                	ret
  8001fe:	8526                	mv	a0,s1
  800200:	e29ff0ef          	jal	ra,800028 <close>
  800204:	85a6                	mv	a1,s1
  800206:	8522                	mv	a0,s0
  800208:	e25ff0ef          	jal	ra,80002c <dup2>
  80020c:	84aa                	mv	s1,a0
  80020e:	8522                	mv	a0,s0
  800210:	e19ff0ef          	jal	ra,800028 <close>
  800214:	8426                	mv	s0,s1
  800216:	bff1                	j	8001f2 <initfd+0x1e>

0000000000800218 <umain>:
  800218:	1101                	addi	sp,sp,-32
  80021a:	e822                	sd	s0,16(sp)
  80021c:	e426                	sd	s1,8(sp)
  80021e:	842a                	mv	s0,a0
  800220:	84ae                	mv	s1,a1
  800222:	4601                	li	a2,0
  800224:	00000597          	auipc	a1,0x0
  800228:	5f458593          	addi	a1,a1,1524 # 800818 <main+0x144>
  80022c:	4501                	li	a0,0
  80022e:	ec06                	sd	ra,24(sp)
  800230:	fa5ff0ef          	jal	ra,8001d4 <initfd>
  800234:	02054263          	bltz	a0,800258 <umain+0x40>
  800238:	4605                	li	a2,1
  80023a:	00000597          	auipc	a1,0x0
  80023e:	61e58593          	addi	a1,a1,1566 # 800858 <main+0x184>
  800242:	4505                	li	a0,1
  800244:	f91ff0ef          	jal	ra,8001d4 <initfd>
  800248:	02054563          	bltz	a0,800272 <umain+0x5a>
  80024c:	85a6                	mv	a1,s1
  80024e:	8522                	mv	a0,s0
  800250:	484000ef          	jal	ra,8006d4 <main>
  800254:	f5fff0ef          	jal	ra,8001b2 <exit>
  800258:	86aa                	mv	a3,a0
  80025a:	00000617          	auipc	a2,0x0
  80025e:	5c660613          	addi	a2,a2,1478 # 800820 <main+0x14c>
  800262:	45e9                	li	a1,26
  800264:	00000517          	auipc	a0,0x0
  800268:	5dc50513          	addi	a0,a0,1500 # 800840 <main+0x16c>
  80026c:	e0bff0ef          	jal	ra,800076 <__warn>
  800270:	b7e1                	j	800238 <umain+0x20>
  800272:	86aa                	mv	a3,a0
  800274:	00000617          	auipc	a2,0x0
  800278:	5ec60613          	addi	a2,a2,1516 # 800860 <main+0x18c>
  80027c:	45f5                	li	a1,29
  80027e:	00000517          	auipc	a0,0x0
  800282:	5c250513          	addi	a0,a0,1474 # 800840 <main+0x16c>
  800286:	df1ff0ef          	jal	ra,800076 <__warn>
  80028a:	b7c9                	j	80024c <umain+0x34>

000000000080028c <printnum>:
  80028c:	02071893          	slli	a7,a4,0x20
  800290:	7139                	addi	sp,sp,-64
  800292:	0208d893          	srli	a7,a7,0x20
  800296:	e456                	sd	s5,8(sp)
  800298:	0316fab3          	remu	s5,a3,a7
  80029c:	f822                	sd	s0,48(sp)
  80029e:	f426                	sd	s1,40(sp)
  8002a0:	f04a                	sd	s2,32(sp)
  8002a2:	ec4e                	sd	s3,24(sp)
  8002a4:	fc06                	sd	ra,56(sp)
  8002a6:	e852                	sd	s4,16(sp)
  8002a8:	84aa                	mv	s1,a0
  8002aa:	89ae                	mv	s3,a1
  8002ac:	8932                	mv	s2,a2
  8002ae:	fff7841b          	addiw	s0,a5,-1
  8002b2:	2a81                	sext.w	s5,s5
  8002b4:	0516f163          	bleu	a7,a3,8002f6 <printnum+0x6a>
  8002b8:	8a42                	mv	s4,a6
  8002ba:	00805863          	blez	s0,8002ca <printnum+0x3e>
  8002be:	347d                	addiw	s0,s0,-1
  8002c0:	864e                	mv	a2,s3
  8002c2:	85ca                	mv	a1,s2
  8002c4:	8552                	mv	a0,s4
  8002c6:	9482                	jalr	s1
  8002c8:	f87d                	bnez	s0,8002be <printnum+0x32>
  8002ca:	1a82                	slli	s5,s5,0x20
  8002cc:	020ada93          	srli	s5,s5,0x20
  8002d0:	00000797          	auipc	a5,0x0
  8002d4:	7d078793          	addi	a5,a5,2000 # 800aa0 <error_string+0xc8>
  8002d8:	9abe                	add	s5,s5,a5
  8002da:	7442                	ld	s0,48(sp)
  8002dc:	000ac503          	lbu	a0,0(s5)
  8002e0:	70e2                	ld	ra,56(sp)
  8002e2:	6a42                	ld	s4,16(sp)
  8002e4:	6aa2                	ld	s5,8(sp)
  8002e6:	864e                	mv	a2,s3
  8002e8:	85ca                	mv	a1,s2
  8002ea:	69e2                	ld	s3,24(sp)
  8002ec:	7902                	ld	s2,32(sp)
  8002ee:	8326                	mv	t1,s1
  8002f0:	74a2                	ld	s1,40(sp)
  8002f2:	6121                	addi	sp,sp,64
  8002f4:	8302                	jr	t1
  8002f6:	0316d6b3          	divu	a3,a3,a7
  8002fa:	87a2                	mv	a5,s0
  8002fc:	f91ff0ef          	jal	ra,80028c <printnum>
  800300:	b7e9                	j	8002ca <printnum+0x3e>

0000000000800302 <vprintfmt>:
  800302:	7119                	addi	sp,sp,-128
  800304:	f4a6                	sd	s1,104(sp)
  800306:	f0ca                	sd	s2,96(sp)
  800308:	ecce                	sd	s3,88(sp)
  80030a:	e4d6                	sd	s5,72(sp)
  80030c:	e0da                	sd	s6,64(sp)
  80030e:	fc5e                	sd	s7,56(sp)
  800310:	f862                	sd	s8,48(sp)
  800312:	ec6e                	sd	s11,24(sp)
  800314:	fc86                	sd	ra,120(sp)
  800316:	f8a2                	sd	s0,112(sp)
  800318:	e8d2                	sd	s4,80(sp)
  80031a:	f466                	sd	s9,40(sp)
  80031c:	f06a                	sd	s10,32(sp)
  80031e:	89aa                	mv	s3,a0
  800320:	892e                	mv	s2,a1
  800322:	84b2                	mv	s1,a2
  800324:	8db6                	mv	s11,a3
  800326:	8b3a                	mv	s6,a4
  800328:	5bfd                	li	s7,-1
  80032a:	00000a97          	auipc	s5,0x0
  80032e:	552a8a93          	addi	s5,s5,1362 # 80087c <main+0x1a8>
  800332:	05e00c13          	li	s8,94
  800336:	000dc503          	lbu	a0,0(s11)
  80033a:	02500793          	li	a5,37
  80033e:	001d8413          	addi	s0,s11,1
  800342:	00f50f63          	beq	a0,a5,800360 <vprintfmt+0x5e>
  800346:	c529                	beqz	a0,800390 <vprintfmt+0x8e>
  800348:	02500a13          	li	s4,37
  80034c:	a011                	j	800350 <vprintfmt+0x4e>
  80034e:	c129                	beqz	a0,800390 <vprintfmt+0x8e>
  800350:	864a                	mv	a2,s2
  800352:	85a6                	mv	a1,s1
  800354:	0405                	addi	s0,s0,1
  800356:	9982                	jalr	s3
  800358:	fff44503          	lbu	a0,-1(s0)
  80035c:	ff4519e3          	bne	a0,s4,80034e <vprintfmt+0x4c>
  800360:	00044603          	lbu	a2,0(s0)
  800364:	02000813          	li	a6,32
  800368:	4a01                	li	s4,0
  80036a:	4881                	li	a7,0
  80036c:	5d7d                	li	s10,-1
  80036e:	5cfd                	li	s9,-1
  800370:	05500593          	li	a1,85
  800374:	4525                	li	a0,9
  800376:	fdd6071b          	addiw	a4,a2,-35
  80037a:	0ff77713          	andi	a4,a4,255
  80037e:	00140d93          	addi	s11,s0,1
  800382:	22e5e363          	bltu	a1,a4,8005a8 <vprintfmt+0x2a6>
  800386:	070a                	slli	a4,a4,0x2
  800388:	9756                	add	a4,a4,s5
  80038a:	4318                	lw	a4,0(a4)
  80038c:	9756                	add	a4,a4,s5
  80038e:	8702                	jr	a4
  800390:	70e6                	ld	ra,120(sp)
  800392:	7446                	ld	s0,112(sp)
  800394:	74a6                	ld	s1,104(sp)
  800396:	7906                	ld	s2,96(sp)
  800398:	69e6                	ld	s3,88(sp)
  80039a:	6a46                	ld	s4,80(sp)
  80039c:	6aa6                	ld	s5,72(sp)
  80039e:	6b06                	ld	s6,64(sp)
  8003a0:	7be2                	ld	s7,56(sp)
  8003a2:	7c42                	ld	s8,48(sp)
  8003a4:	7ca2                	ld	s9,40(sp)
  8003a6:	7d02                	ld	s10,32(sp)
  8003a8:	6de2                	ld	s11,24(sp)
  8003aa:	6109                	addi	sp,sp,128
  8003ac:	8082                	ret
  8003ae:	4705                	li	a4,1
  8003b0:	008b0613          	addi	a2,s6,8
  8003b4:	01174463          	blt	a4,a7,8003bc <vprintfmt+0xba>
  8003b8:	28088563          	beqz	a7,800642 <vprintfmt+0x340>
  8003bc:	000b3683          	ld	a3,0(s6)
  8003c0:	4741                	li	a4,16
  8003c2:	8b32                	mv	s6,a2
  8003c4:	a86d                	j	80047e <vprintfmt+0x17c>
  8003c6:	00144603          	lbu	a2,1(s0)
  8003ca:	4a05                	li	s4,1
  8003cc:	846e                	mv	s0,s11
  8003ce:	b765                	j	800376 <vprintfmt+0x74>
  8003d0:	000b2503          	lw	a0,0(s6)
  8003d4:	864a                	mv	a2,s2
  8003d6:	85a6                	mv	a1,s1
  8003d8:	0b21                	addi	s6,s6,8
  8003da:	9982                	jalr	s3
  8003dc:	bfa9                	j	800336 <vprintfmt+0x34>
  8003de:	4705                	li	a4,1
  8003e0:	008b0a13          	addi	s4,s6,8
  8003e4:	01174463          	blt	a4,a7,8003ec <vprintfmt+0xea>
  8003e8:	24088563          	beqz	a7,800632 <vprintfmt+0x330>
  8003ec:	000b3403          	ld	s0,0(s6)
  8003f0:	26044563          	bltz	s0,80065a <vprintfmt+0x358>
  8003f4:	86a2                	mv	a3,s0
  8003f6:	8b52                	mv	s6,s4
  8003f8:	4729                	li	a4,10
  8003fa:	a051                	j	80047e <vprintfmt+0x17c>
  8003fc:	000b2783          	lw	a5,0(s6)
  800400:	46e1                	li	a3,24
  800402:	0b21                	addi	s6,s6,8
  800404:	41f7d71b          	sraiw	a4,a5,0x1f
  800408:	8fb9                	xor	a5,a5,a4
  80040a:	40e7873b          	subw	a4,a5,a4
  80040e:	1ce6c163          	blt	a3,a4,8005d0 <vprintfmt+0x2ce>
  800412:	00371793          	slli	a5,a4,0x3
  800416:	00000697          	auipc	a3,0x0
  80041a:	5c268693          	addi	a3,a3,1474 # 8009d8 <error_string>
  80041e:	97b6                	add	a5,a5,a3
  800420:	639c                	ld	a5,0(a5)
  800422:	1a078763          	beqz	a5,8005d0 <vprintfmt+0x2ce>
  800426:	873e                	mv	a4,a5
  800428:	00001697          	auipc	a3,0x1
  80042c:	88068693          	addi	a3,a3,-1920 # 800ca8 <error_string+0x2d0>
  800430:	8626                	mv	a2,s1
  800432:	85ca                	mv	a1,s2
  800434:	854e                	mv	a0,s3
  800436:	25a000ef          	jal	ra,800690 <printfmt>
  80043a:	bdf5                	j	800336 <vprintfmt+0x34>
  80043c:	00144603          	lbu	a2,1(s0)
  800440:	2885                	addiw	a7,a7,1
  800442:	846e                	mv	s0,s11
  800444:	bf0d                	j	800376 <vprintfmt+0x74>
  800446:	4705                	li	a4,1
  800448:	008b0613          	addi	a2,s6,8
  80044c:	01174463          	blt	a4,a7,800454 <vprintfmt+0x152>
  800450:	1e088e63          	beqz	a7,80064c <vprintfmt+0x34a>
  800454:	000b3683          	ld	a3,0(s6)
  800458:	4721                	li	a4,8
  80045a:	8b32                	mv	s6,a2
  80045c:	a00d                	j	80047e <vprintfmt+0x17c>
  80045e:	03000513          	li	a0,48
  800462:	864a                	mv	a2,s2
  800464:	85a6                	mv	a1,s1
  800466:	e042                	sd	a6,0(sp)
  800468:	9982                	jalr	s3
  80046a:	864a                	mv	a2,s2
  80046c:	85a6                	mv	a1,s1
  80046e:	07800513          	li	a0,120
  800472:	9982                	jalr	s3
  800474:	0b21                	addi	s6,s6,8
  800476:	ff8b3683          	ld	a3,-8(s6)
  80047a:	6802                	ld	a6,0(sp)
  80047c:	4741                	li	a4,16
  80047e:	87e6                	mv	a5,s9
  800480:	8626                	mv	a2,s1
  800482:	85ca                	mv	a1,s2
  800484:	854e                	mv	a0,s3
  800486:	e07ff0ef          	jal	ra,80028c <printnum>
  80048a:	b575                	j	800336 <vprintfmt+0x34>
  80048c:	000b3703          	ld	a4,0(s6)
  800490:	0b21                	addi	s6,s6,8
  800492:	1e070063          	beqz	a4,800672 <vprintfmt+0x370>
  800496:	00170413          	addi	s0,a4,1
  80049a:	19905563          	blez	s9,800624 <vprintfmt+0x322>
  80049e:	02d00613          	li	a2,45
  8004a2:	14c81963          	bne	a6,a2,8005f4 <vprintfmt+0x2f2>
  8004a6:	00074703          	lbu	a4,0(a4)
  8004aa:	0007051b          	sext.w	a0,a4
  8004ae:	c90d                	beqz	a0,8004e0 <vprintfmt+0x1de>
  8004b0:	000d4563          	bltz	s10,8004ba <vprintfmt+0x1b8>
  8004b4:	3d7d                	addiw	s10,s10,-1
  8004b6:	037d0363          	beq	s10,s7,8004dc <vprintfmt+0x1da>
  8004ba:	864a                	mv	a2,s2
  8004bc:	85a6                	mv	a1,s1
  8004be:	180a0c63          	beqz	s4,800656 <vprintfmt+0x354>
  8004c2:	3701                	addiw	a4,a4,-32
  8004c4:	18ec7963          	bleu	a4,s8,800656 <vprintfmt+0x354>
  8004c8:	03f00513          	li	a0,63
  8004cc:	9982                	jalr	s3
  8004ce:	0405                	addi	s0,s0,1
  8004d0:	fff44703          	lbu	a4,-1(s0)
  8004d4:	3cfd                	addiw	s9,s9,-1
  8004d6:	0007051b          	sext.w	a0,a4
  8004da:	f979                	bnez	a0,8004b0 <vprintfmt+0x1ae>
  8004dc:	e5905de3          	blez	s9,800336 <vprintfmt+0x34>
  8004e0:	3cfd                	addiw	s9,s9,-1
  8004e2:	864a                	mv	a2,s2
  8004e4:	85a6                	mv	a1,s1
  8004e6:	02000513          	li	a0,32
  8004ea:	9982                	jalr	s3
  8004ec:	e40c85e3          	beqz	s9,800336 <vprintfmt+0x34>
  8004f0:	3cfd                	addiw	s9,s9,-1
  8004f2:	864a                	mv	a2,s2
  8004f4:	85a6                	mv	a1,s1
  8004f6:	02000513          	li	a0,32
  8004fa:	9982                	jalr	s3
  8004fc:	fe0c92e3          	bnez	s9,8004e0 <vprintfmt+0x1de>
  800500:	bd1d                	j	800336 <vprintfmt+0x34>
  800502:	4705                	li	a4,1
  800504:	008b0613          	addi	a2,s6,8
  800508:	01174463          	blt	a4,a7,800510 <vprintfmt+0x20e>
  80050c:	12088663          	beqz	a7,800638 <vprintfmt+0x336>
  800510:	000b3683          	ld	a3,0(s6)
  800514:	4729                	li	a4,10
  800516:	8b32                	mv	s6,a2
  800518:	b79d                	j	80047e <vprintfmt+0x17c>
  80051a:	00144603          	lbu	a2,1(s0)
  80051e:	02d00813          	li	a6,45
  800522:	846e                	mv	s0,s11
  800524:	bd89                	j	800376 <vprintfmt+0x74>
  800526:	864a                	mv	a2,s2
  800528:	85a6                	mv	a1,s1
  80052a:	02500513          	li	a0,37
  80052e:	9982                	jalr	s3
  800530:	b519                	j	800336 <vprintfmt+0x34>
  800532:	000b2d03          	lw	s10,0(s6)
  800536:	00144603          	lbu	a2,1(s0)
  80053a:	0b21                	addi	s6,s6,8
  80053c:	846e                	mv	s0,s11
  80053e:	e20cdce3          	bgez	s9,800376 <vprintfmt+0x74>
  800542:	8cea                	mv	s9,s10
  800544:	5d7d                	li	s10,-1
  800546:	bd05                	j	800376 <vprintfmt+0x74>
  800548:	00144603          	lbu	a2,1(s0)
  80054c:	03000813          	li	a6,48
  800550:	846e                	mv	s0,s11
  800552:	b515                	j	800376 <vprintfmt+0x74>
  800554:	fd060d1b          	addiw	s10,a2,-48
  800558:	00144603          	lbu	a2,1(s0)
  80055c:	846e                	mv	s0,s11
  80055e:	fd06071b          	addiw	a4,a2,-48
  800562:	0006031b          	sext.w	t1,a2
  800566:	fce56ce3          	bltu	a0,a4,80053e <vprintfmt+0x23c>
  80056a:	0405                	addi	s0,s0,1
  80056c:	002d171b          	slliw	a4,s10,0x2
  800570:	00044603          	lbu	a2,0(s0)
  800574:	01a706bb          	addw	a3,a4,s10
  800578:	0016969b          	slliw	a3,a3,0x1
  80057c:	006686bb          	addw	a3,a3,t1
  800580:	fd06071b          	addiw	a4,a2,-48
  800584:	fd068d1b          	addiw	s10,a3,-48
  800588:	0006031b          	sext.w	t1,a2
  80058c:	fce57fe3          	bleu	a4,a0,80056a <vprintfmt+0x268>
  800590:	b77d                	j	80053e <vprintfmt+0x23c>
  800592:	fffcc713          	not	a4,s9
  800596:	977d                	srai	a4,a4,0x3f
  800598:	00ecf7b3          	and	a5,s9,a4
  80059c:	00144603          	lbu	a2,1(s0)
  8005a0:	00078c9b          	sext.w	s9,a5
  8005a4:	846e                	mv	s0,s11
  8005a6:	bbc1                	j	800376 <vprintfmt+0x74>
  8005a8:	864a                	mv	a2,s2
  8005aa:	85a6                	mv	a1,s1
  8005ac:	02500513          	li	a0,37
  8005b0:	9982                	jalr	s3
  8005b2:	fff44703          	lbu	a4,-1(s0)
  8005b6:	02500793          	li	a5,37
  8005ba:	8da2                	mv	s11,s0
  8005bc:	d6f70de3          	beq	a4,a5,800336 <vprintfmt+0x34>
  8005c0:	02500713          	li	a4,37
  8005c4:	1dfd                	addi	s11,s11,-1
  8005c6:	fffdc783          	lbu	a5,-1(s11)
  8005ca:	fee79de3          	bne	a5,a4,8005c4 <vprintfmt+0x2c2>
  8005ce:	b3a5                	j	800336 <vprintfmt+0x34>
  8005d0:	00000697          	auipc	a3,0x0
  8005d4:	6c868693          	addi	a3,a3,1736 # 800c98 <error_string+0x2c0>
  8005d8:	8626                	mv	a2,s1
  8005da:	85ca                	mv	a1,s2
  8005dc:	854e                	mv	a0,s3
  8005de:	0b2000ef          	jal	ra,800690 <printfmt>
  8005e2:	bb91                	j	800336 <vprintfmt+0x34>
  8005e4:	00000717          	auipc	a4,0x0
  8005e8:	6ac70713          	addi	a4,a4,1708 # 800c90 <error_string+0x2b8>
  8005ec:	00000417          	auipc	s0,0x0
  8005f0:	6a540413          	addi	s0,s0,1701 # 800c91 <error_string+0x2b9>
  8005f4:	853a                	mv	a0,a4
  8005f6:	85ea                	mv	a1,s10
  8005f8:	e03a                	sd	a4,0(sp)
  8005fa:	e442                	sd	a6,8(sp)
  8005fc:	0b2000ef          	jal	ra,8006ae <strnlen>
  800600:	40ac8cbb          	subw	s9,s9,a0
  800604:	6702                	ld	a4,0(sp)
  800606:	01905f63          	blez	s9,800624 <vprintfmt+0x322>
  80060a:	6822                	ld	a6,8(sp)
  80060c:	0008079b          	sext.w	a5,a6
  800610:	e43e                	sd	a5,8(sp)
  800612:	6522                	ld	a0,8(sp)
  800614:	864a                	mv	a2,s2
  800616:	85a6                	mv	a1,s1
  800618:	e03a                	sd	a4,0(sp)
  80061a:	3cfd                	addiw	s9,s9,-1
  80061c:	9982                	jalr	s3
  80061e:	6702                	ld	a4,0(sp)
  800620:	fe0c99e3          	bnez	s9,800612 <vprintfmt+0x310>
  800624:	00074703          	lbu	a4,0(a4)
  800628:	0007051b          	sext.w	a0,a4
  80062c:	e80512e3          	bnez	a0,8004b0 <vprintfmt+0x1ae>
  800630:	b319                	j	800336 <vprintfmt+0x34>
  800632:	000b2403          	lw	s0,0(s6)
  800636:	bb6d                	j	8003f0 <vprintfmt+0xee>
  800638:	000b6683          	lwu	a3,0(s6)
  80063c:	4729                	li	a4,10
  80063e:	8b32                	mv	s6,a2
  800640:	bd3d                	j	80047e <vprintfmt+0x17c>
  800642:	000b6683          	lwu	a3,0(s6)
  800646:	4741                	li	a4,16
  800648:	8b32                	mv	s6,a2
  80064a:	bd15                	j	80047e <vprintfmt+0x17c>
  80064c:	000b6683          	lwu	a3,0(s6)
  800650:	4721                	li	a4,8
  800652:	8b32                	mv	s6,a2
  800654:	b52d                	j	80047e <vprintfmt+0x17c>
  800656:	9982                	jalr	s3
  800658:	bd9d                	j	8004ce <vprintfmt+0x1cc>
  80065a:	864a                	mv	a2,s2
  80065c:	85a6                	mv	a1,s1
  80065e:	02d00513          	li	a0,45
  800662:	e042                	sd	a6,0(sp)
  800664:	9982                	jalr	s3
  800666:	8b52                	mv	s6,s4
  800668:	408006b3          	neg	a3,s0
  80066c:	4729                	li	a4,10
  80066e:	6802                	ld	a6,0(sp)
  800670:	b539                	j	80047e <vprintfmt+0x17c>
  800672:	01905663          	blez	s9,80067e <vprintfmt+0x37c>
  800676:	02d00713          	li	a4,45
  80067a:	f6e815e3          	bne	a6,a4,8005e4 <vprintfmt+0x2e2>
  80067e:	00000417          	auipc	s0,0x0
  800682:	61340413          	addi	s0,s0,1555 # 800c91 <error_string+0x2b9>
  800686:	02800513          	li	a0,40
  80068a:	02800713          	li	a4,40
  80068e:	b50d                	j	8004b0 <vprintfmt+0x1ae>

0000000000800690 <printfmt>:
  800690:	7139                	addi	sp,sp,-64
  800692:	02010313          	addi	t1,sp,32
  800696:	f03a                	sd	a4,32(sp)
  800698:	871a                	mv	a4,t1
  80069a:	ec06                	sd	ra,24(sp)
  80069c:	f43e                	sd	a5,40(sp)
  80069e:	f842                	sd	a6,48(sp)
  8006a0:	fc46                	sd	a7,56(sp)
  8006a2:	e41a                	sd	t1,8(sp)
  8006a4:	c5fff0ef          	jal	ra,800302 <vprintfmt>
  8006a8:	60e2                	ld	ra,24(sp)
  8006aa:	6121                	addi	sp,sp,64
  8006ac:	8082                	ret

00000000008006ae <strnlen>:
  8006ae:	c185                	beqz	a1,8006ce <strnlen+0x20>
  8006b0:	00054783          	lbu	a5,0(a0)
  8006b4:	cf89                	beqz	a5,8006ce <strnlen+0x20>
  8006b6:	4781                	li	a5,0
  8006b8:	a021                	j	8006c0 <strnlen+0x12>
  8006ba:	00074703          	lbu	a4,0(a4)
  8006be:	c711                	beqz	a4,8006ca <strnlen+0x1c>
  8006c0:	0785                	addi	a5,a5,1
  8006c2:	00f50733          	add	a4,a0,a5
  8006c6:	fef59ae3          	bne	a1,a5,8006ba <strnlen+0xc>
  8006ca:	853e                	mv	a0,a5
  8006cc:	8082                	ret
  8006ce:	4781                	li	a5,0
  8006d0:	853e                	mv	a0,a5
  8006d2:	8082                	ret

00000000008006d4 <main>:
  8006d4:	1101                	addi	sp,sp,-32
  8006d6:	ec06                	sd	ra,24(sp)
  8006d8:	e822                	sd	s0,16(sp)
  8006da:	aefff0ef          	jal	ra,8001c8 <fork>
  8006de:	c169                	beqz	a0,8007a0 <main+0xcc>
  8006e0:	842a                	mv	s0,a0
  8006e2:	0aa05063          	blez	a0,800782 <main+0xae>
  8006e6:	4581                	li	a1,0
  8006e8:	557d                	li	a0,-1
  8006ea:	ae3ff0ef          	jal	ra,8001cc <waitpid>
  8006ee:	c93d                	beqz	a0,800764 <main+0x90>
  8006f0:	458d                	li	a1,3
  8006f2:	05fa                	slli	a1,a1,0x1e
  8006f4:	8522                	mv	a0,s0
  8006f6:	ad7ff0ef          	jal	ra,8001cc <waitpid>
  8006fa:	c531                	beqz	a0,800746 <main+0x72>
  8006fc:	006c                	addi	a1,sp,12
  8006fe:	8522                	mv	a0,s0
  800700:	acdff0ef          	jal	ra,8001cc <waitpid>
  800704:	e115                	bnez	a0,800728 <main+0x54>
  800706:	4732                	lw	a4,12(sp)
  800708:	67b1                	lui	a5,0xc
  80070a:	eaf78793          	addi	a5,a5,-337 # beaf <open-0x7f4171>
  80070e:	00f71d63          	bne	a4,a5,800728 <main+0x54>
  800712:	00000517          	auipc	a0,0x0
  800716:	65650513          	addi	a0,a0,1622 # 800d68 <error_string+0x390>
  80071a:	9dfff0ef          	jal	ra,8000f8 <cprintf>
  80071e:	60e2                	ld	ra,24(sp)
  800720:	6442                	ld	s0,16(sp)
  800722:	4501                	li	a0,0
  800724:	6105                	addi	sp,sp,32
  800726:	8082                	ret
  800728:	00000697          	auipc	a3,0x0
  80072c:	60868693          	addi	a3,a3,1544 # 800d30 <error_string+0x358>
  800730:	00000617          	auipc	a2,0x0
  800734:	59860613          	addi	a2,a2,1432 # 800cc8 <error_string+0x2f0>
  800738:	45c9                	li	a1,18
  80073a:	00000517          	auipc	a0,0x0
  80073e:	5a650513          	addi	a0,a0,1446 # 800ce0 <error_string+0x308>
  800742:	8f5ff0ef          	jal	ra,800036 <__panic>
  800746:	00000697          	auipc	a3,0x0
  80074a:	5c268693          	addi	a3,a3,1474 # 800d08 <error_string+0x330>
  80074e:	00000617          	auipc	a2,0x0
  800752:	57a60613          	addi	a2,a2,1402 # 800cc8 <error_string+0x2f0>
  800756:	45c5                	li	a1,17
  800758:	00000517          	auipc	a0,0x0
  80075c:	58850513          	addi	a0,a0,1416 # 800ce0 <error_string+0x308>
  800760:	8d7ff0ef          	jal	ra,800036 <__panic>
  800764:	00000697          	auipc	a3,0x0
  800768:	58c68693          	addi	a3,a3,1420 # 800cf0 <error_string+0x318>
  80076c:	00000617          	auipc	a2,0x0
  800770:	55c60613          	addi	a2,a2,1372 # 800cc8 <error_string+0x2f0>
  800774:	45c1                	li	a1,16
  800776:	00000517          	auipc	a0,0x0
  80077a:	56a50513          	addi	a0,a0,1386 # 800ce0 <error_string+0x308>
  80077e:	8b9ff0ef          	jal	ra,800036 <__panic>
  800782:	00000697          	auipc	a3,0x0
  800786:	53e68693          	addi	a3,a3,1342 # 800cc0 <error_string+0x2e8>
  80078a:	00000617          	auipc	a2,0x0
  80078e:	53e60613          	addi	a2,a2,1342 # 800cc8 <error_string+0x2f0>
  800792:	45bd                	li	a1,15
  800794:	00000517          	auipc	a0,0x0
  800798:	54c50513          	addi	a0,a0,1356 # 800ce0 <error_string+0x308>
  80079c:	89bff0ef          	jal	ra,800036 <__panic>
  8007a0:	00000517          	auipc	a0,0x0
  8007a4:	51050513          	addi	a0,a0,1296 # 800cb0 <error_string+0x2d8>
  8007a8:	951ff0ef          	jal	ra,8000f8 <cprintf>
  8007ac:	4429                	li	s0,10
  8007ae:	347d                	addiw	s0,s0,-1
  8007b0:	a21ff0ef          	jal	ra,8001d0 <yield>
  8007b4:	fc6d                	bnez	s0,8007ae <main+0xda>
  8007b6:	6531                	lui	a0,0xc
  8007b8:	eaf50513          	addi	a0,a0,-337 # beaf <open-0x7f4171>
  8007bc:	9f7ff0ef          	jal	ra,8001b2 <exit>
