
obj/__user_hello.out：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000000800020 <open>:
  800020:	1582                	slli	a1,a1,0x20
  800022:	9181                	srli	a1,a1,0x20
  800024:	11c0006f          	j	800140 <sys_open>

0000000000800028 <close>:
  800028:	1240006f          	j	80014c <sys_close>

000000000080002c <dup2>:
  80002c:	12a0006f          	j	800156 <sys_dup>

0000000000800030 <_start>:
  800030:	190000ef          	jal	ra,8001c0 <umain>
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
  800048:	69450513          	addi	a0,a0,1684 # 8006d8 <main+0x5c>
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
  800064:	00001517          	auipc	a0,0x1
  800068:	b6450513          	addi	a0,a0,-1180 # 800bc8 <error_string+0x2f8>
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
  8000ac:	1fe000ef          	jal	ra,8002aa <vprintfmt>
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
  8000e6:	1c4000ef          	jal	ra,8002aa <vprintfmt>
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

0000000000800140 <sys_open>:
  800140:	862e                	mv	a2,a1
  800142:	85aa                	mv	a1,a0
  800144:	06400513          	li	a0,100
  800148:	fabff06f          	j	8000f2 <syscall>

000000000080014c <sys_close>:
  80014c:	85aa                	mv	a1,a0
  80014e:	06500513          	li	a0,101
  800152:	fa1ff06f          	j	8000f2 <syscall>

0000000000800156 <sys_dup>:
  800156:	862e                	mv	a2,a1
  800158:	85aa                	mv	a1,a0
  80015a:	08200513          	li	a0,130
  80015e:	f95ff06f          	j	8000f2 <syscall>

0000000000800162 <exit>:
  800162:	1141                	addi	sp,sp,-16
  800164:	e406                	sd	ra,8(sp)
  800166:	fc5ff0ef          	jal	ra,80012a <sys_exit>
  80016a:	00000517          	auipc	a0,0x0
  80016e:	58e50513          	addi	a0,a0,1422 # 8006f8 <main+0x7c>
  800172:	f47ff0ef          	jal	ra,8000b8 <cprintf>
  800176:	a001                	j	800176 <exit+0x14>

0000000000800178 <getpid>:
  800178:	fbbff06f          	j	800132 <sys_getpid>

000000000080017c <initfd>:
  80017c:	1101                	addi	sp,sp,-32
  80017e:	87ae                	mv	a5,a1
  800180:	e426                	sd	s1,8(sp)
  800182:	85b2                	mv	a1,a2
  800184:	84aa                	mv	s1,a0
  800186:	853e                	mv	a0,a5
  800188:	e822                	sd	s0,16(sp)
  80018a:	ec06                	sd	ra,24(sp)
  80018c:	e95ff0ef          	jal	ra,800020 <open>
  800190:	842a                	mv	s0,a0
  800192:	00054463          	bltz	a0,80019a <initfd+0x1e>
  800196:	00951863          	bne	a0,s1,8001a6 <initfd+0x2a>
  80019a:	8522                	mv	a0,s0
  80019c:	60e2                	ld	ra,24(sp)
  80019e:	6442                	ld	s0,16(sp)
  8001a0:	64a2                	ld	s1,8(sp)
  8001a2:	6105                	addi	sp,sp,32
  8001a4:	8082                	ret
  8001a6:	8526                	mv	a0,s1
  8001a8:	e81ff0ef          	jal	ra,800028 <close>
  8001ac:	85a6                	mv	a1,s1
  8001ae:	8522                	mv	a0,s0
  8001b0:	e7dff0ef          	jal	ra,80002c <dup2>
  8001b4:	84aa                	mv	s1,a0
  8001b6:	8522                	mv	a0,s0
  8001b8:	e71ff0ef          	jal	ra,800028 <close>
  8001bc:	8426                	mv	s0,s1
  8001be:	bff1                	j	80019a <initfd+0x1e>

00000000008001c0 <umain>:
  8001c0:	1101                	addi	sp,sp,-32
  8001c2:	e822                	sd	s0,16(sp)
  8001c4:	e426                	sd	s1,8(sp)
  8001c6:	842a                	mv	s0,a0
  8001c8:	84ae                	mv	s1,a1
  8001ca:	4601                	li	a2,0
  8001cc:	00000597          	auipc	a1,0x0
  8001d0:	54458593          	addi	a1,a1,1348 # 800710 <main+0x94>
  8001d4:	4501                	li	a0,0
  8001d6:	ec06                	sd	ra,24(sp)
  8001d8:	fa5ff0ef          	jal	ra,80017c <initfd>
  8001dc:	02054263          	bltz	a0,800200 <umain+0x40>
  8001e0:	4605                	li	a2,1
  8001e2:	00000597          	auipc	a1,0x0
  8001e6:	56e58593          	addi	a1,a1,1390 # 800750 <main+0xd4>
  8001ea:	4505                	li	a0,1
  8001ec:	f91ff0ef          	jal	ra,80017c <initfd>
  8001f0:	02054563          	bltz	a0,80021a <umain+0x5a>
  8001f4:	85a6                	mv	a1,s1
  8001f6:	8522                	mv	a0,s0
  8001f8:	484000ef          	jal	ra,80067c <main>
  8001fc:	f67ff0ef          	jal	ra,800162 <exit>
  800200:	86aa                	mv	a3,a0
  800202:	00000617          	auipc	a2,0x0
  800206:	51660613          	addi	a2,a2,1302 # 800718 <main+0x9c>
  80020a:	45e9                	li	a1,26
  80020c:	00000517          	auipc	a0,0x0
  800210:	52c50513          	addi	a0,a0,1324 # 800738 <main+0xbc>
  800214:	e23ff0ef          	jal	ra,800036 <__warn>
  800218:	b7e1                	j	8001e0 <umain+0x20>
  80021a:	86aa                	mv	a3,a0
  80021c:	00000617          	auipc	a2,0x0
  800220:	53c60613          	addi	a2,a2,1340 # 800758 <main+0xdc>
  800224:	45f5                	li	a1,29
  800226:	00000517          	auipc	a0,0x0
  80022a:	51250513          	addi	a0,a0,1298 # 800738 <main+0xbc>
  80022e:	e09ff0ef          	jal	ra,800036 <__warn>
  800232:	b7c9                	j	8001f4 <umain+0x34>

0000000000800234 <printnum>:
  800234:	02071893          	slli	a7,a4,0x20
  800238:	7139                	addi	sp,sp,-64
  80023a:	0208d893          	srli	a7,a7,0x20
  80023e:	e456                	sd	s5,8(sp)
  800240:	0316fab3          	remu	s5,a3,a7
  800244:	f822                	sd	s0,48(sp)
  800246:	f426                	sd	s1,40(sp)
  800248:	f04a                	sd	s2,32(sp)
  80024a:	ec4e                	sd	s3,24(sp)
  80024c:	fc06                	sd	ra,56(sp)
  80024e:	e852                	sd	s4,16(sp)
  800250:	84aa                	mv	s1,a0
  800252:	89ae                	mv	s3,a1
  800254:	8932                	mv	s2,a2
  800256:	fff7841b          	addiw	s0,a5,-1
  80025a:	2a81                	sext.w	s5,s5
  80025c:	0516f163          	bleu	a7,a3,80029e <printnum+0x6a>
  800260:	8a42                	mv	s4,a6
  800262:	00805863          	blez	s0,800272 <printnum+0x3e>
  800266:	347d                	addiw	s0,s0,-1
  800268:	864e                	mv	a2,s3
  80026a:	85ca                	mv	a1,s2
  80026c:	8552                	mv	a0,s4
  80026e:	9482                	jalr	s1
  800270:	f87d                	bnez	s0,800266 <printnum+0x32>
  800272:	1a82                	slli	s5,s5,0x20
  800274:	020ada93          	srli	s5,s5,0x20
  800278:	00000797          	auipc	a5,0x0
  80027c:	72078793          	addi	a5,a5,1824 # 800998 <error_string+0xc8>
  800280:	9abe                	add	s5,s5,a5
  800282:	7442                	ld	s0,48(sp)
  800284:	000ac503          	lbu	a0,0(s5)
  800288:	70e2                	ld	ra,56(sp)
  80028a:	6a42                	ld	s4,16(sp)
  80028c:	6aa2                	ld	s5,8(sp)
  80028e:	864e                	mv	a2,s3
  800290:	85ca                	mv	a1,s2
  800292:	69e2                	ld	s3,24(sp)
  800294:	7902                	ld	s2,32(sp)
  800296:	8326                	mv	t1,s1
  800298:	74a2                	ld	s1,40(sp)
  80029a:	6121                	addi	sp,sp,64
  80029c:	8302                	jr	t1
  80029e:	0316d6b3          	divu	a3,a3,a7
  8002a2:	87a2                	mv	a5,s0
  8002a4:	f91ff0ef          	jal	ra,800234 <printnum>
  8002a8:	b7e9                	j	800272 <printnum+0x3e>

00000000008002aa <vprintfmt>:
  8002aa:	7119                	addi	sp,sp,-128
  8002ac:	f4a6                	sd	s1,104(sp)
  8002ae:	f0ca                	sd	s2,96(sp)
  8002b0:	ecce                	sd	s3,88(sp)
  8002b2:	e4d6                	sd	s5,72(sp)
  8002b4:	e0da                	sd	s6,64(sp)
  8002b6:	fc5e                	sd	s7,56(sp)
  8002b8:	f862                	sd	s8,48(sp)
  8002ba:	ec6e                	sd	s11,24(sp)
  8002bc:	fc86                	sd	ra,120(sp)
  8002be:	f8a2                	sd	s0,112(sp)
  8002c0:	e8d2                	sd	s4,80(sp)
  8002c2:	f466                	sd	s9,40(sp)
  8002c4:	f06a                	sd	s10,32(sp)
  8002c6:	89aa                	mv	s3,a0
  8002c8:	892e                	mv	s2,a1
  8002ca:	84b2                	mv	s1,a2
  8002cc:	8db6                	mv	s11,a3
  8002ce:	8b3a                	mv	s6,a4
  8002d0:	5bfd                	li	s7,-1
  8002d2:	00000a97          	auipc	s5,0x0
  8002d6:	4a2a8a93          	addi	s5,s5,1186 # 800774 <main+0xf8>
  8002da:	05e00c13          	li	s8,94
  8002de:	000dc503          	lbu	a0,0(s11)
  8002e2:	02500793          	li	a5,37
  8002e6:	001d8413          	addi	s0,s11,1
  8002ea:	00f50f63          	beq	a0,a5,800308 <vprintfmt+0x5e>
  8002ee:	c529                	beqz	a0,800338 <vprintfmt+0x8e>
  8002f0:	02500a13          	li	s4,37
  8002f4:	a011                	j	8002f8 <vprintfmt+0x4e>
  8002f6:	c129                	beqz	a0,800338 <vprintfmt+0x8e>
  8002f8:	864a                	mv	a2,s2
  8002fa:	85a6                	mv	a1,s1
  8002fc:	0405                	addi	s0,s0,1
  8002fe:	9982                	jalr	s3
  800300:	fff44503          	lbu	a0,-1(s0)
  800304:	ff4519e3          	bne	a0,s4,8002f6 <vprintfmt+0x4c>
  800308:	00044603          	lbu	a2,0(s0)
  80030c:	02000813          	li	a6,32
  800310:	4a01                	li	s4,0
  800312:	4881                	li	a7,0
  800314:	5d7d                	li	s10,-1
  800316:	5cfd                	li	s9,-1
  800318:	05500593          	li	a1,85
  80031c:	4525                	li	a0,9
  80031e:	fdd6071b          	addiw	a4,a2,-35
  800322:	0ff77713          	andi	a4,a4,255
  800326:	00140d93          	addi	s11,s0,1
  80032a:	22e5e363          	bltu	a1,a4,800550 <vprintfmt+0x2a6>
  80032e:	070a                	slli	a4,a4,0x2
  800330:	9756                	add	a4,a4,s5
  800332:	4318                	lw	a4,0(a4)
  800334:	9756                	add	a4,a4,s5
  800336:	8702                	jr	a4
  800338:	70e6                	ld	ra,120(sp)
  80033a:	7446                	ld	s0,112(sp)
  80033c:	74a6                	ld	s1,104(sp)
  80033e:	7906                	ld	s2,96(sp)
  800340:	69e6                	ld	s3,88(sp)
  800342:	6a46                	ld	s4,80(sp)
  800344:	6aa6                	ld	s5,72(sp)
  800346:	6b06                	ld	s6,64(sp)
  800348:	7be2                	ld	s7,56(sp)
  80034a:	7c42                	ld	s8,48(sp)
  80034c:	7ca2                	ld	s9,40(sp)
  80034e:	7d02                	ld	s10,32(sp)
  800350:	6de2                	ld	s11,24(sp)
  800352:	6109                	addi	sp,sp,128
  800354:	8082                	ret
  800356:	4705                	li	a4,1
  800358:	008b0613          	addi	a2,s6,8
  80035c:	01174463          	blt	a4,a7,800364 <vprintfmt+0xba>
  800360:	28088563          	beqz	a7,8005ea <vprintfmt+0x340>
  800364:	000b3683          	ld	a3,0(s6)
  800368:	4741                	li	a4,16
  80036a:	8b32                	mv	s6,a2
  80036c:	a86d                	j	800426 <vprintfmt+0x17c>
  80036e:	00144603          	lbu	a2,1(s0)
  800372:	4a05                	li	s4,1
  800374:	846e                	mv	s0,s11
  800376:	b765                	j	80031e <vprintfmt+0x74>
  800378:	000b2503          	lw	a0,0(s6)
  80037c:	864a                	mv	a2,s2
  80037e:	85a6                	mv	a1,s1
  800380:	0b21                	addi	s6,s6,8
  800382:	9982                	jalr	s3
  800384:	bfa9                	j	8002de <vprintfmt+0x34>
  800386:	4705                	li	a4,1
  800388:	008b0a13          	addi	s4,s6,8
  80038c:	01174463          	blt	a4,a7,800394 <vprintfmt+0xea>
  800390:	24088563          	beqz	a7,8005da <vprintfmt+0x330>
  800394:	000b3403          	ld	s0,0(s6)
  800398:	26044563          	bltz	s0,800602 <vprintfmt+0x358>
  80039c:	86a2                	mv	a3,s0
  80039e:	8b52                	mv	s6,s4
  8003a0:	4729                	li	a4,10
  8003a2:	a051                	j	800426 <vprintfmt+0x17c>
  8003a4:	000b2783          	lw	a5,0(s6)
  8003a8:	46e1                	li	a3,24
  8003aa:	0b21                	addi	s6,s6,8
  8003ac:	41f7d71b          	sraiw	a4,a5,0x1f
  8003b0:	8fb9                	xor	a5,a5,a4
  8003b2:	40e7873b          	subw	a4,a5,a4
  8003b6:	1ce6c163          	blt	a3,a4,800578 <vprintfmt+0x2ce>
  8003ba:	00371793          	slli	a5,a4,0x3
  8003be:	00000697          	auipc	a3,0x0
  8003c2:	51268693          	addi	a3,a3,1298 # 8008d0 <error_string>
  8003c6:	97b6                	add	a5,a5,a3
  8003c8:	639c                	ld	a5,0(a5)
  8003ca:	1a078763          	beqz	a5,800578 <vprintfmt+0x2ce>
  8003ce:	873e                	mv	a4,a5
  8003d0:	00000697          	auipc	a3,0x0
  8003d4:	7d068693          	addi	a3,a3,2000 # 800ba0 <error_string+0x2d0>
  8003d8:	8626                	mv	a2,s1
  8003da:	85ca                	mv	a1,s2
  8003dc:	854e                	mv	a0,s3
  8003de:	25a000ef          	jal	ra,800638 <printfmt>
  8003e2:	bdf5                	j	8002de <vprintfmt+0x34>
  8003e4:	00144603          	lbu	a2,1(s0)
  8003e8:	2885                	addiw	a7,a7,1
  8003ea:	846e                	mv	s0,s11
  8003ec:	bf0d                	j	80031e <vprintfmt+0x74>
  8003ee:	4705                	li	a4,1
  8003f0:	008b0613          	addi	a2,s6,8
  8003f4:	01174463          	blt	a4,a7,8003fc <vprintfmt+0x152>
  8003f8:	1e088e63          	beqz	a7,8005f4 <vprintfmt+0x34a>
  8003fc:	000b3683          	ld	a3,0(s6)
  800400:	4721                	li	a4,8
  800402:	8b32                	mv	s6,a2
  800404:	a00d                	j	800426 <vprintfmt+0x17c>
  800406:	03000513          	li	a0,48
  80040a:	864a                	mv	a2,s2
  80040c:	85a6                	mv	a1,s1
  80040e:	e042                	sd	a6,0(sp)
  800410:	9982                	jalr	s3
  800412:	864a                	mv	a2,s2
  800414:	85a6                	mv	a1,s1
  800416:	07800513          	li	a0,120
  80041a:	9982                	jalr	s3
  80041c:	0b21                	addi	s6,s6,8
  80041e:	ff8b3683          	ld	a3,-8(s6)
  800422:	6802                	ld	a6,0(sp)
  800424:	4741                	li	a4,16
  800426:	87e6                	mv	a5,s9
  800428:	8626                	mv	a2,s1
  80042a:	85ca                	mv	a1,s2
  80042c:	854e                	mv	a0,s3
  80042e:	e07ff0ef          	jal	ra,800234 <printnum>
  800432:	b575                	j	8002de <vprintfmt+0x34>
  800434:	000b3703          	ld	a4,0(s6)
  800438:	0b21                	addi	s6,s6,8
  80043a:	1e070063          	beqz	a4,80061a <vprintfmt+0x370>
  80043e:	00170413          	addi	s0,a4,1
  800442:	19905563          	blez	s9,8005cc <vprintfmt+0x322>
  800446:	02d00613          	li	a2,45
  80044a:	14c81963          	bne	a6,a2,80059c <vprintfmt+0x2f2>
  80044e:	00074703          	lbu	a4,0(a4)
  800452:	0007051b          	sext.w	a0,a4
  800456:	c90d                	beqz	a0,800488 <vprintfmt+0x1de>
  800458:	000d4563          	bltz	s10,800462 <vprintfmt+0x1b8>
  80045c:	3d7d                	addiw	s10,s10,-1
  80045e:	037d0363          	beq	s10,s7,800484 <vprintfmt+0x1da>
  800462:	864a                	mv	a2,s2
  800464:	85a6                	mv	a1,s1
  800466:	180a0c63          	beqz	s4,8005fe <vprintfmt+0x354>
  80046a:	3701                	addiw	a4,a4,-32
  80046c:	18ec7963          	bleu	a4,s8,8005fe <vprintfmt+0x354>
  800470:	03f00513          	li	a0,63
  800474:	9982                	jalr	s3
  800476:	0405                	addi	s0,s0,1
  800478:	fff44703          	lbu	a4,-1(s0)
  80047c:	3cfd                	addiw	s9,s9,-1
  80047e:	0007051b          	sext.w	a0,a4
  800482:	f979                	bnez	a0,800458 <vprintfmt+0x1ae>
  800484:	e5905de3          	blez	s9,8002de <vprintfmt+0x34>
  800488:	3cfd                	addiw	s9,s9,-1
  80048a:	864a                	mv	a2,s2
  80048c:	85a6                	mv	a1,s1
  80048e:	02000513          	li	a0,32
  800492:	9982                	jalr	s3
  800494:	e40c85e3          	beqz	s9,8002de <vprintfmt+0x34>
  800498:	3cfd                	addiw	s9,s9,-1
  80049a:	864a                	mv	a2,s2
  80049c:	85a6                	mv	a1,s1
  80049e:	02000513          	li	a0,32
  8004a2:	9982                	jalr	s3
  8004a4:	fe0c92e3          	bnez	s9,800488 <vprintfmt+0x1de>
  8004a8:	bd1d                	j	8002de <vprintfmt+0x34>
  8004aa:	4705                	li	a4,1
  8004ac:	008b0613          	addi	a2,s6,8
  8004b0:	01174463          	blt	a4,a7,8004b8 <vprintfmt+0x20e>
  8004b4:	12088663          	beqz	a7,8005e0 <vprintfmt+0x336>
  8004b8:	000b3683          	ld	a3,0(s6)
  8004bc:	4729                	li	a4,10
  8004be:	8b32                	mv	s6,a2
  8004c0:	b79d                	j	800426 <vprintfmt+0x17c>
  8004c2:	00144603          	lbu	a2,1(s0)
  8004c6:	02d00813          	li	a6,45
  8004ca:	846e                	mv	s0,s11
  8004cc:	bd89                	j	80031e <vprintfmt+0x74>
  8004ce:	864a                	mv	a2,s2
  8004d0:	85a6                	mv	a1,s1
  8004d2:	02500513          	li	a0,37
  8004d6:	9982                	jalr	s3
  8004d8:	b519                	j	8002de <vprintfmt+0x34>
  8004da:	000b2d03          	lw	s10,0(s6)
  8004de:	00144603          	lbu	a2,1(s0)
  8004e2:	0b21                	addi	s6,s6,8
  8004e4:	846e                	mv	s0,s11
  8004e6:	e20cdce3          	bgez	s9,80031e <vprintfmt+0x74>
  8004ea:	8cea                	mv	s9,s10
  8004ec:	5d7d                	li	s10,-1
  8004ee:	bd05                	j	80031e <vprintfmt+0x74>
  8004f0:	00144603          	lbu	a2,1(s0)
  8004f4:	03000813          	li	a6,48
  8004f8:	846e                	mv	s0,s11
  8004fa:	b515                	j	80031e <vprintfmt+0x74>
  8004fc:	fd060d1b          	addiw	s10,a2,-48
  800500:	00144603          	lbu	a2,1(s0)
  800504:	846e                	mv	s0,s11
  800506:	fd06071b          	addiw	a4,a2,-48
  80050a:	0006031b          	sext.w	t1,a2
  80050e:	fce56ce3          	bltu	a0,a4,8004e6 <vprintfmt+0x23c>
  800512:	0405                	addi	s0,s0,1
  800514:	002d171b          	slliw	a4,s10,0x2
  800518:	00044603          	lbu	a2,0(s0)
  80051c:	01a706bb          	addw	a3,a4,s10
  800520:	0016969b          	slliw	a3,a3,0x1
  800524:	006686bb          	addw	a3,a3,t1
  800528:	fd06071b          	addiw	a4,a2,-48
  80052c:	fd068d1b          	addiw	s10,a3,-48
  800530:	0006031b          	sext.w	t1,a2
  800534:	fce57fe3          	bleu	a4,a0,800512 <vprintfmt+0x268>
  800538:	b77d                	j	8004e6 <vprintfmt+0x23c>
  80053a:	fffcc713          	not	a4,s9
  80053e:	977d                	srai	a4,a4,0x3f
  800540:	00ecf7b3          	and	a5,s9,a4
  800544:	00144603          	lbu	a2,1(s0)
  800548:	00078c9b          	sext.w	s9,a5
  80054c:	846e                	mv	s0,s11
  80054e:	bbc1                	j	80031e <vprintfmt+0x74>
  800550:	864a                	mv	a2,s2
  800552:	85a6                	mv	a1,s1
  800554:	02500513          	li	a0,37
  800558:	9982                	jalr	s3
  80055a:	fff44703          	lbu	a4,-1(s0)
  80055e:	02500793          	li	a5,37
  800562:	8da2                	mv	s11,s0
  800564:	d6f70de3          	beq	a4,a5,8002de <vprintfmt+0x34>
  800568:	02500713          	li	a4,37
  80056c:	1dfd                	addi	s11,s11,-1
  80056e:	fffdc783          	lbu	a5,-1(s11)
  800572:	fee79de3          	bne	a5,a4,80056c <vprintfmt+0x2c2>
  800576:	b3a5                	j	8002de <vprintfmt+0x34>
  800578:	00000697          	auipc	a3,0x0
  80057c:	61868693          	addi	a3,a3,1560 # 800b90 <error_string+0x2c0>
  800580:	8626                	mv	a2,s1
  800582:	85ca                	mv	a1,s2
  800584:	854e                	mv	a0,s3
  800586:	0b2000ef          	jal	ra,800638 <printfmt>
  80058a:	bb91                	j	8002de <vprintfmt+0x34>
  80058c:	00000717          	auipc	a4,0x0
  800590:	5fc70713          	addi	a4,a4,1532 # 800b88 <error_string+0x2b8>
  800594:	00000417          	auipc	s0,0x0
  800598:	5f540413          	addi	s0,s0,1525 # 800b89 <error_string+0x2b9>
  80059c:	853a                	mv	a0,a4
  80059e:	85ea                	mv	a1,s10
  8005a0:	e03a                	sd	a4,0(sp)
  8005a2:	e442                	sd	a6,8(sp)
  8005a4:	0b2000ef          	jal	ra,800656 <strnlen>
  8005a8:	40ac8cbb          	subw	s9,s9,a0
  8005ac:	6702                	ld	a4,0(sp)
  8005ae:	01905f63          	blez	s9,8005cc <vprintfmt+0x322>
  8005b2:	6822                	ld	a6,8(sp)
  8005b4:	0008079b          	sext.w	a5,a6
  8005b8:	e43e                	sd	a5,8(sp)
  8005ba:	6522                	ld	a0,8(sp)
  8005bc:	864a                	mv	a2,s2
  8005be:	85a6                	mv	a1,s1
  8005c0:	e03a                	sd	a4,0(sp)
  8005c2:	3cfd                	addiw	s9,s9,-1
  8005c4:	9982                	jalr	s3
  8005c6:	6702                	ld	a4,0(sp)
  8005c8:	fe0c99e3          	bnez	s9,8005ba <vprintfmt+0x310>
  8005cc:	00074703          	lbu	a4,0(a4)
  8005d0:	0007051b          	sext.w	a0,a4
  8005d4:	e80512e3          	bnez	a0,800458 <vprintfmt+0x1ae>
  8005d8:	b319                	j	8002de <vprintfmt+0x34>
  8005da:	000b2403          	lw	s0,0(s6)
  8005de:	bb6d                	j	800398 <vprintfmt+0xee>
  8005e0:	000b6683          	lwu	a3,0(s6)
  8005e4:	4729                	li	a4,10
  8005e6:	8b32                	mv	s6,a2
  8005e8:	bd3d                	j	800426 <vprintfmt+0x17c>
  8005ea:	000b6683          	lwu	a3,0(s6)
  8005ee:	4741                	li	a4,16
  8005f0:	8b32                	mv	s6,a2
  8005f2:	bd15                	j	800426 <vprintfmt+0x17c>
  8005f4:	000b6683          	lwu	a3,0(s6)
  8005f8:	4721                	li	a4,8
  8005fa:	8b32                	mv	s6,a2
  8005fc:	b52d                	j	800426 <vprintfmt+0x17c>
  8005fe:	9982                	jalr	s3
  800600:	bd9d                	j	800476 <vprintfmt+0x1cc>
  800602:	864a                	mv	a2,s2
  800604:	85a6                	mv	a1,s1
  800606:	02d00513          	li	a0,45
  80060a:	e042                	sd	a6,0(sp)
  80060c:	9982                	jalr	s3
  80060e:	8b52                	mv	s6,s4
  800610:	408006b3          	neg	a3,s0
  800614:	4729                	li	a4,10
  800616:	6802                	ld	a6,0(sp)
  800618:	b539                	j	800426 <vprintfmt+0x17c>
  80061a:	01905663          	blez	s9,800626 <vprintfmt+0x37c>
  80061e:	02d00713          	li	a4,45
  800622:	f6e815e3          	bne	a6,a4,80058c <vprintfmt+0x2e2>
  800626:	00000417          	auipc	s0,0x0
  80062a:	56340413          	addi	s0,s0,1379 # 800b89 <error_string+0x2b9>
  80062e:	02800513          	li	a0,40
  800632:	02800713          	li	a4,40
  800636:	b50d                	j	800458 <vprintfmt+0x1ae>

0000000000800638 <printfmt>:
  800638:	7139                	addi	sp,sp,-64
  80063a:	02010313          	addi	t1,sp,32
  80063e:	f03a                	sd	a4,32(sp)
  800640:	871a                	mv	a4,t1
  800642:	ec06                	sd	ra,24(sp)
  800644:	f43e                	sd	a5,40(sp)
  800646:	f842                	sd	a6,48(sp)
  800648:	fc46                	sd	a7,56(sp)
  80064a:	e41a                	sd	t1,8(sp)
  80064c:	c5fff0ef          	jal	ra,8002aa <vprintfmt>
  800650:	60e2                	ld	ra,24(sp)
  800652:	6121                	addi	sp,sp,64
  800654:	8082                	ret

0000000000800656 <strnlen>:
  800656:	c185                	beqz	a1,800676 <strnlen+0x20>
  800658:	00054783          	lbu	a5,0(a0)
  80065c:	cf89                	beqz	a5,800676 <strnlen+0x20>
  80065e:	4781                	li	a5,0
  800660:	a021                	j	800668 <strnlen+0x12>
  800662:	00074703          	lbu	a4,0(a4)
  800666:	c711                	beqz	a4,800672 <strnlen+0x1c>
  800668:	0785                	addi	a5,a5,1
  80066a:	00f50733          	add	a4,a0,a5
  80066e:	fef59ae3          	bne	a1,a5,800662 <strnlen+0xc>
  800672:	853e                	mv	a0,a5
  800674:	8082                	ret
  800676:	4781                	li	a5,0
  800678:	853e                	mv	a0,a5
  80067a:	8082                	ret

000000000080067c <main>:
  80067c:	1141                	addi	sp,sp,-16
  80067e:	00000517          	auipc	a0,0x0
  800682:	52a50513          	addi	a0,a0,1322 # 800ba8 <error_string+0x2d8>
  800686:	e406                	sd	ra,8(sp)
  800688:	a31ff0ef          	jal	ra,8000b8 <cprintf>
  80068c:	aedff0ef          	jal	ra,800178 <getpid>
  800690:	85aa                	mv	a1,a0
  800692:	00000517          	auipc	a0,0x0
  800696:	52650513          	addi	a0,a0,1318 # 800bb8 <error_string+0x2e8>
  80069a:	a1fff0ef          	jal	ra,8000b8 <cprintf>
  80069e:	00000517          	auipc	a0,0x0
  8006a2:	53250513          	addi	a0,a0,1330 # 800bd0 <error_string+0x300>
  8006a6:	a13ff0ef          	jal	ra,8000b8 <cprintf>
  8006aa:	60a2                	ld	ra,8(sp)
  8006ac:	4501                	li	a0,0
  8006ae:	0141                	addi	sp,sp,16
  8006b0:	8082                	ret
