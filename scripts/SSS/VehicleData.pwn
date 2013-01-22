enum E_VEHICLE_DATA
{
Float:	veh_maxFuel,
Float:	veh_fuelCons,
		veh_lootIndex,
		veh_trunkSize
}


new const VehicleFuelData[212][E_VEHICLE_DATA] =
{
	{90.0,	13.0,	loot_CarCivilian,		12}, // 400
	{40.0,	11.0,	loot_CarCivilian,		12}, // 401
	{60.0,	15.0,	loot_CarCivilian,		12}, // 402
	{120.0,	60.0,	loot_CarCivilian,		12}, // 403
	{60.0,	13.0,	loot_CarCivilian,		12}, // 404
	{50.0,	14.0,	loot_CarCivilian,		12}, // 405
	{40.0,	13.0,	loot_CarCivilian,		12}, // 406
	{70.0,	22.0,	loot_CarIndustrial,		16}, // 407
	{70.0,	4.0,	loot_CarCivilian,		12}, // 408
	{50.0,	13.0,	loot_CarCivilian,		12}, // 409
	{40.0,	9.0,	loot_CarCivilian,		12}, // 410

	{50.0,	18.0,	loot_CarCivilian,		12}, // 411
	{50.0,	17.0,	loot_CarCivilian,		12}, // 412
	{50.0,	15.0,	loot_CarCivilian,		12}, // 413
	{50.0,	24.0,	loot_CarCivilian,		12}, // 414
	{60.0,	15.0,	loot_CarCivilian,		12}, // 415
	{80.0,	13.0,	loot_CarIndustrial,		16}, // 416
	{185.0,	143.0,	loot_CarCivilian,		12}, // 417
	{60.0,	18.0,	loot_CarCivilian,		12}, // 418
	{55.0,	17.0,	loot_CarCivilian,		12}, // 419
	{55.0,	12.0,	loot_CarCivilian,		12}, // 420

	{50.0,	13.0,	loot_CarCivilian,		12}, // 421
	{60.0,	16.0,	loot_CarCivilian,		12}, // 422
	{60.0,	17.0,	loot_CarCivilian,		12}, // 423
	{40.0,	8.0,	loot_CarCivilian,		12}, // 424
	{1421.0,441.0,	-1,						0}, // 425
	{55.0,	12.0,	loot_CarCivilian,		12}, // 426
	{90.0,	36.0,	loot_CarMilitary,		12}, // 427
	{90.0,	31.0,	loot_CarMilitary,		12}, // 428
	{40.0,	18.0,	loot_CarCivilian,		12}, // 429
	{70.0,	31.0,	loot_CarMilitary,		12}, // 430

	{70.0,	24.0,	loot_CarCivilian,		12}, // 431
	{1900.0,392.0,	loot_CarMilitary,		12}, // 432
	{200.0,	77.0,	loot_CarMilitary,		12}, // 433
	{50.0,	8.0,	loot_CarCivilian,		12}, // 434
	{-1.0,	0.0,	loot_CarCivilian,		12}, // 435
	{35.0,	8.0,	loot_CarCivilian,		12}, // 436
	{70.0,	24.0,	loot_CarCivilian,		12}, // 437
	{60.0,	17.0,	loot_CarCivilian,		12}, // 438
	{45.0,	14.0,	loot_CarCivilian,		12}, // 439
	{55.0,	19.0,	loot_CarIndustrial,		16}, // 440

	{-1.0,	0.0,	loot_CarCivilian,		12}, // 441
	{35.0,	13.0,	loot_CarCivilian,		12}, // 442
	{60.0,	34.0,	loot_CarCivilian,		12}, // 443
	{80.0,	48.0,	loot_CarCivilian,		12}, // 444
	{35.0,	10.0,	loot_CarCivilian,		12}, // 445
	{50.0,	31.0,	loot_CarCivilian,		12}, // 446
	{80.0,	46.0,	loot_CarCivilian,		12}, // 447
	{8.0,	3.0,	loot_CarCivilian,		12}, // 448
	{-1.0,	13.0,	loot_CarCivilian,		12}, // 449
	{-1.0,	13.0,	loot_CarCivilian,		12}, // 450

	{50.0,	25.0,	loot_CarCivilian,		12}, // 451
	{60.0,	30.0,	loot_CarCivilian,		12}, // 452
	{60.0,	34.0,	loot_CarCivilian,		12}, // 453
	{60.0,	36.0,	loot_CarCivilian,		12}, // 454
	{70.0,	69.0,	loot_CarIndustrial,		16}, // 455
	{60.0,	45.0,	loot_CarIndustrial,		16}, // 456
	{10.0,	4.0,	loot_CarCivilian,		12}, // 457
	{40.0,	14.0,	loot_CarCivilian,		12}, // 458
	{40.0,	16.0,	loot_CarCivilian,		12}, // 459
	{102.0,	11.0,	loot_CarCivilian,		12}, // 460

	{18.0,	6.0,	loot_CarCivilian,		12}, // 461
	{8.0,	3.0,	loot_CarCivilian,		12}, // 462
	{19.0,	5.0,	loot_CarCivilian,		12}, // 463
	{-1.0,	0.0,	loot_CarCivilian,		12}, // 464
	{-1.0,	0.0,	loot_CarCivilian,		12}, // 465
	{45.0,	11.0,	loot_CarCivilian,		12}, // 466
	{45.0,	13.0,	loot_CarCivilian,		12}, // 467
	{10.0,	6.0,	loot_CarCivilian,		12}, // 468
	{190.0,	68.0,	loot_CarIndustrial,		16}, // 469
	{94.0,	26.0,	loot_CarMilitary,		12}, // 470

	{9.0,	13.0,	loot_CarCivilian,		12}, // 471
	{60.0,	28.0,	loot_CarIndustrial,		16}, // 472
	{81.0,	27.0,	loot_CarCivilian,		12}, // 473
	{40.0,	16.0,	loot_CarCivilian,		12}, // 474
	{60.0,	15.0,	loot_CarCivilian,		12}, // 475
	{68.0,	25.0,	loot_CarCivilian,		12}, // 476
	{50.0,	14.0,	loot_CarCivilian,		12}, // 477
	{60.0,	26.0,	loot_CarIndustrial,		16}, // 478
	{55.0,	13.0,	loot_CarCivilian,		12}, // 479
	{50.0,	12.0,	loot_CarCivilian,		12}, // 480

	{-1.0,	0.0,	loot_CarCivilian,		12}, // 481
	{70.0,	13.0,	loot_CarIndustrial,		16}, // 482
	{80.0,	26.0,	loot_CarIndustrial,		16}, // 483
	{900.0,	67.0,	loot_CarCivilian,		12}, // 484
	{24.0,	4.0,	loot_CarCivilian,		12}, // 485
	{50.0,	47.0,	loot_CarCivilian,		12}, // 486
	{240.0,	76.0,	loot_CarCivilian,		12}, // 487
	{240.0,	76.0,	loot_CarCivilian,		12}, // 488
	{100.0,	16.0,	loot_CarCivilian,		12}, // 489
	{100.0,	18.0,	loot_CarMilitary,		12}, // 490

	{45.0,	11.0,	loot_CarCivilian,		12}, // 491
	{55.0,	12.0,	loot_CarCivilian,		12}, // 492
	{90.0,	21.0,	loot_CarCivilian,		12}, // 493
	{80.0,	28.0,	loot_CarCivilian,		12}, // 494
	{120.0,	31.0,	loot_CarCivilian,		12}, // 495
	{40.0,	12.0,	loot_CarCivilian,		12}, // 496
	{240.0,	76.0,	loot_CarCivilian,		12}, // 497
	{75.0,	19.0,	loot_CarIndustrial,		16}, // 498
	{70.0,	19.0,	loot_CarIndustrial,		16}, // 499
	{77.0,	13.0,	loot_CarCivilian,		12}, // 500

	{-1.0,	0.0,	loot_CarCivilian,		12}, // 501
	{80.0,	13.0,	loot_CarCivilian,		12}, // 502
	{80.0,	13.0,	loot_CarCivilian,		12}, // 503
	{65.0,	13.0,	loot_CarCivilian,		12}, // 504
	{70.0,	13.0,	loot_CarCivilian,		12}, // 505
	{50.0,	13.0,	loot_CarCivilian,		12}, // 506
	{35.0,	13.0,	loot_CarCivilian,		12}, // 507
	{60.0,	13.0,	loot_CarCivilian,		12}, // 508
	{-1.0,	13.0,	loot_CarCivilian,		12}, // 509
	{-1.0,	13.0,	loot_CarCivilian,		12}, // 510

	{-1.0,	13.0,	loot_CarCivilian,		12}, // 511
	{-1.0,	13.0,	loot_CarCivilian,		12}, // 512
	{-1.0,	13.0,	loot_CarCivilian,		12}, // 513
	{100.0,	13.0,	loot_CarIndustrial,		16}, // 514
	{100.0,	13.0,	loot_CarIndustrial,		16}, // 515
	{35.0,	13.0,	loot_CarCivilian,		12}, // 516
	{35.0,	13.0,	loot_CarCivilian,		12}, // 517
	{40.0,	13.0,	loot_CarCivilian,		12}, // 518
	{-1.0,	13.0,	loot_CarCivilian,		12}, // 519
	{-1.0,	13.0,	loot_CarCivilian,		12}, // 520

	{45.0,	13.0,	loot_CarCivilian,		12}, // 521
	{45.0,	13.0,	loot_CarCivilian,		12}, // 522
	{60.0,	13.0,	loot_CarCivilian,		12}, // 523
	{60.0,	13.0,	loot_CarCivilian,		12}, // 524
	{50.0,	13.0,	loot_CarIndustrial,		16}, // 525
	{45.0,	13.0,	loot_CarCivilian,		12}, // 526
	{30.0,	13.0,	loot_CarCivilian,		12}, // 527
	{80.0,	13.0,	loot_CarMilitary,		12}, // 528
	{50.0,	13.0,	loot_CarCivilian,		12}, // 529
	{25.0,	13.0,	loot_CarCivilian,		12}, // 530

	{50.0,	13.0,	loot_CarCivilian,		12}, // 531
	{60.0,	13.0,	loot_CarCivilian,		12}, // 532
	{60.0,	13.0,	loot_CarCivilian,		12}, // 533
	{60.0,	13.0,	loot_CarCivilian,		12}, // 534
	{60.0,	13.0,	loot_CarCivilian,		12}, // 535
	{60.0,	13.0,	loot_CarCivilian,		12}, // 536
	{60.0,	13.0,	loot_CarCivilian,		12}, // 537
	{60.0,	13.0,	loot_CarCivilian,		12}, // 538
	{60.0,	13.0,	loot_CarCivilian,		12}, // 539
	{60.0,	13.0,	loot_CarCivilian,		12}, // 540

	{50.0,	13.0,	loot_CarCivilian,		12}, // 541
	{60.0,	13.0,	loot_CarCivilian,		12}, // 542
	{60.0,	13.0,	loot_CarCivilian,		12}, // 543
	{70.0,	13.0,	loot_CarIndustrial,		16}, // 544
	{60.0,	13.0,	loot_CarCivilian,		12}, // 545
	{60.0,	13.0,	loot_CarCivilian,		12}, // 546
	{60.0,	13.0,	loot_CarCivilian,		12}, // 547
	{2000.0,441.0,	loot_CarMilitary,		12}, // 548
	{60.0,	13.0,	loot_CarCivilian,		12}, // 549
	{60.0,	13.0,	loot_CarCivilian,		12}, // 550

	{60.0,	13.0,	loot_CarCivilian,		12}, // 551
	{60.0,	13.0,	loot_CarCivilian,		12}, // 552
	{200.0,	13.0,	loot_CarCivilian,		12}, // 553
	{60.0,	13.0,	loot_CarIndustrial,		16}, // 554
	{60.0,	13.0,	loot_CarCivilian,		12}, // 555
	{40.0,	13.0,	loot_CarCivilian,		12}, // 556
	{40.0,	13.0,	loot_CarCivilian,		12}, // 557
	{50.0,	13.0,	loot_CarCivilian,		12}, // 558
	{50.0,	13.0,	loot_CarCivilian,		12}, // 559
	{60.0,	13.0,	loot_CarCivilian,		12}, // 560

	{60.0,	13.0,	loot_CarCivilian,		12}, // 561
	{60.0,	13.0,	loot_CarCivilian,		12}, // 562
	{200.0,	13.0,	loot_CarCivilian,		12}, // 563
	{-1.0,	13.0,	loot_CarCivilian,		12}, // 564
	{60.0,	13.0,	loot_CarCivilian,		12}, // 565
	{60.0,	13.0,	loot_CarCivilian,		12}, // 566
	{60.0,	13.0,	loot_CarCivilian,		12}, // 567
	{60.0,	13.0,	loot_CarCivilian,		12}, // 568
	{60.0,	13.0,	loot_CarCivilian,		12}, // 569
	{60.0,	13.0,	loot_CarCivilian,		12}, // 570

	{20.0,	13.0,	loot_CarCivilian,		12}, // 571
	{20.0,	13.0,	loot_CarCivilian,		12}, // 572
	{60.0,	13.0,	loot_CarCivilian,		12}, // 573
	{60.0,	13.0,	loot_CarCivilian,		12}, // 574
	{60.0,	13.0,	loot_CarCivilian,		12}, // 575
	{60.0,	13.0,	loot_CarCivilian,		12}, // 576
	{60.0,	13.0,	loot_CarCivilian,		12}, // 577
	{60.0,	13.0,	loot_CarCivilian,		12}, // 578
	{70.0,	13.0,	loot_CarCivilian,		12}, // 579
	{100.0,	13.0,	loot_CarCivilian,		12}, // 580

	{100.0,	13.0,	loot_CarCivilian,		12}, // 581
	{100.0,	13.0,	loot_CarCivilian,		12}, // 582
	{100.0,	13.0,	loot_CarCivilian,		12}, // 583
	{100.0,	13.0,	loot_CarCivilian,		12}, // 584
	{100.0,	13.0,	loot_CarCivilian,		12}, // 585
	{100.0,	13.0,	loot_CarCivilian,		12}, // 586
	{60.0,	13.0,	loot_CarCivilian,		12}, // 587
	{100.0,	13.0,	loot_CarCivilian,		12}, // 588
	{100.0,	13.0,	loot_CarCivilian,		12}, // 589
	{100.0,	13.0,	loot_CarCivilian,		12}, // 590

	{100.0,	13.0,	loot_CarCivilian,		12}, // 591
	{100.0,	13.0,	loot_CarCivilian,		12}, // 592
	{100.0,	13.0,	loot_CarCivilian,		12}, // 593
	{100.0,	13.0,	loot_CarCivilian,		12}, // 594
	{100.0,	13.0,	loot_CarCivilian,		12}, // 595
	{100.0,	13.0,	loot_CarCivilian,		12}, // 596
	{100.0,	13.0,	loot_CarCivilian,		12}, // 597
	{100.0,	13.0,	loot_CarCivilian,		12}, // 598
	{100.0,	13.0,	loot_CarCivilian,		12}, // 599
	{100.0,	13.0,	loot_CarCivilian,		12}, // 600

	{100.0,	13.0,	loot_CarMilitary,		12}, // 601
	{100.0,	13.0,	loot_CarCivilian,		12}, // 602
	{50.0,	13.0,	loot_CarCivilian,		12}, // 603
	{100.0,	13.0,	loot_CarCivilian,		12}, // 604
	{100.0,	13.0,	loot_CarCivilian,		12}, // 605
	{100.0,	13.0,	loot_CarCivilian,		12}, // 606
	{100.0,	13.0,	loot_CarCivilian,		12}, // 607
	{100.0,	13.0,	loot_CarCivilian,		12}, // 608
	{100.0,	13.0,	loot_CarIndustrial,		16}, // 609
	{100.0,	13.0,	loot_CarCivilian,		12}, // 610

	{100.0,	13.0,	loot_CarCivilian,		12}  // 611
};
