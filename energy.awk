
BEGIN {
print("\n\n******** Network Statistics ********\n");

energy_left[50] = 100.000000;
ATEC = 0.000000;
total_energy_consumed = 0.000000;
Remaining_Energy = 0.000000;
}
{
state		= 	$1;
time 		= 	$3;
# For energy consumption statistics see trace file
node_num	= 	$5;
energy_level 	= 	$7;
node_id 	= 	$9;
level 		= 	$19;
pkt_type 	= 	$35;
packet_id	= 	$41;
no_of_forwards 	=	$49;
# To Calculate Average Energy Consumption
if(state == "N") {
	for(i=0;i<50;i++) {
		if(i == node_num) {
				energy_left[i] = energy_level;

		}
	  }
}
}
END {
for(i=0;i<50;i++) {
printf("%d %.2f \n",i, energy_left[i]) > "Residual.txt";

Remaining_Energy = Remaining_Energy + energy_left[i];
ATEC = ATEC + (100 - energy_left[i]);
}
printf " Remaining Energy = " Remaining_Energy;
print "\n";
printf "Remaining Energy = " Remaining_Energy/5000*100 "%" ;
print "\n";
printf " Consumption      = " ATEC ;
print "\n";
printf "  Consumption     = " ATEC/5000 * 100 "%" ;
print "\n";
}
