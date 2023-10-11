
obj/__user_exit.out：     文件格式 elf64-littleriscv


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
  800030:	1f0000ef          	jal	ra,800220 <umain>
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
  800048:	7b450513          	addi	a0,a0,1972 # 8007f8 <main+0x11c>
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
  800068:	80c50513          	addi	a0,a0,-2036 # 800870 <main+0x194>
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
  800088:	79450513          	addi	a0,a0,1940 # 800818 <main+0x13c>
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
  8000a8:	7cc50513          	addi	a0,a0,1996 # 800870 <main+0x194>
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
  8000e4:	ad958593          	addi	a1,a1,-1319 # ffffffffffff6ad9 <magic+0xffffffffff7f5ad9>
  8000e8:	ec06                	sd	ra,24(sp)
  8000ea:	c602                	sw	zero,12(sp)
  8000ec:	21e000ef          	jal	ra,80030a <vprintfmt>
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
  800116:	ad958593          	addi	a1,a1,-1319 # ffffffffffff6ad9 <magic+0xffffffffff7f5ad9>
  80011a:	ec06                	sd	ra,24(sp)
  80011c:	e4be                	sd	a5,72(sp)
  80011e:	e8c2                	sd	a6,80(sp)
  800120:	ecc6                	sd	a7,88(sp)
  800122:	e41a                	sd	t1,8(sp)
  800124:	c202                	sw	zero,4(sp)
  800126:	1e4000ef          	jal	ra,80030a <vprintfmt>
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
  8001be:	67e50513          	addi	a0,a0,1662 # 800838 <main+0x15c>
  8001c2:	f37ff0ef          	jal	ra,8000f8 <cprintf>
  8001c6:	a001                	j	8001c6 <exit+0x14>

00000000008001c8 <fork>:
  8001c8:	fabff06f          	j	800172 <sys_fork>

00000000008001cc <wait>:
  8001cc:	4581                	li	a1,0
  8001ce:	4501                	li	a0,0
  8001d0:	fa9ff06f          	j	800178 <sys_wait>

00000000008001d4 <waitpid>:
  8001d4:	fa5ff06f          	j	800178 <sys_wait>

00000000008001d8 <yield>:
  8001d8:	fabff06f          	j	800182 <sys_yield>

00000000008001dc <initfd>:
  8001dc:	1101                	addi	sp,sp,-32
  8001de:	87ae                	mv	a5,a1
  8001e0:	e426                	sd	s1,8(sp)
  8001e2:	85b2                	mv	a1,a2
  8001e4:	84aa                	mv	s1,a0
  8001e6:	853e                	mv	a0,a5
  8001e8:	e822                	sd	s0,16(sp)
  8001ea:	ec06                	sd	ra,24(sp)
  8001ec:	e35ff0ef          	jal	ra,800020 <open>
  8001f0:	842a                	mv	s0,a0
  8001f2:	00054463          	bltz	a0,8001fa <initfd+0x1e>
  8001f6:	00951863          	bne	a0,s1,800206 <initfd+0x2a>
  8001fa:	8522                	mv	a0,s0
  8001fc:	60e2                	ld	ra,24(sp)
  8001fe:	6442                	ld	s0,16(sp)
  800200:	64a2                	ld	s1,8(sp)
  800202:	6105                	addi	sp,sp,32
  800204:	8082                	ret
  800206:	8526                	mv	a0,s1
  800208:	e21ff0ef          	jal	ra,800028 <close>
  80020c:	85a6                	mv	a1,s1
  80020e:	8522                	mv	a0,s0
  800210:	e1dff0ef          	jal	ra,80002c <dup2>
  800214:	84aa                	mv	s1,a0
  800216:	8522                	mv	a0,s0
  800218:	e11ff0ef          	jal	ra,800028 <close>
  80021c:	8426                	mv	s0,s1
  80021e:	bff1                	j	8001fa <initfd+0x1e>

0000000000800220 <umain>:
  800220:	1101                	addi	sp,sp,-32
  800222:	e822                	sd	s0,16(sp)
  800224:	e426                	sd	s1,8(sp)
  800226:	842a                	mv	s0,a0
  800228:	84ae                	mv	s1,a1
  80022a:	4601                	li	a2,0
  80022c:	00000597          	auipc	a1,0x0
  800230:	62458593          	addi	a1,a1,1572 # 800850 <main+0x174>
  800234:	4501                	li	a0,0
  800236:	ec06                	sd	ra,24(sp)
  800238:	fa5ff0ef          	jal	ra,8001dc <initfd>
  80023c:	02054263          	bltz	a0,800260 <umain+0x40>
  800240:	4605                	li	a2,1
  800242:	00000597          	auipc	a1,0x0
  800246:	64e58593          	addi	a1,a1,1614 # 800890 <main+0x1b4>
  80024a:	4505                	li	a0,1
  80024c:	f91ff0ef          	jal	ra,8001dc <initfd>
  800250:	02054563          	bltz	a0,80027a <umain+0x5a>
  800254:	85a6                	mv	a1,s1
  800256:	8522                	mv	a0,s0
  800258:	484000ef          	jal	ra,8006dc <main>
  80025c:	f57ff0ef          	jal	ra,8001b2 <exit>
  800260:	86aa                	mv	a3,a0
  800262:	00000617          	auipc	a2,0x0
  800266:	5f660613          	addi	a2,a2,1526 # 800858 <main+0x17c>
  80026a:	45e9                	li	a1,26
  80026c:	00000517          	auipc	a0,0x0
  800270:	60c50513          	addi	a0,a0,1548 # 800878 <main+0x19c>
  800274:	e03ff0ef          	jal	ra,800076 <__warn>
  800278:	b7e1                	j	800240 <umain+0x20>
  80027a:	86aa                	mv	a3,a0
  80027c:	00000617          	auipc	a2,0x0
  800280:	61c60613          	addi	a2,a2,1564 # 800898 <main+0x1bc>
  800284:	45f5                	li	a1,29
  800286:	00000517          	auipc	a0,0x0
  80028a:	5f250513          	addi	a0,a0,1522 # 800878 <main+0x19c>
  80028e:	de9ff0ef          	jal	ra,800076 <__warn>
  800292:	b7c9                	j	800254 <umain+0x34>

0000000000800294 <printnum>:
  800294:	02071893          	slli	a7,a4,0x20
  800298:	7139                	addi	sp,sp,-64
  80029a:	0208d893          	srli	a7,a7,0x20
  80029e:	e456                	sd	s5,8(sp)
  8002a0:	0316fab3          	remu	s5,a3,a7
  8002a4:	f822                	sd	s0,48(sp)
  8002a6:	f426                	sd	s1,40(sp)
  8002a8:	f04a                	sd	s2,32(sp)
  8002aa:	ec4e                	sd	s3,24(sp)
  8002ac:	fc06                	sd	ra,56(sp)
  8002ae:	e852                	sd	s4,16(sp)
  8002b0:	84aa                	mv	s1,a0
  8002b2:	89ae                	mv	s3,a1
  8002b4:	8932                	mv	s2,a2
  8002b6:	fff7841b          	addiw	s0,a5,-1
  8002ba:	2a81                	sext.w	s5,s5
  8002bc:	0516f163          	bleu	a7,a3,8002fe <printnum+0x6a>
  8002c0:	8a42                	mv	s4,a6
  8002c2:	00805863          	blez	s0,8002d2 <printnum+0x3e>
  8002c6:	347d                	addiw	s0,s0,-1
  8002c8:	864e                	mv	a2,s3
  8002ca:	85ca                	mv	a1,s2
  8002cc:	8552                	mv	a0,s4
  8002ce:	9482                	jalr	s1
  8002d0:	f87d                	bnez	s0,8002c6 <printnum+0x32>
  8002d2:	1a82                	slli	s5,s5,0x20
  8002d4:	020ada93          	srli	s5,s5,0x20
  8002d8:	00001797          	auipc	a5,0x1
  8002dc:	80078793          	addi	a5,a5,-2048 # 800ad8 <error_string+0xc8>
  8002e0:	9abe                	add	s5,s5,a5
  8002e2:	7442                	ld	s0,48(sp)
  8002e4:	000ac503          	lbu	a0,0(s5)
  8002e8:	70e2                	ld	ra,56(sp)
  8002ea:	6a42                	ld	s4,16(sp)
  8002ec:	6aa2                	ld	s5,8(sp)
  8002ee:	864e                	mv	a2,s3
  8002f0:	85ca                	mv	a1,s2
  8002f2:	69e2                	ld	s3,24(sp)
  8002f4:	7902                	ld	s2,32(sp)
  8002f6:	8326                	mv	t1,s1
  8002f8:	74a2                	ld	s1,40(sp)
  8002fa:	6121                	addi	sp,sp,64
  8002fc:	8302                	jr	t1
  8002fe:	0316d6b3          	divu	a3,a3,a7
  800302:	87a2                	mv	a5,s0
  800304:	f91ff0ef          	jal	ra,800294 <printnum>
  800308:	b7e9                	j	8002d2 <printnum+0x3e>

000000000080030a <vprintfmt>:
  80030a:	7119                	addi	sp,sp,-128
  80030c:	f4a6                	sd	s1,104(sp)
  80030e:	f0ca                	sd	s2,96(sp)
  800310:	ecce                	sd	s3,88(sp)
  800312:	e4d6                	sd	s5,72(sp)
  800314:	e0da                	sd	s6,64(sp)
  800316:	fc5e                	sd	s7,56(sp)
  800318:	f862                	sd	s8,48(sp)
  80031a:	ec6e                	sd	s11,24(sp)
  80031c:	fc86                	sd	ra,120(sp)
  80031e:	f8a2                	sd	s0,112(sp)
  800320:	e8d2                	sd	s4,80(sp)
  800322:	f466                	sd	s9,40(sp)
  800324:	f06a                	sd	s10,32(sp)
  800326:	89aa                	mv	s3,a0
  800328:	892e                	mv	s2,a1
  80032a:	84b2                	mv	s1,a2
  80032c:	8db6                	mv	s11,a3
  80032e:	8b3a                	mv	s6,a4
  800330:	5bfd                	li	s7,-1
  800332:	00000a97          	auipc	s5,0x0
  800336:	582a8a93          	addi	s5,s5,1410 # 8008b4 <main+0x1d8>
  80033a:	05e00c13          	li	s8,94
  80033e:	000dc503          	lbu	a0,0(s11)
  800342:	02500793          	li	a5,37
  800346:	001d8413          	addi	s0,s11,1
  80034a:	00f50f63          	beq	a0,a5,800368 <vprintfmt+0x5e>
  80034e:	c529                	beqz	a0,800398 <vprintfmt+0x8e>
  800350:	02500a13          	li	s4,37
  800354:	a011                	j	800358 <vprintfmt+0x4e>
  800356:	c129                	beqz	a0,800398 <vprintfmt+0x8e>
  800358:	864a                	mv	a2,s2
  80035a:	85a6                	mv	a1,s1
  80035c:	0405                	addi	s0,s0,1
  80035e:	9982                	jalr	s3
  800360:	fff44503          	lbu	a0,-1(s0)
  800364:	ff4519e3          	bne	a0,s4,800356 <vprintfmt+0x4c>
  800368:	00044603          	lbu	a2,0(s0)
  80036c:	02000813          	li	a6,32
  800370:	4a01                	li	s4,0
  800372:	4881                	li	a7,0
  800374:	5d7d                	li	s10,-1
  800376:	5cfd                	li	s9,-1
  800378:	05500593          	li	a1,85
  80037c:	4525                	li	a0,9
  80037e:	fdd6071b          	addiw	a4,a2,-35
  800382:	0ff77713          	andi	a4,a4,255
  800386:	00140d93          	addi	s11,s0,1
  80038a:	22e5e363          	bltu	a1,a4,8005b0 <vprintfmt+0x2a6>
  80038e:	070a                	slli	a4,a4,0x2
  800390:	9756                	add	a4,a4,s5
  800392:	4318                	lw	a4,0(a4)
  800394:	9756                	add	a4,a4,s5
  800396:	8702                	jr	a4
  800398:	70e6                	ld	ra,120(sp)
  80039a:	7446                	ld	s0,112(sp)
  80039c:	74a6                	ld	s1,104(sp)
  80039e:	7906                	ld	s2,96(sp)
  8003a0:	69e6                	ld	s3,88(sp)
  8003a2:	6a46                	ld	s4,80(sp)
  8003a4:	6aa6                	ld	s5,72(sp)
  8003a6:	6b06                	ld	s6,64(sp)
  8003a8:	7be2                	ld	s7,56(sp)
  8003aa:	7c42                	ld	s8,48(sp)
  8003ac:	7ca2                	ld	s9,40(sp)
  8003ae:	7d02                	ld	s10,32(sp)
  8003b0:	6de2                	ld	s11,24(sp)
  8003b2:	6109                	addi	sp,sp,128
  8003b4:	8082                	ret
  8003b6:	4705                	li	a4,1
  8003b8:	008b0613          	addi	a2,s6,8
  8003bc:	01174463          	blt	a4,a7,8003c4 <vprintfmt+0xba>
  8003c0:	28088563          	beqz	a7,80064a <vprintfmt+0x340>
  8003c4:	000b3683          	ld	a3,0(s6)
  8003c8:	4741                	li	a4,16
  8003ca:	8b32                	mv	s6,a2
  8003cc:	a86d                	j	800486 <vprintfmt+0x17c>
  8003ce:	00144603          	lbu	a2,1(s0)
  8003d2:	4a05                	li	s4,1
  8003d4:	846e                	mv	s0,s11
  8003d6:	b765                	j	80037e <vprintfmt+0x74>
  8003d8:	000b2503          	lw	a0,0(s6)
  8003dc:	864a                	mv	a2,s2
  8003de:	85a6                	mv	a1,s1
  8003e0:	0b21                	addi	s6,s6,8
  8003e2:	9982                	jalr	s3
  8003e4:	bfa9                	j	80033e <vprintfmt+0x34>
  8003e6:	4705                	li	a4,1
  8003e8:	008b0a13          	addi	s4,s6,8
  8003ec:	01174463          	blt	a4,a7,8003f4 <vprintfmt+0xea>
  8003f0:	24088563          	beqz	a7,80063a <vprintfmt+0x330>
  8003f4:	000b3403          	ld	s0,0(s6)
  8003f8:	26044563          	bltz	s0,800662 <vprintfmt+0x358>
  8003fc:	86a2                	mv	a3,s0
  8003fe:	8b52                	mv	s6,s4
  800400:	4729                	li	a4,10
  800402:	a051                	j	800486 <vprintfmt+0x17c>
  800404:	000b2783          	lw	a5,0(s6)
  800408:	46e1                	li	a3,24
  80040a:	0b21                	addi	s6,s6,8
  80040c:	41f7d71b          	sraiw	a4,a5,0x1f
  800410:	8fb9                	xor	a5,a5,a4
  800412:	40e7873b          	subw	a4,a5,a4
  800416:	1ce6c163          	blt	a3,a4,8005d8 <vprintfmt+0x2ce>
  80041a:	00371793          	slli	a5,a4,0x3
  80041e:	00000697          	auipc	a3,0x0
  800422:	5f268693          	addi	a3,a3,1522 # 800a10 <error_string>
  800426:	97b6                	add	a5,a5,a3
  800428:	639c                	ld	a5,0(a5)
  80042a:	1a078763          	beqz	a5,8005d8 <vprintfmt+0x2ce>
  80042e:	873e                	mv	a4,a5
  800430:	00001697          	auipc	a3,0x1
  800434:	8b068693          	addi	a3,a3,-1872 # 800ce0 <error_string+0x2d0>
  800438:	8626                	mv	a2,s1
  80043a:	85ca                	mv	a1,s2
  80043c:	854e                	mv	a0,s3
  80043e:	25a000ef          	jal	ra,800698 <printfmt>
  800442:	bdf5                	j	80033e <vprintfmt+0x34>
  800444:	00144603          	lbu	a2,1(s0)
  800448:	2885                	addiw	a7,a7,1
  80044a:	846e                	mv	s0,s11
  80044c:	bf0d                	j	80037e <vprintfmt+0x74>
  80044e:	4705                	li	a4,1
  800450:	008b0613          	addi	a2,s6,8
  800454:	01174463          	blt	a4,a7,80045c <vprintfmt+0x152>
  800458:	1e088e63          	beqz	a7,800654 <vprintfmt+0x34a>
  80045c:	000b3683          	ld	a3,0(s6)
  800460:	4721                	li	a4,8
  800462:	8b32                	mv	s6,a2
  800464:	a00d                	j	800486 <vprintfmt+0x17c>
  800466:	03000513          	li	a0,48
  80046a:	864a                	mv	a2,s2
  80046c:	85a6                	mv	a1,s1
  80046e:	e042                	sd	a6,0(sp)
  800470:	9982                	jalr	s3
  800472:	864a                	mv	a2,s2
  800474:	85a6                	mv	a1,s1
  800476:	07800513          	li	a0,120
  80047a:	9982                	jalr	s3
  80047c:	0b21                	addi	s6,s6,8
  80047e:	ff8b3683          	ld	a3,-8(s6)
  800482:	6802                	ld	a6,0(sp)
  800484:	4741                	li	a4,16
  800486:	87e6                	mv	a5,s9
  800488:	8626                	mv	a2,s1
  80048a:	85ca                	mv	a1,s2
  80048c:	854e                	mv	a0,s3
  80048e:	e07ff0ef          	jal	ra,800294 <printnum>
  800492:	b575                	j	80033e <vprintfmt+0x34>
  800494:	000b3703          	ld	a4,0(s6)
  800498:	0b21                	addi	s6,s6,8
  80049a:	1e070063          	beqz	a4,80067a <vprintfmt+0x370>
  80049e:	00170413          	addi	s0,a4,1
  8004a2:	19905563          	blez	s9,80062c <vprintfmt+0x322>
  8004a6:	02d00613          	li	a2,45
  8004aa:	14c81963          	bne	a6,a2,8005fc <vprintfmt+0x2f2>
  8004ae:	00074703          	lbu	a4,0(a4)
  8004b2:	0007051b          	sext.w	a0,a4
  8004b6:	c90d                	beqz	a0,8004e8 <vprintfmt+0x1de>
  8004b8:	000d4563          	bltz	s10,8004c2 <vprintfmt+0x1b8>
  8004bc:	3d7d                	addiw	s10,s10,-1
  8004be:	037d0363          	beq	s10,s7,8004e4 <vprintfmt+0x1da>
  8004c2:	864a                	mv	a2,s2
  8004c4:	85a6                	mv	a1,s1
  8004c6:	180a0c63          	beqz	s4,80065e <vprintfmt+0x354>
  8004ca:	3701                	addiw	a4,a4,-32
  8004cc:	18ec7963          	bleu	a4,s8,80065e <vprintfmt+0x354>
  8004d0:	03f00513          	li	a0,63
  8004d4:	9982                	jalr	s3
  8004d6:	0405                	addi	s0,s0,1
  8004d8:	fff44703          	lbu	a4,-1(s0)
  8004dc:	3cfd                	addiw	s9,s9,-1
  8004de:	0007051b          	sext.w	a0,a4
  8004e2:	f979                	bnez	a0,8004b8 <vprintfmt+0x1ae>
  8004e4:	e5905de3          	blez	s9,80033e <vprintfmt+0x34>
  8004e8:	3cfd                	addiw	s9,s9,-1
  8004ea:	864a                	mv	a2,s2
  8004ec:	85a6                	mv	a1,s1
  8004ee:	02000513          	li	a0,32
  8004f2:	9982                	jalr	s3
  8004f4:	e40c85e3          	beqz	s9,80033e <vprintfmt+0x34>
  8004f8:	3cfd                	addiw	s9,s9,-1
  8004fa:	864a                	mv	a2,s2
  8004fc:	85a6                	mv	a1,s1
  8004fe:	02000513          	li	a0,32
  800502:	9982                	jalr	s3
  800504:	fe0c92e3          	bnez	s9,8004e8 <vprintfmt+0x1de>
  800508:	bd1d                	j	80033e <vprintfmt+0x34>
  80050a:	4705                	li	a4,1
  80050c:	008b0613          	addi	a2,s6,8
  800510:	01174463          	blt	a4,a7,800518 <vprintfmt+0x20e>
  800514:	12088663          	beqz	a7,800640 <vprintfmt+0x336>
  800518:	000b3683          	ld	a3,0(s6)
  80051c:	4729                	li	a4,10
  80051e:	8b32                	mv	s6,a2
  800520:	b79d                	j	800486 <vprintfmt+0x17c>
  800522:	00144603          	lbu	a2,1(s0)
  800526:	02d00813          	li	a6,45
  80052a:	846e                	mv	s0,s11
  80052c:	bd89                	j	80037e <vprintfmt+0x74>
  80052e:	864a                	mv	a2,s2
  800530:	85a6                	mv	a1,s1
  800532:	02500513          	li	a0,37
  800536:	9982                	jalr	s3
  800538:	b519                	j	80033e <vprintfmt+0x34>
  80053a:	000b2d03          	lw	s10,0(s6)
  80053e:	00144603          	lbu	a2,1(s0)
  800542:	0b21                	addi	s6,s6,8
  800544:	846e                	mv	s0,s11
  800546:	e20cdce3          	bgez	s9,80037e <vprintfmt+0x74>
  80054a:	8cea                	mv	s9,s10
  80054c:	5d7d                	li	s10,-1
  80054e:	bd05                	j	80037e <vprintfmt+0x74>
  800550:	00144603          	lbu	a2,1(s0)
  800554:	03000813          	li	a6,48
  800558:	846e                	mv	s0,s11
  80055a:	b515                	j	80037e <vprintfmt+0x74>
  80055c:	fd060d1b          	addiw	s10,a2,-48
  800560:	00144603          	lbu	a2,1(s0)
  800564:	846e                	mv	s0,s11
  800566:	fd06071b          	addiw	a4,a2,-48
  80056a:	0006031b          	sext.w	t1,a2
  80056e:	fce56ce3          	bltu	a0,a4,800546 <vprintfmt+0x23c>
  800572:	0405                	addi	s0,s0,1
  800574:	002d171b          	slliw	a4,s10,0x2
  800578:	00044603          	lbu	a2,0(s0)
  80057c:	01a706bb          	addw	a3,a4,s10
  800580:	0016969b          	slliw	a3,a3,0x1
  800584:	006686bb          	addw	a3,a3,t1
  800588:	fd06071b          	addiw	a4,a2,-48
  80058c:	fd068d1b          	addiw	s10,a3,-48
  800590:	0006031b          	sext.w	t1,a2
  800594:	fce57fe3          	bleu	a4,a0,800572 <vprintfmt+0x268>
  800598:	b77d                	j	800546 <vprintfmt+0x23c>
  80059a:	fffcc713          	not	a4,s9
  80059e:	977d                	srai	a4,a4,0x3f
  8005a0:	00ecf7b3          	and	a5,s9,a4
  8005a4:	00144603          	lbu	a2,1(s0)
  8005a8:	00078c9b          	sext.w	s9,a5
  8005ac:	846e                	mv	s0,s11
  8005ae:	bbc1                	j	80037e <vprintfmt+0x74>
  8005b0:	864a                	mv	a2,s2
  8005b2:	85a6                	mv	a1,s1
  8005b4:	02500513          	li	a0,37
  8005b8:	9982                	jalr	s3
  8005ba:	fff44703          	lbu	a4,-1(s0)
  8005be:	02500793          	li	a5,37
  8005c2:	8da2                	mv	s11,s0
  8005c4:	d6f70de3          	beq	a4,a5,80033e <vprintfmt+0x34>
  8005c8:	02500713          	li	a4,37
  8005cc:	1dfd                	addi	s11,s11,-1
  8005ce:	fffdc783          	lbu	a5,-1(s11)
  8005d2:	fee79de3          	bne	a5,a4,8005cc <vprintfmt+0x2c2>
  8005d6:	b3a5                	j	80033e <vprintfmt+0x34>
  8005d8:	00000697          	auipc	a3,0x0
  8005dc:	6f868693          	addi	a3,a3,1784 # 800cd0 <error_string+0x2c0>
  8005e0:	8626                	mv	a2,s1
  8005e2:	85ca                	mv	a1,s2
  8005e4:	854e                	mv	a0,s3
  8005e6:	0b2000ef          	jal	ra,800698 <printfmt>
  8005ea:	bb91                	j	80033e <vprintfmt+0x34>
  8005ec:	00000717          	auipc	a4,0x0
  8005f0:	6dc70713          	addi	a4,a4,1756 # 800cc8 <error_string+0x2b8>
  8005f4:	00000417          	auipc	s0,0x0
  8005f8:	6d540413          	addi	s0,s0,1749 # 800cc9 <error_string+0x2b9>
  8005fc:	853a                	mv	a0,a4
  8005fe:	85ea                	mv	a1,s10
  800600:	e03a                	sd	a4,0(sp)
  800602:	e442                	sd	a6,8(sp)
  800604:	0b2000ef          	jal	ra,8006b6 <strnlen>
  800608:	40ac8cbb          	subw	s9,s9,a0
  80060c:	6702                	ld	a4,0(sp)
  80060e:	01905f63          	blez	s9,80062c <vprintfmt+0x322>
  800612:	6822                	ld	a6,8(sp)
  800614:	0008079b          	sext.w	a5,a6
  800618:	e43e                	sd	a5,8(sp)
  80061a:	6522                	ld	a0,8(sp)
  80061c:	864a                	mv	a2,s2
  80061e:	85a6                	mv	a1,s1
  800620:	e03a                	sd	a4,0(sp)
  800622:	3cfd                	addiw	s9,s9,-1
  800624:	9982                	jalr	s3
  800626:	6702                	ld	a4,0(sp)
  800628:	fe0c99e3          	bnez	s9,80061a <vprintfmt+0x310>
  80062c:	00074703          	lbu	a4,0(a4)
  800630:	0007051b          	sext.w	a0,a4
  800634:	e80512e3          	bnez	a0,8004b8 <vprintfmt+0x1ae>
  800638:	b319                	j	80033e <vprintfmt+0x34>
  80063a:	000b2403          	lw	s0,0(s6)
  80063e:	bb6d                	j	8003f8 <vprintfmt+0xee>
  800640:	000b6683          	lwu	a3,0(s6)
  800644:	4729                	li	a4,10
  800646:	8b32                	mv	s6,a2
  800648:	bd3d                	j	800486 <vprintfmt+0x17c>
  80064a:	000b6683          	lwu	a3,0(s6)
  80064e:	4741                	li	a4,16
  800650:	8b32                	mv	s6,a2
  800652:	bd15                	j	800486 <vprintfmt+0x17c>
  800654:	000b6683          	lwu	a3,0(s6)
  800658:	4721                	li	a4,8
  80065a:	8b32                	mv	s6,a2
  80065c:	b52d                	j	800486 <vprintfmt+0x17c>
  80065e:	9982                	jalr	s3
  800660:	bd9d                	j	8004d6 <vprintfmt+0x1cc>
  800662:	864a                	mv	a2,s2
  800664:	85a6                	mv	a1,s1
  800666:	02d00513          	li	a0,45
  80066a:	e042                	sd	a6,0(sp)
  80066c:	9982                	jalr	s3
  80066e:	8b52                	mv	s6,s4
  800670:	408006b3          	neg	a3,s0
  800674:	4729                	li	a4,10
  800676:	6802                	ld	a6,0(sp)
  800678:	b539                	j	800486 <vprintfmt+0x17c>
  80067a:	01905663          	blez	s9,800686 <vprintfmt+0x37c>
  80067e:	02d00713          	li	a4,45
  800682:	f6e815e3          	bne	a6,a4,8005ec <vprintfmt+0x2e2>
  800686:	00000417          	auipc	s0,0x0
  80068a:	64340413          	addi	s0,s0,1603 # 800cc9 <error_string+0x2b9>
  80068e:	02800513          	li	a0,40
  800692:	02800713          	li	a4,40
  800696:	b50d                	j	8004b8 <vprintfmt+0x1ae>

0000000000800698 <printfmt>:
  800698:	7139                	addi	sp,sp,-64
  80069a:	02010313          	addi	t1,sp,32
  80069e:	f03a                	sd	a4,32(sp)
  8006a0:	871a                	mv	a4,t1
  8006a2:	ec06                	sd	ra,24(sp)
  8006a4:	f43e                	sd	a5,40(sp)
  8006a6:	f842                	sd	a6,48(sp)
  8006a8:	fc46                	sd	a7,56(sp)
  8006aa:	e41a                	sd	t1,8(sp)
  8006ac:	c5fff0ef          	jal	ra,80030a <vprintfmt>
  8006b0:	60e2                	ld	ra,24(sp)
  8006b2:	6121                	addi	sp,sp,64
  8006b4:	8082                	ret

00000000008006b6 <strnlen>:
  8006b6:	c185                	beqz	a1,8006d6 <strnlen+0x20>
  8006b8:	00054783          	lbu	a5,0(a0)
  8006bc:	cf89                	beqz	a5,8006d6 <strnlen+0x20>
  8006be:	4781                	li	a5,0
  8006c0:	a021                	j	8006c8 <strnlen+0x12>
  8006c2:	00074703          	lbu	a4,0(a4)
  8006c6:	c711                	beqz	a4,8006d2 <strnlen+0x1c>
  8006c8:	0785                	addi	a5,a5,1
  8006ca:	00f50733          	add	a4,a0,a5
  8006ce:	fef59ae3          	bne	a1,a5,8006c2 <strnlen+0xc>
  8006d2:	853e                	mv	a0,a5
  8006d4:	8082                	ret
  8006d6:	4781                	li	a5,0
  8006d8:	853e                	mv	a0,a5
  8006da:	8082                	ret

00000000008006dc <main>:
  8006dc:	1101                	addi	sp,sp,-32
  8006de:	00000517          	auipc	a0,0x0
  8006e2:	60a50513          	addi	a0,a0,1546 # 800ce8 <error_string+0x2d8>
  8006e6:	ec06                	sd	ra,24(sp)
  8006e8:	e822                	sd	s0,16(sp)
  8006ea:	a0fff0ef          	jal	ra,8000f8 <cprintf>
  8006ee:	adbff0ef          	jal	ra,8001c8 <fork>
  8006f2:	c569                	beqz	a0,8007bc <main+0xe0>
  8006f4:	842a                	mv	s0,a0
  8006f6:	85aa                	mv	a1,a0
  8006f8:	00000517          	auipc	a0,0x0
  8006fc:	63050513          	addi	a0,a0,1584 # 800d28 <error_string+0x318>
  800700:	9f9ff0ef          	jal	ra,8000f8 <cprintf>
  800704:	08805d63          	blez	s0,80079e <main+0xc2>
  800708:	00000517          	auipc	a0,0x0
  80070c:	67850513          	addi	a0,a0,1656 # 800d80 <error_string+0x370>
  800710:	9e9ff0ef          	jal	ra,8000f8 <cprintf>
  800714:	006c                	addi	a1,sp,12
  800716:	8522                	mv	a0,s0
  800718:	abdff0ef          	jal	ra,8001d4 <waitpid>
  80071c:	e139                	bnez	a0,800762 <main+0x86>
  80071e:	00001797          	auipc	a5,0x1
  800722:	8e278793          	addi	a5,a5,-1822 # 801000 <magic>
  800726:	4732                	lw	a4,12(sp)
  800728:	439c                	lw	a5,0(a5)
  80072a:	02f71c63          	bne	a4,a5,800762 <main+0x86>
  80072e:	006c                	addi	a1,sp,12
  800730:	8522                	mv	a0,s0
  800732:	aa3ff0ef          	jal	ra,8001d4 <waitpid>
  800736:	c529                	beqz	a0,800780 <main+0xa4>
  800738:	a95ff0ef          	jal	ra,8001cc <wait>
  80073c:	c131                	beqz	a0,800780 <main+0xa4>
  80073e:	85a2                	mv	a1,s0
  800740:	00000517          	auipc	a0,0x0
  800744:	6b850513          	addi	a0,a0,1720 # 800df8 <error_string+0x3e8>
  800748:	9b1ff0ef          	jal	ra,8000f8 <cprintf>
  80074c:	00000517          	auipc	a0,0x0
  800750:	6bc50513          	addi	a0,a0,1724 # 800e08 <error_string+0x3f8>
  800754:	9a5ff0ef          	jal	ra,8000f8 <cprintf>
  800758:	60e2                	ld	ra,24(sp)
  80075a:	6442                	ld	s0,16(sp)
  80075c:	4501                	li	a0,0
  80075e:	6105                	addi	sp,sp,32
  800760:	8082                	ret
  800762:	00000697          	auipc	a3,0x0
  800766:	63e68693          	addi	a3,a3,1598 # 800da0 <error_string+0x390>
  80076a:	00000617          	auipc	a2,0x0
  80076e:	5ee60613          	addi	a2,a2,1518 # 800d58 <error_string+0x348>
  800772:	45ed                	li	a1,27
  800774:	00000517          	auipc	a0,0x0
  800778:	5fc50513          	addi	a0,a0,1532 # 800d70 <error_string+0x360>
  80077c:	8bbff0ef          	jal	ra,800036 <__panic>
  800780:	00000697          	auipc	a3,0x0
  800784:	65068693          	addi	a3,a3,1616 # 800dd0 <error_string+0x3c0>
  800788:	00000617          	auipc	a2,0x0
  80078c:	5d060613          	addi	a2,a2,1488 # 800d58 <error_string+0x348>
  800790:	45f1                	li	a1,28
  800792:	00000517          	auipc	a0,0x0
  800796:	5de50513          	addi	a0,a0,1502 # 800d70 <error_string+0x360>
  80079a:	89dff0ef          	jal	ra,800036 <__panic>
  80079e:	00000697          	auipc	a3,0x0
  8007a2:	5b268693          	addi	a3,a3,1458 # 800d50 <error_string+0x340>
  8007a6:	00000617          	auipc	a2,0x0
  8007aa:	5b260613          	addi	a2,a2,1458 # 800d58 <error_string+0x348>
  8007ae:	45e1                	li	a1,24
  8007b0:	00000517          	auipc	a0,0x0
  8007b4:	5c050513          	addi	a0,a0,1472 # 800d70 <error_string+0x360>
  8007b8:	87fff0ef          	jal	ra,800036 <__panic>
  8007bc:	00000517          	auipc	a0,0x0
  8007c0:	55450513          	addi	a0,a0,1364 # 800d10 <error_string+0x300>
  8007c4:	935ff0ef          	jal	ra,8000f8 <cprintf>
  8007c8:	a11ff0ef          	jal	ra,8001d8 <yield>
  8007cc:	a0dff0ef          	jal	ra,8001d8 <yield>
  8007d0:	a09ff0ef          	jal	ra,8001d8 <yield>
  8007d4:	a05ff0ef          	jal	ra,8001d8 <yield>
  8007d8:	a01ff0ef          	jal	ra,8001d8 <yield>
  8007dc:	9fdff0ef          	jal	ra,8001d8 <yield>
  8007e0:	9f9ff0ef          	jal	ra,8001d8 <yield>
  8007e4:	00001797          	auipc	a5,0x1
  8007e8:	81c78793          	addi	a5,a5,-2020 # 801000 <magic>
  8007ec:	4388                	lw	a0,0(a5)
  8007ee:	9c5ff0ef          	jal	ra,8001b2 <exit>
