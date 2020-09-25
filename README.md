# nio-exchange

Running exchange.sh calculates the free energy of NiO in various magnetic configurations (Non-Spin Polarized, Ferromagnetic, AF1, AF2).

I used 4 methods to overcome any possible convergence issues for each configuration

1. Calculate from scratch
2. Continue from WAVECAR generated during non-spin polarized calculation.
3. Continue from CHGCAR generated during non-spin polarized calculation.
4. Continue from both WAVECAR and CHGCAR generated during non-spin polarized calculation.


Final Magnetic moments are as below:

<ins>Ferromagnetic case</ins>

Spin up Ni: 1.246 uB
Spin up O:  0.231 uB


<ins>AF1 case</ins>

Spin up Ni: 0.641 uB
Spin down Ni: -0.641 uB
Spin up O:  0.036 uB
Spin down O:  0.036 uB

<ins>AF2 case</ins>

Spin up Ni: 1.318 uB
Spin down Ni: -1.318 uB
Spin up O:  0 uB
Spin down O:  0 uB

Examine results folder for detailed information.
