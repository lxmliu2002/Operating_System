
obj/__user_matrix.out：     文件格式 elf64-littleriscv


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
  800030:	202000ef          	jal	ra,800232 <umain>
  800034:	a001                	j	800034 <_start+0x4>

0000000000800036 <__panic>:
  800036:	715d                	addi	sp,sp,-80
  800038:	e822                	sd	s0,16(sp)
  80003a:	fc3e                	sd	a5,56(sp)
  80003c:	8432                	mv	s0,a2
  80003e:	103c                	addi	a5,sp,40
  800040:	862e                	mv	a2,a1
  800042:	85aa                	mv	a1,a0
  800044:	00001517          	auipc	a0,0x1
  800048:	8f450513          	addi	a0,a0,-1804 # 800938 <main+0xce>
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
  800068:	94c50513          	addi	a0,a0,-1716 # 8009b0 <main+0x146>
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
  800084:	00001517          	auipc	a0,0x1
  800088:	8d450513          	addi	a0,a0,-1836 # 800958 <main+0xee>
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
  8000a8:	90c50513          	addi	a0,a0,-1780 # 8009b0 <main+0x146>
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
  8000e4:	ad958593          	addi	a1,a1,-1319 # ffffffffffff6ad9 <matc+0xffffffffff7f57b1>
  8000e8:	ec06                	sd	ra,24(sp)
  8000ea:	c602                	sw	zero,12(sp)
  8000ec:	230000ef          	jal	ra,80031c <vprintfmt>
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
  800116:	ad958593          	addi	a1,a1,-1319 # ffffffffffff6ad9 <matc+0xffffffffff7f57b1>
  80011a:	ec06                	sd	ra,24(sp)
  80011c:	e4be                	sd	a5,72(sp)
  80011e:	e8c2                	sd	a6,80(sp)
  800120:	ecc6                	sd	a7,88(sp)
  800122:	e41a                	sd	t1,8(sp)
  800124:	c202                	sw	zero,4(sp)
  800126:	1f6000ef          	jal	ra,80031c <vprintfmt>
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
  8001cc:	7b050513          	addi	a0,a0,1968 # 800978 <main+0x10e>
  8001d0:	f29ff0ef          	jal	ra,8000f8 <cprintf>
  8001d4:	a001                	j	8001d4 <exit+0x14>

00000000008001d6 <fork>:
  8001d6:	f9dff06f          	j	800172 <sys_fork>

00000000008001da <wait>:
  8001da:	4581                	li	a1,0
  8001dc:	4501                	li	a0,0
  8001de:	f9bff06f          	j	800178 <sys_wait>

00000000008001e2 <yield>:
  8001e2:	fa1ff06f          	j	800182 <sys_yield>

00000000008001e6 <kill>:
  8001e6:	fa3ff06f          	j	800188 <sys_kill>

00000000008001ea <getpid>:
  8001ea:	fa7ff06f          	j	800190 <sys_getpid>

00000000008001ee <initfd>:
  8001ee:	1101                	addi	sp,sp,-32
  8001f0:	87ae                	mv	a5,a1
  8001f2:	e426                	sd	s1,8(sp)
  8001f4:	85b2                	mv	a1,a2
  8001f6:	84aa                	mv	s1,a0
  8001f8:	853e                	mv	a0,a5
  8001fa:	e822                	sd	s0,16(sp)
  8001fc:	ec06                	sd	ra,24(sp)
  8001fe:	e23ff0ef          	jal	ra,800020 <open>
  800202:	842a                	mv	s0,a0
  800204:	00054463          	bltz	a0,80020c <initfd+0x1e>
  800208:	00951863          	bne	a0,s1,800218 <initfd+0x2a>
  80020c:	8522                	mv	a0,s0
  80020e:	60e2                	ld	ra,24(sp)
  800210:	6442                	ld	s0,16(sp)
  800212:	64a2                	ld	s1,8(sp)
  800214:	6105                	addi	sp,sp,32
  800216:	8082                	ret
  800218:	8526                	mv	a0,s1
  80021a:	e0fff0ef          	jal	ra,800028 <close>
  80021e:	85a6                	mv	a1,s1
  800220:	8522                	mv	a0,s0
  800222:	e0bff0ef          	jal	ra,80002c <dup2>
  800226:	84aa                	mv	s1,a0
  800228:	8522                	mv	a0,s0
  80022a:	dffff0ef          	jal	ra,800028 <close>
  80022e:	8426                	mv	s0,s1
  800230:	bff1                	j	80020c <initfd+0x1e>

0000000000800232 <umain>:
  800232:	1101                	addi	sp,sp,-32
  800234:	e822                	sd	s0,16(sp)
  800236:	e426                	sd	s1,8(sp)
  800238:	842a                	mv	s0,a0
  80023a:	84ae                	mv	s1,a1
  80023c:	4601                	li	a2,0
  80023e:	00000597          	auipc	a1,0x0
  800242:	75258593          	addi	a1,a1,1874 # 800990 <main+0x126>
  800246:	4501                	li	a0,0
  800248:	ec06                	sd	ra,24(sp)
  80024a:	fa5ff0ef          	jal	ra,8001ee <initfd>
  80024e:	02054263          	bltz	a0,800272 <umain+0x40>
  800252:	4605                	li	a2,1
  800254:	00000597          	auipc	a1,0x0
  800258:	77c58593          	addi	a1,a1,1916 # 8009d0 <main+0x166>
  80025c:	4505                	li	a0,1
  80025e:	f91ff0ef          	jal	ra,8001ee <initfd>
  800262:	02054563          	bltz	a0,80028c <umain+0x5a>
  800266:	85a6                	mv	a1,s1
  800268:	8522                	mv	a0,s0
  80026a:	600000ef          	jal	ra,80086a <main>
  80026e:	f53ff0ef          	jal	ra,8001c0 <exit>
  800272:	86aa                	mv	a3,a0
  800274:	00000617          	auipc	a2,0x0
  800278:	72460613          	addi	a2,a2,1828 # 800998 <main+0x12e>
  80027c:	45e9                	li	a1,26
  80027e:	00000517          	auipc	a0,0x0
  800282:	73a50513          	addi	a0,a0,1850 # 8009b8 <main+0x14e>
  800286:	df1ff0ef          	jal	ra,800076 <__warn>
  80028a:	b7e1                	j	800252 <umain+0x20>
  80028c:	86aa                	mv	a3,a0
  80028e:	00000617          	auipc	a2,0x0
  800292:	74a60613          	addi	a2,a2,1866 # 8009d8 <main+0x16e>
  800296:	45f5                	li	a1,29
  800298:	00000517          	auipc	a0,0x0
  80029c:	72050513          	addi	a0,a0,1824 # 8009b8 <main+0x14e>
  8002a0:	dd7ff0ef          	jal	ra,800076 <__warn>
  8002a4:	b7c9                	j	800266 <umain+0x34>

00000000008002a6 <printnum>:
  8002a6:	02071893          	slli	a7,a4,0x20
  8002aa:	7139                	addi	sp,sp,-64
  8002ac:	0208d893          	srli	a7,a7,0x20
  8002b0:	e456                	sd	s5,8(sp)
  8002b2:	0316fab3          	remu	s5,a3,a7
  8002b6:	f822                	sd	s0,48(sp)
  8002b8:	f426                	sd	s1,40(sp)
  8002ba:	f04a                	sd	s2,32(sp)
  8002bc:	ec4e                	sd	s3,24(sp)
  8002be:	fc06                	sd	ra,56(sp)
  8002c0:	e852                	sd	s4,16(sp)
  8002c2:	84aa                	mv	s1,a0
  8002c4:	89ae                	mv	s3,a1
  8002c6:	8932                	mv	s2,a2
  8002c8:	fff7841b          	addiw	s0,a5,-1
  8002cc:	2a81                	sext.w	s5,s5
  8002ce:	0516f163          	bleu	a7,a3,800310 <printnum+0x6a>
  8002d2:	8a42                	mv	s4,a6
  8002d4:	00805863          	blez	s0,8002e4 <printnum+0x3e>
  8002d8:	347d                	addiw	s0,s0,-1
  8002da:	864e                	mv	a2,s3
  8002dc:	85ca                	mv	a1,s2
  8002de:	8552                	mv	a0,s4
  8002e0:	9482                	jalr	s1
  8002e2:	f87d                	bnez	s0,8002d8 <printnum+0x32>
  8002e4:	1a82                	slli	s5,s5,0x20
  8002e6:	020ada93          	srli	s5,s5,0x20
  8002ea:	00001797          	auipc	a5,0x1
  8002ee:	92e78793          	addi	a5,a5,-1746 # 800c18 <error_string+0xc8>
  8002f2:	9abe                	add	s5,s5,a5
  8002f4:	7442                	ld	s0,48(sp)
  8002f6:	000ac503          	lbu	a0,0(s5)
  8002fa:	70e2                	ld	ra,56(sp)
  8002fc:	6a42                	ld	s4,16(sp)
  8002fe:	6aa2                	ld	s5,8(sp)
  800300:	864e                	mv	a2,s3
  800302:	85ca                	mv	a1,s2
  800304:	69e2                	ld	s3,24(sp)
  800306:	7902                	ld	s2,32(sp)
  800308:	8326                	mv	t1,s1
  80030a:	74a2                	ld	s1,40(sp)
  80030c:	6121                	addi	sp,sp,64
  80030e:	8302                	jr	t1
  800310:	0316d6b3          	divu	a3,a3,a7
  800314:	87a2                	mv	a5,s0
  800316:	f91ff0ef          	jal	ra,8002a6 <printnum>
  80031a:	b7e9                	j	8002e4 <printnum+0x3e>

000000000080031c <vprintfmt>:
  80031c:	7119                	addi	sp,sp,-128
  80031e:	f4a6                	sd	s1,104(sp)
  800320:	f0ca                	sd	s2,96(sp)
  800322:	ecce                	sd	s3,88(sp)
  800324:	e4d6                	sd	s5,72(sp)
  800326:	e0da                	sd	s6,64(sp)
  800328:	fc5e                	sd	s7,56(sp)
  80032a:	f862                	sd	s8,48(sp)
  80032c:	ec6e                	sd	s11,24(sp)
  80032e:	fc86                	sd	ra,120(sp)
  800330:	f8a2                	sd	s0,112(sp)
  800332:	e8d2                	sd	s4,80(sp)
  800334:	f466                	sd	s9,40(sp)
  800336:	f06a                	sd	s10,32(sp)
  800338:	89aa                	mv	s3,a0
  80033a:	892e                	mv	s2,a1
  80033c:	84b2                	mv	s1,a2
  80033e:	8db6                	mv	s11,a3
  800340:	8b3a                	mv	s6,a4
  800342:	5bfd                	li	s7,-1
  800344:	00000a97          	auipc	s5,0x0
  800348:	6b0a8a93          	addi	s5,s5,1712 # 8009f4 <main+0x18a>
  80034c:	05e00c13          	li	s8,94
  800350:	000dc503          	lbu	a0,0(s11)
  800354:	02500793          	li	a5,37
  800358:	001d8413          	addi	s0,s11,1
  80035c:	00f50f63          	beq	a0,a5,80037a <vprintfmt+0x5e>
  800360:	c529                	beqz	a0,8003aa <vprintfmt+0x8e>
  800362:	02500a13          	li	s4,37
  800366:	a011                	j	80036a <vprintfmt+0x4e>
  800368:	c129                	beqz	a0,8003aa <vprintfmt+0x8e>
  80036a:	864a                	mv	a2,s2
  80036c:	85a6                	mv	a1,s1
  80036e:	0405                	addi	s0,s0,1
  800370:	9982                	jalr	s3
  800372:	fff44503          	lbu	a0,-1(s0)
  800376:	ff4519e3          	bne	a0,s4,800368 <vprintfmt+0x4c>
  80037a:	00044603          	lbu	a2,0(s0)
  80037e:	02000813          	li	a6,32
  800382:	4a01                	li	s4,0
  800384:	4881                	li	a7,0
  800386:	5d7d                	li	s10,-1
  800388:	5cfd                	li	s9,-1
  80038a:	05500593          	li	a1,85
  80038e:	4525                	li	a0,9
  800390:	fdd6071b          	addiw	a4,a2,-35
  800394:	0ff77713          	andi	a4,a4,255
  800398:	00140d93          	addi	s11,s0,1
  80039c:	22e5e363          	bltu	a1,a4,8005c2 <vprintfmt+0x2a6>
  8003a0:	070a                	slli	a4,a4,0x2
  8003a2:	9756                	add	a4,a4,s5
  8003a4:	4318                	lw	a4,0(a4)
  8003a6:	9756                	add	a4,a4,s5
  8003a8:	8702                	jr	a4
  8003aa:	70e6                	ld	ra,120(sp)
  8003ac:	7446                	ld	s0,112(sp)
  8003ae:	74a6                	ld	s1,104(sp)
  8003b0:	7906                	ld	s2,96(sp)
  8003b2:	69e6                	ld	s3,88(sp)
  8003b4:	6a46                	ld	s4,80(sp)
  8003b6:	6aa6                	ld	s5,72(sp)
  8003b8:	6b06                	ld	s6,64(sp)
  8003ba:	7be2                	ld	s7,56(sp)
  8003bc:	7c42                	ld	s8,48(sp)
  8003be:	7ca2                	ld	s9,40(sp)
  8003c0:	7d02                	ld	s10,32(sp)
  8003c2:	6de2                	ld	s11,24(sp)
  8003c4:	6109                	addi	sp,sp,128
  8003c6:	8082                	ret
  8003c8:	4705                	li	a4,1
  8003ca:	008b0613          	addi	a2,s6,8
  8003ce:	01174463          	blt	a4,a7,8003d6 <vprintfmt+0xba>
  8003d2:	28088563          	beqz	a7,80065c <vprintfmt+0x340>
  8003d6:	000b3683          	ld	a3,0(s6)
  8003da:	4741                	li	a4,16
  8003dc:	8b32                	mv	s6,a2
  8003de:	a86d                	j	800498 <vprintfmt+0x17c>
  8003e0:	00144603          	lbu	a2,1(s0)
  8003e4:	4a05                	li	s4,1
  8003e6:	846e                	mv	s0,s11
  8003e8:	b765                	j	800390 <vprintfmt+0x74>
  8003ea:	000b2503          	lw	a0,0(s6)
  8003ee:	864a                	mv	a2,s2
  8003f0:	85a6                	mv	a1,s1
  8003f2:	0b21                	addi	s6,s6,8
  8003f4:	9982                	jalr	s3
  8003f6:	bfa9                	j	800350 <vprintfmt+0x34>
  8003f8:	4705                	li	a4,1
  8003fa:	008b0a13          	addi	s4,s6,8
  8003fe:	01174463          	blt	a4,a7,800406 <vprintfmt+0xea>
  800402:	24088563          	beqz	a7,80064c <vprintfmt+0x330>
  800406:	000b3403          	ld	s0,0(s6)
  80040a:	26044563          	bltz	s0,800674 <vprintfmt+0x358>
  80040e:	86a2                	mv	a3,s0
  800410:	8b52                	mv	s6,s4
  800412:	4729                	li	a4,10
  800414:	a051                	j	800498 <vprintfmt+0x17c>
  800416:	000b2783          	lw	a5,0(s6)
  80041a:	46e1                	li	a3,24
  80041c:	0b21                	addi	s6,s6,8
  80041e:	41f7d71b          	sraiw	a4,a5,0x1f
  800422:	8fb9                	xor	a5,a5,a4
  800424:	40e7873b          	subw	a4,a5,a4
  800428:	1ce6c163          	blt	a3,a4,8005ea <vprintfmt+0x2ce>
  80042c:	00371793          	slli	a5,a4,0x3
  800430:	00000697          	auipc	a3,0x0
  800434:	72068693          	addi	a3,a3,1824 # 800b50 <error_string>
  800438:	97b6                	add	a5,a5,a3
  80043a:	639c                	ld	a5,0(a5)
  80043c:	1a078763          	beqz	a5,8005ea <vprintfmt+0x2ce>
  800440:	873e                	mv	a4,a5
  800442:	00001697          	auipc	a3,0x1
  800446:	9de68693          	addi	a3,a3,-1570 # 800e20 <error_string+0x2d0>
  80044a:	8626                	mv	a2,s1
  80044c:	85ca                	mv	a1,s2
  80044e:	854e                	mv	a0,s3
  800450:	25a000ef          	jal	ra,8006aa <printfmt>
  800454:	bdf5                	j	800350 <vprintfmt+0x34>
  800456:	00144603          	lbu	a2,1(s0)
  80045a:	2885                	addiw	a7,a7,1
  80045c:	846e                	mv	s0,s11
  80045e:	bf0d                	j	800390 <vprintfmt+0x74>
  800460:	4705                	li	a4,1
  800462:	008b0613          	addi	a2,s6,8
  800466:	01174463          	blt	a4,a7,80046e <vprintfmt+0x152>
  80046a:	1e088e63          	beqz	a7,800666 <vprintfmt+0x34a>
  80046e:	000b3683          	ld	a3,0(s6)
  800472:	4721                	li	a4,8
  800474:	8b32                	mv	s6,a2
  800476:	a00d                	j	800498 <vprintfmt+0x17c>
  800478:	03000513          	li	a0,48
  80047c:	864a                	mv	a2,s2
  80047e:	85a6                	mv	a1,s1
  800480:	e042                	sd	a6,0(sp)
  800482:	9982                	jalr	s3
  800484:	864a                	mv	a2,s2
  800486:	85a6                	mv	a1,s1
  800488:	07800513          	li	a0,120
  80048c:	9982                	jalr	s3
  80048e:	0b21                	addi	s6,s6,8
  800490:	ff8b3683          	ld	a3,-8(s6)
  800494:	6802                	ld	a6,0(sp)
  800496:	4741                	li	a4,16
  800498:	87e6                	mv	a5,s9
  80049a:	8626                	mv	a2,s1
  80049c:	85ca                	mv	a1,s2
  80049e:	854e                	mv	a0,s3
  8004a0:	e07ff0ef          	jal	ra,8002a6 <printnum>
  8004a4:	b575                	j	800350 <vprintfmt+0x34>
  8004a6:	000b3703          	ld	a4,0(s6)
  8004aa:	0b21                	addi	s6,s6,8
  8004ac:	1e070063          	beqz	a4,80068c <vprintfmt+0x370>
  8004b0:	00170413          	addi	s0,a4,1
  8004b4:	19905563          	blez	s9,80063e <vprintfmt+0x322>
  8004b8:	02d00613          	li	a2,45
  8004bc:	14c81963          	bne	a6,a2,80060e <vprintfmt+0x2f2>
  8004c0:	00074703          	lbu	a4,0(a4)
  8004c4:	0007051b          	sext.w	a0,a4
  8004c8:	c90d                	beqz	a0,8004fa <vprintfmt+0x1de>
  8004ca:	000d4563          	bltz	s10,8004d4 <vprintfmt+0x1b8>
  8004ce:	3d7d                	addiw	s10,s10,-1
  8004d0:	037d0363          	beq	s10,s7,8004f6 <vprintfmt+0x1da>
  8004d4:	864a                	mv	a2,s2
  8004d6:	85a6                	mv	a1,s1
  8004d8:	180a0c63          	beqz	s4,800670 <vprintfmt+0x354>
  8004dc:	3701                	addiw	a4,a4,-32
  8004de:	18ec7963          	bleu	a4,s8,800670 <vprintfmt+0x354>
  8004e2:	03f00513          	li	a0,63
  8004e6:	9982                	jalr	s3
  8004e8:	0405                	addi	s0,s0,1
  8004ea:	fff44703          	lbu	a4,-1(s0)
  8004ee:	3cfd                	addiw	s9,s9,-1
  8004f0:	0007051b          	sext.w	a0,a4
  8004f4:	f979                	bnez	a0,8004ca <vprintfmt+0x1ae>
  8004f6:	e5905de3          	blez	s9,800350 <vprintfmt+0x34>
  8004fa:	3cfd                	addiw	s9,s9,-1
  8004fc:	864a                	mv	a2,s2
  8004fe:	85a6                	mv	a1,s1
  800500:	02000513          	li	a0,32
  800504:	9982                	jalr	s3
  800506:	e40c85e3          	beqz	s9,800350 <vprintfmt+0x34>
  80050a:	3cfd                	addiw	s9,s9,-1
  80050c:	864a                	mv	a2,s2
  80050e:	85a6                	mv	a1,s1
  800510:	02000513          	li	a0,32
  800514:	9982                	jalr	s3
  800516:	fe0c92e3          	bnez	s9,8004fa <vprintfmt+0x1de>
  80051a:	bd1d                	j	800350 <vprintfmt+0x34>
  80051c:	4705                	li	a4,1
  80051e:	008b0613          	addi	a2,s6,8
  800522:	01174463          	blt	a4,a7,80052a <vprintfmt+0x20e>
  800526:	12088663          	beqz	a7,800652 <vprintfmt+0x336>
  80052a:	000b3683          	ld	a3,0(s6)
  80052e:	4729                	li	a4,10
  800530:	8b32                	mv	s6,a2
  800532:	b79d                	j	800498 <vprintfmt+0x17c>
  800534:	00144603          	lbu	a2,1(s0)
  800538:	02d00813          	li	a6,45
  80053c:	846e                	mv	s0,s11
  80053e:	bd89                	j	800390 <vprintfmt+0x74>
  800540:	864a                	mv	a2,s2
  800542:	85a6                	mv	a1,s1
  800544:	02500513          	li	a0,37
  800548:	9982                	jalr	s3
  80054a:	b519                	j	800350 <vprintfmt+0x34>
  80054c:	000b2d03          	lw	s10,0(s6)
  800550:	00144603          	lbu	a2,1(s0)
  800554:	0b21                	addi	s6,s6,8
  800556:	846e                	mv	s0,s11
  800558:	e20cdce3          	bgez	s9,800390 <vprintfmt+0x74>
  80055c:	8cea                	mv	s9,s10
  80055e:	5d7d                	li	s10,-1
  800560:	bd05                	j	800390 <vprintfmt+0x74>
  800562:	00144603          	lbu	a2,1(s0)
  800566:	03000813          	li	a6,48
  80056a:	846e                	mv	s0,s11
  80056c:	b515                	j	800390 <vprintfmt+0x74>
  80056e:	fd060d1b          	addiw	s10,a2,-48
  800572:	00144603          	lbu	a2,1(s0)
  800576:	846e                	mv	s0,s11
  800578:	fd06071b          	addiw	a4,a2,-48
  80057c:	0006031b          	sext.w	t1,a2
  800580:	fce56ce3          	bltu	a0,a4,800558 <vprintfmt+0x23c>
  800584:	0405                	addi	s0,s0,1
  800586:	002d171b          	slliw	a4,s10,0x2
  80058a:	00044603          	lbu	a2,0(s0)
  80058e:	01a706bb          	addw	a3,a4,s10
  800592:	0016969b          	slliw	a3,a3,0x1
  800596:	006686bb          	addw	a3,a3,t1
  80059a:	fd06071b          	addiw	a4,a2,-48
  80059e:	fd068d1b          	addiw	s10,a3,-48
  8005a2:	0006031b          	sext.w	t1,a2
  8005a6:	fce57fe3          	bleu	a4,a0,800584 <vprintfmt+0x268>
  8005aa:	b77d                	j	800558 <vprintfmt+0x23c>
  8005ac:	fffcc713          	not	a4,s9
  8005b0:	977d                	srai	a4,a4,0x3f
  8005b2:	00ecf7b3          	and	a5,s9,a4
  8005b6:	00144603          	lbu	a2,1(s0)
  8005ba:	00078c9b          	sext.w	s9,a5
  8005be:	846e                	mv	s0,s11
  8005c0:	bbc1                	j	800390 <vprintfmt+0x74>
  8005c2:	864a                	mv	a2,s2
  8005c4:	85a6                	mv	a1,s1
  8005c6:	02500513          	li	a0,37
  8005ca:	9982                	jalr	s3
  8005cc:	fff44703          	lbu	a4,-1(s0)
  8005d0:	02500793          	li	a5,37
  8005d4:	8da2                	mv	s11,s0
  8005d6:	d6f70de3          	beq	a4,a5,800350 <vprintfmt+0x34>
  8005da:	02500713          	li	a4,37
  8005de:	1dfd                	addi	s11,s11,-1
  8005e0:	fffdc783          	lbu	a5,-1(s11)
  8005e4:	fee79de3          	bne	a5,a4,8005de <vprintfmt+0x2c2>
  8005e8:	b3a5                	j	800350 <vprintfmt+0x34>
  8005ea:	00001697          	auipc	a3,0x1
  8005ee:	82668693          	addi	a3,a3,-2010 # 800e10 <error_string+0x2c0>
  8005f2:	8626                	mv	a2,s1
  8005f4:	85ca                	mv	a1,s2
  8005f6:	854e                	mv	a0,s3
  8005f8:	0b2000ef          	jal	ra,8006aa <printfmt>
  8005fc:	bb91                	j	800350 <vprintfmt+0x34>
  8005fe:	00001717          	auipc	a4,0x1
  800602:	80a70713          	addi	a4,a4,-2038 # 800e08 <error_string+0x2b8>
  800606:	00001417          	auipc	s0,0x1
  80060a:	80340413          	addi	s0,s0,-2045 # 800e09 <error_string+0x2b9>
  80060e:	853a                	mv	a0,a4
  800610:	85ea                	mv	a1,s10
  800612:	e03a                	sd	a4,0(sp)
  800614:	e442                	sd	a6,8(sp)
  800616:	0f6000ef          	jal	ra,80070c <strnlen>
  80061a:	40ac8cbb          	subw	s9,s9,a0
  80061e:	6702                	ld	a4,0(sp)
  800620:	01905f63          	blez	s9,80063e <vprintfmt+0x322>
  800624:	6822                	ld	a6,8(sp)
  800626:	0008079b          	sext.w	a5,a6
  80062a:	e43e                	sd	a5,8(sp)
  80062c:	6522                	ld	a0,8(sp)
  80062e:	864a                	mv	a2,s2
  800630:	85a6                	mv	a1,s1
  800632:	e03a                	sd	a4,0(sp)
  800634:	3cfd                	addiw	s9,s9,-1
  800636:	9982                	jalr	s3
  800638:	6702                	ld	a4,0(sp)
  80063a:	fe0c99e3          	bnez	s9,80062c <vprintfmt+0x310>
  80063e:	00074703          	lbu	a4,0(a4)
  800642:	0007051b          	sext.w	a0,a4
  800646:	e80512e3          	bnez	a0,8004ca <vprintfmt+0x1ae>
  80064a:	b319                	j	800350 <vprintfmt+0x34>
  80064c:	000b2403          	lw	s0,0(s6)
  800650:	bb6d                	j	80040a <vprintfmt+0xee>
  800652:	000b6683          	lwu	a3,0(s6)
  800656:	4729                	li	a4,10
  800658:	8b32                	mv	s6,a2
  80065a:	bd3d                	j	800498 <vprintfmt+0x17c>
  80065c:	000b6683          	lwu	a3,0(s6)
  800660:	4741                	li	a4,16
  800662:	8b32                	mv	s6,a2
  800664:	bd15                	j	800498 <vprintfmt+0x17c>
  800666:	000b6683          	lwu	a3,0(s6)
  80066a:	4721                	li	a4,8
  80066c:	8b32                	mv	s6,a2
  80066e:	b52d                	j	800498 <vprintfmt+0x17c>
  800670:	9982                	jalr	s3
  800672:	bd9d                	j	8004e8 <vprintfmt+0x1cc>
  800674:	864a                	mv	a2,s2
  800676:	85a6                	mv	a1,s1
  800678:	02d00513          	li	a0,45
  80067c:	e042                	sd	a6,0(sp)
  80067e:	9982                	jalr	s3
  800680:	8b52                	mv	s6,s4
  800682:	408006b3          	neg	a3,s0
  800686:	4729                	li	a4,10
  800688:	6802                	ld	a6,0(sp)
  80068a:	b539                	j	800498 <vprintfmt+0x17c>
  80068c:	01905663          	blez	s9,800698 <vprintfmt+0x37c>
  800690:	02d00713          	li	a4,45
  800694:	f6e815e3          	bne	a6,a4,8005fe <vprintfmt+0x2e2>
  800698:	00000417          	auipc	s0,0x0
  80069c:	77140413          	addi	s0,s0,1905 # 800e09 <error_string+0x2b9>
  8006a0:	02800513          	li	a0,40
  8006a4:	02800713          	li	a4,40
  8006a8:	b50d                	j	8004ca <vprintfmt+0x1ae>

00000000008006aa <printfmt>:
  8006aa:	7139                	addi	sp,sp,-64
  8006ac:	02010313          	addi	t1,sp,32
  8006b0:	f03a                	sd	a4,32(sp)
  8006b2:	871a                	mv	a4,t1
  8006b4:	ec06                	sd	ra,24(sp)
  8006b6:	f43e                	sd	a5,40(sp)
  8006b8:	f842                	sd	a6,48(sp)
  8006ba:	fc46                	sd	a7,56(sp)
  8006bc:	e41a                	sd	t1,8(sp)
  8006be:	c5fff0ef          	jal	ra,80031c <vprintfmt>
  8006c2:	60e2                	ld	ra,24(sp)
  8006c4:	6121                	addi	sp,sp,64
  8006c6:	8082                	ret

00000000008006c8 <rand>:
  8006c8:	00001697          	auipc	a3,0x1
  8006cc:	93868693          	addi	a3,a3,-1736 # 801000 <next>
  8006d0:	00000717          	auipc	a4,0x0
  8006d4:	75870713          	addi	a4,a4,1880 # 800e28 <error_string+0x2d8>
  8006d8:	629c                	ld	a5,0(a3)
  8006da:	6318                	ld	a4,0(a4)
  8006dc:	02e787b3          	mul	a5,a5,a4
  8006e0:	577d                	li	a4,-1
  8006e2:	8341                	srli	a4,a4,0x10
  8006e4:	07ad                	addi	a5,a5,11
  8006e6:	8ff9                	and	a5,a5,a4
  8006e8:	80000737          	lui	a4,0x80000
  8006ec:	00c7d513          	srli	a0,a5,0xc
  8006f0:	fff74713          	not	a4,a4
  8006f4:	02e57533          	remu	a0,a0,a4
  8006f8:	e29c                	sd	a5,0(a3)
  8006fa:	2505                	addiw	a0,a0,1
  8006fc:	8082                	ret

00000000008006fe <srand>:
  8006fe:	1502                	slli	a0,a0,0x20
  800700:	9101                	srli	a0,a0,0x20
  800702:	00001797          	auipc	a5,0x1
  800706:	8ea7bf23          	sd	a0,-1794(a5) # 801000 <next>
  80070a:	8082                	ret

000000000080070c <strnlen>:
  80070c:	c185                	beqz	a1,80072c <strnlen+0x20>
  80070e:	00054783          	lbu	a5,0(a0)
  800712:	cf89                	beqz	a5,80072c <strnlen+0x20>
  800714:	4781                	li	a5,0
  800716:	a021                	j	80071e <strnlen+0x12>
  800718:	00074703          	lbu	a4,0(a4) # ffffffff80000000 <matc+0xffffffff7f7fecd8>
  80071c:	c711                	beqz	a4,800728 <strnlen+0x1c>
  80071e:	0785                	addi	a5,a5,1
  800720:	00f50733          	add	a4,a0,a5
  800724:	fef59ae3          	bne	a1,a5,800718 <strnlen+0xc>
  800728:	853e                	mv	a0,a5
  80072a:	8082                	ret
  80072c:	4781                	li	a5,0
  80072e:	853e                	mv	a0,a5
  800730:	8082                	ret

0000000000800732 <memset>:
  800732:	ca01                	beqz	a2,800742 <memset+0x10>
  800734:	962a                	add	a2,a2,a0
  800736:	87aa                	mv	a5,a0
  800738:	0785                	addi	a5,a5,1
  80073a:	feb78fa3          	sb	a1,-1(a5)
  80073e:	fec79de3          	bne	a5,a2,800738 <memset+0x6>
  800742:	8082                	ret

0000000000800744 <work>:
  800744:	7179                	addi	sp,sp,-48
  800746:	e84a                	sd	s2,16(sp)
  800748:	00001597          	auipc	a1,0x1
  80074c:	89858593          	addi	a1,a1,-1896 # 800fe0 <error_string+0x490>
  800750:	00001917          	auipc	s2,0x1
  800754:	a4890913          	addi	s2,s2,-1464 # 801198 <matb>
  800758:	f022                	sd	s0,32(sp)
  80075a:	ec26                	sd	s1,24(sp)
  80075c:	e44e                	sd	s3,8(sp)
  80075e:	f406                	sd	ra,40(sp)
  800760:	84aa                	mv	s1,a0
  800762:	00001617          	auipc	a2,0x1
  800766:	a5e60613          	addi	a2,a2,-1442 # 8011c0 <matb+0x28>
  80076a:	00001417          	auipc	s0,0x1
  80076e:	be640413          	addi	s0,s0,-1050 # 801350 <matc+0x28>
  800772:	00001997          	auipc	s3,0x1
  800776:	89698993          	addi	s3,s3,-1898 # 801008 <mata>
  80077a:	412585b3          	sub	a1,a1,s2
  80077e:	4685                	li	a3,1
  800780:	fd860793          	addi	a5,a2,-40
  800784:	00c58733          	add	a4,a1,a2
  800788:	c394                	sw	a3,0(a5)
  80078a:	c314                	sw	a3,0(a4)
  80078c:	0791                	addi	a5,a5,4
  80078e:	0711                	addi	a4,a4,4
  800790:	fec79ce3          	bne	a5,a2,800788 <work+0x44>
  800794:	02878613          	addi	a2,a5,40
  800798:	fe8614e3          	bne	a2,s0,800780 <work+0x3c>
  80079c:	a47ff0ef          	jal	ra,8001e2 <yield>
  8007a0:	a4bff0ef          	jal	ra,8001ea <getpid>
  8007a4:	8626                	mv	a2,s1
  8007a6:	85aa                	mv	a1,a0
  8007a8:	00000517          	auipc	a0,0x0
  8007ac:	6d850513          	addi	a0,a0,1752 # 800e80 <error_string+0x330>
  8007b0:	949ff0ef          	jal	ra,8000f8 <cprintf>
  8007b4:	53fd                	li	t2,-1
  8007b6:	34fd                	addiw	s1,s1,-1
  8007b8:	00001297          	auipc	t0,0x1
  8007bc:	9e028293          	addi	t0,t0,-1568 # 801198 <matb>
  8007c0:	00001f97          	auipc	t6,0x1
  8007c4:	b68f8f93          	addi	t6,t6,-1176 # 801328 <matc>
  8007c8:	00001f17          	auipc	t5,0x1
  8007cc:	cf0f0f13          	addi	t5,t5,-784 # 8014b8 <matc+0x190>
  8007d0:	02800e13          	li	t3,40
  8007d4:	06748f63          	beq	s1,t2,800852 <work+0x10e>
  8007d8:	00001897          	auipc	a7,0x1
  8007dc:	b5088893          	addi	a7,a7,-1200 # 801328 <matc>
  8007e0:	8ec6                	mv	t4,a7
  8007e2:	834e                	mv	t1,s3
  8007e4:	857e                	mv	a0,t6
  8007e6:	8876                	mv	a6,t4
  8007e8:	e7050793          	addi	a5,a0,-400
  8007ec:	869a                	mv	a3,t1
  8007ee:	4601                	li	a2,0
  8007f0:	4298                	lw	a4,0(a3)
  8007f2:	438c                	lw	a1,0(a5)
  8007f4:	02878793          	addi	a5,a5,40
  8007f8:	0691                	addi	a3,a3,4
  8007fa:	02b7073b          	mulw	a4,a4,a1
  8007fe:	9e39                	addw	a2,a2,a4
  800800:	fea798e3          	bne	a5,a0,8007f0 <work+0xac>
  800804:	00c82023          	sw	a2,0(a6)
  800808:	00478513          	addi	a0,a5,4
  80080c:	0811                	addi	a6,a6,4
  80080e:	fc851de3          	bne	a0,s0,8007e8 <work+0xa4>
  800812:	02830313          	addi	t1,t1,40
  800816:	028e8e93          	addi	t4,t4,40
  80081a:	fc5315e3          	bne	t1,t0,8007e4 <work+0xa0>
  80081e:	854e                	mv	a0,s3
  800820:	85ca                	mv	a1,s2
  800822:	4781                	li	a5,0
  800824:	00f88733          	add	a4,a7,a5
  800828:	4318                	lw	a4,0(a4)
  80082a:	00f58633          	add	a2,a1,a5
  80082e:	00f506b3          	add	a3,a0,a5
  800832:	c218                	sw	a4,0(a2)
  800834:	c298                	sw	a4,0(a3)
  800836:	0791                	addi	a5,a5,4
  800838:	ffc796e3          	bne	a5,t3,800824 <work+0xe0>
  80083c:	02888893          	addi	a7,a7,40
  800840:	02858593          	addi	a1,a1,40
  800844:	02850513          	addi	a0,a0,40
  800848:	fde89de3          	bne	a7,t5,800822 <work+0xde>
  80084c:	34fd                	addiw	s1,s1,-1
  80084e:	f87495e3          	bne	s1,t2,8007d8 <work+0x94>
  800852:	999ff0ef          	jal	ra,8001ea <getpid>
  800856:	85aa                	mv	a1,a0
  800858:	00000517          	auipc	a0,0x0
  80085c:	64850513          	addi	a0,a0,1608 # 800ea0 <error_string+0x350>
  800860:	899ff0ef          	jal	ra,8000f8 <cprintf>
  800864:	4501                	li	a0,0
  800866:	95bff0ef          	jal	ra,8001c0 <exit>

000000000080086a <main>:
  80086a:	7175                	addi	sp,sp,-144
  80086c:	f4ce                	sd	s3,104(sp)
  80086e:	05400613          	li	a2,84
  800872:	4581                	li	a1,0
  800874:	0028                	addi	a0,sp,8
  800876:	00810993          	addi	s3,sp,8
  80087a:	e122                	sd	s0,128(sp)
  80087c:	fca6                	sd	s1,120(sp)
  80087e:	f8ca                	sd	s2,112(sp)
  800880:	e506                	sd	ra,136(sp)
  800882:	84ce                	mv	s1,s3
  800884:	eafff0ef          	jal	ra,800732 <memset>
  800888:	4401                	li	s0,0
  80088a:	4955                	li	s2,21
  80088c:	94bff0ef          	jal	ra,8001d6 <fork>
  800890:	c088                	sw	a0,0(s1)
  800892:	cd2d                	beqz	a0,80090c <main+0xa2>
  800894:	04054663          	bltz	a0,8008e0 <main+0x76>
  800898:	2405                	addiw	s0,s0,1
  80089a:	0491                	addi	s1,s1,4
  80089c:	ff2418e3          	bne	s0,s2,80088c <main+0x22>
  8008a0:	00000517          	auipc	a0,0x0
  8008a4:	59050513          	addi	a0,a0,1424 # 800e30 <error_string+0x2e0>
  8008a8:	851ff0ef          	jal	ra,8000f8 <cprintf>
  8008ac:	4455                	li	s0,21
  8008ae:	92dff0ef          	jal	ra,8001da <wait>
  8008b2:	e10d                	bnez	a0,8008d4 <main+0x6a>
  8008b4:	347d                	addiw	s0,s0,-1
  8008b6:	fc65                	bnez	s0,8008ae <main+0x44>
  8008b8:	00000517          	auipc	a0,0x0
  8008bc:	59850513          	addi	a0,a0,1432 # 800e50 <error_string+0x300>
  8008c0:	839ff0ef          	jal	ra,8000f8 <cprintf>
  8008c4:	60aa                	ld	ra,136(sp)
  8008c6:	640a                	ld	s0,128(sp)
  8008c8:	74e6                	ld	s1,120(sp)
  8008ca:	7946                	ld	s2,112(sp)
  8008cc:	79a6                	ld	s3,104(sp)
  8008ce:	4501                	li	a0,0
  8008d0:	6149                	addi	sp,sp,144
  8008d2:	8082                	ret
  8008d4:	00000517          	auipc	a0,0x0
  8008d8:	56c50513          	addi	a0,a0,1388 # 800e40 <error_string+0x2f0>
  8008dc:	81dff0ef          	jal	ra,8000f8 <cprintf>
  8008e0:	08e0                	addi	s0,sp,92
  8008e2:	0009a503          	lw	a0,0(s3)
  8008e6:	00a05463          	blez	a0,8008ee <main+0x84>
  8008ea:	8fdff0ef          	jal	ra,8001e6 <kill>
  8008ee:	0991                	addi	s3,s3,4
  8008f0:	ff3419e3          	bne	s0,s3,8008e2 <main+0x78>
  8008f4:	00000617          	auipc	a2,0x0
  8008f8:	56c60613          	addi	a2,a2,1388 # 800e60 <error_string+0x310>
  8008fc:	05200593          	li	a1,82
  800900:	00000517          	auipc	a0,0x0
  800904:	57050513          	addi	a0,a0,1392 # 800e70 <error_string+0x320>
  800908:	f2eff0ef          	jal	ra,800036 <__panic>
  80090c:	0284053b          	mulw	a0,s0,s0
  800910:	defff0ef          	jal	ra,8006fe <srand>
  800914:	db5ff0ef          	jal	ra,8006c8 <rand>
  800918:	47d5                	li	a5,21
  80091a:	02f5753b          	remuw	a0,a0,a5
  80091e:	02a5053b          	mulw	a0,a0,a0
  800922:	00a5079b          	addiw	a5,a0,10
  800926:	06400513          	li	a0,100
  80092a:	02f50533          	mul	a0,a0,a5
  80092e:	e17ff0ef          	jal	ra,800744 <work>
