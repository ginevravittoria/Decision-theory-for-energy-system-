set P;	                # solar panels set
set T;					# time interval set
set PVprod;				# pv production
set Consum;				# power consumed
#set Grid;				# power inported/exported (negative) from grid


#param t := card(T);		# time interval value
param p := card(P);		# number of PV
param Price{T};			# spot price of power
param Batt_max > 0;		# maximum capacity of battery (W)
param Batt_rate > 0;	# maximum battery charge rate
param V2G_max > 0;
param V2G_rate > 0;
param V2G_min > 0;
param ceof;				# coef per W of power from grid



var Batt{T};			# battery state: charging (neg), discharging (postitive)
var V2G{T};				# V2G state: charging (neg), discharging (postitive)

var g{T};				# grid state: import(positive), export (neg)


minimize cost:
	sum{t in T} Price[t]*g[t];

minimize emission:
	sum{t in T} coef[t]*g[t];

subject to equilibrium:
	sum{t in T} Consum[t] = PVprod[t] + g[t] + Batt[t] + V2G[t];
  
subject to V2G_constraint_min{t in T}:
	V2G[t] >= V2G_min;
	
subject to V2G_constraint_max{t in T}:
	V2G[t] <= V2G_max;
	
subject to battery_constraint_max{t in T}:
	Batt[t] <= Batt_max;
	
# battery rates, use HUC ramp up down tutorial