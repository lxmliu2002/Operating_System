
obj/__user_testbss.out：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000000800020 <open>:
  800020:	1582                	slli	a1,a1,0x20
  800022:	9181                	srli	a1,a1,0x20
  800024:	1560006f          	j	80017a <sys_open>

0000000000800028 <close>:
  800028:	15e0006f          	j	800186 <sys_close>

000000000080002c <dup2>:
  80002c:	1640006f          	j	800190 <sys_dup>

0000000000800030 <_start>:
  800030:	1c6000ef          	jal	ra,8001f6 <umain>
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
  800048:	72c50513          	addi	a0,a0,1836 # 800770 <main+0xbe>
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
  800068:	78450513          	addi	a0,a0,1924 # 8007e8 <main+0x136>
  80006c:	08c000ef          	jal	ra,8000f8 <cprintf>
  800070:	5559                	li	a0,-10
  800072:	12a000ef          	jal	ra,80019c <exit>

0000000000800076 <__warn>:
  800076:	715d                	addi	sp,sp,-80
  800078:	e822                	sd	s0,16(sp)
  80007a:	fc3e                	sd	a5,56(sp)
  80007c:	8432                	mv	s0,a2
  80007e:	103c                	addi	a5,sp,40
  800080:	862e                	mv	a2,a1
  800082:	85aa                	mv	a1,a0
  800084:	00000517          	auipc	a0,0x0
  800088:	70c50513          	addi	a0,a0,1804 # 800790 <main+0xde>
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
  8000a8:	74450513          	addi	a0,a0,1860 # 8007e8 <main+0x136>
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
  8000c0:	0b2000ef          	jal	ra,800172 <sys_putc>
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
  8000e4:	ad958593          	addi	a1,a1,-1319 # ffffffffffff6ad9 <bigarray+0xffffffffff7f5ad9>
  8000e8:	ec06                	sd	ra,24(sp)
  8000ea:	c602                	sw	zero,12(sp)
  8000ec:	1f4000ef          	jal	ra,8002e0 <vprintfmt>
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
  800116:	ad958593          	addi	a1,a1,-1319 # ffffffffffff6ad9 <bigarray+0xffffffffff7f5ad9>
  80011a:	ec06                	sd	ra,24(sp)
  80011c:	e4be                	sd	a5,72(sp)
  80011e:	e8c2                	sd	a6,80(sp)
  800120:	ecc6                	sd	a7,88(sp)
  800122:	e41a                	sd	t1,8(sp)
  800124:	c202                	sw	zero,4(sp)
  800126:	1ba000ef          	jal	ra,8002e0 <vprintfmt>
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

0000000000800172 <sys_putc>:
  800172:	85aa                	mv	a1,a0
  800174:	4579                	li	a0,30
  800176:	fbdff06f          	j	800132 <syscall>

000000000080017a <sys_open>:
  80017a:	862e                	mv	a2,a1
  80017c:	85aa                	mv	a1,a0
  80017e:	06400513          	li	a0,100
  800182:	fb1ff06f          	j	800132 <syscall>

0000000000800186 <sys_close>:
  800186:	85aa                	mv	a1,a0
  800188:	06500513          	li	a0,101
  80018c:	fa7ff06f          	j	800132 <syscall>

0000000000800190 <sys_dup>:
  800190:	862e                	mv	a2,a1
  800192:	85aa                	mv	a1,a0
  800194:	08200513          	li	a0,130
  800198:	f9bff06f          	j	800132 <syscall>

000000000080019c <exit>:
  80019c:	1141                	addi	sp,sp,-16
  80019e:	e406                	sd	ra,8(sp)
  8001a0:	fcbff0ef          	jal	ra,80016a <sys_exit>
  8001a4:	00000517          	auipc	a0,0x0
  8001a8:	60c50513          	addi	a0,a0,1548 # 8007b0 <main+0xfe>
  8001ac:	f4dff0ef          	jal	ra,8000f8 <cprintf>
  8001b0:	a001                	j	8001b0 <exit+0x14>

00000000008001b2 <initfd>:
  8001b2:	1101                	addi	sp,sp,-32
  8001b4:	87ae                	mv	a5,a1
  8001b6:	e426                	sd	s1,8(sp)
  8001b8:	85b2                	mv	a1,a2
  8001ba:	84aa                	mv	s1,a0
  8001bc:	853e                	mv	a0,a5
  8001be:	e822                	sd	s0,16(sp)
  8001c0:	ec06                	sd	ra,24(sp)
  8001c2:	e5fff0ef          	jal	ra,800020 <open>
  8001c6:	842a                	mv	s0,a0
  8001c8:	00054463          	bltz	a0,8001d0 <initfd+0x1e>
  8001cc:	00951863          	bne	a0,s1,8001dc <initfd+0x2a>
  8001d0:	8522                	mv	a0,s0
  8001d2:	60e2                	ld	ra,24(sp)
  8001d4:	6442                	ld	s0,16(sp)
  8001d6:	64a2                	ld	s1,8(sp)
  8001d8:	6105                	addi	sp,sp,32
  8001da:	8082                	ret
  8001dc:	8526                	mv	a0,s1
  8001de:	e4bff0ef          	jal	ra,800028 <close>
  8001e2:	85a6                	mv	a1,s1
  8001e4:	8522                	mv	a0,s0
  8001e6:	e47ff0ef          	jal	ra,80002c <dup2>
  8001ea:	84aa                	mv	s1,a0
  8001ec:	8522                	mv	a0,s0
  8001ee:	e3bff0ef          	jal	ra,800028 <close>
  8001f2:	8426                	mv	s0,s1
  8001f4:	bff1                	j	8001d0 <initfd+0x1e>

00000000008001f6 <umain>:
  8001f6:	1101                	addi	sp,sp,-32
  8001f8:	e822                	sd	s0,16(sp)
  8001fa:	e426                	sd	s1,8(sp)
  8001fc:	842a                	mv	s0,a0
  8001fe:	84ae                	mv	s1,a1
  800200:	4601                	li	a2,0
  800202:	00000597          	auipc	a1,0x0
  800206:	5c658593          	addi	a1,a1,1478 # 8007c8 <main+0x116>
  80020a:	4501                	li	a0,0
  80020c:	ec06                	sd	ra,24(sp)
  80020e:	fa5ff0ef          	jal	ra,8001b2 <initfd>
  800212:	02054263          	bltz	a0,800236 <umain+0x40>
  800216:	4605                	li	a2,1
  800218:	00000597          	auipc	a1,0x0
  80021c:	5f058593          	addi	a1,a1,1520 # 800808 <main+0x156>
  800220:	4505                	li	a0,1
  800222:	f91ff0ef          	jal	ra,8001b2 <initfd>
  800226:	02054563          	bltz	a0,800250 <umain+0x5a>
  80022a:	85a6                	mv	a1,s1
  80022c:	8522                	mv	a0,s0
  80022e:	484000ef          	jal	ra,8006b2 <main>
  800232:	f6bff0ef          	jal	ra,80019c <exit>
  800236:	86aa                	mv	a3,a0
  800238:	00000617          	auipc	a2,0x0
  80023c:	59860613          	addi	a2,a2,1432 # 8007d0 <main+0x11e>
  800240:	45e9                	li	a1,26
  800242:	00000517          	auipc	a0,0x0
  800246:	5ae50513          	addi	a0,a0,1454 # 8007f0 <main+0x13e>
  80024a:	e2dff0ef          	jal	ra,800076 <__warn>
  80024e:	b7e1                	j	800216 <umain+0x20>
  800250:	86aa                	mv	a3,a0
  800252:	00000617          	auipc	a2,0x0
  800256:	5be60613          	addi	a2,a2,1470 # 800810 <main+0x15e>
  80025a:	45f5                	li	a1,29
  80025c:	00000517          	auipc	a0,0x0
  800260:	59450513          	addi	a0,a0,1428 # 8007f0 <main+0x13e>
  800264:	e13ff0ef          	jal	ra,800076 <__warn>
  800268:	b7c9                	j	80022a <umain+0x34>

000000000080026a <printnum>:
  80026a:	02071893          	slli	a7,a4,0x20
  80026e:	7139                	addi	sp,sp,-64
  800270:	0208d893          	srli	a7,a7,0x20
  800274:	e456                	sd	s5,8(sp)
  800276:	0316fab3          	remu	s5,a3,a7
  80027a:	f822                	sd	s0,48(sp)
  80027c:	f426                	sd	s1,40(sp)
  80027e:	f04a                	sd	s2,32(sp)
  800280:	ec4e                	sd	s3,24(sp)
  800282:	fc06                	sd	ra,56(sp)
  800284:	e852                	sd	s4,16(sp)
  800286:	84aa                	mv	s1,a0
  800288:	89ae                	mv	s3,a1
  80028a:	8932                	mv	s2,a2
  80028c:	fff7841b          	addiw	s0,a5,-1
  800290:	2a81                	sext.w	s5,s5
  800292:	0516f163          	bleu	a7,a3,8002d4 <printnum+0x6a>
  800296:	8a42                	mv	s4,a6
  800298:	00805863          	blez	s0,8002a8 <printnum+0x3e>
  80029c:	347d                	addiw	s0,s0,-1
  80029e:	864e                	mv	a2,s3
  8002a0:	85ca                	mv	a1,s2
  8002a2:	8552                	mv	a0,s4
  8002a4:	9482                	jalr	s1
  8002a6:	f87d                	bnez	s0,80029c <printnum+0x32>
  8002a8:	1a82                	slli	s5,s5,0x20
  8002aa:	020ada93          	srli	s5,s5,0x20
  8002ae:	00000797          	auipc	a5,0x0
  8002b2:	7a278793          	addi	a5,a5,1954 # 800a50 <error_string+0xc8>
  8002b6:	9abe                	add	s5,s5,a5
  8002b8:	7442                	ld	s0,48(sp)
  8002ba:	000ac503          	lbu	a0,0(s5)
  8002be:	70e2                	ld	ra,56(sp)
  8002c0:	6a42                	ld	s4,16(sp)
  8002c2:	6aa2                	ld	s5,8(sp)
  8002c4:	864e                	mv	a2,s3
  8002c6:	85ca                	mv	a1,s2
  8002c8:	69e2                	ld	s3,24(sp)
  8002ca:	7902                	ld	s2,32(sp)
  8002cc:	8326                	mv	t1,s1
  8002ce:	74a2                	ld	s1,40(sp)
  8002d0:	6121                	addi	sp,sp,64
  8002d2:	8302                	jr	t1
  8002d4:	0316d6b3          	divu	a3,a3,a7
  8002d8:	87a2                	mv	a5,s0
  8002da:	f91ff0ef          	jal	ra,80026a <printnum>
  8002de:	b7e9                	j	8002a8 <printnum+0x3e>

00000000008002e0 <vprintfmt>:
  8002e0:	7119                	addi	sp,sp,-128
  8002e2:	f4a6                	sd	s1,104(sp)
  8002e4:	f0ca                	sd	s2,96(sp)
  8002e6:	ecce                	sd	s3,88(sp)
  8002e8:	e4d6                	sd	s5,72(sp)
  8002ea:	e0da                	sd	s6,64(sp)
  8002ec:	fc5e                	sd	s7,56(sp)
  8002ee:	f862                	sd	s8,48(sp)
  8002f0:	ec6e                	sd	s11,24(sp)
  8002f2:	fc86                	sd	ra,120(sp)
  8002f4:	f8a2                	sd	s0,112(sp)
  8002f6:	e8d2                	sd	s4,80(sp)
  8002f8:	f466                	sd	s9,40(sp)
  8002fa:	f06a                	sd	s10,32(sp)
  8002fc:	89aa                	mv	s3,a0
  8002fe:	892e                	mv	s2,a1
  800300:	84b2                	mv	s1,a2
  800302:	8db6                	mv	s11,a3
  800304:	8b3a                	mv	s6,a4
  800306:	5bfd                	li	s7,-1
  800308:	00000a97          	auipc	s5,0x0
  80030c:	524a8a93          	addi	s5,s5,1316 # 80082c <main+0x17a>
  800310:	05e00c13          	li	s8,94
  800314:	000dc503          	lbu	a0,0(s11)
  800318:	02500793          	li	a5,37
  80031c:	001d8413          	addi	s0,s11,1
  800320:	00f50f63          	beq	a0,a5,80033e <vprintfmt+0x5e>
  800324:	c529                	beqz	a0,80036e <vprintfmt+0x8e>
  800326:	02500a13          	li	s4,37
  80032a:	a011                	j	80032e <vprintfmt+0x4e>
  80032c:	c129                	beqz	a0,80036e <vprintfmt+0x8e>
  80032e:	864a                	mv	a2,s2
  800330:	85a6                	mv	a1,s1
  800332:	0405                	addi	s0,s0,1
  800334:	9982                	jalr	s3
  800336:	fff44503          	lbu	a0,-1(s0)
  80033a:	ff4519e3          	bne	a0,s4,80032c <vprintfmt+0x4c>
  80033e:	00044603          	lbu	a2,0(s0)
  800342:	02000813          	li	a6,32
  800346:	4a01                	li	s4,0
  800348:	4881                	li	a7,0
  80034a:	5d7d                	li	s10,-1
  80034c:	5cfd                	li	s9,-1
  80034e:	05500593          	li	a1,85
  800352:	4525                	li	a0,9
  800354:	fdd6071b          	addiw	a4,a2,-35
  800358:	0ff77713          	andi	a4,a4,255
  80035c:	00140d93          	addi	s11,s0,1
  800360:	22e5e363          	bltu	a1,a4,800586 <vprintfmt+0x2a6>
  800364:	070a                	slli	a4,a4,0x2
  800366:	9756                	add	a4,a4,s5
  800368:	4318                	lw	a4,0(a4)
  80036a:	9756                	add	a4,a4,s5
  80036c:	8702                	jr	a4
  80036e:	70e6                	ld	ra,120(sp)
  800370:	7446                	ld	s0,112(sp)
  800372:	74a6                	ld	s1,104(sp)
  800374:	7906                	ld	s2,96(sp)
  800376:	69e6                	ld	s3,88(sp)
  800378:	6a46                	ld	s4,80(sp)
  80037a:	6aa6                	ld	s5,72(sp)
  80037c:	6b06                	ld	s6,64(sp)
  80037e:	7be2                	ld	s7,56(sp)
  800380:	7c42                	ld	s8,48(sp)
  800382:	7ca2                	ld	s9,40(sp)
  800384:	7d02                	ld	s10,32(sp)
  800386:	6de2                	ld	s11,24(sp)
  800388:	6109                	addi	sp,sp,128
  80038a:	8082                	ret
  80038c:	4705                	li	a4,1
  80038e:	008b0613          	addi	a2,s6,8
  800392:	01174463          	blt	a4,a7,80039a <vprintfmt+0xba>
  800396:	28088563          	beqz	a7,800620 <vprintfmt+0x340>
  80039a:	000b3683          	ld	a3,0(s6)
  80039e:	4741                	li	a4,16
  8003a0:	8b32                	mv	s6,a2
  8003a2:	a86d                	j	80045c <vprintfmt+0x17c>
  8003a4:	00144603          	lbu	a2,1(s0)
  8003a8:	4a05                	li	s4,1
  8003aa:	846e                	mv	s0,s11
  8003ac:	b765                	j	800354 <vprintfmt+0x74>
  8003ae:	000b2503          	lw	a0,0(s6)
  8003b2:	864a                	mv	a2,s2
  8003b4:	85a6                	mv	a1,s1
  8003b6:	0b21                	addi	s6,s6,8
  8003b8:	9982                	jalr	s3
  8003ba:	bfa9                	j	800314 <vprintfmt+0x34>
  8003bc:	4705                	li	a4,1
  8003be:	008b0a13          	addi	s4,s6,8
  8003c2:	01174463          	blt	a4,a7,8003ca <vprintfmt+0xea>
  8003c6:	24088563          	beqz	a7,800610 <vprintfmt+0x330>
  8003ca:	000b3403          	ld	s0,0(s6)
  8003ce:	26044563          	bltz	s0,800638 <vprintfmt+0x358>
  8003d2:	86a2                	mv	a3,s0
  8003d4:	8b52                	mv	s6,s4
  8003d6:	4729                	li	a4,10
  8003d8:	a051                	j	80045c <vprintfmt+0x17c>
  8003da:	000b2783          	lw	a5,0(s6)
  8003de:	46e1                	li	a3,24
  8003e0:	0b21                	addi	s6,s6,8
  8003e2:	41f7d71b          	sraiw	a4,a5,0x1f
  8003e6:	8fb9                	xor	a5,a5,a4
  8003e8:	40e7873b          	subw	a4,a5,a4
  8003ec:	1ce6c163          	blt	a3,a4,8005ae <vprintfmt+0x2ce>
  8003f0:	00371793          	slli	a5,a4,0x3
  8003f4:	00000697          	auipc	a3,0x0
  8003f8:	59468693          	addi	a3,a3,1428 # 800988 <error_string>
  8003fc:	97b6                	add	a5,a5,a3
  8003fe:	639c                	ld	a5,0(a5)
  800400:	1a078763          	beqz	a5,8005ae <vprintfmt+0x2ce>
  800404:	873e                	mv	a4,a5
  800406:	00001697          	auipc	a3,0x1
  80040a:	85268693          	addi	a3,a3,-1966 # 800c58 <error_string+0x2d0>
  80040e:	8626                	mv	a2,s1
  800410:	85ca                	mv	a1,s2
  800412:	854e                	mv	a0,s3
  800414:	25a000ef          	jal	ra,80066e <printfmt>
  800418:	bdf5                	j	800314 <vprintfmt+0x34>
  80041a:	00144603          	lbu	a2,1(s0)
  80041e:	2885                	addiw	a7,a7,1
  800420:	846e                	mv	s0,s11
  800422:	bf0d                	j	800354 <vprintfmt+0x74>
  800424:	4705                	li	a4,1
  800426:	008b0613          	addi	a2,s6,8
  80042a:	01174463          	blt	a4,a7,800432 <vprintfmt+0x152>
  80042e:	1e088e63          	beqz	a7,80062a <vprintfmt+0x34a>
  800432:	000b3683          	ld	a3,0(s6)
  800436:	4721                	li	a4,8
  800438:	8b32                	mv	s6,a2
  80043a:	a00d                	j	80045c <vprintfmt+0x17c>
  80043c:	03000513          	li	a0,48
  800440:	864a                	mv	a2,s2
  800442:	85a6                	mv	a1,s1
  800444:	e042                	sd	a6,0(sp)
  800446:	9982                	jalr	s3
  800448:	864a                	mv	a2,s2
  80044a:	85a6                	mv	a1,s1
  80044c:	07800513          	li	a0,120
  800450:	9982                	jalr	s3
  800452:	0b21                	addi	s6,s6,8
  800454:	ff8b3683          	ld	a3,-8(s6)
  800458:	6802                	ld	a6,0(sp)
  80045a:	4741                	li	a4,16
  80045c:	87e6                	mv	a5,s9
  80045e:	8626                	mv	a2,s1
  800460:	85ca                	mv	a1,s2
  800462:	854e                	mv	a0,s3
  800464:	e07ff0ef          	jal	ra,80026a <printnum>
  800468:	b575                	j	800314 <vprintfmt+0x34>
  80046a:	000b3703          	ld	a4,0(s6)
  80046e:	0b21                	addi	s6,s6,8
  800470:	1e070063          	beqz	a4,800650 <vprintfmt+0x370>
  800474:	00170413          	addi	s0,a4,1
  800478:	19905563          	blez	s9,800602 <vprintfmt+0x322>
  80047c:	02d00613          	li	a2,45
  800480:	14c81963          	bne	a6,a2,8005d2 <vprintfmt+0x2f2>
  800484:	00074703          	lbu	a4,0(a4)
  800488:	0007051b          	sext.w	a0,a4
  80048c:	c90d                	beqz	a0,8004be <vprintfmt+0x1de>
  80048e:	000d4563          	bltz	s10,800498 <vprintfmt+0x1b8>
  800492:	3d7d                	addiw	s10,s10,-1
  800494:	037d0363          	beq	s10,s7,8004ba <vprintfmt+0x1da>
  800498:	864a                	mv	a2,s2
  80049a:	85a6                	mv	a1,s1
  80049c:	180a0c63          	beqz	s4,800634 <vprintfmt+0x354>
  8004a0:	3701                	addiw	a4,a4,-32
  8004a2:	18ec7963          	bleu	a4,s8,800634 <vprintfmt+0x354>
  8004a6:	03f00513          	li	a0,63
  8004aa:	9982                	jalr	s3
  8004ac:	0405                	addi	s0,s0,1
  8004ae:	fff44703          	lbu	a4,-1(s0)
  8004b2:	3cfd                	addiw	s9,s9,-1
  8004b4:	0007051b          	sext.w	a0,a4
  8004b8:	f979                	bnez	a0,80048e <vprintfmt+0x1ae>
  8004ba:	e5905de3          	blez	s9,800314 <vprintfmt+0x34>
  8004be:	3cfd                	addiw	s9,s9,-1
  8004c0:	864a                	mv	a2,s2
  8004c2:	85a6                	mv	a1,s1
  8004c4:	02000513          	li	a0,32
  8004c8:	9982                	jalr	s3
  8004ca:	e40c85e3          	beqz	s9,800314 <vprintfmt+0x34>
  8004ce:	3cfd                	addiw	s9,s9,-1
  8004d0:	864a                	mv	a2,s2
  8004d2:	85a6                	mv	a1,s1
  8004d4:	02000513          	li	a0,32
  8004d8:	9982                	jalr	s3
  8004da:	fe0c92e3          	bnez	s9,8004be <vprintfmt+0x1de>
  8004de:	bd1d                	j	800314 <vprintfmt+0x34>
  8004e0:	4705                	li	a4,1
  8004e2:	008b0613          	addi	a2,s6,8
  8004e6:	01174463          	blt	a4,a7,8004ee <vprintfmt+0x20e>
  8004ea:	12088663          	beqz	a7,800616 <vprintfmt+0x336>
  8004ee:	000b3683          	ld	a3,0(s6)
  8004f2:	4729                	li	a4,10
  8004f4:	8b32                	mv	s6,a2
  8004f6:	b79d                	j	80045c <vprintfmt+0x17c>
  8004f8:	00144603          	lbu	a2,1(s0)
  8004fc:	02d00813          	li	a6,45
  800500:	846e                	mv	s0,s11
  800502:	bd89                	j	800354 <vprintfmt+0x74>
  800504:	864a                	mv	a2,s2
  800506:	85a6                	mv	a1,s1
  800508:	02500513          	li	a0,37
  80050c:	9982                	jalr	s3
  80050e:	b519                	j	800314 <vprintfmt+0x34>
  800510:	000b2d03          	lw	s10,0(s6)
  800514:	00144603          	lbu	a2,1(s0)
  800518:	0b21                	addi	s6,s6,8
  80051a:	846e                	mv	s0,s11
  80051c:	e20cdce3          	bgez	s9,800354 <vprintfmt+0x74>
  800520:	8cea                	mv	s9,s10
  800522:	5d7d                	li	s10,-1
  800524:	bd05                	j	800354 <vprintfmt+0x74>
  800526:	00144603          	lbu	a2,1(s0)
  80052a:	03000813          	li	a6,48
  80052e:	846e                	mv	s0,s11
  800530:	b515                	j	800354 <vprintfmt+0x74>
  800532:	fd060d1b          	addiw	s10,a2,-48
  800536:	00144603          	lbu	a2,1(s0)
  80053a:	846e                	mv	s0,s11
  80053c:	fd06071b          	addiw	a4,a2,-48
  800540:	0006031b          	sext.w	t1,a2
  800544:	fce56ce3          	bltu	a0,a4,80051c <vprintfmt+0x23c>
  800548:	0405                	addi	s0,s0,1
  80054a:	002d171b          	slliw	a4,s10,0x2
  80054e:	00044603          	lbu	a2,0(s0)
  800552:	01a706bb          	addw	a3,a4,s10
  800556:	0016969b          	slliw	a3,a3,0x1
  80055a:	006686bb          	addw	a3,a3,t1
  80055e:	fd06071b          	addiw	a4,a2,-48
  800562:	fd068d1b          	addiw	s10,a3,-48
  800566:	0006031b          	sext.w	t1,a2
  80056a:	fce57fe3          	bleu	a4,a0,800548 <vprintfmt+0x268>
  80056e:	b77d                	j	80051c <vprintfmt+0x23c>
  800570:	fffcc713          	not	a4,s9
  800574:	977d                	srai	a4,a4,0x3f
  800576:	00ecf7b3          	and	a5,s9,a4
  80057a:	00144603          	lbu	a2,1(s0)
  80057e:	00078c9b          	sext.w	s9,a5
  800582:	846e                	mv	s0,s11
  800584:	bbc1                	j	800354 <vprintfmt+0x74>
  800586:	864a                	mv	a2,s2
  800588:	85a6                	mv	a1,s1
  80058a:	02500513          	li	a0,37
  80058e:	9982                	jalr	s3
  800590:	fff44703          	lbu	a4,-1(s0)
  800594:	02500793          	li	a5,37
  800598:	8da2                	mv	s11,s0
  80059a:	d6f70de3          	beq	a4,a5,800314 <vprintfmt+0x34>
  80059e:	02500713          	li	a4,37
  8005a2:	1dfd                	addi	s11,s11,-1
  8005a4:	fffdc783          	lbu	a5,-1(s11)
  8005a8:	fee79de3          	bne	a5,a4,8005a2 <vprintfmt+0x2c2>
  8005ac:	b3a5                	j	800314 <vprintfmt+0x34>
  8005ae:	00000697          	auipc	a3,0x0
  8005b2:	69a68693          	addi	a3,a3,1690 # 800c48 <error_string+0x2c0>
  8005b6:	8626                	mv	a2,s1
  8005b8:	85ca                	mv	a1,s2
  8005ba:	854e                	mv	a0,s3
  8005bc:	0b2000ef          	jal	ra,80066e <printfmt>
  8005c0:	bb91                	j	800314 <vprintfmt+0x34>
  8005c2:	00000717          	auipc	a4,0x0
  8005c6:	67e70713          	addi	a4,a4,1662 # 800c40 <error_string+0x2b8>
  8005ca:	00000417          	auipc	s0,0x0
  8005ce:	67740413          	addi	s0,s0,1655 # 800c41 <error_string+0x2b9>
  8005d2:	853a                	mv	a0,a4
  8005d4:	85ea                	mv	a1,s10
  8005d6:	e03a                	sd	a4,0(sp)
  8005d8:	e442                	sd	a6,8(sp)
  8005da:	0b2000ef          	jal	ra,80068c <strnlen>
  8005de:	40ac8cbb          	subw	s9,s9,a0
  8005e2:	6702                	ld	a4,0(sp)
  8005e4:	01905f63          	blez	s9,800602 <vprintfmt+0x322>
  8005e8:	6822                	ld	a6,8(sp)
  8005ea:	0008079b          	sext.w	a5,a6
  8005ee:	e43e                	sd	a5,8(sp)
  8005f0:	6522                	ld	a0,8(sp)
  8005f2:	864a                	mv	a2,s2
  8005f4:	85a6                	mv	a1,s1
  8005f6:	e03a                	sd	a4,0(sp)
  8005f8:	3cfd                	addiw	s9,s9,-1
  8005fa:	9982                	jalr	s3
  8005fc:	6702                	ld	a4,0(sp)
  8005fe:	fe0c99e3          	bnez	s9,8005f0 <vprintfmt+0x310>
  800602:	00074703          	lbu	a4,0(a4)
  800606:	0007051b          	sext.w	a0,a4
  80060a:	e80512e3          	bnez	a0,80048e <vprintfmt+0x1ae>
  80060e:	b319                	j	800314 <vprintfmt+0x34>
  800610:	000b2403          	lw	s0,0(s6)
  800614:	bb6d                	j	8003ce <vprintfmt+0xee>
  800616:	000b6683          	lwu	a3,0(s6)
  80061a:	4729                	li	a4,10
  80061c:	8b32                	mv	s6,a2
  80061e:	bd3d                	j	80045c <vprintfmt+0x17c>
  800620:	000b6683          	lwu	a3,0(s6)
  800624:	4741                	li	a4,16
  800626:	8b32                	mv	s6,a2
  800628:	bd15                	j	80045c <vprintfmt+0x17c>
  80062a:	000b6683          	lwu	a3,0(s6)
  80062e:	4721                	li	a4,8
  800630:	8b32                	mv	s6,a2
  800632:	b52d                	j	80045c <vprintfmt+0x17c>
  800634:	9982                	jalr	s3
  800636:	bd9d                	j	8004ac <vprintfmt+0x1cc>
  800638:	864a                	mv	a2,s2
  80063a:	85a6                	mv	a1,s1
  80063c:	02d00513          	li	a0,45
  800640:	e042                	sd	a6,0(sp)
  800642:	9982                	jalr	s3
  800644:	8b52                	mv	s6,s4
  800646:	408006b3          	neg	a3,s0
  80064a:	4729                	li	a4,10
  80064c:	6802                	ld	a6,0(sp)
  80064e:	b539                	j	80045c <vprintfmt+0x17c>
  800650:	01905663          	blez	s9,80065c <vprintfmt+0x37c>
  800654:	02d00713          	li	a4,45
  800658:	f6e815e3          	bne	a6,a4,8005c2 <vprintfmt+0x2e2>
  80065c:	00000417          	auipc	s0,0x0
  800660:	5e540413          	addi	s0,s0,1509 # 800c41 <error_string+0x2b9>
  800664:	02800513          	li	a0,40
  800668:	02800713          	li	a4,40
  80066c:	b50d                	j	80048e <vprintfmt+0x1ae>

000000000080066e <printfmt>:
  80066e:	7139                	addi	sp,sp,-64
  800670:	02010313          	addi	t1,sp,32
  800674:	f03a                	sd	a4,32(sp)
  800676:	871a                	mv	a4,t1
  800678:	ec06                	sd	ra,24(sp)
  80067a:	f43e                	sd	a5,40(sp)
  80067c:	f842                	sd	a6,48(sp)
  80067e:	fc46                	sd	a7,56(sp)
  800680:	e41a                	sd	t1,8(sp)
  800682:	c5fff0ef          	jal	ra,8002e0 <vprintfmt>
  800686:	60e2                	ld	ra,24(sp)
  800688:	6121                	addi	sp,sp,64
  80068a:	8082                	ret

000000000080068c <strnlen>:
  80068c:	c185                	beqz	a1,8006ac <strnlen+0x20>
  80068e:	00054783          	lbu	a5,0(a0)
  800692:	cf89                	beqz	a5,8006ac <strnlen+0x20>
  800694:	4781                	li	a5,0
  800696:	a021                	j	80069e <strnlen+0x12>
  800698:	00074703          	lbu	a4,0(a4)
  80069c:	c711                	beqz	a4,8006a8 <strnlen+0x1c>
  80069e:	0785                	addi	a5,a5,1
  8006a0:	00f50733          	add	a4,a0,a5
  8006a4:	fef59ae3          	bne	a1,a5,800698 <strnlen+0xc>
  8006a8:	853e                	mv	a0,a5
  8006aa:	8082                	ret
  8006ac:	4781                	li	a5,0
  8006ae:	853e                	mv	a0,a5
  8006b0:	8082                	ret

00000000008006b2 <main>:
  8006b2:	1141                	addi	sp,sp,-16
  8006b4:	00000517          	auipc	a0,0x0
  8006b8:	5ac50513          	addi	a0,a0,1452 # 800c60 <error_string+0x2d8>
  8006bc:	e406                	sd	ra,8(sp)
  8006be:	a3bff0ef          	jal	ra,8000f8 <cprintf>
  8006c2:	00001597          	auipc	a1,0x1
  8006c6:	93e58593          	addi	a1,a1,-1730 # 801000 <bigarray>
  8006ca:	87ae                	mv	a5,a1
  8006cc:	4681                	li	a3,0
  8006ce:	00100637          	lui	a2,0x100
  8006d2:	a029                	j	8006dc <main+0x2a>
  8006d4:	2685                	addiw	a3,a3,1
  8006d6:	0791                	addi	a5,a5,4
  8006d8:	00c68f63          	beq	a3,a2,8006f6 <main+0x44>
  8006dc:	4398                	lw	a4,0(a5)
  8006de:	db7d                	beqz	a4,8006d4 <main+0x22>
  8006e0:	00000617          	auipc	a2,0x0
  8006e4:	5a060613          	addi	a2,a2,1440 # 800c80 <error_string+0x2f8>
  8006e8:	45b9                	li	a1,14
  8006ea:	00000517          	auipc	a0,0x0
  8006ee:	5b650513          	addi	a0,a0,1462 # 800ca0 <error_string+0x318>
  8006f2:	945ff0ef          	jal	ra,800036 <__panic>
  8006f6:	00001717          	auipc	a4,0x1
  8006fa:	90a70713          	addi	a4,a4,-1782 # 801000 <bigarray>
  8006fe:	4781                	li	a5,0
  800700:	001006b7          	lui	a3,0x100
  800704:	c31c                	sw	a5,0(a4)
  800706:	2785                	addiw	a5,a5,1
  800708:	0711                	addi	a4,a4,4
  80070a:	fed79de3          	bne	a5,a3,800704 <main+0x52>
  80070e:	4681                	li	a3,0
  800710:	00100737          	lui	a4,0x100
  800714:	a029                	j	80071e <main+0x6c>
  800716:	2685                	addiw	a3,a3,1
  800718:	0591                	addi	a1,a1,4
  80071a:	02e68063          	beq	a3,a4,80073a <main+0x88>
  80071e:	419c                	lw	a5,0(a1)
  800720:	fed78be3          	beq	a5,a3,800716 <main+0x64>
  800724:	00000617          	auipc	a2,0x0
  800728:	58c60613          	addi	a2,a2,1420 # 800cb0 <error_string+0x328>
  80072c:	45d9                	li	a1,22
  80072e:	00000517          	auipc	a0,0x0
  800732:	57250513          	addi	a0,a0,1394 # 800ca0 <error_string+0x318>
  800736:	901ff0ef          	jal	ra,800036 <__panic>
  80073a:	00000517          	auipc	a0,0x0
  80073e:	59e50513          	addi	a0,a0,1438 # 800cd8 <error_string+0x350>
  800742:	9b7ff0ef          	jal	ra,8000f8 <cprintf>
  800746:	00000517          	auipc	a0,0x0
  80074a:	5ca50513          	addi	a0,a0,1482 # 800d10 <error_string+0x388>
  80074e:	9abff0ef          	jal	ra,8000f8 <cprintf>
  800752:	00000617          	auipc	a2,0x0
  800756:	5d660613          	addi	a2,a2,1494 # 800d28 <error_string+0x3a0>
  80075a:	45fd                	li	a1,31
  80075c:	00000517          	auipc	a0,0x0
  800760:	54450513          	addi	a0,a0,1348 # 800ca0 <error_string+0x318>
  800764:	00402797          	auipc	a5,0x402
  800768:	8807ae23          	sw	zero,-1892(a5) # c02000 <bigarray+0x401000>
  80076c:	8cbff0ef          	jal	ra,800036 <__panic>
