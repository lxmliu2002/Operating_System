
obj/__user_priority.out：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000000800020 <open>:
  800020:	1582                	slli	a1,a1,0x20
  800022:	9181                	srli	a1,a1,0x20
  800024:	1840006f          	j	8001a8 <sys_open>

0000000000800028 <close>:
  800028:	18c0006f          	j	8001b4 <sys_close>

000000000080002c <dup2>:
  80002c:	1920006f          	j	8001be <sys_dup>

0000000000800030 <_start>:
  800030:	210000ef          	jal	ra,800240 <umain>
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
  800048:	88450513          	addi	a0,a0,-1916 # 8008c8 <main+0x1ba>
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
  800068:	8dc50513          	addi	a0,a0,-1828 # 800940 <main+0x232>
  80006c:	08c000ef          	jal	ra,8000f8 <cprintf>
  800070:	5559                	li	a0,-10
  800072:	158000ef          	jal	ra,8001ca <exit>

0000000000800076 <__warn>:
  800076:	715d                	addi	sp,sp,-80
  800078:	e822                	sd	s0,16(sp)
  80007a:	fc3e                	sd	a5,56(sp)
  80007c:	8432                	mv	s0,a2
  80007e:	103c                	addi	a5,sp,40
  800080:	862e                	mv	a2,a1
  800082:	85aa                	mv	a1,a0
  800084:	00001517          	auipc	a0,0x1
  800088:	86450513          	addi	a0,a0,-1948 # 8008e8 <main+0x1da>
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
  8000a8:	89c50513          	addi	a0,a0,-1892 # 800940 <main+0x232>
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
  8000c0:	0d0000ef          	jal	ra,800190 <sys_putc>
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
  8000e4:	ad958593          	addi	a1,a1,-1319 # ffffffffffff6ad9 <pids+0xffffffffff7f5aa9>
  8000e8:	ec06                	sd	ra,24(sp)
  8000ea:	c602                	sw	zero,12(sp)
  8000ec:	23e000ef          	jal	ra,80032a <vprintfmt>
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
  800116:	ad958593          	addi	a1,a1,-1319 # ffffffffffff6ad9 <pids+0xffffffffff7f5aa9>
  80011a:	ec06                	sd	ra,24(sp)
  80011c:	e4be                	sd	a5,72(sp)
  80011e:	e8c2                	sd	a6,80(sp)
  800120:	ecc6                	sd	a7,88(sp)
  800122:	e41a                	sd	t1,8(sp)
  800124:	c202                	sw	zero,4(sp)
  800126:	204000ef          	jal	ra,80032a <vprintfmt>
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

0000000000800182 <sys_kill>:
  800182:	85aa                	mv	a1,a0
  800184:	4531                	li	a0,12
  800186:	fadff06f          	j	800132 <syscall>

000000000080018a <sys_getpid>:
  80018a:	4549                	li	a0,18
  80018c:	fa7ff06f          	j	800132 <syscall>

0000000000800190 <sys_putc>:
  800190:	85aa                	mv	a1,a0
  800192:	4579                	li	a0,30
  800194:	f9fff06f          	j	800132 <syscall>

0000000000800198 <sys_lab6_set_priority>:
  800198:	85aa                	mv	a1,a0
  80019a:	0ff00513          	li	a0,255
  80019e:	f95ff06f          	j	800132 <syscall>

00000000008001a2 <sys_gettime>:
  8001a2:	4545                	li	a0,17
  8001a4:	f8fff06f          	j	800132 <syscall>

00000000008001a8 <sys_open>:
  8001a8:	862e                	mv	a2,a1
  8001aa:	85aa                	mv	a1,a0
  8001ac:	06400513          	li	a0,100
  8001b0:	f83ff06f          	j	800132 <syscall>

00000000008001b4 <sys_close>:
  8001b4:	85aa                	mv	a1,a0
  8001b6:	06500513          	li	a0,101
  8001ba:	f79ff06f          	j	800132 <syscall>

00000000008001be <sys_dup>:
  8001be:	862e                	mv	a2,a1
  8001c0:	85aa                	mv	a1,a0
  8001c2:	08200513          	li	a0,130
  8001c6:	f6dff06f          	j	800132 <syscall>

00000000008001ca <exit>:
  8001ca:	1141                	addi	sp,sp,-16
  8001cc:	e406                	sd	ra,8(sp)
  8001ce:	f9dff0ef          	jal	ra,80016a <sys_exit>
  8001d2:	00000517          	auipc	a0,0x0
  8001d6:	73650513          	addi	a0,a0,1846 # 800908 <main+0x1fa>
  8001da:	f1fff0ef          	jal	ra,8000f8 <cprintf>
  8001de:	a001                	j	8001de <exit+0x14>

00000000008001e0 <fork>:
  8001e0:	f93ff06f          	j	800172 <sys_fork>

00000000008001e4 <waitpid>:
  8001e4:	f95ff06f          	j	800178 <sys_wait>

00000000008001e8 <kill>:
  8001e8:	f9bff06f          	j	800182 <sys_kill>

00000000008001ec <getpid>:
  8001ec:	f9fff06f          	j	80018a <sys_getpid>

00000000008001f0 <gettime_msec>:
  8001f0:	fb3ff06f          	j	8001a2 <sys_gettime>

00000000008001f4 <lab6_set_priority>:
  8001f4:	1502                	slli	a0,a0,0x20
  8001f6:	9101                	srli	a0,a0,0x20
  8001f8:	fa1ff06f          	j	800198 <sys_lab6_set_priority>

00000000008001fc <initfd>:
  8001fc:	1101                	addi	sp,sp,-32
  8001fe:	87ae                	mv	a5,a1
  800200:	e426                	sd	s1,8(sp)
  800202:	85b2                	mv	a1,a2
  800204:	84aa                	mv	s1,a0
  800206:	853e                	mv	a0,a5
  800208:	e822                	sd	s0,16(sp)
  80020a:	ec06                	sd	ra,24(sp)
  80020c:	e15ff0ef          	jal	ra,800020 <open>
  800210:	842a                	mv	s0,a0
  800212:	00054463          	bltz	a0,80021a <initfd+0x1e>
  800216:	00951863          	bne	a0,s1,800226 <initfd+0x2a>
  80021a:	8522                	mv	a0,s0
  80021c:	60e2                	ld	ra,24(sp)
  80021e:	6442                	ld	s0,16(sp)
  800220:	64a2                	ld	s1,8(sp)
  800222:	6105                	addi	sp,sp,32
  800224:	8082                	ret
  800226:	8526                	mv	a0,s1
  800228:	e01ff0ef          	jal	ra,800028 <close>
  80022c:	85a6                	mv	a1,s1
  80022e:	8522                	mv	a0,s0
  800230:	dfdff0ef          	jal	ra,80002c <dup2>
  800234:	84aa                	mv	s1,a0
  800236:	8522                	mv	a0,s0
  800238:	df1ff0ef          	jal	ra,800028 <close>
  80023c:	8426                	mv	s0,s1
  80023e:	bff1                	j	80021a <initfd+0x1e>

0000000000800240 <umain>:
  800240:	1101                	addi	sp,sp,-32
  800242:	e822                	sd	s0,16(sp)
  800244:	e426                	sd	s1,8(sp)
  800246:	842a                	mv	s0,a0
  800248:	84ae                	mv	s1,a1
  80024a:	4601                	li	a2,0
  80024c:	00000597          	auipc	a1,0x0
  800250:	6d458593          	addi	a1,a1,1748 # 800920 <main+0x212>
  800254:	4501                	li	a0,0
  800256:	ec06                	sd	ra,24(sp)
  800258:	fa5ff0ef          	jal	ra,8001fc <initfd>
  80025c:	02054263          	bltz	a0,800280 <umain+0x40>
  800260:	4605                	li	a2,1
  800262:	00000597          	auipc	a1,0x0
  800266:	6fe58593          	addi	a1,a1,1790 # 800960 <main+0x252>
  80026a:	4505                	li	a0,1
  80026c:	f91ff0ef          	jal	ra,8001fc <initfd>
  800270:	02054563          	bltz	a0,80029a <umain+0x5a>
  800274:	85a6                	mv	a1,s1
  800276:	8522                	mv	a0,s0
  800278:	496000ef          	jal	ra,80070e <main>
  80027c:	f4fff0ef          	jal	ra,8001ca <exit>
  800280:	86aa                	mv	a3,a0
  800282:	00000617          	auipc	a2,0x0
  800286:	6a660613          	addi	a2,a2,1702 # 800928 <main+0x21a>
  80028a:	45e9                	li	a1,26
  80028c:	00000517          	auipc	a0,0x0
  800290:	6bc50513          	addi	a0,a0,1724 # 800948 <main+0x23a>
  800294:	de3ff0ef          	jal	ra,800076 <__warn>
  800298:	b7e1                	j	800260 <umain+0x20>
  80029a:	86aa                	mv	a3,a0
  80029c:	00000617          	auipc	a2,0x0
  8002a0:	6cc60613          	addi	a2,a2,1740 # 800968 <main+0x25a>
  8002a4:	45f5                	li	a1,29
  8002a6:	00000517          	auipc	a0,0x0
  8002aa:	6a250513          	addi	a0,a0,1698 # 800948 <main+0x23a>
  8002ae:	dc9ff0ef          	jal	ra,800076 <__warn>
  8002b2:	b7c9                	j	800274 <umain+0x34>

00000000008002b4 <printnum>:
  8002b4:	02071893          	slli	a7,a4,0x20
  8002b8:	7139                	addi	sp,sp,-64
  8002ba:	0208d893          	srli	a7,a7,0x20
  8002be:	e456                	sd	s5,8(sp)
  8002c0:	0316fab3          	remu	s5,a3,a7
  8002c4:	f822                	sd	s0,48(sp)
  8002c6:	f426                	sd	s1,40(sp)
  8002c8:	f04a                	sd	s2,32(sp)
  8002ca:	ec4e                	sd	s3,24(sp)
  8002cc:	fc06                	sd	ra,56(sp)
  8002ce:	e852                	sd	s4,16(sp)
  8002d0:	84aa                	mv	s1,a0
  8002d2:	89ae                	mv	s3,a1
  8002d4:	8932                	mv	s2,a2
  8002d6:	fff7841b          	addiw	s0,a5,-1
  8002da:	2a81                	sext.w	s5,s5
  8002dc:	0516f163          	bleu	a7,a3,80031e <printnum+0x6a>
  8002e0:	8a42                	mv	s4,a6
  8002e2:	00805863          	blez	s0,8002f2 <printnum+0x3e>
  8002e6:	347d                	addiw	s0,s0,-1
  8002e8:	864e                	mv	a2,s3
  8002ea:	85ca                	mv	a1,s2
  8002ec:	8552                	mv	a0,s4
  8002ee:	9482                	jalr	s1
  8002f0:	f87d                	bnez	s0,8002e6 <printnum+0x32>
  8002f2:	1a82                	slli	s5,s5,0x20
  8002f4:	020ada93          	srli	s5,s5,0x20
  8002f8:	00001797          	auipc	a5,0x1
  8002fc:	8b078793          	addi	a5,a5,-1872 # 800ba8 <error_string+0xc8>
  800300:	9abe                	add	s5,s5,a5
  800302:	7442                	ld	s0,48(sp)
  800304:	000ac503          	lbu	a0,0(s5)
  800308:	70e2                	ld	ra,56(sp)
  80030a:	6a42                	ld	s4,16(sp)
  80030c:	6aa2                	ld	s5,8(sp)
  80030e:	864e                	mv	a2,s3
  800310:	85ca                	mv	a1,s2
  800312:	69e2                	ld	s3,24(sp)
  800314:	7902                	ld	s2,32(sp)
  800316:	8326                	mv	t1,s1
  800318:	74a2                	ld	s1,40(sp)
  80031a:	6121                	addi	sp,sp,64
  80031c:	8302                	jr	t1
  80031e:	0316d6b3          	divu	a3,a3,a7
  800322:	87a2                	mv	a5,s0
  800324:	f91ff0ef          	jal	ra,8002b4 <printnum>
  800328:	b7e9                	j	8002f2 <printnum+0x3e>

000000000080032a <vprintfmt>:
  80032a:	7119                	addi	sp,sp,-128
  80032c:	f4a6                	sd	s1,104(sp)
  80032e:	f0ca                	sd	s2,96(sp)
  800330:	ecce                	sd	s3,88(sp)
  800332:	e4d6                	sd	s5,72(sp)
  800334:	e0da                	sd	s6,64(sp)
  800336:	fc5e                	sd	s7,56(sp)
  800338:	f862                	sd	s8,48(sp)
  80033a:	ec6e                	sd	s11,24(sp)
  80033c:	fc86                	sd	ra,120(sp)
  80033e:	f8a2                	sd	s0,112(sp)
  800340:	e8d2                	sd	s4,80(sp)
  800342:	f466                	sd	s9,40(sp)
  800344:	f06a                	sd	s10,32(sp)
  800346:	89aa                	mv	s3,a0
  800348:	892e                	mv	s2,a1
  80034a:	84b2                	mv	s1,a2
  80034c:	8db6                	mv	s11,a3
  80034e:	8b3a                	mv	s6,a4
  800350:	5bfd                	li	s7,-1
  800352:	00000a97          	auipc	s5,0x0
  800356:	632a8a93          	addi	s5,s5,1586 # 800984 <main+0x276>
  80035a:	05e00c13          	li	s8,94
  80035e:	000dc503          	lbu	a0,0(s11)
  800362:	02500793          	li	a5,37
  800366:	001d8413          	addi	s0,s11,1
  80036a:	00f50f63          	beq	a0,a5,800388 <vprintfmt+0x5e>
  80036e:	c529                	beqz	a0,8003b8 <vprintfmt+0x8e>
  800370:	02500a13          	li	s4,37
  800374:	a011                	j	800378 <vprintfmt+0x4e>
  800376:	c129                	beqz	a0,8003b8 <vprintfmt+0x8e>
  800378:	864a                	mv	a2,s2
  80037a:	85a6                	mv	a1,s1
  80037c:	0405                	addi	s0,s0,1
  80037e:	9982                	jalr	s3
  800380:	fff44503          	lbu	a0,-1(s0)
  800384:	ff4519e3          	bne	a0,s4,800376 <vprintfmt+0x4c>
  800388:	00044603          	lbu	a2,0(s0)
  80038c:	02000813          	li	a6,32
  800390:	4a01                	li	s4,0
  800392:	4881                	li	a7,0
  800394:	5d7d                	li	s10,-1
  800396:	5cfd                	li	s9,-1
  800398:	05500593          	li	a1,85
  80039c:	4525                	li	a0,9
  80039e:	fdd6071b          	addiw	a4,a2,-35
  8003a2:	0ff77713          	andi	a4,a4,255
  8003a6:	00140d93          	addi	s11,s0,1
  8003aa:	22e5e363          	bltu	a1,a4,8005d0 <vprintfmt+0x2a6>
  8003ae:	070a                	slli	a4,a4,0x2
  8003b0:	9756                	add	a4,a4,s5
  8003b2:	4318                	lw	a4,0(a4)
  8003b4:	9756                	add	a4,a4,s5
  8003b6:	8702                	jr	a4
  8003b8:	70e6                	ld	ra,120(sp)
  8003ba:	7446                	ld	s0,112(sp)
  8003bc:	74a6                	ld	s1,104(sp)
  8003be:	7906                	ld	s2,96(sp)
  8003c0:	69e6                	ld	s3,88(sp)
  8003c2:	6a46                	ld	s4,80(sp)
  8003c4:	6aa6                	ld	s5,72(sp)
  8003c6:	6b06                	ld	s6,64(sp)
  8003c8:	7be2                	ld	s7,56(sp)
  8003ca:	7c42                	ld	s8,48(sp)
  8003cc:	7ca2                	ld	s9,40(sp)
  8003ce:	7d02                	ld	s10,32(sp)
  8003d0:	6de2                	ld	s11,24(sp)
  8003d2:	6109                	addi	sp,sp,128
  8003d4:	8082                	ret
  8003d6:	4705                	li	a4,1
  8003d8:	008b0613          	addi	a2,s6,8
  8003dc:	01174463          	blt	a4,a7,8003e4 <vprintfmt+0xba>
  8003e0:	28088563          	beqz	a7,80066a <vprintfmt+0x340>
  8003e4:	000b3683          	ld	a3,0(s6)
  8003e8:	4741                	li	a4,16
  8003ea:	8b32                	mv	s6,a2
  8003ec:	a86d                	j	8004a6 <vprintfmt+0x17c>
  8003ee:	00144603          	lbu	a2,1(s0)
  8003f2:	4a05                	li	s4,1
  8003f4:	846e                	mv	s0,s11
  8003f6:	b765                	j	80039e <vprintfmt+0x74>
  8003f8:	000b2503          	lw	a0,0(s6)
  8003fc:	864a                	mv	a2,s2
  8003fe:	85a6                	mv	a1,s1
  800400:	0b21                	addi	s6,s6,8
  800402:	9982                	jalr	s3
  800404:	bfa9                	j	80035e <vprintfmt+0x34>
  800406:	4705                	li	a4,1
  800408:	008b0a13          	addi	s4,s6,8
  80040c:	01174463          	blt	a4,a7,800414 <vprintfmt+0xea>
  800410:	24088563          	beqz	a7,80065a <vprintfmt+0x330>
  800414:	000b3403          	ld	s0,0(s6)
  800418:	26044563          	bltz	s0,800682 <vprintfmt+0x358>
  80041c:	86a2                	mv	a3,s0
  80041e:	8b52                	mv	s6,s4
  800420:	4729                	li	a4,10
  800422:	a051                	j	8004a6 <vprintfmt+0x17c>
  800424:	000b2783          	lw	a5,0(s6)
  800428:	46e1                	li	a3,24
  80042a:	0b21                	addi	s6,s6,8
  80042c:	41f7d71b          	sraiw	a4,a5,0x1f
  800430:	8fb9                	xor	a5,a5,a4
  800432:	40e7873b          	subw	a4,a5,a4
  800436:	1ce6c163          	blt	a3,a4,8005f8 <vprintfmt+0x2ce>
  80043a:	00371793          	slli	a5,a4,0x3
  80043e:	00000697          	auipc	a3,0x0
  800442:	6a268693          	addi	a3,a3,1698 # 800ae0 <error_string>
  800446:	97b6                	add	a5,a5,a3
  800448:	639c                	ld	a5,0(a5)
  80044a:	1a078763          	beqz	a5,8005f8 <vprintfmt+0x2ce>
  80044e:	873e                	mv	a4,a5
  800450:	00001697          	auipc	a3,0x1
  800454:	96068693          	addi	a3,a3,-1696 # 800db0 <error_string+0x2d0>
  800458:	8626                	mv	a2,s1
  80045a:	85ca                	mv	a1,s2
  80045c:	854e                	mv	a0,s3
  80045e:	25a000ef          	jal	ra,8006b8 <printfmt>
  800462:	bdf5                	j	80035e <vprintfmt+0x34>
  800464:	00144603          	lbu	a2,1(s0)
  800468:	2885                	addiw	a7,a7,1
  80046a:	846e                	mv	s0,s11
  80046c:	bf0d                	j	80039e <vprintfmt+0x74>
  80046e:	4705                	li	a4,1
  800470:	008b0613          	addi	a2,s6,8
  800474:	01174463          	blt	a4,a7,80047c <vprintfmt+0x152>
  800478:	1e088e63          	beqz	a7,800674 <vprintfmt+0x34a>
  80047c:	000b3683          	ld	a3,0(s6)
  800480:	4721                	li	a4,8
  800482:	8b32                	mv	s6,a2
  800484:	a00d                	j	8004a6 <vprintfmt+0x17c>
  800486:	03000513          	li	a0,48
  80048a:	864a                	mv	a2,s2
  80048c:	85a6                	mv	a1,s1
  80048e:	e042                	sd	a6,0(sp)
  800490:	9982                	jalr	s3
  800492:	864a                	mv	a2,s2
  800494:	85a6                	mv	a1,s1
  800496:	07800513          	li	a0,120
  80049a:	9982                	jalr	s3
  80049c:	0b21                	addi	s6,s6,8
  80049e:	ff8b3683          	ld	a3,-8(s6)
  8004a2:	6802                	ld	a6,0(sp)
  8004a4:	4741                	li	a4,16
  8004a6:	87e6                	mv	a5,s9
  8004a8:	8626                	mv	a2,s1
  8004aa:	85ca                	mv	a1,s2
  8004ac:	854e                	mv	a0,s3
  8004ae:	e07ff0ef          	jal	ra,8002b4 <printnum>
  8004b2:	b575                	j	80035e <vprintfmt+0x34>
  8004b4:	000b3703          	ld	a4,0(s6)
  8004b8:	0b21                	addi	s6,s6,8
  8004ba:	1e070063          	beqz	a4,80069a <vprintfmt+0x370>
  8004be:	00170413          	addi	s0,a4,1
  8004c2:	19905563          	blez	s9,80064c <vprintfmt+0x322>
  8004c6:	02d00613          	li	a2,45
  8004ca:	14c81963          	bne	a6,a2,80061c <vprintfmt+0x2f2>
  8004ce:	00074703          	lbu	a4,0(a4)
  8004d2:	0007051b          	sext.w	a0,a4
  8004d6:	c90d                	beqz	a0,800508 <vprintfmt+0x1de>
  8004d8:	000d4563          	bltz	s10,8004e2 <vprintfmt+0x1b8>
  8004dc:	3d7d                	addiw	s10,s10,-1
  8004de:	037d0363          	beq	s10,s7,800504 <vprintfmt+0x1da>
  8004e2:	864a                	mv	a2,s2
  8004e4:	85a6                	mv	a1,s1
  8004e6:	180a0c63          	beqz	s4,80067e <vprintfmt+0x354>
  8004ea:	3701                	addiw	a4,a4,-32
  8004ec:	18ec7963          	bleu	a4,s8,80067e <vprintfmt+0x354>
  8004f0:	03f00513          	li	a0,63
  8004f4:	9982                	jalr	s3
  8004f6:	0405                	addi	s0,s0,1
  8004f8:	fff44703          	lbu	a4,-1(s0)
  8004fc:	3cfd                	addiw	s9,s9,-1
  8004fe:	0007051b          	sext.w	a0,a4
  800502:	f979                	bnez	a0,8004d8 <vprintfmt+0x1ae>
  800504:	e5905de3          	blez	s9,80035e <vprintfmt+0x34>
  800508:	3cfd                	addiw	s9,s9,-1
  80050a:	864a                	mv	a2,s2
  80050c:	85a6                	mv	a1,s1
  80050e:	02000513          	li	a0,32
  800512:	9982                	jalr	s3
  800514:	e40c85e3          	beqz	s9,80035e <vprintfmt+0x34>
  800518:	3cfd                	addiw	s9,s9,-1
  80051a:	864a                	mv	a2,s2
  80051c:	85a6                	mv	a1,s1
  80051e:	02000513          	li	a0,32
  800522:	9982                	jalr	s3
  800524:	fe0c92e3          	bnez	s9,800508 <vprintfmt+0x1de>
  800528:	bd1d                	j	80035e <vprintfmt+0x34>
  80052a:	4705                	li	a4,1
  80052c:	008b0613          	addi	a2,s6,8
  800530:	01174463          	blt	a4,a7,800538 <vprintfmt+0x20e>
  800534:	12088663          	beqz	a7,800660 <vprintfmt+0x336>
  800538:	000b3683          	ld	a3,0(s6)
  80053c:	4729                	li	a4,10
  80053e:	8b32                	mv	s6,a2
  800540:	b79d                	j	8004a6 <vprintfmt+0x17c>
  800542:	00144603          	lbu	a2,1(s0)
  800546:	02d00813          	li	a6,45
  80054a:	846e                	mv	s0,s11
  80054c:	bd89                	j	80039e <vprintfmt+0x74>
  80054e:	864a                	mv	a2,s2
  800550:	85a6                	mv	a1,s1
  800552:	02500513          	li	a0,37
  800556:	9982                	jalr	s3
  800558:	b519                	j	80035e <vprintfmt+0x34>
  80055a:	000b2d03          	lw	s10,0(s6)
  80055e:	00144603          	lbu	a2,1(s0)
  800562:	0b21                	addi	s6,s6,8
  800564:	846e                	mv	s0,s11
  800566:	e20cdce3          	bgez	s9,80039e <vprintfmt+0x74>
  80056a:	8cea                	mv	s9,s10
  80056c:	5d7d                	li	s10,-1
  80056e:	bd05                	j	80039e <vprintfmt+0x74>
  800570:	00144603          	lbu	a2,1(s0)
  800574:	03000813          	li	a6,48
  800578:	846e                	mv	s0,s11
  80057a:	b515                	j	80039e <vprintfmt+0x74>
  80057c:	fd060d1b          	addiw	s10,a2,-48
  800580:	00144603          	lbu	a2,1(s0)
  800584:	846e                	mv	s0,s11
  800586:	fd06071b          	addiw	a4,a2,-48
  80058a:	0006031b          	sext.w	t1,a2
  80058e:	fce56ce3          	bltu	a0,a4,800566 <vprintfmt+0x23c>
  800592:	0405                	addi	s0,s0,1
  800594:	002d171b          	slliw	a4,s10,0x2
  800598:	00044603          	lbu	a2,0(s0)
  80059c:	01a706bb          	addw	a3,a4,s10
  8005a0:	0016969b          	slliw	a3,a3,0x1
  8005a4:	006686bb          	addw	a3,a3,t1
  8005a8:	fd06071b          	addiw	a4,a2,-48
  8005ac:	fd068d1b          	addiw	s10,a3,-48
  8005b0:	0006031b          	sext.w	t1,a2
  8005b4:	fce57fe3          	bleu	a4,a0,800592 <vprintfmt+0x268>
  8005b8:	b77d                	j	800566 <vprintfmt+0x23c>
  8005ba:	fffcc713          	not	a4,s9
  8005be:	977d                	srai	a4,a4,0x3f
  8005c0:	00ecf7b3          	and	a5,s9,a4
  8005c4:	00144603          	lbu	a2,1(s0)
  8005c8:	00078c9b          	sext.w	s9,a5
  8005cc:	846e                	mv	s0,s11
  8005ce:	bbc1                	j	80039e <vprintfmt+0x74>
  8005d0:	864a                	mv	a2,s2
  8005d2:	85a6                	mv	a1,s1
  8005d4:	02500513          	li	a0,37
  8005d8:	9982                	jalr	s3
  8005da:	fff44703          	lbu	a4,-1(s0)
  8005de:	02500793          	li	a5,37
  8005e2:	8da2                	mv	s11,s0
  8005e4:	d6f70de3          	beq	a4,a5,80035e <vprintfmt+0x34>
  8005e8:	02500713          	li	a4,37
  8005ec:	1dfd                	addi	s11,s11,-1
  8005ee:	fffdc783          	lbu	a5,-1(s11)
  8005f2:	fee79de3          	bne	a5,a4,8005ec <vprintfmt+0x2c2>
  8005f6:	b3a5                	j	80035e <vprintfmt+0x34>
  8005f8:	00000697          	auipc	a3,0x0
  8005fc:	7a868693          	addi	a3,a3,1960 # 800da0 <error_string+0x2c0>
  800600:	8626                	mv	a2,s1
  800602:	85ca                	mv	a1,s2
  800604:	854e                	mv	a0,s3
  800606:	0b2000ef          	jal	ra,8006b8 <printfmt>
  80060a:	bb91                	j	80035e <vprintfmt+0x34>
  80060c:	00000717          	auipc	a4,0x0
  800610:	78c70713          	addi	a4,a4,1932 # 800d98 <error_string+0x2b8>
  800614:	00000417          	auipc	s0,0x0
  800618:	78540413          	addi	s0,s0,1925 # 800d99 <error_string+0x2b9>
  80061c:	853a                	mv	a0,a4
  80061e:	85ea                	mv	a1,s10
  800620:	e03a                	sd	a4,0(sp)
  800622:	e442                	sd	a6,8(sp)
  800624:	0b2000ef          	jal	ra,8006d6 <strnlen>
  800628:	40ac8cbb          	subw	s9,s9,a0
  80062c:	6702                	ld	a4,0(sp)
  80062e:	01905f63          	blez	s9,80064c <vprintfmt+0x322>
  800632:	6822                	ld	a6,8(sp)
  800634:	0008079b          	sext.w	a5,a6
  800638:	e43e                	sd	a5,8(sp)
  80063a:	6522                	ld	a0,8(sp)
  80063c:	864a                	mv	a2,s2
  80063e:	85a6                	mv	a1,s1
  800640:	e03a                	sd	a4,0(sp)
  800642:	3cfd                	addiw	s9,s9,-1
  800644:	9982                	jalr	s3
  800646:	6702                	ld	a4,0(sp)
  800648:	fe0c99e3          	bnez	s9,80063a <vprintfmt+0x310>
  80064c:	00074703          	lbu	a4,0(a4)
  800650:	0007051b          	sext.w	a0,a4
  800654:	e80512e3          	bnez	a0,8004d8 <vprintfmt+0x1ae>
  800658:	b319                	j	80035e <vprintfmt+0x34>
  80065a:	000b2403          	lw	s0,0(s6)
  80065e:	bb6d                	j	800418 <vprintfmt+0xee>
  800660:	000b6683          	lwu	a3,0(s6)
  800664:	4729                	li	a4,10
  800666:	8b32                	mv	s6,a2
  800668:	bd3d                	j	8004a6 <vprintfmt+0x17c>
  80066a:	000b6683          	lwu	a3,0(s6)
  80066e:	4741                	li	a4,16
  800670:	8b32                	mv	s6,a2
  800672:	bd15                	j	8004a6 <vprintfmt+0x17c>
  800674:	000b6683          	lwu	a3,0(s6)
  800678:	4721                	li	a4,8
  80067a:	8b32                	mv	s6,a2
  80067c:	b52d                	j	8004a6 <vprintfmt+0x17c>
  80067e:	9982                	jalr	s3
  800680:	bd9d                	j	8004f6 <vprintfmt+0x1cc>
  800682:	864a                	mv	a2,s2
  800684:	85a6                	mv	a1,s1
  800686:	02d00513          	li	a0,45
  80068a:	e042                	sd	a6,0(sp)
  80068c:	9982                	jalr	s3
  80068e:	8b52                	mv	s6,s4
  800690:	408006b3          	neg	a3,s0
  800694:	4729                	li	a4,10
  800696:	6802                	ld	a6,0(sp)
  800698:	b539                	j	8004a6 <vprintfmt+0x17c>
  80069a:	01905663          	blez	s9,8006a6 <vprintfmt+0x37c>
  80069e:	02d00713          	li	a4,45
  8006a2:	f6e815e3          	bne	a6,a4,80060c <vprintfmt+0x2e2>
  8006a6:	00000417          	auipc	s0,0x0
  8006aa:	6f340413          	addi	s0,s0,1779 # 800d99 <error_string+0x2b9>
  8006ae:	02800513          	li	a0,40
  8006b2:	02800713          	li	a4,40
  8006b6:	b50d                	j	8004d8 <vprintfmt+0x1ae>

00000000008006b8 <printfmt>:
  8006b8:	7139                	addi	sp,sp,-64
  8006ba:	02010313          	addi	t1,sp,32
  8006be:	f03a                	sd	a4,32(sp)
  8006c0:	871a                	mv	a4,t1
  8006c2:	ec06                	sd	ra,24(sp)
  8006c4:	f43e                	sd	a5,40(sp)
  8006c6:	f842                	sd	a6,48(sp)
  8006c8:	fc46                	sd	a7,56(sp)
  8006ca:	e41a                	sd	t1,8(sp)
  8006cc:	c5fff0ef          	jal	ra,80032a <vprintfmt>
  8006d0:	60e2                	ld	ra,24(sp)
  8006d2:	6121                	addi	sp,sp,64
  8006d4:	8082                	ret

00000000008006d6 <strnlen>:
  8006d6:	c185                	beqz	a1,8006f6 <strnlen+0x20>
  8006d8:	00054783          	lbu	a5,0(a0)
  8006dc:	cf89                	beqz	a5,8006f6 <strnlen+0x20>
  8006de:	4781                	li	a5,0
  8006e0:	a021                	j	8006e8 <strnlen+0x12>
  8006e2:	00074703          	lbu	a4,0(a4)
  8006e6:	c711                	beqz	a4,8006f2 <strnlen+0x1c>
  8006e8:	0785                	addi	a5,a5,1
  8006ea:	00f50733          	add	a4,a0,a5
  8006ee:	fef59ae3          	bne	a1,a5,8006e2 <strnlen+0xc>
  8006f2:	853e                	mv	a0,a5
  8006f4:	8082                	ret
  8006f6:	4781                	li	a5,0
  8006f8:	853e                	mv	a0,a5
  8006fa:	8082                	ret

00000000008006fc <memset>:
  8006fc:	ca01                	beqz	a2,80070c <memset+0x10>
  8006fe:	962a                	add	a2,a2,a0
  800700:	87aa                	mv	a5,a0
  800702:	0785                	addi	a5,a5,1
  800704:	feb78fa3          	sb	a1,-1(a5)
  800708:	fec79de3          	bne	a5,a2,800702 <memset+0x6>
  80070c:	8082                	ret

000000000080070e <main>:
  80070e:	711d                	addi	sp,sp,-96
  800710:	4651                	li	a2,20
  800712:	4581                	li	a1,0
  800714:	00001517          	auipc	a0,0x1
  800718:	91c50513          	addi	a0,a0,-1764 # 801030 <pids>
  80071c:	ec86                	sd	ra,88(sp)
  80071e:	e8a2                	sd	s0,80(sp)
  800720:	e4a6                	sd	s1,72(sp)
  800722:	e0ca                	sd	s2,64(sp)
  800724:	fc4e                	sd	s3,56(sp)
  800726:	f852                	sd	s4,48(sp)
  800728:	f456                	sd	s5,40(sp)
  80072a:	f05a                	sd	s6,32(sp)
  80072c:	ec5e                	sd	s7,24(sp)
  80072e:	fcfff0ef          	jal	ra,8006fc <memset>
  800732:	4519                	li	a0,6
  800734:	00001a97          	auipc	s5,0x1
  800738:	8cca8a93          	addi	s5,s5,-1844 # 801000 <acc>
  80073c:	00001917          	auipc	s2,0x1
  800740:	8f490913          	addi	s2,s2,-1804 # 801030 <pids>
  800744:	ab1ff0ef          	jal	ra,8001f4 <lab6_set_priority>
  800748:	89d6                	mv	s3,s5
  80074a:	84ca                	mv	s1,s2
  80074c:	4401                	li	s0,0
  80074e:	4a15                	li	s4,5
  800750:	0009a023          	sw	zero,0(s3)
  800754:	a8dff0ef          	jal	ra,8001e0 <fork>
  800758:	c088                	sw	a0,0(s1)
  80075a:	c969                	beqz	a0,80082c <main+0x11e>
  80075c:	12054d63          	bltz	a0,800896 <main+0x188>
  800760:	2405                	addiw	s0,s0,1
  800762:	0991                	addi	s3,s3,4
  800764:	0491                	addi	s1,s1,4
  800766:	ff4415e3          	bne	s0,s4,800750 <main+0x42>
  80076a:	00001497          	auipc	s1,0x1
  80076e:	8ae48493          	addi	s1,s1,-1874 # 801018 <status>
  800772:	00000517          	auipc	a0,0x0
  800776:	66650513          	addi	a0,a0,1638 # 800dd8 <error_string+0x2f8>
  80077a:	97fff0ef          	jal	ra,8000f8 <cprintf>
  80077e:	00001997          	auipc	s3,0x1
  800782:	8ae98993          	addi	s3,s3,-1874 # 80102c <status+0x14>
  800786:	8a26                	mv	s4,s1
  800788:	8426                	mv	s0,s1
  80078a:	00000b97          	auipc	s7,0x0
  80078e:	676b8b93          	addi	s7,s7,1654 # 800e00 <error_string+0x320>
  800792:	00092503          	lw	a0,0(s2)
  800796:	85a2                	mv	a1,s0
  800798:	00042023          	sw	zero,0(s0)
  80079c:	a49ff0ef          	jal	ra,8001e4 <waitpid>
  8007a0:	00092a83          	lw	s5,0(s2)
  8007a4:	00042b03          	lw	s6,0(s0)
  8007a8:	a49ff0ef          	jal	ra,8001f0 <gettime_msec>
  8007ac:	0005069b          	sext.w	a3,a0
  8007b0:	865a                	mv	a2,s6
  8007b2:	85d6                	mv	a1,s5
  8007b4:	855e                	mv	a0,s7
  8007b6:	0411                	addi	s0,s0,4
  8007b8:	941ff0ef          	jal	ra,8000f8 <cprintf>
  8007bc:	0911                	addi	s2,s2,4
  8007be:	fd341ae3          	bne	s0,s3,800792 <main+0x84>
  8007c2:	00000517          	auipc	a0,0x0
  8007c6:	65e50513          	addi	a0,a0,1630 # 800e20 <error_string+0x340>
  8007ca:	92fff0ef          	jal	ra,8000f8 <cprintf>
  8007ce:	00000517          	auipc	a0,0x0
  8007d2:	66a50513          	addi	a0,a0,1642 # 800e38 <error_string+0x358>
  8007d6:	923ff0ef          	jal	ra,8000f8 <cprintf>
  8007da:	00000417          	auipc	s0,0x0
  8007de:	67e40413          	addi	s0,s0,1662 # 800e58 <error_string+0x378>
  8007e2:	408c                	lw	a1,0(s1)
  8007e4:	000a2783          	lw	a5,0(s4)
  8007e8:	0491                	addi	s1,s1,4
  8007ea:	0015959b          	slliw	a1,a1,0x1
  8007ee:	02f5c5bb          	divw	a1,a1,a5
  8007f2:	8522                	mv	a0,s0
  8007f4:	2585                	addiw	a1,a1,1
  8007f6:	01f5d79b          	srliw	a5,a1,0x1f
  8007fa:	9dbd                	addw	a1,a1,a5
  8007fc:	4015d59b          	sraiw	a1,a1,0x1
  800800:	8f9ff0ef          	jal	ra,8000f8 <cprintf>
  800804:	fd349fe3          	bne	s1,s3,8007e2 <main+0xd4>
  800808:	00000517          	auipc	a0,0x0
  80080c:	13850513          	addi	a0,a0,312 # 800940 <main+0x232>
  800810:	8e9ff0ef          	jal	ra,8000f8 <cprintf>
  800814:	60e6                	ld	ra,88(sp)
  800816:	6446                	ld	s0,80(sp)
  800818:	64a6                	ld	s1,72(sp)
  80081a:	6906                	ld	s2,64(sp)
  80081c:	79e2                	ld	s3,56(sp)
  80081e:	7a42                	ld	s4,48(sp)
  800820:	7aa2                	ld	s5,40(sp)
  800822:	7b02                	ld	s6,32(sp)
  800824:	6be2                	ld	s7,24(sp)
  800826:	4501                	li	a0,0
  800828:	6125                	addi	sp,sp,96
  80082a:	8082                	ret
  80082c:	0014051b          	addiw	a0,s0,1
  800830:	040a                	slli	s0,s0,0x2
  800832:	9456                	add	s0,s0,s5
  800834:	6485                	lui	s1,0x1
  800836:	6909                	lui	s2,0x2
  800838:	9bdff0ef          	jal	ra,8001f4 <lab6_set_priority>
  80083c:	fa04849b          	addiw	s1,s1,-96
  800840:	00042023          	sw	zero,0(s0)
  800844:	71090913          	addi	s2,s2,1808 # 2710 <open-0x7fd910>
  800848:	4014                	lw	a3,0(s0)
  80084a:	2685                	addiw	a3,a3,1
  80084c:	0c800713          	li	a4,200
  800850:	47b2                	lw	a5,12(sp)
  800852:	377d                	addiw	a4,a4,-1
  800854:	2781                	sext.w	a5,a5
  800856:	0017b793          	seqz	a5,a5
  80085a:	c63e                	sw	a5,12(sp)
  80085c:	fb75                	bnez	a4,800850 <main+0x142>
  80085e:	0296f7bb          	remuw	a5,a3,s1
  800862:	0016871b          	addiw	a4,a3,1
  800866:	c399                	beqz	a5,80086c <main+0x15e>
  800868:	86ba                	mv	a3,a4
  80086a:	b7cd                	j	80084c <main+0x13e>
  80086c:	c014                	sw	a3,0(s0)
  80086e:	983ff0ef          	jal	ra,8001f0 <gettime_msec>
  800872:	0005099b          	sext.w	s3,a0
  800876:	fd3959e3          	ble	s3,s2,800848 <main+0x13a>
  80087a:	973ff0ef          	jal	ra,8001ec <getpid>
  80087e:	4010                	lw	a2,0(s0)
  800880:	85aa                	mv	a1,a0
  800882:	86ce                	mv	a3,s3
  800884:	00000517          	auipc	a0,0x0
  800888:	53450513          	addi	a0,a0,1332 # 800db8 <error_string+0x2d8>
  80088c:	86dff0ef          	jal	ra,8000f8 <cprintf>
  800890:	4008                	lw	a0,0(s0)
  800892:	939ff0ef          	jal	ra,8001ca <exit>
  800896:	00000417          	auipc	s0,0x0
  80089a:	7ae40413          	addi	s0,s0,1966 # 801044 <pids+0x14>
  80089e:	00092503          	lw	a0,0(s2)
  8008a2:	00a05463          	blez	a0,8008aa <main+0x19c>
  8008a6:	943ff0ef          	jal	ra,8001e8 <kill>
  8008aa:	0911                	addi	s2,s2,4
  8008ac:	ff2419e3          	bne	s0,s2,80089e <main+0x190>
  8008b0:	00000617          	auipc	a2,0x0
  8008b4:	5b060613          	addi	a2,a2,1456 # 800e60 <error_string+0x380>
  8008b8:	04b00593          	li	a1,75
  8008bc:	00000517          	auipc	a0,0x0
  8008c0:	5b450513          	addi	a0,a0,1460 # 800e70 <error_string+0x390>
  8008c4:	f72ff0ef          	jal	ra,800036 <__panic>
