#! /bin/bash

#SBATCH —job-name=exchange
#SBATCH --ntasks=2
#SBATCH --time=480:00:00

module purge
module load vasp/5.4.4-p1-cuda10-intel19

LANG=en_US
SCRATCHPATH=/scratch/tugberkozdemir




# Prepare workspace (local)


rm -rf $SCRATCHPATH/exchange-final
mkdir $SCRATCHPATH/exchange-final

rm -rf results
mkdir results

mkdir results/from-scratch
mkdir results/continue-both
mkdir results/continue-wave
mkdir results/continue-chg


#Non-spin-polarized base calculation

echo -e "\e[1;31m*** Non-spin polarized base calculation ***\e[0m"

mkdir $SCRATCHPATH/exchange-final/non-spin-polarized

cp resources/INCAR.NS $SCRATCHPATH/exchange-final/non-spin-polarized/INCAR
cp resources/POSCAR.NS $SCRATCHPATH/exchange-final/non-spin-polarized/POSCAR
cp resources/KPOINTS $SCRATCHPATH/exchange-final/non-spin-polarized/KPOINTS
cp resources/POTCAR $SCRATCHPATH/exchange-final/non-spin-polarized/POTCAR

mpirun -np 1 -wdir $SCRATCHPATH/exchange-final/non-spin-polarized vasp_gpu

# grab wavecar & chgcar
cp $SCRATCHPATH/exchange-final/non-spin-polarized/WAVECAR  $SCRATCHPATH/exchange-final/WAVECAR
cp $SCRATCHPATH/exchange-final/non-spin-polarized/CHGCAR  $SCRATCHPATH/exchange-final/CHGCAR

cp $SCRATCHPATH/exchange-final/non-spin-polarized/OUTCAR  results/OUTCAR.NS
cp $SCRATCHPATH/exchange-final/non-spin-polarized/OSZICAR  results/OSZICAR.NS


#perform other calculations

mkdir $SCRATCHPATH/exchange-final/continue-chg
mkdir $SCRATCHPATH/exchange-final/continue-wave
mkdir $SCRATCHPATH/exchange-final/continue-both
mkdir $SCRATCHPATH/exchange-final/from-scratch

#mag stands for magnetic configuration
for mag in FM AF1 AF2
do
    #start from scratch
    echo -e "\e[1;31m*** $mag calculation is performed from scratch ***\e[0m"
    mkdir $SCRATCHPATH/exchange-final/from-scratch/$mag
    
    cp resources/INCAR.$mag $SCRATCHPATH/exchange-final/from-scratch/$mag/INCAR
    cp resources/POSCAR.$mag $SCRATCHPATH/exchange-final/from-scratch/$mag/POSCAR
    cp resources/KPOINTS $SCRATCHPATH/exchange-final/from-scratch/$mag/KPOINTS
    cp resources/POTCAR $SCRATCHPATH/exchange-final/from-scratch/$mag/POTCAR
    
    echo 'ISTART = 0' >> $SCRATCHPATH/exchange-final/from-scratch/$mag/INCAR
    echo 'ICHARG = 2' >> $SCRATCHPATH/exchange-final/from-scratch/$mag/INCAR
    
    mpirun -np 1 -wdir $SCRATCHPATH/exchange-final/from-scratch/$mag/ vasp_gpu
    
    cp $SCRATCHPATH/exchange-final/from-scratch/$mag/OUTCAR results/from-scratch/OUTCAR.$mag
    cp $SCRATCHPATH/exchange-final/from-scratch/$mag/OSZICAR results/from-scratch/OSZICAR.$mag


    #continue from wavecar
    echo -e "\e[1;31m*** $mag calculation continues from WAVECAR only ***\e[0m"
    mkdir $SCRATCHPATH/exchange-final/continue-wave/$mag
    
    cp resources/INCAR.$mag $SCRATCHPATH/exchange-final/continue-wave/$mag/INCAR
    cp resources/POSCAR.$mag $SCRATCHPATH/exchange-final/continue-wave/$mag/POSCAR
    cp resources/KPOINTS $SCRATCHPATH/exchange-final/continue-wave/$mag/KPOINTS
    cp resources/POTCAR $SCRATCHPATH/exchange-final/continue-wave/$mag/POTCAR
    cp $SCRATCHPATH/exchange-final/WAVECAR $SCRATCHPATH/exchange-final/continue-wave/$mag/WAVECAR
    
    echo 'ISTART = 1' >> $SCRATCHPATH/exchange-final/continue-wave/$mag/INCAR
    echo 'ICHARG = 2' >> $SCRATCHPATH/exchange-final/continue-wave/$mag/INCAR
    
    mpirun -np 1 -wdir $SCRATCHPATH/exchange-final/continue-wave/$mag/ vasp_gpu
    
    cp $SCRATCHPATH/exchange-final/continue-wave/$mag/OUTCAR results/continue-wave/OUTCAR.$mag
    cp $SCRATCHPATH/exchange-final/continue-wave/$mag/OSZICAR results/continue-wave/OSZICAR.$mag
    
    #continue from chgcar
    echo -e "\e[1;31m*** $mag calculation continues from CHGCAR only ***\e[0m"
    mkdir $SCRATCHPATH/exchange-final/continue-chg/$mag
    
    cp resources/INCAR.$mag $SCRATCHPATH/exchange-final/continue-chg/$mag/INCAR
    cp resources/POSCAR.$mag $SCRATCHPATH/exchange-final/continue-chg/$mag/POSCAR
    cp resources/KPOINTS $SCRATCHPATH/exchange-final/continue-chg/$mag/KPOINTS
    cp resources/POTCAR $SCRATCHPATH/exchange-final/continue-chg/$mag/POTCAR
    cp $SCRATCHPATH/exchange-final/CHGCAR $SCRATCHPATH/exchange-final/continue-chg/$mag/CHGCAR
    
    echo 'ISTART = 0' >> $SCRATCHPATH/exchange-final/continue-chg/$mag/INCAR
    echo 'ICHARG = 1' >> $SCRATCHPATH/exchange-final/continue-chg/$mag/INCAR
    
    mpirun -np 1 -wdir $SCRATCHPATH/exchange-final/continue-chg/$mag/ vasp_gpu
    
    cp $SCRATCHPATH/exchange-final/continue-chg/$mag/OUTCAR results/continue-chg/OUTCAR.$mag
    cp $SCRATCHPATH/exchange-final/continue-chg/$mag/OSZICAR results/continue-chg/OSZICAR.$mag
    
    
    #continue from both
    echo -e "\e[1;31m*** $mag calculation continues from both CHGCAR and WAVECAR ***\e[0m"
    mkdir $SCRATCHPATH/exchange-final/continue-both/$mag
    
    cp resources/INCAR.$mag $SCRATCHPATH/exchange-final/continue-both/$mag/INCAR
    cp resources/POSCAR.$mag $SCRATCHPATH/exchange-final/continue-both/$mag/POSCAR
    cp resources/KPOINTS $SCRATCHPATH/exchange-final/continue-both/$mag/KPOINTS
    cp resources/POTCAR $SCRATCHPATH/exchange-final/continue-both/$mag/POTCAR
    cp $SCRATCHPATH/exchange-final/WAVECAR $SCRATCHPATH/exchange-final/continue-both/$mag/WAVECAR
    cp $SCRATCHPATH/exchange-final/CHGCAR $SCRATCHPATH/exchange-final/continue-both/$mag/CHGCAR
    
    echo 'ISTART = 1' >> $SCRATCHPATH/exchange-final/continue-both/$mag/INCAR
    echo 'ICHARG = 1' >> $SCRATCHPATH/exchange-final/continue-both/$mag/INCAR
    
    mpirun -np 1 -wdir $SCRATCHPATH/exchange-final/continue-both/$mag/ vasp_gpu
    
    cp $SCRATCHPATH/exchange-final/continue-both/$mag/OUTCAR results/continue-both/OUTCAR.$mag
    cp $SCRATCHPATH/exchange-final/continue-both/$mag/OSZICAR results/continue-both/OSZICAR.$mag
done


