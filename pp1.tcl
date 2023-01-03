# ======================================================================
# Define options
# ======================================================================
set val(chan)       Channel/WirelessChannel
set val(prop)       Propagation/TwoRayGround
set val(netif)      Phy/WirelessPhy
set val(mac)        Mac/802_11
set val(ifq)        Queue/DropTail/PriQueue
set val(ll)         LL  ;   #Logical link layer
set val(ant)        Antenna/OmniAntenna
set val(x)              670   ;# X dimension of the topography
set val(y)              670   ;# Y dimension of the topography
set val(ifqlen)         50            ;# max packet in ifq
set val(adhocRouting)   AOMDV ;#Adhoc ondemand Multipath distance vector routing protocol
set val(nn)             50             ;# how many nodes are simulated
set val(sc)            clus2
set val(cp)            clus1
set val(traffic)        cbr  ;#constant bit rate
#set val(rxPower)        0.01                         ;#Potencia recepción en W
#set val(txPower)        0.01     ;#Potencia transmisión en W 
#set val(energymodel)    EnergyModel     ;
set val(initialenergy)  100     ;# Initial energy in Joules
set val(sleeppower)     0.001 
set val(packet)         CLUS 
set val(stop)           50.0           ;# simulation time
# =====================================================================
# Main Program
# ======================================================================

#
# Initialize Global Variables
#

# create simulator instance

set ns_		[new Simulator]
#set thres 3
# setup topography object

set topo	[new Topography]

# create trace object for ns and nam

set tracefd	[open energy.tr w]
set namtrace    [open energy.nam w]

$ns_ trace-all $tracefd
$ns_ namtrace-all-wireless $namtrace $val(x) $val(y)

# define topology
$topo load_flatgrid $val(x) $val(y)


#
# Create God
#
set god_ [create-god $val(nn)]

#
# define how node should be created
#

#global node setting

$ns_ node-config -adhocRouting AOMDV \
                 -llType $val(ll) \
                 -macType $val(mac) \
                 -ifqType $val(ifq) \
                 -ifqLen $val(ifqlen) \
                 -antType $val(ant) \
                 -propType $val(prop) \
                 -phyType $val(netif) \
                 -channelType $val(chan) \
		 -topoInstance $topo \
		 -agentTrace ON \
                 -routerTrace ON \
                 -macTrace ON 
$ns_ node-config -energyModel EnergyModel \
     -rxPower 0.01 \
      -txPower 0.01 \
     -sleepPower 0.001 \
     -initialEnergy 100 
#
#  Create the specified number of nodes [$val(nn)] and "attach" them
#  to the channel. 

for {set i 0} {$i < $val(nn) } {incr i} {
	set node_($i) [$ns_ node]	
	$node_($i) random-motion 0		;# disable random motion
}
  
# 
# Define node movement model
#
puts "Loading connection pattern..."

# 
# Define traffic model
#
puts "Loading scenario file..."
source $val(sc)

# Define node initial position in nam
source $val(cp)  

for {set i 0} {$i < $val(nn)} {incr i} {
  
    $ns_ initial_node_pos $node_($i) 20
}

for {set i 0} {$i < $val(nn) } {incr i} {
    $ns_ at $val(stop).0 "$node_($i) reset";
}
proc finish {} {
    global ns_ tracefd namtrace
    close $tracefd
    close $namtrace
exec nam energy.nam &
exec awk -f delay.awk energy.tr > Performance
exec awk -f energy.awk energy.tr > Energy_perf
exec xgraph PDR -x "No.of Nodes" -y "PDR" &
exec xgraph Delay -x "No.of Nodes" -y "Delay" &
}
$ns_ at $val(stop).0001 "finish"
$ns_ at  $val(stop).0002 "puts \"NS EXITING...\" ; $ns_ halt"
puts "Done"

puts "Starting Simulation..."
$ns_ run




