
obj/__user_softint.out：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000000800020 <open>:
  800020:	1582                	slli	a1,a1,0x20
  800022:	9181                	srli	a1,a1,0x20
  800024:	1160006f          	j	80013a <sys_open>

0000000000800028 <close>:
  800028:	11e0006f          	j	800146 <sys_close>

000000000080002c <dup2>:
  80002c:	1240006f          	j	800150 <sys_dup>

0000000000800030 <_start>:
  800030:	186000ef          	jal	ra,8001b6 <umain>
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
  800048:	65c50513          	addi	a0,a0,1628 # 8006a0 <main+0x2e>
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
  800068:	69450513          	addi	a0,a0,1684 # 8006f8 <main+0x86>
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
  800080:	0b2000ef          	jal	ra,800132 <sys_putc>
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
  8000a4:	ad958593          	addi	a1,a1,-1319 # ffffffffffff6ad9 <error_string+0xffffffffff7f6241>
  8000a8:	ec06                	sd	ra,24(sp)
  8000aa:	c602                	sw	zero,12(sp)
  8000ac:	1f4000ef          	jal	ra,8002a0 <vprintfmt>
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
  8000d6:	ad958593          	addi	a1,a1,-1319 # ffffffffffff6ad9 <error_string+0xffffffffff7f6241>
  8000da:	ec06                	sd	ra,24(sp)
  8000dc:	e4be                	sd	a5,72(sp)
  8000de:	e8c2                	sd	a6,80(sp)
  8000e0:	ecc6                	sd	a7,88(sp)
  8000e2:	e41a                	sd	t1,8(sp)
  8000e4:	c202                	sw	zero,4(sp)
  8000e6:	1ba000ef          	jal	ra,8002a0 <vprintfmt>
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

0000000000800132 <sys_putc>:
  800132:	85aa                	mv	a1,a0
  800134:	4579                	li	a0,30
  800136:	fbdff06f          	j	8000f2 <syscall>

000000000080013a <sys_open>:
  80013a:	862e                	mv	a2,a1
  80013c:	85aa                	mv	a1,a0
  80013e:	06400513          	li	a0,100
  800142:	fb1ff06f          	j	8000f2 <syscall>

0000000000800146 <sys_close>:
  800146:	85aa                	mv	a1,a0
  800148:	06500513          	li	a0,101
  80014c:	fa7ff06f          	j	8000f2 <syscall>

0000000000800150 <sys_dup>:
  800150:	862e                	mv	a2,a1
  800152:	85aa                	mv	a1,a0
  800154:	08200513          	li	a0,130
  800158:	f9bff06f          	j	8000f2 <syscall>

000000000080015c <exit>:
  80015c:	1141                	addi	sp,sp,-16
  80015e:	e406                	sd	ra,8(sp)
  800160:	fcbff0ef          	jal	ra,80012a <sys_exit>
  800164:	00000517          	auipc	a0,0x0
  800168:	55c50513          	addi	a0,a0,1372 # 8006c0 <main+0x4e>
  80016c:	f4dff0ef          	jal	ra,8000b8 <cprintf>
  800170:	a001                	j	800170 <exit+0x14>

0000000000800172 <initfd>:
  800172:	1101                	addi	sp,sp,-32
  800174:	87ae                	mv	a5,a1
  800176:	e426                	sd	s1,8(sp)
  800178:	85b2                	mv	a1,a2
  80017a:	84aa                	mv	s1,a0
  80017c:	853e                	mv	a0,a5
  80017e:	e822                	sd	s0,16(sp)
  800180:	ec06                	sd	ra,24(sp)
  800182:	e9fff0ef          	jal	ra,800020 <open>
  800186:	842a                	mv	s0,a0
  800188:	00054463          	bltz	a0,800190 <initfd+0x1e>
  80018c:	00951863          	bne	a0,s1,80019c <initfd+0x2a>
  800190:	8522                	mv	a0,s0
  800192:	60e2                	ld	ra,24(sp)
  800194:	6442                	ld	s0,16(sp)
  800196:	64a2                	ld	s1,8(sp)
  800198:	6105                	addi	sp,sp,32
  80019a:	8082                	ret
  80019c:	8526                	mv	a0,s1
  80019e:	e8bff0ef          	jal	ra,800028 <close>
  8001a2:	85a6                	mv	a1,s1
  8001a4:	8522                	mv	a0,s0
  8001a6:	e87ff0ef          	jal	ra,80002c <dup2>
  8001aa:	84aa                	mv	s1,a0
  8001ac:	8522                	mv	a0,s0
  8001ae:	e7bff0ef          	jal	ra,800028 <close>
  8001b2:	8426                	mv	s0,s1
  8001b4:	bff1                	j	800190 <initfd+0x1e>

00000000008001b6 <umain>:
  8001b6:	1101                	addi	sp,sp,-32
  8001b8:	e822                	sd	s0,16(sp)
  8001ba:	e426                	sd	s1,8(sp)
  8001bc:	842a                	mv	s0,a0
  8001be:	84ae                	mv	s1,a1
  8001c0:	4601                	li	a2,0
  8001c2:	00000597          	auipc	a1,0x0
  8001c6:	51658593          	addi	a1,a1,1302 # 8006d8 <main+0x66>
  8001ca:	4501                	li	a0,0
  8001cc:	ec06                	sd	ra,24(sp)
  8001ce:	fa5ff0ef          	jal	ra,800172 <initfd>
  8001d2:	02054263          	bltz	a0,8001f6 <umain+0x40>
  8001d6:	4605                	li	a2,1
  8001d8:	00000597          	auipc	a1,0x0
  8001dc:	54058593          	addi	a1,a1,1344 # 800718 <main+0xa6>
  8001e0:	4505                	li	a0,1
  8001e2:	f91ff0ef          	jal	ra,800172 <initfd>
  8001e6:	02054563          	bltz	a0,800210 <umain+0x5a>
  8001ea:	85a6                	mv	a1,s1
  8001ec:	8522                	mv	a0,s0
  8001ee:	484000ef          	jal	ra,800672 <main>
  8001f2:	f6bff0ef          	jal	ra,80015c <exit>
  8001f6:	86aa                	mv	a3,a0
  8001f8:	00000617          	auipc	a2,0x0
  8001fc:	4e860613          	addi	a2,a2,1256 # 8006e0 <main+0x6e>
  800200:	45e9                	li	a1,26
  800202:	00000517          	auipc	a0,0x0
  800206:	4fe50513          	addi	a0,a0,1278 # 800700 <main+0x8e>
  80020a:	e2dff0ef          	jal	ra,800036 <__warn>
  80020e:	b7e1                	j	8001d6 <umain+0x20>
  800210:	86aa                	mv	a3,a0
  800212:	00000617          	auipc	a2,0x0
  800216:	50e60613          	addi	a2,a2,1294 # 800720 <main+0xae>
  80021a:	45f5                	li	a1,29
  80021c:	00000517          	auipc	a0,0x0
  800220:	4e450513          	addi	a0,a0,1252 # 800700 <main+0x8e>
  800224:	e13ff0ef          	jal	ra,800036 <__warn>
  800228:	b7c9                	j	8001ea <umain+0x34>

000000000080022a <printnum>:
  80022a:	02071893          	slli	a7,a4,0x20
  80022e:	7139                	addi	sp,sp,-64
  800230:	0208d893          	srli	a7,a7,0x20
  800234:	e456                	sd	s5,8(sp)
  800236:	0316fab3          	remu	s5,a3,a7
  80023a:	f822                	sd	s0,48(sp)
  80023c:	f426                	sd	s1,40(sp)
  80023e:	f04a                	sd	s2,32(sp)
  800240:	ec4e                	sd	s3,24(sp)
  800242:	fc06                	sd	ra,56(sp)
  800244:	e852                	sd	s4,16(sp)
  800246:	84aa                	mv	s1,a0
  800248:	89ae                	mv	s3,a1
  80024a:	8932                	mv	s2,a2
  80024c:	fff7841b          	addiw	s0,a5,-1
  800250:	2a81                	sext.w	s5,s5
  800252:	0516f163          	bleu	a7,a3,800294 <printnum+0x6a>
  800256:	8a42                	mv	s4,a6
  800258:	00805863          	blez	s0,800268 <printnum+0x3e>
  80025c:	347d                	addiw	s0,s0,-1
  80025e:	864e                	mv	a2,s3
  800260:	85ca                	mv	a1,s2
  800262:	8552                	mv	a0,s4
  800264:	9482                	jalr	s1
  800266:	f87d                	bnez	s0,80025c <printnum+0x32>
  800268:	1a82                	slli	s5,s5,0x20
  80026a:	020ada93          	srli	s5,s5,0x20
  80026e:	00000797          	auipc	a5,0x0
  800272:	6f278793          	addi	a5,a5,1778 # 800960 <error_string+0xc8>
  800276:	9abe                	add	s5,s5,a5
  800278:	7442                	ld	s0,48(sp)
  80027a:	000ac503          	lbu	a0,0(s5)
  80027e:	70e2                	ld	ra,56(sp)
  800280:	6a42                	ld	s4,16(sp)
  800282:	6aa2                	ld	s5,8(sp)
  800284:	864e                	mv	a2,s3
  800286:	85ca                	mv	a1,s2
  800288:	69e2                	ld	s3,24(sp)
  80028a:	7902                	ld	s2,32(sp)
  80028c:	8326                	mv	t1,s1
  80028e:	74a2                	ld	s1,40(sp)
  800290:	6121                	addi	sp,sp,64
  800292:	8302                	jr	t1
  800294:	0316d6b3          	divu	a3,a3,a7
  800298:	87a2                	mv	a5,s0
  80029a:	f91ff0ef          	jal	ra,80022a <printnum>
  80029e:	b7e9                	j	800268 <printnum+0x3e>

00000000008002a0 <vprintfmt>:
  8002a0:	7119                	addi	sp,sp,-128
  8002a2:	f4a6                	sd	s1,104(sp)
  8002a4:	f0ca                	sd	s2,96(sp)
  8002a6:	ecce                	sd	s3,88(sp)
  8002a8:	e4d6                	sd	s5,72(sp)
  8002aa:	e0da                	sd	s6,64(sp)
  8002ac:	fc5e                	sd	s7,56(sp)
  8002ae:	f862                	sd	s8,48(sp)
  8002b0:	ec6e                	sd	s11,24(sp)
  8002b2:	fc86                	sd	ra,120(sp)
  8002b4:	f8a2                	sd	s0,112(sp)
  8002b6:	e8d2                	sd	s4,80(sp)
  8002b8:	f466                	sd	s9,40(sp)
  8002ba:	f06a                	sd	s10,32(sp)
  8002bc:	89aa                	mv	s3,a0
  8002be:	892e                	mv	s2,a1
  8002c0:	84b2                	mv	s1,a2
  8002c2:	8db6                	mv	s11,a3
  8002c4:	8b3a                	mv	s6,a4
  8002c6:	5bfd                	li	s7,-1
  8002c8:	00000a97          	auipc	s5,0x0
  8002cc:	474a8a93          	addi	s5,s5,1140 # 80073c <main+0xca>
  8002d0:	05e00c13          	li	s8,94
  8002d4:	000dc503          	lbu	a0,0(s11)
  8002d8:	02500793          	li	a5,37
  8002dc:	001d8413          	addi	s0,s11,1
  8002e0:	00f50f63          	beq	a0,a5,8002fe <vprintfmt+0x5e>
  8002e4:	c529                	beqz	a0,80032e <vprintfmt+0x8e>
  8002e6:	02500a13          	li	s4,37
  8002ea:	a011                	j	8002ee <vprintfmt+0x4e>
  8002ec:	c129                	beqz	a0,80032e <vprintfmt+0x8e>
  8002ee:	864a                	mv	a2,s2
  8002f0:	85a6                	mv	a1,s1
  8002f2:	0405                	addi	s0,s0,1
  8002f4:	9982                	jalr	s3
  8002f6:	fff44503          	lbu	a0,-1(s0)
  8002fa:	ff4519e3          	bne	a0,s4,8002ec <vprintfmt+0x4c>
  8002fe:	00044603          	lbu	a2,0(s0)
  800302:	02000813          	li	a6,32
  800306:	4a01                	li	s4,0
  800308:	4881                	li	a7,0
  80030a:	5d7d                	li	s10,-1
  80030c:	5cfd                	li	s9,-1
  80030e:	05500593          	li	a1,85
  800312:	4525                	li	a0,9
  800314:	fdd6071b          	addiw	a4,a2,-35
  800318:	0ff77713          	andi	a4,a4,255
  80031c:	00140d93          	addi	s11,s0,1
  800320:	22e5e363          	bltu	a1,a4,800546 <vprintfmt+0x2a6>
  800324:	070a                	slli	a4,a4,0x2
  800326:	9756                	add	a4,a4,s5
  800328:	4318                	lw	a4,0(a4)
  80032a:	9756                	add	a4,a4,s5
  80032c:	8702                	jr	a4
  80032e:	70e6                	ld	ra,120(sp)
  800330:	7446                	ld	s0,112(sp)
  800332:	74a6                	ld	s1,104(sp)
  800334:	7906                	ld	s2,96(sp)
  800336:	69e6                	ld	s3,88(sp)
  800338:	6a46                	ld	s4,80(sp)
  80033a:	6aa6                	ld	s5,72(sp)
  80033c:	6b06                	ld	s6,64(sp)
  80033e:	7be2                	ld	s7,56(sp)
  800340:	7c42                	ld	s8,48(sp)
  800342:	7ca2                	ld	s9,40(sp)
  800344:	7d02                	ld	s10,32(sp)
  800346:	6de2                	ld	s11,24(sp)
  800348:	6109                	addi	sp,sp,128
  80034a:	8082                	ret
  80034c:	4705                	li	a4,1
  80034e:	008b0613          	addi	a2,s6,8
  800352:	01174463          	blt	a4,a7,80035a <vprintfmt+0xba>
  800356:	28088563          	beqz	a7,8005e0 <vprintfmt+0x340>
  80035a:	000b3683          	ld	a3,0(s6)
  80035e:	4741                	li	a4,16
  800360:	8b32                	mv	s6,a2
  800362:	a86d                	j	80041c <vprintfmt+0x17c>
  800364:	00144603          	lbu	a2,1(s0)
  800368:	4a05                	li	s4,1
  80036a:	846e                	mv	s0,s11
  80036c:	b765                	j	800314 <vprintfmt+0x74>
  80036e:	000b2503          	lw	a0,0(s6)
  800372:	864a                	mv	a2,s2
  800374:	85a6                	mv	a1,s1
  800376:	0b21                	addi	s6,s6,8
  800378:	9982                	jalr	s3
  80037a:	bfa9                	j	8002d4 <vprintfmt+0x34>
  80037c:	4705                	li	a4,1
  80037e:	008b0a13          	addi	s4,s6,8
  800382:	01174463          	blt	a4,a7,80038a <vprintfmt+0xea>
  800386:	24088563          	beqz	a7,8005d0 <vprintfmt+0x330>
  80038a:	000b3403          	ld	s0,0(s6)
  80038e:	26044563          	bltz	s0,8005f8 <vprintfmt+0x358>
  800392:	86a2                	mv	a3,s0
  800394:	8b52                	mv	s6,s4
  800396:	4729                	li	a4,10
  800398:	a051                	j	80041c <vprintfmt+0x17c>
  80039a:	000b2783          	lw	a5,0(s6)
  80039e:	46e1                	li	a3,24
  8003a0:	0b21                	addi	s6,s6,8
  8003a2:	41f7d71b          	sraiw	a4,a5,0x1f
  8003a6:	8fb9                	xor	a5,a5,a4
  8003a8:	40e7873b          	subw	a4,a5,a4
  8003ac:	1ce6c163          	blt	a3,a4,80056e <vprintfmt+0x2ce>
  8003b0:	00371793          	slli	a5,a4,0x3
  8003b4:	00000697          	auipc	a3,0x0
  8003b8:	4e468693          	addi	a3,a3,1252 # 800898 <error_string>
  8003bc:	97b6                	add	a5,a5,a3
  8003be:	639c                	ld	a5,0(a5)
  8003c0:	1a078763          	beqz	a5,80056e <vprintfmt+0x2ce>
  8003c4:	873e                	mv	a4,a5
  8003c6:	00000697          	auipc	a3,0x0
  8003ca:	7a268693          	addi	a3,a3,1954 # 800b68 <error_string+0x2d0>
  8003ce:	8626                	mv	a2,s1
  8003d0:	85ca                	mv	a1,s2
  8003d2:	854e                	mv	a0,s3
  8003d4:	25a000ef          	jal	ra,80062e <printfmt>
  8003d8:	bdf5                	j	8002d4 <vprintfmt+0x34>
  8003da:	00144603          	lbu	a2,1(s0)
  8003de:	2885                	addiw	a7,a7,1
  8003e0:	846e                	mv	s0,s11
  8003e2:	bf0d                	j	800314 <vprintfmt+0x74>
  8003e4:	4705                	li	a4,1
  8003e6:	008b0613          	addi	a2,s6,8
  8003ea:	01174463          	blt	a4,a7,8003f2 <vprintfmt+0x152>
  8003ee:	1e088e63          	beqz	a7,8005ea <vprintfmt+0x34a>
  8003f2:	000b3683          	ld	a3,0(s6)
  8003f6:	4721                	li	a4,8
  8003f8:	8b32                	mv	s6,a2
  8003fa:	a00d                	j	80041c <vprintfmt+0x17c>
  8003fc:	03000513          	li	a0,48
  800400:	864a                	mv	a2,s2
  800402:	85a6                	mv	a1,s1
  800404:	e042                	sd	a6,0(sp)
  800406:	9982                	jalr	s3
  800408:	864a                	mv	a2,s2
  80040a:	85a6                	mv	a1,s1
  80040c:	07800513          	li	a0,120
  800410:	9982                	jalr	s3
  800412:	0b21                	addi	s6,s6,8
  800414:	ff8b3683          	ld	a3,-8(s6)
  800418:	6802                	ld	a6,0(sp)
  80041a:	4741                	li	a4,16
  80041c:	87e6                	mv	a5,s9
  80041e:	8626                	mv	a2,s1
  800420:	85ca                	mv	a1,s2
  800422:	854e                	mv	a0,s3
  800424:	e07ff0ef          	jal	ra,80022a <printnum>
  800428:	b575                	j	8002d4 <vprintfmt+0x34>
  80042a:	000b3703          	ld	a4,0(s6)
  80042e:	0b21                	addi	s6,s6,8
  800430:	1e070063          	beqz	a4,800610 <vprintfmt+0x370>
  800434:	00170413          	addi	s0,a4,1
  800438:	19905563          	blez	s9,8005c2 <vprintfmt+0x322>
  80043c:	02d00613          	li	a2,45
  800440:	14c81963          	bne	a6,a2,800592 <vprintfmt+0x2f2>
  800444:	00074703          	lbu	a4,0(a4)
  800448:	0007051b          	sext.w	a0,a4
  80044c:	c90d                	beqz	a0,80047e <vprintfmt+0x1de>
  80044e:	000d4563          	bltz	s10,800458 <vprintfmt+0x1b8>
  800452:	3d7d                	addiw	s10,s10,-1
  800454:	037d0363          	beq	s10,s7,80047a <vprintfmt+0x1da>
  800458:	864a                	mv	a2,s2
  80045a:	85a6                	mv	a1,s1
  80045c:	180a0c63          	beqz	s4,8005f4 <vprintfmt+0x354>
  800460:	3701                	addiw	a4,a4,-32
  800462:	18ec7963          	bleu	a4,s8,8005f4 <vprintfmt+0x354>
  800466:	03f00513          	li	a0,63
  80046a:	9982                	jalr	s3
  80046c:	0405                	addi	s0,s0,1
  80046e:	fff44703          	lbu	a4,-1(s0)
  800472:	3cfd                	addiw	s9,s9,-1
  800474:	0007051b          	sext.w	a0,a4
  800478:	f979                	bnez	a0,80044e <vprintfmt+0x1ae>
  80047a:	e5905de3          	blez	s9,8002d4 <vprintfmt+0x34>
  80047e:	3cfd                	addiw	s9,s9,-1
  800480:	864a                	mv	a2,s2
  800482:	85a6                	mv	a1,s1
  800484:	02000513          	li	a0,32
  800488:	9982                	jalr	s3
  80048a:	e40c85e3          	beqz	s9,8002d4 <vprintfmt+0x34>
  80048e:	3cfd                	addiw	s9,s9,-1
  800490:	864a                	mv	a2,s2
  800492:	85a6                	mv	a1,s1
  800494:	02000513          	li	a0,32
  800498:	9982                	jalr	s3
  80049a:	fe0c92e3          	bnez	s9,80047e <vprintfmt+0x1de>
  80049e:	bd1d                	j	8002d4 <vprintfmt+0x34>
  8004a0:	4705                	li	a4,1
  8004a2:	008b0613          	addi	a2,s6,8
  8004a6:	01174463          	blt	a4,a7,8004ae <vprintfmt+0x20e>
  8004aa:	12088663          	beqz	a7,8005d6 <vprintfmt+0x336>
  8004ae:	000b3683          	ld	a3,0(s6)
  8004b2:	4729                	li	a4,10
  8004b4:	8b32                	mv	s6,a2
  8004b6:	b79d                	j	80041c <vprintfmt+0x17c>
  8004b8:	00144603          	lbu	a2,1(s0)
  8004bc:	02d00813          	li	a6,45
  8004c0:	846e                	mv	s0,s11
  8004c2:	bd89                	j	800314 <vprintfmt+0x74>
  8004c4:	864a                	mv	a2,s2
  8004c6:	85a6                	mv	a1,s1
  8004c8:	02500513          	li	a0,37
  8004cc:	9982                	jalr	s3
  8004ce:	b519                	j	8002d4 <vprintfmt+0x34>
  8004d0:	000b2d03          	lw	s10,0(s6)
  8004d4:	00144603          	lbu	a2,1(s0)
  8004d8:	0b21                	addi	s6,s6,8
  8004da:	846e                	mv	s0,s11
  8004dc:	e20cdce3          	bgez	s9,800314 <vprintfmt+0x74>
  8004e0:	8cea                	mv	s9,s10
  8004e2:	5d7d                	li	s10,-1
  8004e4:	bd05                	j	800314 <vprintfmt+0x74>
  8004e6:	00144603          	lbu	a2,1(s0)
  8004ea:	03000813          	li	a6,48
  8004ee:	846e                	mv	s0,s11
  8004f0:	b515                	j	800314 <vprintfmt+0x74>
  8004f2:	fd060d1b          	addiw	s10,a2,-48
  8004f6:	00144603          	lbu	a2,1(s0)
  8004fa:	846e                	mv	s0,s11
  8004fc:	fd06071b          	addiw	a4,a2,-48
  800500:	0006031b          	sext.w	t1,a2
  800504:	fce56ce3          	bltu	a0,a4,8004dc <vprintfmt+0x23c>
  800508:	0405                	addi	s0,s0,1
  80050a:	002d171b          	slliw	a4,s10,0x2
  80050e:	00044603          	lbu	a2,0(s0)
  800512:	01a706bb          	addw	a3,a4,s10
  800516:	0016969b          	slliw	a3,a3,0x1
  80051a:	006686bb          	addw	a3,a3,t1
  80051e:	fd06071b          	addiw	a4,a2,-48
  800522:	fd068d1b          	addiw	s10,a3,-48
  800526:	0006031b          	sext.w	t1,a2
  80052a:	fce57fe3          	bleu	a4,a0,800508 <vprintfmt+0x268>
  80052e:	b77d                	j	8004dc <vprintfmt+0x23c>
  800530:	fffcc713          	not	a4,s9
  800534:	977d                	srai	a4,a4,0x3f
  800536:	00ecf7b3          	and	a5,s9,a4
  80053a:	00144603          	lbu	a2,1(s0)
  80053e:	00078c9b          	sext.w	s9,a5
  800542:	846e                	mv	s0,s11
  800544:	bbc1                	j	800314 <vprintfmt+0x74>
  800546:	864a                	mv	a2,s2
  800548:	85a6                	mv	a1,s1
  80054a:	02500513          	li	a0,37
  80054e:	9982                	jalr	s3
  800550:	fff44703          	lbu	a4,-1(s0)
  800554:	02500793          	li	a5,37
  800558:	8da2                	mv	s11,s0
  80055a:	d6f70de3          	beq	a4,a5,8002d4 <vprintfmt+0x34>
  80055e:	02500713          	li	a4,37
  800562:	1dfd                	addi	s11,s11,-1
  800564:	fffdc783          	lbu	a5,-1(s11)
  800568:	fee79de3          	bne	a5,a4,800562 <vprintfmt+0x2c2>
  80056c:	b3a5                	j	8002d4 <vprintfmt+0x34>
  80056e:	00000697          	auipc	a3,0x0
  800572:	5ea68693          	addi	a3,a3,1514 # 800b58 <error_string+0x2c0>
  800576:	8626                	mv	a2,s1
  800578:	85ca                	mv	a1,s2
  80057a:	854e                	mv	a0,s3
  80057c:	0b2000ef          	jal	ra,80062e <printfmt>
  800580:	bb91                	j	8002d4 <vprintfmt+0x34>
  800582:	00000717          	auipc	a4,0x0
  800586:	5ce70713          	addi	a4,a4,1486 # 800b50 <error_string+0x2b8>
  80058a:	00000417          	auipc	s0,0x0
  80058e:	5c740413          	addi	s0,s0,1479 # 800b51 <error_string+0x2b9>
  800592:	853a                	mv	a0,a4
  800594:	85ea                	mv	a1,s10
  800596:	e03a                	sd	a4,0(sp)
  800598:	e442                	sd	a6,8(sp)
  80059a:	0b2000ef          	jal	ra,80064c <strnlen>
  80059e:	40ac8cbb          	subw	s9,s9,a0
  8005a2:	6702                	ld	a4,0(sp)
  8005a4:	01905f63          	blez	s9,8005c2 <vprintfmt+0x322>
  8005a8:	6822                	ld	a6,8(sp)
  8005aa:	0008079b          	sext.w	a5,a6
  8005ae:	e43e                	sd	a5,8(sp)
  8005b0:	6522                	ld	a0,8(sp)
  8005b2:	864a                	mv	a2,s2
  8005b4:	85a6                	mv	a1,s1
  8005b6:	e03a                	sd	a4,0(sp)
  8005b8:	3cfd                	addiw	s9,s9,-1
  8005ba:	9982                	jalr	s3
  8005bc:	6702                	ld	a4,0(sp)
  8005be:	fe0c99e3          	bnez	s9,8005b0 <vprintfmt+0x310>
  8005c2:	00074703          	lbu	a4,0(a4)
  8005c6:	0007051b          	sext.w	a0,a4
  8005ca:	e80512e3          	bnez	a0,80044e <vprintfmt+0x1ae>
  8005ce:	b319                	j	8002d4 <vprintfmt+0x34>
  8005d0:	000b2403          	lw	s0,0(s6)
  8005d4:	bb6d                	j	80038e <vprintfmt+0xee>
  8005d6:	000b6683          	lwu	a3,0(s6)
  8005da:	4729                	li	a4,10
  8005dc:	8b32                	mv	s6,a2
  8005de:	bd3d                	j	80041c <vprintfmt+0x17c>
  8005e0:	000b6683          	lwu	a3,0(s6)
  8005e4:	4741                	li	a4,16
  8005e6:	8b32                	mv	s6,a2
  8005e8:	bd15                	j	80041c <vprintfmt+0x17c>
  8005ea:	000b6683          	lwu	a3,0(s6)
  8005ee:	4721                	li	a4,8
  8005f0:	8b32                	mv	s6,a2
  8005f2:	b52d                	j	80041c <vprintfmt+0x17c>
  8005f4:	9982                	jalr	s3
  8005f6:	bd9d                	j	80046c <vprintfmt+0x1cc>
  8005f8:	864a                	mv	a2,s2
  8005fa:	85a6                	mv	a1,s1
  8005fc:	02d00513          	li	a0,45
  800600:	e042                	sd	a6,0(sp)
  800602:	9982                	jalr	s3
  800604:	8b52                	mv	s6,s4
  800606:	408006b3          	neg	a3,s0
  80060a:	4729                	li	a4,10
  80060c:	6802                	ld	a6,0(sp)
  80060e:	b539                	j	80041c <vprintfmt+0x17c>
  800610:	01905663          	blez	s9,80061c <vprintfmt+0x37c>
  800614:	02d00713          	li	a4,45
  800618:	f6e815e3          	bne	a6,a4,800582 <vprintfmt+0x2e2>
  80061c:	00000417          	auipc	s0,0x0
  800620:	53540413          	addi	s0,s0,1333 # 800b51 <error_string+0x2b9>
  800624:	02800513          	li	a0,40
  800628:	02800713          	li	a4,40
  80062c:	b50d                	j	80044e <vprintfmt+0x1ae>

000000000080062e <printfmt>:
  80062e:	7139                	addi	sp,sp,-64
  800630:	02010313          	addi	t1,sp,32
  800634:	f03a                	sd	a4,32(sp)
  800636:	871a                	mv	a4,t1
  800638:	ec06                	sd	ra,24(sp)
  80063a:	f43e                	sd	a5,40(sp)
  80063c:	f842                	sd	a6,48(sp)
  80063e:	fc46                	sd	a7,56(sp)
  800640:	e41a                	sd	t1,8(sp)
  800642:	c5fff0ef          	jal	ra,8002a0 <vprintfmt>
  800646:	60e2                	ld	ra,24(sp)
  800648:	6121                	addi	sp,sp,64
  80064a:	8082                	ret

000000000080064c <strnlen>:
  80064c:	c185                	beqz	a1,80066c <strnlen+0x20>
  80064e:	00054783          	lbu	a5,0(a0)
  800652:	cf89                	beqz	a5,80066c <strnlen+0x20>
  800654:	4781                	li	a5,0
  800656:	a021                	j	80065e <strnlen+0x12>
  800658:	00074703          	lbu	a4,0(a4)
  80065c:	c711                	beqz	a4,800668 <strnlen+0x1c>
  80065e:	0785                	addi	a5,a5,1
  800660:	00f50733          	add	a4,a0,a5
  800664:	fef59ae3          	bne	a1,a5,800658 <strnlen+0xc>
  800668:	853e                	mv	a0,a5
  80066a:	8082                	ret
  80066c:	4781                	li	a5,0
  80066e:	853e                	mv	a0,a5
  800670:	8082                	ret

0000000000800672 <main>:
  800672:	1141                	addi	sp,sp,-16
  800674:	4501                	li	a0,0
  800676:	e406                	sd	ra,8(sp)
  800678:	ae5ff0ef          	jal	ra,80015c <exit>
