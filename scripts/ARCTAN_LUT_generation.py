#!/bin/python

import math

N_QUOT = 9                          # quotient width
K = 11                              # full circle angle output width
N_YQ = K - 3                        # [0, 45 deg] output width
N_LUT_line = 2**N_QUOT              # LUT lines
lsb = (2 * math.pi) / (2**float(K)) # 1 LSB in radians (2*pi / 2^11)

print("-" * 40)
print("N_QUOT : " + str(N_QUOT))
print("lines  : " + str(N_LUT_line))
print("N_YQ   : " + str(N_YQ))
print("lsb    : " + str(lsb))

mname = "arctan_lut_" + str(N_LUT_line) + "_" + str(N_YQ) + "bit"
fname = mname + ".vhd"

out_file = open(fname, "w")
out_file.write("library IEEE;\n")
out_file.write("\tuse IEEE.std_logic_1164.all;\n")
out_file.write("\tuse IEEE.numeric_std.all;\n")
out_file.write("\n")
out_file.write("entity " + mname + " is\n")
out_file.write("\tport (\n")
out_file.write("\t\taddress    : in  std_logic_vector(" + str(N_QUOT-1) + " downto 0);\n")
out_file.write("\t\tarctan_out : out std_logic_vector(" + str(N_YQ-1) + " downto 0)\n")
out_file.write("\t);\n")
out_file.write("end entity;\n")
out_file.write("\n")
out_file.write("architecture rtl of " + mname + " is\n")
out_file.write("\n")
out_file.write("\ttype LUT_t is array (natural range 0 to " + str(N_LUT_line-1) + ") of integer;\n")
out_file.write("\tconstant LUT: LUT_t := (\n")

# arctan(quot) calculation
# for 'a' near 512 atan(a/512) would be near 45 degree and its
# representation is about 2^11/8 = 256, overflowing the 8bit
# unsigned output. in this case the output is capped at 255
for a in range(N_LUT_line):
	x = round(math.atan(a / N_LUT_line) / lsb)
	if x > (2**N_YQ - 1):
		x = 2**N_YQ - 1

	if a<(N_LUT_line-1):
		out_file.write("\t\t" + str(a) + " => " + str(int(x)) +",\n")
	else:
		out_file.write("\t\t" + str(a) + " => " + str(int(x)) +"\n")

out_file.write("\t);\n")
out_file.write("\n")
out_file.write("begin\n")
out_file.write("\tarctan_out <= std_logic_vector(to_unsigned(LUT(to_integer(unsigned(address)))," + str(N_YQ) + "));\n")
out_file.write("end architecture;\n")

out_file.close()