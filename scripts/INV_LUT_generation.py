#!/bin/python

N_DEN = 8                  # denominator width
N_YQ  = 17                 # output width
N_LUT_line = 2**N_DEN      # LUT lines
lsb = 1/(2**(float(N_YQ))) # Least Significant Bit value (2^-17)

print("-" * 40)
print("N_DEN : " + str(N_DEN))
print("lines : " + str(N_LUT_line))
print("N_YQ  : " + str(N_YQ))
print("lsb   : " + str(lsb))

mname = "inv_lut_" + str(N_LUT_line) + "_" + str(N_YQ) + "bit"
fname = mname + ".vhd"

out_file = open(fname, "w")
out_file.write("library IEEE;\n")
out_file.write("\tuse IEEE.std_logic_1164.all;\n")
out_file.write("\tuse IEEE.numeric_std.all;\n")
out_file.write("\n")
out_file.write("entity " + mname + " is\n")
out_file.write("\tport (\n")
out_file.write("\t\taddress : in  std_logic_vector(" + str(N_DEN-1) + " downto 0);\n")
out_file.write("\t\tinv_out : out std_logic_vector(" + str(N_YQ-1) + " downto 0)\n")
out_file.write("\t);\n")
out_file.write("end entity;\n")
out_file.write("\n")
out_file.write("architecture rtl of " + mname + " is\n")
out_file.write("\n")
out_file.write("\ttype LUT_t is array (natural range 0 to " + str(N_LUT_line-1) + ") of integer;\n")
out_file.write("\tconstant LUT: LUT_t := (\n")

for a in range(N_LUT_line):
	if a == 0:
        # when den=0 i just put a placeholder '0' in the LUT, as the
        # division is skipped entirely thanks to 'zero_div' signal
		x = 0
	else:
		x = round((1/a)/lsb)
		if x > (2**N_YQ - 1):
			x = 2**N_YQ - 1

	if a<(N_LUT_line-1):
		out_file.write("\t\t" + str(a) + " => " + str(int(x)) +",\n")
	else:
		out_file.write("\t\t" + str(a) + " => " + str(int(x)) +"\n")

out_file.write("\t);\n")
out_file.write("\n")
out_file.write("begin\n")
out_file.write("\tinv_out <= std_logic_vector(to_unsigned(LUT(to_integer(unsigned(address)))," + str(N_YQ) + "));\n")
out_file.write("end architecture;\n")

out_file.close()