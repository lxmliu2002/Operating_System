
obj/__user_sh.out：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000000800020 <open>:
  800020:	1582                	slli	a1,a1,0x20
  800022:	9181                	srli	a1,a1,0x20
  800024:	2160006f          	j	80023a <sys_open>

0000000000800028 <close>:
  800028:	21e0006f          	j	800246 <sys_close>

000000000080002c <read>:
  80002c:	2240006f          	j	800250 <sys_read>

0000000000800030 <write>:
  800030:	22e0006f          	j	80025e <sys_write>

0000000000800034 <dup2>:
  800034:	2380006f          	j	80026c <sys_dup>

0000000000800038 <_start>:
  800038:	2c4000ef          	jal	ra,8002fc <umain>
  80003c:	a001                	j	80003c <_start+0x4>

000000000080003e <__panic>:
  80003e:	715d                	addi	sp,sp,-80
  800040:	e822                	sd	s0,16(sp)
  800042:	fc3e                	sd	a5,56(sp)
  800044:	8432                	mv	s0,a2
  800046:	103c                	addi	a5,sp,40
  800048:	862e                	mv	a2,a1
  80004a:	85aa                	mv	a1,a0
  80004c:	00001517          	auipc	a0,0x1
  800050:	d4450513          	addi	a0,a0,-700 # 800d90 <main+0xca>
  800054:	ec06                	sd	ra,24(sp)
  800056:	f436                	sd	a3,40(sp)
  800058:	f83a                	sd	a4,48(sp)
  80005a:	e0c2                	sd	a6,64(sp)
  80005c:	e4c6                	sd	a7,72(sp)
  80005e:	e43e                	sd	a5,8(sp)
  800060:	0c8000ef          	jal	ra,800128 <cprintf>
  800064:	65a2                	ld	a1,8(sp)
  800066:	8522                	mv	a0,s0
  800068:	09a000ef          	jal	ra,800102 <vcprintf>
  80006c:	00001517          	auipc	a0,0x1
  800070:	d9c50513          	addi	a0,a0,-612 # 800e08 <main+0x142>
  800074:	0b4000ef          	jal	ra,800128 <cprintf>
  800078:	5559                	li	a0,-10
  80007a:	1fe000ef          	jal	ra,800278 <exit>

000000000080007e <__warn>:
  80007e:	715d                	addi	sp,sp,-80
  800080:	e822                	sd	s0,16(sp)
  800082:	fc3e                	sd	a5,56(sp)
  800084:	8432                	mv	s0,a2
  800086:	103c                	addi	a5,sp,40
  800088:	862e                	mv	a2,a1
  80008a:	85aa                	mv	a1,a0
  80008c:	00001517          	auipc	a0,0x1
  800090:	d2450513          	addi	a0,a0,-732 # 800db0 <main+0xea>
  800094:	ec06                	sd	ra,24(sp)
  800096:	f436                	sd	a3,40(sp)
  800098:	f83a                	sd	a4,48(sp)
  80009a:	e0c2                	sd	a6,64(sp)
  80009c:	e4c6                	sd	a7,72(sp)
  80009e:	e43e                	sd	a5,8(sp)
  8000a0:	088000ef          	jal	ra,800128 <cprintf>
  8000a4:	65a2                	ld	a1,8(sp)
  8000a6:	8522                	mv	a0,s0
  8000a8:	05a000ef          	jal	ra,800102 <vcprintf>
  8000ac:	00001517          	auipc	a0,0x1
  8000b0:	d5c50513          	addi	a0,a0,-676 # 800e08 <main+0x142>
  8000b4:	074000ef          	jal	ra,800128 <cprintf>
  8000b8:	60e2                	ld	ra,24(sp)
  8000ba:	6442                	ld	s0,16(sp)
  8000bc:	6161                	addi	sp,sp,80
  8000be:	8082                	ret

00000000008000c0 <cputch>:
  8000c0:	1141                	addi	sp,sp,-16
  8000c2:	e022                	sd	s0,0(sp)
  8000c4:	e406                	sd	ra,8(sp)
  8000c6:	842e                	mv	s0,a1
  8000c8:	15e000ef          	jal	ra,800226 <sys_putc>
  8000cc:	401c                	lw	a5,0(s0)
  8000ce:	60a2                	ld	ra,8(sp)
  8000d0:	2785                	addiw	a5,a5,1
  8000d2:	c01c                	sw	a5,0(s0)
  8000d4:	6402                	ld	s0,0(sp)
  8000d6:	0141                	addi	sp,sp,16
  8000d8:	8082                	ret

00000000008000da <fputch>:
  8000da:	1101                	addi	sp,sp,-32
  8000dc:	87b2                	mv	a5,a2
  8000de:	e822                	sd	s0,16(sp)
  8000e0:	00a107a3          	sb	a0,15(sp)
  8000e4:	842e                	mv	s0,a1
  8000e6:	853e                	mv	a0,a5
  8000e8:	00f10593          	addi	a1,sp,15
  8000ec:	4605                	li	a2,1
  8000ee:	ec06                	sd	ra,24(sp)
  8000f0:	f41ff0ef          	jal	ra,800030 <write>
  8000f4:	401c                	lw	a5,0(s0)
  8000f6:	60e2                	ld	ra,24(sp)
  8000f8:	2785                	addiw	a5,a5,1
  8000fa:	c01c                	sw	a5,0(s0)
  8000fc:	6442                	ld	s0,16(sp)
  8000fe:	6105                	addi	sp,sp,32
  800100:	8082                	ret

0000000000800102 <vcprintf>:
  800102:	1101                	addi	sp,sp,-32
  800104:	872e                	mv	a4,a1
  800106:	75dd                	lui	a1,0xffff7
  800108:	86aa                	mv	a3,a0
  80010a:	0070                	addi	a2,sp,12
  80010c:	00000517          	auipc	a0,0x0
  800110:	fb450513          	addi	a0,a0,-76 # 8000c0 <cputch>
  800114:	ad958593          	addi	a1,a1,-1319 # ffffffffffff6ad9 <buffer.1212+0xffffffffff7f29d1>
  800118:	ec06                	sd	ra,24(sp)
  80011a:	c602                	sw	zero,12(sp)
  80011c:	2e4000ef          	jal	ra,800400 <vprintfmt>
  800120:	60e2                	ld	ra,24(sp)
  800122:	4532                	lw	a0,12(sp)
  800124:	6105                	addi	sp,sp,32
  800126:	8082                	ret

0000000000800128 <cprintf>:
  800128:	711d                	addi	sp,sp,-96
  80012a:	02810313          	addi	t1,sp,40
  80012e:	f42e                	sd	a1,40(sp)
  800130:	75dd                	lui	a1,0xffff7
  800132:	f832                	sd	a2,48(sp)
  800134:	fc36                	sd	a3,56(sp)
  800136:	e0ba                	sd	a4,64(sp)
  800138:	86aa                	mv	a3,a0
  80013a:	0050                	addi	a2,sp,4
  80013c:	00000517          	auipc	a0,0x0
  800140:	f8450513          	addi	a0,a0,-124 # 8000c0 <cputch>
  800144:	871a                	mv	a4,t1
  800146:	ad958593          	addi	a1,a1,-1319 # ffffffffffff6ad9 <buffer.1212+0xffffffffff7f29d1>
  80014a:	ec06                	sd	ra,24(sp)
  80014c:	e4be                	sd	a5,72(sp)
  80014e:	e8c2                	sd	a6,80(sp)
  800150:	ecc6                	sd	a7,88(sp)
  800152:	e41a                	sd	t1,8(sp)
  800154:	c202                	sw	zero,4(sp)
  800156:	2aa000ef          	jal	ra,800400 <vprintfmt>
  80015a:	60e2                	ld	ra,24(sp)
  80015c:	4512                	lw	a0,4(sp)
  80015e:	6125                	addi	sp,sp,96
  800160:	8082                	ret

0000000000800162 <cputs>:
  800162:	1101                	addi	sp,sp,-32
  800164:	e822                	sd	s0,16(sp)
  800166:	ec06                	sd	ra,24(sp)
  800168:	e426                	sd	s1,8(sp)
  80016a:	842a                	mv	s0,a0
  80016c:	00054503          	lbu	a0,0(a0)
  800170:	c51d                	beqz	a0,80019e <cputs+0x3c>
  800172:	0405                	addi	s0,s0,1
  800174:	4485                	li	s1,1
  800176:	9c81                	subw	s1,s1,s0
  800178:	0ae000ef          	jal	ra,800226 <sys_putc>
  80017c:	008487bb          	addw	a5,s1,s0
  800180:	0405                	addi	s0,s0,1
  800182:	fff44503          	lbu	a0,-1(s0)
  800186:	f96d                	bnez	a0,800178 <cputs+0x16>
  800188:	0017841b          	addiw	s0,a5,1
  80018c:	4529                	li	a0,10
  80018e:	098000ef          	jal	ra,800226 <sys_putc>
  800192:	8522                	mv	a0,s0
  800194:	60e2                	ld	ra,24(sp)
  800196:	6442                	ld	s0,16(sp)
  800198:	64a2                	ld	s1,8(sp)
  80019a:	6105                	addi	sp,sp,32
  80019c:	8082                	ret
  80019e:	4405                	li	s0,1
  8001a0:	b7f5                	j	80018c <cputs+0x2a>

00000000008001a2 <fprintf>:
  8001a2:	715d                	addi	sp,sp,-80
  8001a4:	02010313          	addi	t1,sp,32
  8001a8:	f032                	sd	a2,32(sp)
  8001aa:	f436                	sd	a3,40(sp)
  8001ac:	f83a                	sd	a4,48(sp)
  8001ae:	86ae                	mv	a3,a1
  8001b0:	0050                	addi	a2,sp,4
  8001b2:	85aa                	mv	a1,a0
  8001b4:	871a                	mv	a4,t1
  8001b6:	00000517          	auipc	a0,0x0
  8001ba:	f2450513          	addi	a0,a0,-220 # 8000da <fputch>
  8001be:	ec06                	sd	ra,24(sp)
  8001c0:	fc3e                	sd	a5,56(sp)
  8001c2:	e0c2                	sd	a6,64(sp)
  8001c4:	e4c6                	sd	a7,72(sp)
  8001c6:	e41a                	sd	t1,8(sp)
  8001c8:	c202                	sw	zero,4(sp)
  8001ca:	236000ef          	jal	ra,800400 <vprintfmt>
  8001ce:	60e2                	ld	ra,24(sp)
  8001d0:	4512                	lw	a0,4(sp)
  8001d2:	6161                	addi	sp,sp,80
  8001d4:	8082                	ret

00000000008001d6 <syscall>:
  8001d6:	7175                	addi	sp,sp,-144
  8001d8:	f8ba                	sd	a4,112(sp)
  8001da:	e0ba                	sd	a4,64(sp)
  8001dc:	0118                	addi	a4,sp,128
  8001de:	e42a                	sd	a0,8(sp)
  8001e0:	ecae                	sd	a1,88(sp)
  8001e2:	f0b2                	sd	a2,96(sp)
  8001e4:	f4b6                	sd	a3,104(sp)
  8001e6:	fcbe                	sd	a5,120(sp)
  8001e8:	e142                	sd	a6,128(sp)
  8001ea:	e546                	sd	a7,136(sp)
  8001ec:	f42e                	sd	a1,40(sp)
  8001ee:	f832                	sd	a2,48(sp)
  8001f0:	fc36                	sd	a3,56(sp)
  8001f2:	f03a                	sd	a4,32(sp)
  8001f4:	e4be                	sd	a5,72(sp)
  8001f6:	4522                	lw	a0,8(sp)
  8001f8:	55a2                	lw	a1,40(sp)
  8001fa:	5642                	lw	a2,48(sp)
  8001fc:	56e2                	lw	a3,56(sp)
  8001fe:	4706                	lw	a4,64(sp)
  800200:	47a6                	lw	a5,72(sp)
  800202:	00000073          	ecall
  800206:	ce2a                	sw	a0,28(sp)
  800208:	4572                	lw	a0,28(sp)
  80020a:	6149                	addi	sp,sp,144
  80020c:	8082                	ret

000000000080020e <sys_exit>:
  80020e:	85aa                	mv	a1,a0
  800210:	4505                	li	a0,1
  800212:	fc5ff06f          	j	8001d6 <syscall>

0000000000800216 <sys_fork>:
  800216:	4509                	li	a0,2
  800218:	fbfff06f          	j	8001d6 <syscall>

000000000080021c <sys_wait>:
  80021c:	862e                	mv	a2,a1
  80021e:	85aa                	mv	a1,a0
  800220:	450d                	li	a0,3
  800222:	fb5ff06f          	j	8001d6 <syscall>

0000000000800226 <sys_putc>:
  800226:	85aa                	mv	a1,a0
  800228:	4579                	li	a0,30
  80022a:	fadff06f          	j	8001d6 <syscall>

000000000080022e <sys_exec>:
  80022e:	86b2                	mv	a3,a2
  800230:	862e                	mv	a2,a1
  800232:	85aa                	mv	a1,a0
  800234:	4511                	li	a0,4
  800236:	fa1ff06f          	j	8001d6 <syscall>

000000000080023a <sys_open>:
  80023a:	862e                	mv	a2,a1
  80023c:	85aa                	mv	a1,a0
  80023e:	06400513          	li	a0,100
  800242:	f95ff06f          	j	8001d6 <syscall>

0000000000800246 <sys_close>:
  800246:	85aa                	mv	a1,a0
  800248:	06500513          	li	a0,101
  80024c:	f8bff06f          	j	8001d6 <syscall>

0000000000800250 <sys_read>:
  800250:	86b2                	mv	a3,a2
  800252:	862e                	mv	a2,a1
  800254:	85aa                	mv	a1,a0
  800256:	06600513          	li	a0,102
  80025a:	f7dff06f          	j	8001d6 <syscall>

000000000080025e <sys_write>:
  80025e:	86b2                	mv	a3,a2
  800260:	862e                	mv	a2,a1
  800262:	85aa                	mv	a1,a0
  800264:	06700513          	li	a0,103
  800268:	f6fff06f          	j	8001d6 <syscall>

000000000080026c <sys_dup>:
  80026c:	862e                	mv	a2,a1
  80026e:	85aa                	mv	a1,a0
  800270:	08200513          	li	a0,130
  800274:	f63ff06f          	j	8001d6 <syscall>

0000000000800278 <exit>:
  800278:	1141                	addi	sp,sp,-16
  80027a:	e406                	sd	ra,8(sp)
  80027c:	f93ff0ef          	jal	ra,80020e <sys_exit>
  800280:	00001517          	auipc	a0,0x1
  800284:	b5050513          	addi	a0,a0,-1200 # 800dd0 <main+0x10a>
  800288:	ea1ff0ef          	jal	ra,800128 <cprintf>
  80028c:	a001                	j	80028c <exit+0x14>

000000000080028e <fork>:
  80028e:	f89ff06f          	j	800216 <sys_fork>

0000000000800292 <waitpid>:
  800292:	f8bff06f          	j	80021c <sys_wait>

0000000000800296 <__exec>:
  800296:	619c                	ld	a5,0(a1)
  800298:	862e                	mv	a2,a1
  80029a:	cf81                	beqz	a5,8002b2 <__exec+0x1c>
  80029c:	00858793          	addi	a5,a1,8
  8002a0:	4701                	li	a4,0
  8002a2:	07a1                	addi	a5,a5,8
  8002a4:	ff87b683          	ld	a3,-8(a5)
  8002a8:	2705                	addiw	a4,a4,1
  8002aa:	fee5                	bnez	a3,8002a2 <__exec+0xc>
  8002ac:	85ba                	mv	a1,a4
  8002ae:	f81ff06f          	j	80022e <sys_exec>
  8002b2:	4581                	li	a1,0
  8002b4:	f7bff06f          	j	80022e <sys_exec>

00000000008002b8 <initfd>:
  8002b8:	1101                	addi	sp,sp,-32
  8002ba:	87ae                	mv	a5,a1
  8002bc:	e426                	sd	s1,8(sp)
  8002be:	85b2                	mv	a1,a2
  8002c0:	84aa                	mv	s1,a0
  8002c2:	853e                	mv	a0,a5
  8002c4:	e822                	sd	s0,16(sp)
  8002c6:	ec06                	sd	ra,24(sp)
  8002c8:	d59ff0ef          	jal	ra,800020 <open>
  8002cc:	842a                	mv	s0,a0
  8002ce:	00054463          	bltz	a0,8002d6 <initfd+0x1e>
  8002d2:	00951863          	bne	a0,s1,8002e2 <initfd+0x2a>
  8002d6:	8522                	mv	a0,s0
  8002d8:	60e2                	ld	ra,24(sp)
  8002da:	6442                	ld	s0,16(sp)
  8002dc:	64a2                	ld	s1,8(sp)
  8002de:	6105                	addi	sp,sp,32
  8002e0:	8082                	ret
  8002e2:	8526                	mv	a0,s1
  8002e4:	d45ff0ef          	jal	ra,800028 <close>
  8002e8:	85a6                	mv	a1,s1
  8002ea:	8522                	mv	a0,s0
  8002ec:	d49ff0ef          	jal	ra,800034 <dup2>
  8002f0:	84aa                	mv	s1,a0
  8002f2:	8522                	mv	a0,s0
  8002f4:	d35ff0ef          	jal	ra,800028 <close>
  8002f8:	8426                	mv	s0,s1
  8002fa:	bff1                	j	8002d6 <initfd+0x1e>

00000000008002fc <umain>:
  8002fc:	1101                	addi	sp,sp,-32
  8002fe:	e822                	sd	s0,16(sp)
  800300:	e426                	sd	s1,8(sp)
  800302:	842a                	mv	s0,a0
  800304:	84ae                	mv	s1,a1
  800306:	4601                	li	a2,0
  800308:	00001597          	auipc	a1,0x1
  80030c:	ae058593          	addi	a1,a1,-1312 # 800de8 <main+0x122>
  800310:	4501                	li	a0,0
  800312:	ec06                	sd	ra,24(sp)
  800314:	fa5ff0ef          	jal	ra,8002b8 <initfd>
  800318:	02054263          	bltz	a0,80033c <umain+0x40>
  80031c:	4605                	li	a2,1
  80031e:	00001597          	auipc	a1,0x1
  800322:	b0a58593          	addi	a1,a1,-1270 # 800e28 <main+0x162>
  800326:	4505                	li	a0,1
  800328:	f91ff0ef          	jal	ra,8002b8 <initfd>
  80032c:	02054563          	bltz	a0,800356 <umain+0x5a>
  800330:	85a6                	mv	a1,s1
  800332:	8522                	mv	a0,s0
  800334:	193000ef          	jal	ra,800cc6 <main>
  800338:	f41ff0ef          	jal	ra,800278 <exit>
  80033c:	86aa                	mv	a3,a0
  80033e:	00001617          	auipc	a2,0x1
  800342:	ab260613          	addi	a2,a2,-1358 # 800df0 <main+0x12a>
  800346:	45e9                	li	a1,26
  800348:	00001517          	auipc	a0,0x1
  80034c:	ac850513          	addi	a0,a0,-1336 # 800e10 <main+0x14a>
  800350:	d2fff0ef          	jal	ra,80007e <__warn>
  800354:	b7e1                	j	80031c <umain+0x20>
  800356:	86aa                	mv	a3,a0
  800358:	00001617          	auipc	a2,0x1
  80035c:	ad860613          	addi	a2,a2,-1320 # 800e30 <main+0x16a>
  800360:	45f5                	li	a1,29
  800362:	00001517          	auipc	a0,0x1
  800366:	aae50513          	addi	a0,a0,-1362 # 800e10 <main+0x14a>
  80036a:	d15ff0ef          	jal	ra,80007e <__warn>
  80036e:	b7c9                	j	800330 <umain+0x34>

0000000000800370 <printnum>:
  800370:	02071893          	slli	a7,a4,0x20
  800374:	7139                	addi	sp,sp,-64
  800376:	0208d893          	srli	a7,a7,0x20
  80037a:	e456                	sd	s5,8(sp)
  80037c:	0316fab3          	remu	s5,a3,a7
  800380:	f822                	sd	s0,48(sp)
  800382:	f426                	sd	s1,40(sp)
  800384:	f04a                	sd	s2,32(sp)
  800386:	ec4e                	sd	s3,24(sp)
  800388:	fc06                	sd	ra,56(sp)
  80038a:	e852                	sd	s4,16(sp)
  80038c:	84aa                	mv	s1,a0
  80038e:	89ae                	mv	s3,a1
  800390:	8932                	mv	s2,a2
  800392:	fff7841b          	addiw	s0,a5,-1
  800396:	2a81                	sext.w	s5,s5
  800398:	0516f163          	bleu	a7,a3,8003da <printnum+0x6a>
  80039c:	8a42                	mv	s4,a6
  80039e:	00805863          	blez	s0,8003ae <printnum+0x3e>
  8003a2:	347d                	addiw	s0,s0,-1
  8003a4:	864e                	mv	a2,s3
  8003a6:	85ca                	mv	a1,s2
  8003a8:	8552                	mv	a0,s4
  8003aa:	9482                	jalr	s1
  8003ac:	f87d                	bnez	s0,8003a2 <printnum+0x32>
  8003ae:	1a82                	slli	s5,s5,0x20
  8003b0:	020ada93          	srli	s5,s5,0x20
  8003b4:	00001797          	auipc	a5,0x1
  8003b8:	cbc78793          	addi	a5,a5,-836 # 801070 <error_string+0xc8>
  8003bc:	9abe                	add	s5,s5,a5
  8003be:	7442                	ld	s0,48(sp)
  8003c0:	000ac503          	lbu	a0,0(s5)
  8003c4:	70e2                	ld	ra,56(sp)
  8003c6:	6a42                	ld	s4,16(sp)
  8003c8:	6aa2                	ld	s5,8(sp)
  8003ca:	864e                	mv	a2,s3
  8003cc:	85ca                	mv	a1,s2
  8003ce:	69e2                	ld	s3,24(sp)
  8003d0:	7902                	ld	s2,32(sp)
  8003d2:	8326                	mv	t1,s1
  8003d4:	74a2                	ld	s1,40(sp)
  8003d6:	6121                	addi	sp,sp,64
  8003d8:	8302                	jr	t1
  8003da:	0316d6b3          	divu	a3,a3,a7
  8003de:	87a2                	mv	a5,s0
  8003e0:	f91ff0ef          	jal	ra,800370 <printnum>
  8003e4:	b7e9                	j	8003ae <printnum+0x3e>

00000000008003e6 <sprintputch>:
  8003e6:	499c                	lw	a5,16(a1)
  8003e8:	6198                	ld	a4,0(a1)
  8003ea:	6594                	ld	a3,8(a1)
  8003ec:	2785                	addiw	a5,a5,1
  8003ee:	c99c                	sw	a5,16(a1)
  8003f0:	00d77763          	bleu	a3,a4,8003fe <sprintputch+0x18>
  8003f4:	00170793          	addi	a5,a4,1
  8003f8:	e19c                	sd	a5,0(a1)
  8003fa:	00a70023          	sb	a0,0(a4)
  8003fe:	8082                	ret

0000000000800400 <vprintfmt>:
  800400:	7119                	addi	sp,sp,-128
  800402:	f4a6                	sd	s1,104(sp)
  800404:	f0ca                	sd	s2,96(sp)
  800406:	ecce                	sd	s3,88(sp)
  800408:	e4d6                	sd	s5,72(sp)
  80040a:	e0da                	sd	s6,64(sp)
  80040c:	fc5e                	sd	s7,56(sp)
  80040e:	f862                	sd	s8,48(sp)
  800410:	ec6e                	sd	s11,24(sp)
  800412:	fc86                	sd	ra,120(sp)
  800414:	f8a2                	sd	s0,112(sp)
  800416:	e8d2                	sd	s4,80(sp)
  800418:	f466                	sd	s9,40(sp)
  80041a:	f06a                	sd	s10,32(sp)
  80041c:	89aa                	mv	s3,a0
  80041e:	892e                	mv	s2,a1
  800420:	84b2                	mv	s1,a2
  800422:	8db6                	mv	s11,a3
  800424:	8b3a                	mv	s6,a4
  800426:	5bfd                	li	s7,-1
  800428:	00001a97          	auipc	s5,0x1
  80042c:	a24a8a93          	addi	s5,s5,-1500 # 800e4c <main+0x186>
  800430:	05e00c13          	li	s8,94
  800434:	000dc503          	lbu	a0,0(s11)
  800438:	02500793          	li	a5,37
  80043c:	001d8413          	addi	s0,s11,1
  800440:	00f50f63          	beq	a0,a5,80045e <vprintfmt+0x5e>
  800444:	c529                	beqz	a0,80048e <vprintfmt+0x8e>
  800446:	02500a13          	li	s4,37
  80044a:	a011                	j	80044e <vprintfmt+0x4e>
  80044c:	c129                	beqz	a0,80048e <vprintfmt+0x8e>
  80044e:	864a                	mv	a2,s2
  800450:	85a6                	mv	a1,s1
  800452:	0405                	addi	s0,s0,1
  800454:	9982                	jalr	s3
  800456:	fff44503          	lbu	a0,-1(s0)
  80045a:	ff4519e3          	bne	a0,s4,80044c <vprintfmt+0x4c>
  80045e:	00044603          	lbu	a2,0(s0)
  800462:	02000813          	li	a6,32
  800466:	4a01                	li	s4,0
  800468:	4881                	li	a7,0
  80046a:	5d7d                	li	s10,-1
  80046c:	5cfd                	li	s9,-1
  80046e:	05500593          	li	a1,85
  800472:	4525                	li	a0,9
  800474:	fdd6071b          	addiw	a4,a2,-35
  800478:	0ff77713          	andi	a4,a4,255
  80047c:	00140d93          	addi	s11,s0,1
  800480:	22e5e363          	bltu	a1,a4,8006a6 <vprintfmt+0x2a6>
  800484:	070a                	slli	a4,a4,0x2
  800486:	9756                	add	a4,a4,s5
  800488:	4318                	lw	a4,0(a4)
  80048a:	9756                	add	a4,a4,s5
  80048c:	8702                	jr	a4
  80048e:	70e6                	ld	ra,120(sp)
  800490:	7446                	ld	s0,112(sp)
  800492:	74a6                	ld	s1,104(sp)
  800494:	7906                	ld	s2,96(sp)
  800496:	69e6                	ld	s3,88(sp)
  800498:	6a46                	ld	s4,80(sp)
  80049a:	6aa6                	ld	s5,72(sp)
  80049c:	6b06                	ld	s6,64(sp)
  80049e:	7be2                	ld	s7,56(sp)
  8004a0:	7c42                	ld	s8,48(sp)
  8004a2:	7ca2                	ld	s9,40(sp)
  8004a4:	7d02                	ld	s10,32(sp)
  8004a6:	6de2                	ld	s11,24(sp)
  8004a8:	6109                	addi	sp,sp,128
  8004aa:	8082                	ret
  8004ac:	4705                	li	a4,1
  8004ae:	008b0613          	addi	a2,s6,8
  8004b2:	01174463          	blt	a4,a7,8004ba <vprintfmt+0xba>
  8004b6:	28088563          	beqz	a7,800740 <vprintfmt+0x340>
  8004ba:	000b3683          	ld	a3,0(s6)
  8004be:	4741                	li	a4,16
  8004c0:	8b32                	mv	s6,a2
  8004c2:	a86d                	j	80057c <vprintfmt+0x17c>
  8004c4:	00144603          	lbu	a2,1(s0)
  8004c8:	4a05                	li	s4,1
  8004ca:	846e                	mv	s0,s11
  8004cc:	b765                	j	800474 <vprintfmt+0x74>
  8004ce:	000b2503          	lw	a0,0(s6)
  8004d2:	864a                	mv	a2,s2
  8004d4:	85a6                	mv	a1,s1
  8004d6:	0b21                	addi	s6,s6,8
  8004d8:	9982                	jalr	s3
  8004da:	bfa9                	j	800434 <vprintfmt+0x34>
  8004dc:	4705                	li	a4,1
  8004de:	008b0a13          	addi	s4,s6,8
  8004e2:	01174463          	blt	a4,a7,8004ea <vprintfmt+0xea>
  8004e6:	24088563          	beqz	a7,800730 <vprintfmt+0x330>
  8004ea:	000b3403          	ld	s0,0(s6)
  8004ee:	26044563          	bltz	s0,800758 <vprintfmt+0x358>
  8004f2:	86a2                	mv	a3,s0
  8004f4:	8b52                	mv	s6,s4
  8004f6:	4729                	li	a4,10
  8004f8:	a051                	j	80057c <vprintfmt+0x17c>
  8004fa:	000b2783          	lw	a5,0(s6)
  8004fe:	46e1                	li	a3,24
  800500:	0b21                	addi	s6,s6,8
  800502:	41f7d71b          	sraiw	a4,a5,0x1f
  800506:	8fb9                	xor	a5,a5,a4
  800508:	40e7873b          	subw	a4,a5,a4
  80050c:	1ce6c163          	blt	a3,a4,8006ce <vprintfmt+0x2ce>
  800510:	00371793          	slli	a5,a4,0x3
  800514:	00001697          	auipc	a3,0x1
  800518:	a9468693          	addi	a3,a3,-1388 # 800fa8 <error_string>
  80051c:	97b6                	add	a5,a5,a3
  80051e:	639c                	ld	a5,0(a5)
  800520:	1a078763          	beqz	a5,8006ce <vprintfmt+0x2ce>
  800524:	873e                	mv	a4,a5
  800526:	00001697          	auipc	a3,0x1
  80052a:	d5268693          	addi	a3,a3,-686 # 801278 <error_string+0x2d0>
  80052e:	8626                	mv	a2,s1
  800530:	85ca                	mv	a1,s2
  800532:	854e                	mv	a0,s3
  800534:	25a000ef          	jal	ra,80078e <printfmt>
  800538:	bdf5                	j	800434 <vprintfmt+0x34>
  80053a:	00144603          	lbu	a2,1(s0)
  80053e:	2885                	addiw	a7,a7,1
  800540:	846e                	mv	s0,s11
  800542:	bf0d                	j	800474 <vprintfmt+0x74>
  800544:	4705                	li	a4,1
  800546:	008b0613          	addi	a2,s6,8
  80054a:	01174463          	blt	a4,a7,800552 <vprintfmt+0x152>
  80054e:	1e088e63          	beqz	a7,80074a <vprintfmt+0x34a>
  800552:	000b3683          	ld	a3,0(s6)
  800556:	4721                	li	a4,8
  800558:	8b32                	mv	s6,a2
  80055a:	a00d                	j	80057c <vprintfmt+0x17c>
  80055c:	03000513          	li	a0,48
  800560:	864a                	mv	a2,s2
  800562:	85a6                	mv	a1,s1
  800564:	e042                	sd	a6,0(sp)
  800566:	9982                	jalr	s3
  800568:	864a                	mv	a2,s2
  80056a:	85a6                	mv	a1,s1
  80056c:	07800513          	li	a0,120
  800570:	9982                	jalr	s3
  800572:	0b21                	addi	s6,s6,8
  800574:	ff8b3683          	ld	a3,-8(s6)
  800578:	6802                	ld	a6,0(sp)
  80057a:	4741                	li	a4,16
  80057c:	87e6                	mv	a5,s9
  80057e:	8626                	mv	a2,s1
  800580:	85ca                	mv	a1,s2
  800582:	854e                	mv	a0,s3
  800584:	dedff0ef          	jal	ra,800370 <printnum>
  800588:	b575                	j	800434 <vprintfmt+0x34>
  80058a:	000b3703          	ld	a4,0(s6)
  80058e:	0b21                	addi	s6,s6,8
  800590:	1e070063          	beqz	a4,800770 <vprintfmt+0x370>
  800594:	00170413          	addi	s0,a4,1
  800598:	19905563          	blez	s9,800722 <vprintfmt+0x322>
  80059c:	02d00613          	li	a2,45
  8005a0:	14c81963          	bne	a6,a2,8006f2 <vprintfmt+0x2f2>
  8005a4:	00074703          	lbu	a4,0(a4)
  8005a8:	0007051b          	sext.w	a0,a4
  8005ac:	c90d                	beqz	a0,8005de <vprintfmt+0x1de>
  8005ae:	000d4563          	bltz	s10,8005b8 <vprintfmt+0x1b8>
  8005b2:	3d7d                	addiw	s10,s10,-1
  8005b4:	037d0363          	beq	s10,s7,8005da <vprintfmt+0x1da>
  8005b8:	864a                	mv	a2,s2
  8005ba:	85a6                	mv	a1,s1
  8005bc:	180a0c63          	beqz	s4,800754 <vprintfmt+0x354>
  8005c0:	3701                	addiw	a4,a4,-32
  8005c2:	18ec7963          	bleu	a4,s8,800754 <vprintfmt+0x354>
  8005c6:	03f00513          	li	a0,63
  8005ca:	9982                	jalr	s3
  8005cc:	0405                	addi	s0,s0,1
  8005ce:	fff44703          	lbu	a4,-1(s0)
  8005d2:	3cfd                	addiw	s9,s9,-1
  8005d4:	0007051b          	sext.w	a0,a4
  8005d8:	f979                	bnez	a0,8005ae <vprintfmt+0x1ae>
  8005da:	e5905de3          	blez	s9,800434 <vprintfmt+0x34>
  8005de:	3cfd                	addiw	s9,s9,-1
  8005e0:	864a                	mv	a2,s2
  8005e2:	85a6                	mv	a1,s1
  8005e4:	02000513          	li	a0,32
  8005e8:	9982                	jalr	s3
  8005ea:	e40c85e3          	beqz	s9,800434 <vprintfmt+0x34>
  8005ee:	3cfd                	addiw	s9,s9,-1
  8005f0:	864a                	mv	a2,s2
  8005f2:	85a6                	mv	a1,s1
  8005f4:	02000513          	li	a0,32
  8005f8:	9982                	jalr	s3
  8005fa:	fe0c92e3          	bnez	s9,8005de <vprintfmt+0x1de>
  8005fe:	bd1d                	j	800434 <vprintfmt+0x34>
  800600:	4705                	li	a4,1
  800602:	008b0613          	addi	a2,s6,8
  800606:	01174463          	blt	a4,a7,80060e <vprintfmt+0x20e>
  80060a:	12088663          	beqz	a7,800736 <vprintfmt+0x336>
  80060e:	000b3683          	ld	a3,0(s6)
  800612:	4729                	li	a4,10
  800614:	8b32                	mv	s6,a2
  800616:	b79d                	j	80057c <vprintfmt+0x17c>
  800618:	00144603          	lbu	a2,1(s0)
  80061c:	02d00813          	li	a6,45
  800620:	846e                	mv	s0,s11
  800622:	bd89                	j	800474 <vprintfmt+0x74>
  800624:	864a                	mv	a2,s2
  800626:	85a6                	mv	a1,s1
  800628:	02500513          	li	a0,37
  80062c:	9982                	jalr	s3
  80062e:	b519                	j	800434 <vprintfmt+0x34>
  800630:	000b2d03          	lw	s10,0(s6)
  800634:	00144603          	lbu	a2,1(s0)
  800638:	0b21                	addi	s6,s6,8
  80063a:	846e                	mv	s0,s11
  80063c:	e20cdce3          	bgez	s9,800474 <vprintfmt+0x74>
  800640:	8cea                	mv	s9,s10
  800642:	5d7d                	li	s10,-1
  800644:	bd05                	j	800474 <vprintfmt+0x74>
  800646:	00144603          	lbu	a2,1(s0)
  80064a:	03000813          	li	a6,48
  80064e:	846e                	mv	s0,s11
  800650:	b515                	j	800474 <vprintfmt+0x74>
  800652:	fd060d1b          	addiw	s10,a2,-48
  800656:	00144603          	lbu	a2,1(s0)
  80065a:	846e                	mv	s0,s11
  80065c:	fd06071b          	addiw	a4,a2,-48
  800660:	0006031b          	sext.w	t1,a2
  800664:	fce56ce3          	bltu	a0,a4,80063c <vprintfmt+0x23c>
  800668:	0405                	addi	s0,s0,1
  80066a:	002d171b          	slliw	a4,s10,0x2
  80066e:	00044603          	lbu	a2,0(s0)
  800672:	01a706bb          	addw	a3,a4,s10
  800676:	0016969b          	slliw	a3,a3,0x1
  80067a:	006686bb          	addw	a3,a3,t1
  80067e:	fd06071b          	addiw	a4,a2,-48
  800682:	fd068d1b          	addiw	s10,a3,-48
  800686:	0006031b          	sext.w	t1,a2
  80068a:	fce57fe3          	bleu	a4,a0,800668 <vprintfmt+0x268>
  80068e:	b77d                	j	80063c <vprintfmt+0x23c>
  800690:	fffcc713          	not	a4,s9
  800694:	977d                	srai	a4,a4,0x3f
  800696:	00ecf7b3          	and	a5,s9,a4
  80069a:	00144603          	lbu	a2,1(s0)
  80069e:	00078c9b          	sext.w	s9,a5
  8006a2:	846e                	mv	s0,s11
  8006a4:	bbc1                	j	800474 <vprintfmt+0x74>
  8006a6:	864a                	mv	a2,s2
  8006a8:	85a6                	mv	a1,s1
  8006aa:	02500513          	li	a0,37
  8006ae:	9982                	jalr	s3
  8006b0:	fff44703          	lbu	a4,-1(s0)
  8006b4:	02500793          	li	a5,37
  8006b8:	8da2                	mv	s11,s0
  8006ba:	d6f70de3          	beq	a4,a5,800434 <vprintfmt+0x34>
  8006be:	02500713          	li	a4,37
  8006c2:	1dfd                	addi	s11,s11,-1
  8006c4:	fffdc783          	lbu	a5,-1(s11)
  8006c8:	fee79de3          	bne	a5,a4,8006c2 <vprintfmt+0x2c2>
  8006cc:	b3a5                	j	800434 <vprintfmt+0x34>
  8006ce:	00001697          	auipc	a3,0x1
  8006d2:	b9a68693          	addi	a3,a3,-1126 # 801268 <error_string+0x2c0>
  8006d6:	8626                	mv	a2,s1
  8006d8:	85ca                	mv	a1,s2
  8006da:	854e                	mv	a0,s3
  8006dc:	0b2000ef          	jal	ra,80078e <printfmt>
  8006e0:	bb91                	j	800434 <vprintfmt+0x34>
  8006e2:	00001717          	auipc	a4,0x1
  8006e6:	b7e70713          	addi	a4,a4,-1154 # 801260 <error_string+0x2b8>
  8006ea:	00001417          	auipc	s0,0x1
  8006ee:	b7740413          	addi	s0,s0,-1161 # 801261 <error_string+0x2b9>
  8006f2:	853a                	mv	a0,a4
  8006f4:	85ea                	mv	a1,s10
  8006f6:	e03a                	sd	a4,0(sp)
  8006f8:	e442                	sd	a6,8(sp)
  8006fa:	110000ef          	jal	ra,80080a <strnlen>
  8006fe:	40ac8cbb          	subw	s9,s9,a0
  800702:	6702                	ld	a4,0(sp)
  800704:	01905f63          	blez	s9,800722 <vprintfmt+0x322>
  800708:	6822                	ld	a6,8(sp)
  80070a:	0008079b          	sext.w	a5,a6
  80070e:	e43e                	sd	a5,8(sp)
  800710:	6522                	ld	a0,8(sp)
  800712:	864a                	mv	a2,s2
  800714:	85a6                	mv	a1,s1
  800716:	e03a                	sd	a4,0(sp)
  800718:	3cfd                	addiw	s9,s9,-1
  80071a:	9982                	jalr	s3
  80071c:	6702                	ld	a4,0(sp)
  80071e:	fe0c99e3          	bnez	s9,800710 <vprintfmt+0x310>
  800722:	00074703          	lbu	a4,0(a4)
  800726:	0007051b          	sext.w	a0,a4
  80072a:	e80512e3          	bnez	a0,8005ae <vprintfmt+0x1ae>
  80072e:	b319                	j	800434 <vprintfmt+0x34>
  800730:	000b2403          	lw	s0,0(s6)
  800734:	bb6d                	j	8004ee <vprintfmt+0xee>
  800736:	000b6683          	lwu	a3,0(s6)
  80073a:	4729                	li	a4,10
  80073c:	8b32                	mv	s6,a2
  80073e:	bd3d                	j	80057c <vprintfmt+0x17c>
  800740:	000b6683          	lwu	a3,0(s6)
  800744:	4741                	li	a4,16
  800746:	8b32                	mv	s6,a2
  800748:	bd15                	j	80057c <vprintfmt+0x17c>
  80074a:	000b6683          	lwu	a3,0(s6)
  80074e:	4721                	li	a4,8
  800750:	8b32                	mv	s6,a2
  800752:	b52d                	j	80057c <vprintfmt+0x17c>
  800754:	9982                	jalr	s3
  800756:	bd9d                	j	8005cc <vprintfmt+0x1cc>
  800758:	864a                	mv	a2,s2
  80075a:	85a6                	mv	a1,s1
  80075c:	02d00513          	li	a0,45
  800760:	e042                	sd	a6,0(sp)
  800762:	9982                	jalr	s3
  800764:	8b52                	mv	s6,s4
  800766:	408006b3          	neg	a3,s0
  80076a:	4729                	li	a4,10
  80076c:	6802                	ld	a6,0(sp)
  80076e:	b539                	j	80057c <vprintfmt+0x17c>
  800770:	01905663          	blez	s9,80077c <vprintfmt+0x37c>
  800774:	02d00713          	li	a4,45
  800778:	f6e815e3          	bne	a6,a4,8006e2 <vprintfmt+0x2e2>
  80077c:	00001417          	auipc	s0,0x1
  800780:	ae540413          	addi	s0,s0,-1307 # 801261 <error_string+0x2b9>
  800784:	02800513          	li	a0,40
  800788:	02800713          	li	a4,40
  80078c:	b50d                	j	8005ae <vprintfmt+0x1ae>

000000000080078e <printfmt>:
  80078e:	7139                	addi	sp,sp,-64
  800790:	02010313          	addi	t1,sp,32
  800794:	f03a                	sd	a4,32(sp)
  800796:	871a                	mv	a4,t1
  800798:	ec06                	sd	ra,24(sp)
  80079a:	f43e                	sd	a5,40(sp)
  80079c:	f842                	sd	a6,48(sp)
  80079e:	fc46                	sd	a7,56(sp)
  8007a0:	e41a                	sd	t1,8(sp)
  8007a2:	c5fff0ef          	jal	ra,800400 <vprintfmt>
  8007a6:	60e2                	ld	ra,24(sp)
  8007a8:	6121                	addi	sp,sp,64
  8007aa:	8082                	ret

00000000008007ac <vsnprintf>:
  8007ac:	15fd                	addi	a1,a1,-1
  8007ae:	7179                	addi	sp,sp,-48
  8007b0:	95aa                	add	a1,a1,a0
  8007b2:	f406                	sd	ra,40(sp)
  8007b4:	e42a                	sd	a0,8(sp)
  8007b6:	e82e                	sd	a1,16(sp)
  8007b8:	cc02                	sw	zero,24(sp)
  8007ba:	c515                	beqz	a0,8007e6 <vsnprintf+0x3a>
  8007bc:	02a5e563          	bltu	a1,a0,8007e6 <vsnprintf+0x3a>
  8007c0:	75dd                	lui	a1,0xffff7
  8007c2:	8736                	mv	a4,a3
  8007c4:	00000517          	auipc	a0,0x0
  8007c8:	c2250513          	addi	a0,a0,-990 # 8003e6 <sprintputch>
  8007cc:	86b2                	mv	a3,a2
  8007ce:	ad958593          	addi	a1,a1,-1319 # ffffffffffff6ad9 <buffer.1212+0xffffffffff7f29d1>
  8007d2:	0030                	addi	a2,sp,8
  8007d4:	c2dff0ef          	jal	ra,800400 <vprintfmt>
  8007d8:	67a2                	ld	a5,8(sp)
  8007da:	00078023          	sb	zero,0(a5)
  8007de:	4562                	lw	a0,24(sp)
  8007e0:	70a2                	ld	ra,40(sp)
  8007e2:	6145                	addi	sp,sp,48
  8007e4:	8082                	ret
  8007e6:	5575                	li	a0,-3
  8007e8:	bfe5                	j	8007e0 <vsnprintf+0x34>

00000000008007ea <snprintf>:
  8007ea:	715d                	addi	sp,sp,-80
  8007ec:	02810313          	addi	t1,sp,40
  8007f0:	f436                	sd	a3,40(sp)
  8007f2:	869a                	mv	a3,t1
  8007f4:	ec06                	sd	ra,24(sp)
  8007f6:	f83a                	sd	a4,48(sp)
  8007f8:	fc3e                	sd	a5,56(sp)
  8007fa:	e0c2                	sd	a6,64(sp)
  8007fc:	e4c6                	sd	a7,72(sp)
  8007fe:	e41a                	sd	t1,8(sp)
  800800:	fadff0ef          	jal	ra,8007ac <vsnprintf>
  800804:	60e2                	ld	ra,24(sp)
  800806:	6161                	addi	sp,sp,80
  800808:	8082                	ret

000000000080080a <strnlen>:
  80080a:	c185                	beqz	a1,80082a <strnlen+0x20>
  80080c:	00054783          	lbu	a5,0(a0)
  800810:	cf89                	beqz	a5,80082a <strnlen+0x20>
  800812:	4781                	li	a5,0
  800814:	a021                	j	80081c <strnlen+0x12>
  800816:	00074703          	lbu	a4,0(a4)
  80081a:	c711                	beqz	a4,800826 <strnlen+0x1c>
  80081c:	0785                	addi	a5,a5,1
  80081e:	00f50733          	add	a4,a0,a5
  800822:	fef59ae3          	bne	a1,a5,800816 <strnlen+0xc>
  800826:	853e                	mv	a0,a5
  800828:	8082                	ret
  80082a:	4781                	li	a5,0
  80082c:	853e                	mv	a0,a5
  80082e:	8082                	ret

0000000000800830 <strcpy>:
  800830:	87aa                	mv	a5,a0
  800832:	0585                	addi	a1,a1,1
  800834:	fff5c703          	lbu	a4,-1(a1)
  800838:	0785                	addi	a5,a5,1
  80083a:	fee78fa3          	sb	a4,-1(a5)
  80083e:	fb75                	bnez	a4,800832 <strcpy+0x2>
  800840:	8082                	ret

0000000000800842 <strcmp>:
  800842:	00054783          	lbu	a5,0(a0)
  800846:	0005c703          	lbu	a4,0(a1)
  80084a:	cb91                	beqz	a5,80085e <strcmp+0x1c>
  80084c:	00e79c63          	bne	a5,a4,800864 <strcmp+0x22>
  800850:	0505                	addi	a0,a0,1
  800852:	00054783          	lbu	a5,0(a0)
  800856:	0585                	addi	a1,a1,1
  800858:	0005c703          	lbu	a4,0(a1)
  80085c:	fbe5                	bnez	a5,80084c <strcmp+0xa>
  80085e:	4501                	li	a0,0
  800860:	9d19                	subw	a0,a0,a4
  800862:	8082                	ret
  800864:	0007851b          	sext.w	a0,a5
  800868:	9d19                	subw	a0,a0,a4
  80086a:	8082                	ret

000000000080086c <strchr>:
  80086c:	00054783          	lbu	a5,0(a0)
  800870:	cb91                	beqz	a5,800884 <strchr+0x18>
  800872:	00b79563          	bne	a5,a1,80087c <strchr+0x10>
  800876:	a809                	j	800888 <strchr+0x1c>
  800878:	00b78763          	beq	a5,a1,800886 <strchr+0x1a>
  80087c:	0505                	addi	a0,a0,1
  80087e:	00054783          	lbu	a5,0(a0)
  800882:	fbfd                	bnez	a5,800878 <strchr+0xc>
  800884:	4501                	li	a0,0
  800886:	8082                	ret
  800888:	8082                	ret

000000000080088a <gettoken>:
  80088a:	7139                	addi	sp,sp,-64
  80088c:	f822                	sd	s0,48(sp)
  80088e:	6100                	ld	s0,0(a0)
  800890:	fc06                	sd	ra,56(sp)
  800892:	f426                	sd	s1,40(sp)
  800894:	f04a                	sd	s2,32(sp)
  800896:	ec4e                	sd	s3,24(sp)
  800898:	e852                	sd	s4,16(sp)
  80089a:	e456                	sd	s5,8(sp)
  80089c:	e05a                	sd	s6,0(sp)
  80089e:	c405                	beqz	s0,8008c6 <gettoken+0x3c>
  8008a0:	89aa                	mv	s3,a0
  8008a2:	892e                	mv	s2,a1
  8008a4:	00001497          	auipc	s1,0x1
  8008a8:	9dc48493          	addi	s1,s1,-1572 # 801280 <error_string+0x2d8>
  8008ac:	a021                	j	8008b4 <gettoken+0x2a>
  8008ae:	0405                	addi	s0,s0,1
  8008b0:	fe040fa3          	sb	zero,-1(s0)
  8008b4:	00044583          	lbu	a1,0(s0)
  8008b8:	8526                	mv	a0,s1
  8008ba:	fb3ff0ef          	jal	ra,80086c <strchr>
  8008be:	f965                	bnez	a0,8008ae <gettoken+0x24>
  8008c0:	00044783          	lbu	a5,0(s0)
  8008c4:	ef81                	bnez	a5,8008dc <gettoken+0x52>
  8008c6:	4501                	li	a0,0
  8008c8:	70e2                	ld	ra,56(sp)
  8008ca:	7442                	ld	s0,48(sp)
  8008cc:	74a2                	ld	s1,40(sp)
  8008ce:	7902                	ld	s2,32(sp)
  8008d0:	69e2                	ld	s3,24(sp)
  8008d2:	6a42                	ld	s4,16(sp)
  8008d4:	6aa2                	ld	s5,8(sp)
  8008d6:	6b02                	ld	s6,0(sp)
  8008d8:	6121                	addi	sp,sp,64
  8008da:	8082                	ret
  8008dc:	00893023          	sd	s0,0(s2)
  8008e0:	00044583          	lbu	a1,0(s0)
  8008e4:	00001517          	auipc	a0,0x1
  8008e8:	9a450513          	addi	a0,a0,-1628 # 801288 <error_string+0x2e0>
  8008ec:	f81ff0ef          	jal	ra,80086c <strchr>
  8008f0:	892a                	mv	s2,a0
  8008f2:	c115                	beqz	a0,800916 <gettoken+0x8c>
  8008f4:	00044503          	lbu	a0,0(s0)
  8008f8:	00140913          	addi	s2,s0,1
  8008fc:	00040023          	sb	zero,0(s0)
  800900:	00094783          	lbu	a5,0(s2)
  800904:	00f037b3          	snez	a5,a5
  800908:	40f007b3          	neg	a5,a5
  80090c:	00f97933          	and	s2,s2,a5
  800910:	0129b023          	sd	s2,0(s3)
  800914:	bf55                	j	8008c8 <gettoken+0x3e>
  800916:	00044583          	lbu	a1,0(s0)
  80091a:	4481                	li	s1,0
  80091c:	00001b17          	auipc	s6,0x1
  800920:	974b0b13          	addi	s6,s6,-1676 # 801290 <error_string+0x2e8>
  800924:	02200a13          	li	s4,34
  800928:	02000a93          	li	s5,32
  80092c:	cd91                	beqz	a1,800948 <gettoken+0xbe>
  80092e:	c095                	beqz	s1,800952 <gettoken+0xc8>
  800930:	00044783          	lbu	a5,0(s0)
  800934:	01479663          	bne	a5,s4,800940 <gettoken+0xb6>
  800938:	01540023          	sb	s5,0(s0)
  80093c:	0014c493          	xori	s1,s1,1
  800940:	0405                	addi	s0,s0,1
  800942:	00044583          	lbu	a1,0(s0)
  800946:	f5e5                	bnez	a1,80092e <gettoken+0xa4>
  800948:	07700513          	li	a0,119
  80094c:	0129b023          	sd	s2,0(s3)
  800950:	bfa5                	j	8008c8 <gettoken+0x3e>
  800952:	855a                	mv	a0,s6
  800954:	f19ff0ef          	jal	ra,80086c <strchr>
  800958:	dd61                	beqz	a0,800930 <gettoken+0xa6>
  80095a:	8922                	mv	s2,s0
  80095c:	07700513          	li	a0,119
  800960:	b745                	j	800900 <gettoken+0x76>

0000000000800962 <readline>:
  800962:	711d                	addi	sp,sp,-96
  800964:	ec86                	sd	ra,88(sp)
  800966:	e8a2                	sd	s0,80(sp)
  800968:	e4a6                	sd	s1,72(sp)
  80096a:	e0ca                	sd	s2,64(sp)
  80096c:	fc4e                	sd	s3,56(sp)
  80096e:	f852                	sd	s4,48(sp)
  800970:	f456                	sd	s5,40(sp)
  800972:	f05a                	sd	s6,32(sp)
  800974:	ec5e                	sd	s7,24(sp)
  800976:	c909                	beqz	a0,800988 <readline+0x26>
  800978:	862a                	mv	a2,a0
  80097a:	00001597          	auipc	a1,0x1
  80097e:	8fe58593          	addi	a1,a1,-1794 # 801278 <error_string+0x2d0>
  800982:	4505                	li	a0,1
  800984:	81fff0ef          	jal	ra,8001a2 <fprintf>
  800988:	6985                	lui	s3,0x1
  80098a:	4401                	li	s0,0
  80098c:	448d                	li	s1,3
  80098e:	497d                	li	s2,31
  800990:	4a21                	li	s4,8
  800992:	4aa9                	li	s5,10
  800994:	4b35                	li	s6,13
  800996:	19f9                	addi	s3,s3,-2
  800998:	00003b97          	auipc	s7,0x3
  80099c:	770b8b93          	addi	s7,s7,1904 # 804108 <buffer.1212>
  8009a0:	4605                	li	a2,1
  8009a2:	00f10593          	addi	a1,sp,15
  8009a6:	4501                	li	a0,0
  8009a8:	e84ff0ef          	jal	ra,80002c <read>
  8009ac:	04054163          	bltz	a0,8009ee <readline+0x8c>
  8009b0:	c549                	beqz	a0,800a3a <readline+0xd8>
  8009b2:	00f14603          	lbu	a2,15(sp)
  8009b6:	02960c63          	beq	a2,s1,8009ee <readline+0x8c>
  8009ba:	04c97663          	bleu	a2,s2,800a06 <readline+0xa4>
  8009be:	fe89c1e3          	blt	s3,s0,8009a0 <readline+0x3e>
  8009c2:	00001597          	auipc	a1,0x1
  8009c6:	94658593          	addi	a1,a1,-1722 # 801308 <error_string+0x360>
  8009ca:	4505                	li	a0,1
  8009cc:	fd6ff0ef          	jal	ra,8001a2 <fprintf>
  8009d0:	00f14703          	lbu	a4,15(sp)
  8009d4:	008b87b3          	add	a5,s7,s0
  8009d8:	4605                	li	a2,1
  8009da:	00f10593          	addi	a1,sp,15
  8009de:	4501                	li	a0,0
  8009e0:	00e78023          	sb	a4,0(a5)
  8009e4:	2405                	addiw	s0,s0,1
  8009e6:	e46ff0ef          	jal	ra,80002c <read>
  8009ea:	fc0553e3          	bgez	a0,8009b0 <readline+0x4e>
  8009ee:	4501                	li	a0,0
  8009f0:	60e6                	ld	ra,88(sp)
  8009f2:	6446                	ld	s0,80(sp)
  8009f4:	64a6                	ld	s1,72(sp)
  8009f6:	6906                	ld	s2,64(sp)
  8009f8:	79e2                	ld	s3,56(sp)
  8009fa:	7a42                	ld	s4,48(sp)
  8009fc:	7aa2                	ld	s5,40(sp)
  8009fe:	7b02                	ld	s6,32(sp)
  800a00:	6be2                	ld	s7,24(sp)
  800a02:	6125                	addi	sp,sp,96
  800a04:	8082                	ret
  800a06:	01461d63          	bne	a2,s4,800a20 <readline+0xbe>
  800a0a:	d859                	beqz	s0,8009a0 <readline+0x3e>
  800a0c:	4621                	li	a2,8
  800a0e:	00001597          	auipc	a1,0x1
  800a12:	8fa58593          	addi	a1,a1,-1798 # 801308 <error_string+0x360>
  800a16:	4505                	li	a0,1
  800a18:	f8aff0ef          	jal	ra,8001a2 <fprintf>
  800a1c:	347d                	addiw	s0,s0,-1
  800a1e:	b749                	j	8009a0 <readline+0x3e>
  800a20:	03560a63          	beq	a2,s5,800a54 <readline+0xf2>
  800a24:	f7661ee3          	bne	a2,s6,8009a0 <readline+0x3e>
  800a28:	4635                	li	a2,13
  800a2a:	00001597          	auipc	a1,0x1
  800a2e:	8de58593          	addi	a1,a1,-1826 # 801308 <error_string+0x360>
  800a32:	4505                	li	a0,1
  800a34:	f6eff0ef          	jal	ra,8001a2 <fprintf>
  800a38:	a011                	j	800a3c <readline+0xda>
  800a3a:	d855                	beqz	s0,8009ee <readline+0x8c>
  800a3c:	00003797          	auipc	a5,0x3
  800a40:	6cc78793          	addi	a5,a5,1740 # 804108 <buffer.1212>
  800a44:	943e                	add	s0,s0,a5
  800a46:	00040023          	sb	zero,0(s0)
  800a4a:	00003517          	auipc	a0,0x3
  800a4e:	6be50513          	addi	a0,a0,1726 # 804108 <buffer.1212>
  800a52:	bf79                	j	8009f0 <readline+0x8e>
  800a54:	4629                	li	a2,10
  800a56:	bfd1                	j	800a2a <readline+0xc8>

0000000000800a58 <reopen>:
  800a58:	1101                	addi	sp,sp,-32
  800a5a:	ec06                	sd	ra,24(sp)
  800a5c:	e822                	sd	s0,16(sp)
  800a5e:	e426                	sd	s1,8(sp)
  800a60:	842e                	mv	s0,a1
  800a62:	e04a                	sd	s2,0(sp)
  800a64:	84aa                	mv	s1,a0
  800a66:	8932                	mv	s2,a2
  800a68:	dc0ff0ef          	jal	ra,800028 <close>
  800a6c:	8522                	mv	a0,s0
  800a6e:	85ca                	mv	a1,s2
  800a70:	db0ff0ef          	jal	ra,800020 <open>
  800a74:	842a                	mv	s0,a0
  800a76:	00054463          	bltz	a0,800a7e <reopen+0x26>
  800a7a:	00a49e63          	bne	s1,a0,800a96 <reopen+0x3e>
  800a7e:	00142513          	slti	a0,s0,1
  800a82:	40a0053b          	negw	a0,a0
  800a86:	8d61                	and	a0,a0,s0
  800a88:	60e2                	ld	ra,24(sp)
  800a8a:	6442                	ld	s0,16(sp)
  800a8c:	64a2                	ld	s1,8(sp)
  800a8e:	6902                	ld	s2,0(sp)
  800a90:	2501                	sext.w	a0,a0
  800a92:	6105                	addi	sp,sp,32
  800a94:	8082                	ret
  800a96:	8526                	mv	a0,s1
  800a98:	d90ff0ef          	jal	ra,800028 <close>
  800a9c:	85a6                	mv	a1,s1
  800a9e:	8522                	mv	a0,s0
  800aa0:	d94ff0ef          	jal	ra,800034 <dup2>
  800aa4:	84aa                	mv	s1,a0
  800aa6:	8522                	mv	a0,s0
  800aa8:	d80ff0ef          	jal	ra,800028 <close>
  800aac:	8426                	mv	s0,s1
  800aae:	bfc1                	j	800a7e <reopen+0x26>

0000000000800ab0 <testfile>:
  800ab0:	1141                	addi	sp,sp,-16
  800ab2:	4581                	li	a1,0
  800ab4:	e406                	sd	ra,8(sp)
  800ab6:	d6aff0ef          	jal	ra,800020 <open>
  800aba:	87aa                	mv	a5,a0
  800abc:	00054563          	bltz	a0,800ac6 <testfile+0x16>
  800ac0:	d68ff0ef          	jal	ra,800028 <close>
  800ac4:	4781                	li	a5,0
  800ac6:	60a2                	ld	ra,8(sp)
  800ac8:	853e                	mv	a0,a5
  800aca:	0141                	addi	sp,sp,16
  800acc:	8082                	ret

0000000000800ace <runcmd>:
  800ace:	711d                	addi	sp,sp,-96
  800ad0:	e0ca                	sd	s2,64(sp)
  800ad2:	f852                	sd	s4,48(sp)
  800ad4:	f456                	sd	s5,40(sp)
  800ad6:	f05a                	sd	s6,32(sp)
  800ad8:	ec86                	sd	ra,88(sp)
  800ada:	e8a2                	sd	s0,80(sp)
  800adc:	e4a6                	sd	s1,72(sp)
  800ade:	fc4e                	sd	s3,56(sp)
  800ae0:	e42a                	sd	a0,8(sp)
  800ae2:	07700913          	li	s2,119
  800ae6:	02000a93          	li	s5,32
  800aea:	00002b17          	auipc	s6,0x2
  800aee:	516b0b13          	addi	s6,s6,1302 # 803000 <argv.1236>
  800af2:	07c00a13          	li	s4,124
  800af6:	4481                	li	s1,0
  800af8:	03c00413          	li	s0,60
  800afc:	03e00993          	li	s3,62
  800b00:	082c                	addi	a1,sp,24
  800b02:	0028                	addi	a0,sp,8
  800b04:	d87ff0ef          	jal	ra,80088a <gettoken>
  800b08:	0c850563          	beq	a0,s0,800bd2 <runcmd+0x104>
  800b0c:	02a45c63          	ble	a0,s0,800b44 <runcmd+0x76>
  800b10:	0b250363          	beq	a0,s2,800bb6 <runcmd+0xe8>
  800b14:	0f450d63          	beq	a0,s4,800c0e <runcmd+0x140>
  800b18:	0d350c63          	beq	a0,s3,800bf0 <runcmd+0x122>
  800b1c:	862a                	mv	a2,a0
  800b1e:	00001597          	auipc	a1,0x1
  800b22:	87258593          	addi	a1,a1,-1934 # 801390 <error_string+0x3e8>
  800b26:	4505                	li	a0,1
  800b28:	e7aff0ef          	jal	ra,8001a2 <fprintf>
  800b2c:	54fd                	li	s1,-1
  800b2e:	60e6                	ld	ra,88(sp)
  800b30:	6446                	ld	s0,80(sp)
  800b32:	8526                	mv	a0,s1
  800b34:	6906                	ld	s2,64(sp)
  800b36:	64a6                	ld	s1,72(sp)
  800b38:	79e2                	ld	s3,56(sp)
  800b3a:	7a42                	ld	s4,48(sp)
  800b3c:	7aa2                	ld	s5,40(sp)
  800b3e:	7b02                	ld	s6,32(sp)
  800b40:	6125                	addi	sp,sp,96
  800b42:	8082                	ret
  800b44:	c121                	beqz	a0,800b84 <runcmd+0xb6>
  800b46:	03b00793          	li	a5,59
  800b4a:	fcf519e3          	bne	a0,a5,800b1c <runcmd+0x4e>
  800b4e:	f40ff0ef          	jal	ra,80028e <fork>
  800b52:	87aa                	mv	a5,a0
  800b54:	c905                	beqz	a0,800b84 <runcmd+0xb6>
  800b56:	12054963          	bltz	a0,800c88 <runcmd+0x1ba>
  800b5a:	4581                	li	a1,0
  800b5c:	f36ff0ef          	jal	ra,800292 <waitpid>
  800b60:	bf59                	j	800af6 <runcmd+0x28>
  800b62:	12054363          	bltz	a0,800c88 <runcmd+0x1ba>
  800b66:	4505                	li	a0,1
  800b68:	cc0ff0ef          	jal	ra,800028 <close>
  800b6c:	4585                	li	a1,1
  800b6e:	4501                	li	a0,0
  800b70:	cc4ff0ef          	jal	ra,800034 <dup2>
  800b74:	06054c63          	bltz	a0,800bec <runcmd+0x11e>
  800b78:	4501                	li	a0,0
  800b7a:	caeff0ef          	jal	ra,800028 <close>
  800b7e:	4501                	li	a0,0
  800b80:	ca8ff0ef          	jal	ra,800028 <close>
  800b84:	d4cd                	beqz	s1,800b2e <runcmd+0x60>
  800b86:	00002417          	auipc	s0,0x2
  800b8a:	47a40413          	addi	s0,s0,1146 # 803000 <argv.1236>
  800b8e:	6008                	ld	a0,0(s0)
  800b90:	00001597          	auipc	a1,0x1
  800b94:	82858593          	addi	a1,a1,-2008 # 8013b8 <error_string+0x410>
  800b98:	cabff0ef          	jal	ra,800842 <strcmp>
  800b9c:	ed49                	bnez	a0,800c36 <runcmd+0x168>
  800b9e:	4789                	li	a5,2
  800ba0:	0ef49663          	bne	s1,a5,800c8c <runcmd+0x1be>
  800ba4:	640c                	ld	a1,8(s0)
  800ba6:	00001517          	auipc	a0,0x1
  800baa:	45a50513          	addi	a0,a0,1114 # 802000 <shcwd>
  800bae:	4481                	li	s1,0
  800bb0:	c81ff0ef          	jal	ra,800830 <strcpy>
  800bb4:	bfad                	j	800b2e <runcmd+0x60>
  800bb6:	0f548f63          	beq	s1,s5,800cb4 <runcmd+0x1e6>
  800bba:	6762                	ld	a4,24(sp)
  800bbc:	00349793          	slli	a5,s1,0x3
  800bc0:	97da                	add	a5,a5,s6
  800bc2:	082c                	addi	a1,sp,24
  800bc4:	0028                	addi	a0,sp,8
  800bc6:	e398                	sd	a4,0(a5)
  800bc8:	2485                	addiw	s1,s1,1
  800bca:	cc1ff0ef          	jal	ra,80088a <gettoken>
  800bce:	f2851fe3          	bne	a0,s0,800b0c <runcmd+0x3e>
  800bd2:	082c                	addi	a1,sp,24
  800bd4:	0028                	addi	a0,sp,8
  800bd6:	cb5ff0ef          	jal	ra,80088a <gettoken>
  800bda:	0d251463          	bne	a0,s2,800ca2 <runcmd+0x1d4>
  800bde:	65e2                	ld	a1,24(sp)
  800be0:	4601                	li	a2,0
  800be2:	4501                	li	a0,0
  800be4:	e75ff0ef          	jal	ra,800a58 <reopen>
  800be8:	f0050ce3          	beqz	a0,800b00 <runcmd+0x32>
  800bec:	84aa                	mv	s1,a0
  800bee:	b781                	j	800b2e <runcmd+0x60>
  800bf0:	082c                	addi	a1,sp,24
  800bf2:	0028                	addi	a0,sp,8
  800bf4:	c97ff0ef          	jal	ra,80088a <gettoken>
  800bf8:	09251c63          	bne	a0,s2,800c90 <runcmd+0x1c2>
  800bfc:	65e2                	ld	a1,24(sp)
  800bfe:	4659                	li	a2,22
  800c00:	4505                	li	a0,1
  800c02:	e57ff0ef          	jal	ra,800a58 <reopen>
  800c06:	ee050de3          	beqz	a0,800b00 <runcmd+0x32>
  800c0a:	84aa                	mv	s1,a0
  800c0c:	b70d                	j	800b2e <runcmd+0x60>
  800c0e:	e80ff0ef          	jal	ra,80028e <fork>
  800c12:	87aa                	mv	a5,a0
  800c14:	f539                	bnez	a0,800b62 <runcmd+0x94>
  800c16:	c12ff0ef          	jal	ra,800028 <close>
  800c1a:	4581                	li	a1,0
  800c1c:	4501                	li	a0,0
  800c1e:	c16ff0ef          	jal	ra,800034 <dup2>
  800c22:	84aa                	mv	s1,a0
  800c24:	f00545e3          	bltz	a0,800b2e <runcmd+0x60>
  800c28:	4501                	li	a0,0
  800c2a:	bfeff0ef          	jal	ra,800028 <close>
  800c2e:	4501                	li	a0,0
  800c30:	bf8ff0ef          	jal	ra,800028 <close>
  800c34:	b5c9                	j	800af6 <runcmd+0x28>
  800c36:	6008                	ld	a0,0(s0)
  800c38:	e79ff0ef          	jal	ra,800ab0 <testfile>
  800c3c:	c905                	beqz	a0,800c6c <runcmd+0x19e>
  800c3e:	57c1                	li	a5,-16
  800c40:	faf516e3          	bne	a0,a5,800bec <runcmd+0x11e>
  800c44:	6014                	ld	a3,0(s0)
  800c46:	00000617          	auipc	a2,0x0
  800c4a:	77a60613          	addi	a2,a2,1914 # 8013c0 <error_string+0x418>
  800c4e:	6585                	lui	a1,0x1
  800c50:	00002517          	auipc	a0,0x2
  800c54:	4b850513          	addi	a0,a0,1208 # 803108 <argv0.1235>
  800c58:	b93ff0ef          	jal	ra,8007ea <snprintf>
  800c5c:	00002797          	auipc	a5,0x2
  800c60:	4ac78793          	addi	a5,a5,1196 # 803108 <argv0.1235>
  800c64:	00002717          	auipc	a4,0x2
  800c68:	38f73e23          	sd	a5,924(a4) # 803000 <argv.1236>
  800c6c:	00349793          	slli	a5,s1,0x3
  800c70:	97a2                	add	a5,a5,s0
  800c72:	0007b023          	sd	zero,0(a5)
  800c76:	6008                	ld	a0,0(s0)
  800c78:	00002597          	auipc	a1,0x2
  800c7c:	38858593          	addi	a1,a1,904 # 803000 <argv.1236>
  800c80:	e16ff0ef          	jal	ra,800296 <__exec>
  800c84:	84aa                	mv	s1,a0
  800c86:	b565                	j	800b2e <runcmd+0x60>
  800c88:	84be                	mv	s1,a5
  800c8a:	b555                	j	800b2e <runcmd+0x60>
  800c8c:	54fd                	li	s1,-1
  800c8e:	b545                	j	800b2e <runcmd+0x60>
  800c90:	00000597          	auipc	a1,0x0
  800c94:	6d058593          	addi	a1,a1,1744 # 801360 <error_string+0x3b8>
  800c98:	4505                	li	a0,1
  800c9a:	d08ff0ef          	jal	ra,8001a2 <fprintf>
  800c9e:	54fd                	li	s1,-1
  800ca0:	b579                	j	800b2e <runcmd+0x60>
  800ca2:	00000597          	auipc	a1,0x0
  800ca6:	68e58593          	addi	a1,a1,1678 # 801330 <error_string+0x388>
  800caa:	4505                	li	a0,1
  800cac:	cf6ff0ef          	jal	ra,8001a2 <fprintf>
  800cb0:	54fd                	li	s1,-1
  800cb2:	bdb5                	j	800b2e <runcmd+0x60>
  800cb4:	00000597          	auipc	a1,0x0
  800cb8:	65c58593          	addi	a1,a1,1628 # 801310 <error_string+0x368>
  800cbc:	4505                	li	a0,1
  800cbe:	ce4ff0ef          	jal	ra,8001a2 <fprintf>
  800cc2:	54fd                	li	s1,-1
  800cc4:	b5ad                	j	800b2e <runcmd+0x60>

0000000000800cc6 <main>:
  800cc6:	7179                	addi	sp,sp,-48
  800cc8:	f022                	sd	s0,32(sp)
  800cca:	842a                	mv	s0,a0
  800ccc:	00000517          	auipc	a0,0x0
  800cd0:	5d450513          	addi	a0,a0,1492 # 8012a0 <error_string+0x2f8>
  800cd4:	ec26                	sd	s1,24(sp)
  800cd6:	f406                	sd	ra,40(sp)
  800cd8:	e84a                	sd	s2,16(sp)
  800cda:	84ae                	mv	s1,a1
  800cdc:	c86ff0ef          	jal	ra,800162 <cputs>
  800ce0:	4789                	li	a5,2
  800ce2:	04f40e63          	beq	s0,a5,800d3e <main+0x78>
  800ce6:	00000497          	auipc	s1,0x0
  800cea:	60a48493          	addi	s1,s1,1546 # 8012f0 <error_string+0x348>
  800cee:	0687c163          	blt	a5,s0,800d50 <main+0x8a>
  800cf2:	00000917          	auipc	s2,0x0
  800cf6:	60690913          	addi	s2,s2,1542 # 8012f8 <error_string+0x350>
  800cfa:	a831                	j	800d16 <main+0x50>
  800cfc:	00001797          	auipc	a5,0x1
  800d00:	30078223          	sb	zero,772(a5) # 802000 <shcwd>
  800d04:	d8aff0ef          	jal	ra,80028e <fork>
  800d08:	cd2d                	beqz	a0,800d82 <main+0xbc>
  800d0a:	04054c63          	bltz	a0,800d62 <main+0x9c>
  800d0e:	006c                	addi	a1,sp,12
  800d10:	d82ff0ef          	jal	ra,800292 <waitpid>
  800d14:	cd09                	beqz	a0,800d2e <main+0x68>
  800d16:	8526                	mv	a0,s1
  800d18:	c4bff0ef          	jal	ra,800962 <readline>
  800d1c:	842a                	mv	s0,a0
  800d1e:	fd79                	bnez	a0,800cfc <main+0x36>
  800d20:	4501                	li	a0,0
  800d22:	70a2                	ld	ra,40(sp)
  800d24:	7402                	ld	s0,32(sp)
  800d26:	64e2                	ld	s1,24(sp)
  800d28:	6942                	ld	s2,16(sp)
  800d2a:	6145                	addi	sp,sp,48
  800d2c:	8082                	ret
  800d2e:	46b2                	lw	a3,12(sp)
  800d30:	d2fd                	beqz	a3,800d16 <main+0x50>
  800d32:	8636                	mv	a2,a3
  800d34:	85ca                	mv	a1,s2
  800d36:	4505                	li	a0,1
  800d38:	c6aff0ef          	jal	ra,8001a2 <fprintf>
  800d3c:	bfe9                	j	800d16 <main+0x50>
  800d3e:	648c                	ld	a1,8(s1)
  800d40:	4601                	li	a2,0
  800d42:	4501                	li	a0,0
  800d44:	d15ff0ef          	jal	ra,800a58 <reopen>
  800d48:	c62a                	sw	a0,12(sp)
  800d4a:	4481                	li	s1,0
  800d4c:	d15d                	beqz	a0,800cf2 <main+0x2c>
  800d4e:	bfd1                	j	800d22 <main+0x5c>
  800d50:	00000597          	auipc	a1,0x0
  800d54:	67858593          	addi	a1,a1,1656 # 8013c8 <error_string+0x420>
  800d58:	4505                	li	a0,1
  800d5a:	c48ff0ef          	jal	ra,8001a2 <fprintf>
  800d5e:	557d                	li	a0,-1
  800d60:	b7c9                	j	800d22 <main+0x5c>
  800d62:	00000697          	auipc	a3,0x0
  800d66:	55668693          	addi	a3,a3,1366 # 8012b8 <error_string+0x310>
  800d6a:	00000617          	auipc	a2,0x0
  800d6e:	55e60613          	addi	a2,a2,1374 # 8012c8 <error_string+0x320>
  800d72:	0f200593          	li	a1,242
  800d76:	00000517          	auipc	a0,0x0
  800d7a:	56a50513          	addi	a0,a0,1386 # 8012e0 <error_string+0x338>
  800d7e:	ac0ff0ef          	jal	ra,80003e <__panic>
  800d82:	8522                	mv	a0,s0
  800d84:	d4bff0ef          	jal	ra,800ace <runcmd>
  800d88:	c62a                	sw	a0,12(sp)
  800d8a:	ceeff0ef          	jal	ra,800278 <exit>
