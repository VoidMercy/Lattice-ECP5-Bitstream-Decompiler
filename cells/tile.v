`include "cells_sim.v"

module tile_PLC2 (
	// LUT inputs
	input wire A0_SLICE,
	input wire A1_SLICE,
	input wire A2_SLICE,
	input wire A3_SLICE,
	input wire A4_SLICE,
	input wire A5_SLICE,
	input wire A6_SLICE,
	input wire A7_SLICE,
	input wire B0_SLICE,
	input wire B1_SLICE,
	input wire B2_SLICE,
	input wire B3_SLICE,
	input wire B4_SLICE,
	input wire B5_SLICE,
	input wire B6_SLICE,
	input wire B7_SLICE,
	input wire C0_SLICE,
	input wire C1_SLICE,
	input wire C2_SLICE,
	input wire C3_SLICE,
	input wire C4_SLICE,
	input wire C5_SLICE,
	input wire C6_SLICE,
	input wire C7_SLICE,
	input wire D0_SLICE,
	input wire D1_SLICE,
	input wire D2_SLICE,
	input wire D3_SLICE,
	input wire D4_SLICE,
	input wire D5_SLICE,
	input wire D6_SLICE,
	input wire D7_SLICE,
	input wire M0_SLICE,
	input wire M1_SLICE,
	input wire M2_SLICE,
	input wire M3_SLICE,
	input wire M4_SLICE,
	input wire M5_SLICE,
	input wire M6_SLICE,
	input wire M7_SLICE,

	output wire F0_SLICE,
	output wire F1_SLICE,
	output wire F2_SLICE,
	output wire F3_SLICE,
	output wire F4_SLICE,
	output wire F5_SLICE,
	output wire F6_SLICE,
	output wire F7_SLICE,

	// FF inputs
	input wire CE0_SLICE, // Slice granularity
	input wire CE1_SLICE,
	input wire CE2_SLICE,
	input wire CE3_SLICE,
	input wire CLK0_SLICE, // Slice granularity
	input wire CLK1_SLICE,
	input wire CLK2_SLICE,
	input wire CLK3_SLICE,
	input wire LSR0_SLICE,
	input wire LSR1_SLICE,
	input wire LSR2_SLICE,
	input wire LSR3_SLICE,
	input wire DI0_SLICE,
	input wire DI1_SLICE,
	input wire DI2_SLICE,
	input wire DI3_SLICE,
	input wire DI4_SLICE,
	input wire DI5_SLICE,
	input wire DI6_SLICE,
	input wire DI7_SLICE,
	input wire FXAA_SLICE,
	input wire FXAB_SLICE,
	input wire FXAC_SLICE,
	input wire FXAD_SLICE,
	input wire FXBA_SLICE,
	input wire FXBB_SLICE,
	input wire FXBC_SLICE,
	input wire FXBD_SLICE,

	output wire Q0_SLICE,
	output wire Q1_SLICE,
	output wire Q2_SLICE,
	output wire Q3_SLICE,
	output wire Q4_SLICE,
	output wire Q5_SLICE,
	output wire Q6_SLICE,
	output wire Q7_SLICE,
	output wire FCOA_SLICE,
	output wire FCOB_SLICE,
	output wire FCOC_SLICE,
	output wire FCO_SLICE,

	input wire FCI_SLICE,
	input wire FCIB_SLICE,
	input wire FCIC_SLICE,
	input wire FCID_SLICE,

	input wire WAD0A_SLICE,
	input wire WAD0B_SLICE,
	input wire WAD1A_SLICE,
	input wire WAD1B_SLICE,
	input wire WAD2A_SLICE,
	input wire WAD2B_SLICE,
	input wire WAD3A_SLICE,
	input wire WAD3B_SLICE,

	input wire WCK0_SLICE,
	input wire WCK1_SLICE,

	input wire WD0A_SLICE,
	input wire WD0B_SLICE,
	input wire WD1A_SLICE,
	input wire WD1B_SLICE,

	input wire WRE0_SLICE,
	input wire WRE1_SLICE,

	output wire F5A_SLICE,
	output wire FXA_SLICE,
	output wire F5B_SLICE,
	output wire FXB_SLICE,
	output wire F5C_SLICE,
	output wire FXC_SLICE,
	output wire F5D_SLICE,
	output wire FXD_SLICE,

	output wire WADO0C_SLICE,
	output wire WADO1C_SLICE,
	output wire WADO2C_SLICE,
	output wire WADO3C_SLICE,
	output wire WDO0C_SLICE,
	output wire WDO1C_SLICE,
	output wire WDO2C_SLICE,
	output wire WDO3C_SLICE

);
	parameter SLICEA_MODE = "LOGIC";
	parameter SLICEA_A0MUX = "A0";
	parameter SLICEA_A1MUX = "A1";
	parameter SLICEA_B0MUX = "B0";
	parameter SLICEA_B1MUX = "B1";
	parameter SLICEA_C0MUX = "C0";
	parameter SLICEA_C1MUX = "C1";
	parameter SLICEA_CCU2_INJECT1_0 = "YES";
	parameter SLICEA_CCU2_INJECT1_1 = "YES";
	parameter SLICEA_CEMUX = "CE";
	parameter SLICEA_D0MUX = "D0";
	parameter SLICEA_D1MUX = "D1";
	parameter SLICEA_GSR = "ENABLED";
	parameter SLICEA_M0MUX = "M0";
	parameter SLICEA_M1MUX = "M1";
	parameter SLICEA_REG0_LSRMODE = "LSR";
	parameter SLICEA_REG0_REGSET = "SET";
	parameter SLICEA_REG0_SD = "1";
	parameter SLICEA_REG1_LSRMODE = "LSR";
	parameter SLICEA_REG1_REGSET = "SET";
	parameter SLICEA_REG1_SD = "1";
	parameter SLICEA_WREMUX = "WRE";
	parameter SLICEA_LUT0_INITVAL = 16'hffff;
	parameter SLICEA_LUT1_INITVAL = 16'hffff;
	parameter LSR0_SRMODE = "LSR_OVER_CE";
	parameter SLICEA_LSRMUX = "LSR";

	parameter SLICEB_MODE = "LOGIC";
	parameter SLICEB_A0MUX = "A0";
	parameter SLICEB_A1MUX = "A1";
	parameter SLICEB_B0MUX = "B0";
	parameter SLICEB_B1MUX = "B1";
	parameter SLICEB_C0MUX = "C0";
	parameter SLICEB_C1MUX = "C1";
	parameter SLICEB_CCU2_INJECT1_0 = "YES";
	parameter SLICEB_CCU2_INJECT1_1 = "YES";
	parameter SLICEB_CEMUX = "CE";
	parameter SLICEB_D0MUX = "D0";
	parameter SLICEB_D1MUX = "D1";
	parameter SLICEB_GSR = "ENABLED";
	parameter SLICEB_M0MUX = "M0";
	parameter SLICEB_M1MUX = "M1";
	parameter SLICEB_REG0_LSRMODE = "LSR";
	parameter SLICEB_REG0_REGSET = "SET";
	parameter SLICEB_REG0_SD = "1";
	parameter SLICEB_REG1_LSRMODE = "LSR";
	parameter SLICEB_REG1_REGSET = "SET";
	parameter SLICEB_REG1_SD = "1";
	parameter SLICEB_WREMUX = "WRE";
	parameter SLICEB_LUT0_INITVAL = 16'hffff;
	parameter SLICEB_LUT1_INITVAL = 16'hffff;
	parameter LSR1_SRMODE = "LSR_OVER_CE";
	parameter SLICEB_LSRMUX = "LSR";

	parameter SLICEC_MODE = "LOGIC";
	parameter SLICEC_A0MUX = "A0";
	parameter SLICEC_A1MUX = "A1";
	parameter SLICEC_B0MUX = "B0";
	parameter SLICEC_B1MUX = "B1";
	parameter SLICEC_C0MUX = "C0";
	parameter SLICEC_C1MUX = "C1";
	parameter SLICEC_CCU2_INJECT1_0 = "YES";
	parameter SLICEC_CCU2_INJECT1_1 = "YES";
	parameter SLICEC_CEMUX = "CE";
	parameter SLICEC_D0MUX = "D0";
	parameter SLICEC_D1MUX = "D1";
	parameter SLICEC_GSR = "ENABLED";
	parameter SLICEC_M0MUX = "M0";
	parameter SLICEC_M1MUX = "M1";
	parameter SLICEC_REG0_LSRMODE = "LSR";
	parameter SLICEC_REG0_REGSET = "SET";
	parameter SLICEC_REG0_SD = "1";
	parameter SLICEC_REG1_LSRMODE = "LSR";
	parameter SLICEC_REG1_REGSET = "SET";
	parameter SLICEC_REG1_SD = "1";
	parameter SLICEC_WREMUX = "WRE";
	parameter SLICEC_LUT0_INITVAL = 16'hffff;
	parameter SLICEC_LUT1_INITVAL = 16'hffff;
	parameter SLICEC_SRMODE = "LSR_OVER_CE";
	parameter SLICEC_LSRMUX = "LSR";

	parameter SLICED_MODE = "LOGIC";
	parameter SLICED_A0MUX = "A0";
	parameter SLICED_A1MUX = "A1";
	parameter SLICED_B0MUX = "B0";
	parameter SLICED_B1MUX = "B1";
	parameter SLICED_C0MUX = "C0";
	parameter SLICED_C1MUX = "C1";
	parameter SLICED_CCU2_INJECT1_0 = "YES";
	parameter SLICED_CCU2_INJECT1_1 = "YES";
	parameter SLICED_CEMUX = "CE";
	parameter SLICED_D0MUX = "D0";
	parameter SLICED_D1MUX = "D1";
	parameter SLICED_GSR = "ENABLED";
	parameter SLICED_M0MUX = "M0";
	parameter SLICED_M1MUX = "M1";
	parameter SLICED_REG0_LSRMODE = "LSR";
	parameter SLICED_REG0_REGSET = "SET";
	parameter SLICED_REG0_SD = "1";
	parameter SLICED_REG1_LSRMODE = "LSR";
	parameter SLICED_REG1_REGSET = "SET";
	parameter SLICED_REG1_SD = "1";
	parameter SLICED_WREMUX = "WRE";
	parameter SLICED_LUT0_INITVAL = 16'hffff;
	parameter SLICED_LUT1_INITVAL = 16'hffff;
	parameter SLICED_SRMODE = "LSR_OVER_CE";
	parameter SLICED_LSRMUX = "LSR";

	// Carries
	wire FCOB_SLICE, FCOC_SLICE;

	TRELLIS_SLICE #(
		.A0MUX(SLICEA_A0MUX),
		.A1MUX(SLICEA_A1MUX),
		.B0MUX(SLICEA_B0MUX),
		.B1MUX(SLICEA_B1MUX),
		.C0MUX(SLICEA_C0MUX),
		.C1MUX(SLICEA_C1MUX),
		.D0MUX(SLICEA_D0MUX),
		.D1MUX(SLICEA_D1MUX),
		.MODE(SLICEA_MODE),
		.GSR(SLICEA_GSR),
		.SRMODE(LSR0_SRMODE),
		.CEMUX(SLICEA_CEMUX),
		.LSRMUX(SLICEA_LSRMUX),
		.LUT0_INITVAL(SLICEA_LUT0_INITVAL),
		.LUT1_INITVAL(SLICEA_LUT1_INITVAL),
		.REG0_SD(SLICEA_REG0_SD),
		.REG1_SD(SLICEA_REG1_SD),
		.REG0_REGSET(SLICEA_REG0_REGSET),
		.REG1_REGSET(SLICEA_REG1_REGSET),
		.REG0_LSRMODE(SLICEA_REG0_LSRMODE),
		.REG1_LSRMODE(SLICEA_REG1_LSRMODE),
		.CCU2_INJECT1_0(SLICEA_CCU2_INJECT1_0),
		.CCU2_INJECT1_1(SLICEA_CCU2_INJECT1_1),
		.WREMUX(SLICEA_WREMUX)
		) sliceA_inst (
		.A0(A0_SLICE),
		.B0(B0_SLICE),
		.C0(C0_SLICE),
		.D0(D0_SLICE),
		.A1(A1_SLICE),
		.B1(B1_SLICE),
		.C1(C1_SLICE),
		.D1(D1_SLICE),
		.M0(M0_SLICE),
		.M1(M1_SLICE),
		.FCI(FCI_SLICE),
		.FXA(FXAA_SLICE),
		.FXB(FXBA_SLICE),
		.CLK(CLK0_SLICE),
		.LSR(LSR0_SLICE),
		.CE(CE0_SLICE),
		.F0(F0_SLICE),
		.F1(F1_SLICE),
		.Q0(Q0_SLICE),
		.Q1(Q1_SLICE),
		.OFX0(F5A_SLICE),
		.OFX1(FXA_SLICE),
		.FCO(FCOA_SLICE),
		.DI0(DI0_SLICE),
		.DI1(DI1_SLICE),
		.WD0(WD0A_SLICE),
		.WD1(WD1A_SLICE),
		.WAD0(WAD0A_SLICE),
		.WAD1(WAD1A_SLICE),
		.WAD2(WAD2A_SLICE),
		.WAD3(WAD3A_SLICE),
		.WRE(WRE0_SLICE),
		.WCK(WCK0_SLICE)
	);

	TRELLIS_SLICE #(
		.A0MUX(SLICEB_A0MUX),
		.A1MUX(SLICEB_A1MUX),
		.B0MUX(SLICEB_B0MUX),
		.B1MUX(SLICEB_B1MUX),
		.C0MUX(SLICEB_C0MUX),
		.C1MUX(SLICEB_C1MUX),
		.D0MUX(SLICEB_D0MUX),
		.D1MUX(SLICEB_D1MUX),
		.MODE(SLICEB_MODE),
		.GSR(SLICEB_GSR),
		.SRMODE(LSR0_SRMODE),
		.CEMUX(SLICEB_CEMUX),
		.LSRMUX(SLICEB_LSRMUX),
		.LUT0_INITVAL(SLICEB_LUT0_INITVAL),
		.LUT1_INITVAL(SLICEB_LUT1_INITVAL),
		.REG0_SD(SLICEB_REG0_SD),
		.REG1_SD(SLICEB_REG1_SD),
		.REG0_REGSET(SLICEB_REG0_REGSET),
		.REG1_REGSET(SLICEB_REG1_REGSET),
		.REG0_LSRMODE(SLICEB_REG0_LSRMODE),
		.REG1_LSRMODE(SLICEB_REG1_LSRMODE),
		.CCU2_INJECT1_0(SLICEB_CCU2_INJECT1_0),
		.CCU2_INJECT1_1(SLICEB_CCU2_INJECT1_1),
		.WREMUX(SLICEB_WREMUX)
		) sliceB_inst (
		.A0(A2_SLICE),
		.B0(B2_SLICE),
		.C0(C2_SLICE),
		.D0(D2_SLICE),
		.A1(A3_SLICE),
		.B1(B3_SLICE),
		.C1(C3_SLICE),
		.D1(D3_SLICE),
		.M0(M2_SLICE),
		.M1(M3_SLICE),
		.FCI(FCIB_SLICE),
		.FXA(FXAB_SLICE),
		.FXB(FXBB_SLICE),
		.CLK(CLK1_SLICE),
		.LSR(LSR1_SLICE),
		.CE(CE1_SLICE),
		.F0(F2_SLICE),
		.F1(F3_SLICE),
		.Q0(Q2_SLICE),
		.Q1(Q3_SLICE),
		.OFX0(F5B_SLICE),
		.OFX1(FXB_SLICE),
		.FCO(FCOB_SLICE),
		.DI0(DI2_SLICE),
		.DI1(DI3_SLICE),
		.WD0(WD0B_SLICE),
		.WD1(WD1B_SLICE),
		.WAD0(WAD0B_SLICE),
		.WAD1(WAD1B_SLICE),
		.WAD2(WAD2B_SLICE),
		.WAD3(WAD3B_SLICE),
		.WRE(WRE1_SLICE),
		.WCK(WCK1_SLICE)
	);

	// SLICEC
	TRELLIS_SLICE #(
		.A0MUX(SLICEC_A0MUX),
		.A1MUX(SLICEC_A1MUX),
		.B0MUX(SLICEC_B0MUX),
		.B1MUX(SLICEC_B1MUX),
		.C0MUX(SLICEC_C0MUX),
		.C1MUX(SLICEC_C1MUX),
		.D0MUX(SLICEC_D0MUX),
		.D1MUX(SLICEC_D1MUX),
		.MODE(SLICEC_MODE),
		.GSR(SLICEC_GSR),
		.SRMODE(LSR1_SRMODE),
		.CEMUX(SLICEC_CEMUX),
		.LSRMUX(SLICEC_LSRMUX),
		.LUT0_INITVAL(SLICEC_LUT0_INITVAL),
		.LUT1_INITVAL(SLICEC_LUT1_INITVAL),
		.REG0_SD(SLICEC_REG0_SD),
		.REG1_SD(SLICEC_REG1_SD),
		.REG0_REGSET(SLICEC_REG0_REGSET),
		.REG1_REGSET(SLICEC_REG1_REGSET),
		.REG0_LSRMODE(SLICEC_REG0_LSRMODE),
		.REG1_LSRMODE(SLICEC_REG1_LSRMODE),
		.CCU2_INJECT1_0(SLICEC_CCU2_INJECT1_0),
		.CCU2_INJECT1_1(SLICEC_CCU2_INJECT1_1),
		.WREMUX(SLICEC_WREMUX)
		) sliceC_inst (
		.A0(A4_SLICE),
		.B0(B4_SLICE),
		.C0(C4_SLICE),
		.D0(D4_SLICE),
		.A1(A5_SLICE),
		.B1(B5_SLICE),
		.C1(C5_SLICE),
		.D1(D5_SLICE),
		.M0(M4_SLICE),
		.M1(M5_SLICE),
		.FCI(FCIC_SLICE),
		.FXA(FXAC_SLICE),
		.FXB(FXBC_SLICE),
		.CLK(CLK2_SLICE),
		.LSR(LSR2_SLICE),
		.CE(CE2_SLICE),
		.F0(F4_SLICE),
		.F1(F5_SLICE),
		.Q0(Q4_SLICE),
		.Q1(Q5_SLICE),
		.OFX0(F5C_SLICE),
		.OFX1(FXC_SLICE),
		.FCO(FCOC_SLICE),
		.DI0(DI4_SLICE),
		.DI1(DI5_SLICE),
		.WDO0(WDO0C_SLICE),
		.WDO1(WDO1C_SLICE),
		.WDO2(WDO2C_SLICE),
		.WDO3(WDO3C_SLICE),
		.WADO0(WADO0C_SLICE),
		.WADO1(WADO1C_SLICE),
		.WADO2(WADO2C_SLICE),
		.WADO3(WADO3C_SLICE)
	);

	// SLICED
	TRELLIS_SLICE #(
		.A0MUX(SLICED_A0MUX),
		.A1MUX(SLICED_A1MUX),
		.B0MUX(SLICED_B0MUX),
		.B1MUX(SLICED_B1MUX),
		.C0MUX(SLICED_C0MUX),
		.C1MUX(SLICED_C1MUX),
		.D0MUX(SLICED_D0MUX),
		.D1MUX(SLICED_D1MUX),
		.MODE(SLICED_MODE),
		.GSR(SLICED_GSR),
		.SRMODE(LSR1_SRMODE),
		.CEMUX(SLICED_CEMUX),
		.LSRMUX(SLICED_LSRMUX),
		.LUT0_INITVAL(SLICED_LUT0_INITVAL),
		.LUT1_INITVAL(SLICED_LUT1_INITVAL),
		.REG0_SD(SLICED_REG0_SD),
		.REG1_SD(SLICED_REG1_SD),
		.REG0_REGSET(SLICED_REG0_REGSET),
		.REG1_REGSET(SLICED_REG1_REGSET),
		.REG0_LSRMODE(SLICED_REG0_LSRMODE),
		.REG1_LSRMODE(SLICED_REG1_LSRMODE),
		.CCU2_INJECT1_0(SLICED_CCU2_INJECT1_0),
		.CCU2_INJECT1_1(SLICED_CCU2_INJECT1_1),
		.WREMUX(SLICED_WREMUX)
		) sliceD_inst (
		.A0(A6_SLICE),
		.B0(B6_SLICE),
		.C0(C6_SLICE),
		.D0(D6_SLICE),
		.A1(A7_SLICE),
		.B1(B7_SLICE),
		.C1(C7_SLICE),
		.D1(D7_SLICE),
		.M0(M6_SLICE),
		.M1(M7_SLICE),
		.FCI(FCID_SLICE),
		.FXA(FXAD_SLICE),
		.FXB(FXBD_SLICE),
		.CLK(CLK3_SLICE),
		.LSR(LSR3_SLICE),
		.CE(CE3_SLICE),
		.F0(F6_SLICE),
		.F1(F7_SLICE),
		.Q0(Q6_SLICE),
		.Q1(Q7_SLICE),
		.OFX0(F5D_SLICE),
		.OFX1(FXD_SLICE),
		.FCO(FCO_SLICE),
		.DI0(DI6_SLICE),
		.DI1(DI7_SLICE)
	);
endmodule
