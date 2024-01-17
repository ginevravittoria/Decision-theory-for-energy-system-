# INF569: Project mod file
# GROUP: Amaury Fabre, Leopold Dardel, Ginerva Vittoria

# PARAMETERS -----------------------------------------------------------------------
# Parameter sets for input data
set T;						# time interval set
param PVprod{T};			# pv production (W)
param Consum{T};			# power consumed (W)
param Price{T};				# spot price of power (eur/kW)
param coefCO2{T};			# coef of CO2 per W of power from grid (eur/kW)

# Power system parameters
param Batt_max >= 0;		# maximum capacity of battery (Wh)
param Batt_rate >= 0;		# maximum battery charge rate (W)
param V2G_max >= 0;			# maximum capacity of vehicle battery (Wh)
param V2G_min >= 0;			# minimum capacity of vehicle battery (Wh)
param V2G_rate >= 0;		# maximum vehicle battery charge rate (W)

# Bi-objective parameter
param w1 >=0, default 0.5;	# weight for o.f. 1


# VARIABLES -----------------------------------------------------------------------
var Batt{T} >=0;			# Battery charge level time series
var V2G{T} >= 0;			# V2G battery charge level time series
var g{T} >=0 ;				# grid connection state: import(positive)
var sink{T} >= 0;			# power sink for excess solar power


# OBJECTIVE FUNCTIONS --------------------------------------------------------------
# objective 1: minimize electricity costs
minimize cost:
	sum{t in T} (Price[t]*g[t]);

# objective 2: minimize electricity lost/wasted
minimize emission: 
	sum{t in T} (coefCO2[t]*(g[t]+sink[t]));

# objectives combined, weighted, and normalized
minimize combined:
	sum{t in T}( w1*Price[t]*g[t] + (1-w1)*coefCO2[t]*(g[t]+sink[t]) );


# CONSTRAINTS ---------------------------------------------------------------------
# Electricity equilibrium at each time step
subject to equilibrium{t in T diff {1}}:
	Consum[t] + sink[t] = PVprod[t] + g[t] - Batt[t] + Batt[t-1] - V2G[t] + V2G[t-1];

# equilibrium at step 1 (no battery or V2G at 0)
subject to equilibrium2{t in {1}}:
	Consum[t] + sink[t] = PVprod[t] + g[t] - Batt[t] - V2G[t];

# Maximum V2G battery level constraint
subject to V2G_constraint_max{t in T}:
	V2G[t] <= V2G_max;
	
# Minimum V2G battery level constraint
subject to V2G_constraint_min{t in T}:
	V2G[t] >= V2G_min;

# Maximum battery level constraint
subject to battery_constraint_max{t in T}:
	Batt[t] <= Batt_max;

# Maximum V2G battery charge rate constraint
subject to V2G_constraint_charge{t in T diff {1}}:
	V2G[t] - V2G[t-1] <= V2G_rate;

# Maximum V2G battery discharge rate constraint
subject to V2G_constraint_charge2{t in T diff {1}}:
	V2G[t-1] - V2G[t] <= V2G_rate;

# Maximum battery charge rate constraint
subject to battery_constraint_charge{t in T diff {1}}:
	Batt[t] - Batt[t-1] <= Batt_rate;

# Maximum battery discharge rate constraint
subject to battery_constraint_charge2{t in T diff {1}}:
	Batt[t-1] - Batt[t] <= Batt_rate;

	
