v 20130925 2
C 40000 40000 0 0 0 title-B.sym
C 45800 45700 1 90 0 resistor-2.sym
{
T 45450 46100 5 10 0 0 90 0 1
device=RESISTOR
T 45600 46400 5 10 1 1 180 0 1
refdes=R5
T 45200 46000 5 10 1 1 0 0 1
value=1.5M
}
C 48000 44400 1 180 0 capacitor-1.sym
{
T 47800 43700 5 10 0 0 180 0 1
device=CAPACITOR
T 47200 44300 5 10 1 1 0 0 1
refdes=C3
T 47800 43500 5 10 0 0 180 0 1
symversion=0.1
T 48000 44500 5 10 1 1 180 0 1
value=0.1u
}
C 47600 40300 1 0 0 gnd-1.sym
C 48900 43700 1 0 0 npn-2.sym
{
T 49500 44200 5 10 0 0 0 0 1
device=NPN_TRANSISTOR
T 49300 44100 5 10 1 1 0 0 1
refdes=T2
T 48900 43700 5 10 0 1 0 0 1
value=Vt=26mV,Is=14.06fA,Bf=187.6,Br=4.541
T 49600 43800 5 10 1 1 0 0 1
model-name=BC368
}
C 41000 43500 1 0 0 input-1.sym
{
T 41000 43800 5 10 0 0 0 0 1
device=INPUT
T 41000 43500 5 10 1 1 0 0 1
refdes=IN1
}
C 46500 46600 1 270 1 output-1.sym
{
T 46800 46700 5 10 0 0 270 6 1
device=OUTPUT
T 46500 46800 5 10 1 1 270 6 1
refdes=OUT1
}
C 44000 41500 1 90 0 resistor-2.sym
{
T 43650 41900 5 10 0 0 90 0 1
device=RESISTOR
T 43700 42200 5 10 1 1 180 0 1
refdes=R2
T 43400 41800 5 10 1 1 0 0 1
value=4.7k
}
C 44500 42200 1 90 0 resistor-2.sym
{
T 44150 42600 5 10 0 0 90 0 1
device=RESISTOR
T 44200 43000 5 10 1 1 180 0 1
refdes=R3
T 43900 42500 5 10 1 1 0 0 1
value=120
}
C 46600 46800 1 180 0 capacitor-1.sym
{
T 46400 46100 5 10 0 0 180 0 1
device=CAPACITOR
T 45800 46700 5 10 1 1 0 0 1
refdes=C5
T 46400 45900 5 10 0 0 180 0 1
symversion=0.1
T 46500 46900 5 10 1 1 180 0 1
value=0.1u
}
C 43900 43100 1 0 0 npn-2.sym
{
T 44500 43600 5 10 0 0 0 0 1
device=NPN_TRANSISTOR
T 44300 43600 5 10 1 1 0 0 1
refdes=T1
T 43900 43100 5 10 0 1 0 0 1
value=Vt=26mV,Is=14.06fA,Bf=187.6,Br=4.541
T 44400 43400 5 10 1 1 0 0 1
model-name=BC368
}
C 44500 47200 1 90 0 resistor-2.sym
{
T 44150 47600 5 10 0 0 90 0 1
device=RESISTOR
T 44200 47900 5 10 1 1 180 0 1
refdes=R4
T 43800 47500 5 10 1 1 0 0 1
value=10k
}
C 43900 43700 1 180 0 resistor-2.sym
{
T 43500 43350 5 10 0 0 180 0 1
device=RESISTOR
T 43200 43800 5 10 1 1 0 0 1
refdes=R1
T 43800 43400 5 10 1 1 180 0 1
value=48k
}
C 49400 46800 1 180 0 resistor-2.sym
{
T 49000 46450 5 10 0 0 180 0 1
device=RESISTOR
T 48600 46800 5 10 1 1 0 0 1
refdes=R8
T 49300 47000 5 10 1 1 180 0 1
value=620k
}
C 46900 42000 1 90 0 resistor-2.sym
{
T 46550 42400 5 10 0 0 90 0 1
device=RESISTOR
T 46700 42800 5 10 1 1 180 0 1
refdes=R6
T 46400 42300 5 10 1 1 0 0 1
value=47k
}
C 44500 41900 1 0 1 gnd-1.sym
C 45800 42400 1 90 0 resistor-2.sym
{
T 45450 42800 5 10 0 0 90 0 1
device=RESISTOR
T 46100 43100 5 10 1 1 180 0 1
refdes=RL
T 45800 42600 5 10 1 1 0 0 1
value=60
}
C 47800 40600 1 90 0 resistor-2.sym
{
T 47450 41000 5 10 0 0 90 0 1
device=RESISTOR
T 48100 41300 5 10 1 1 180 0 1
refdes=R7
T 47900 40700 5 10 1 1 0 0 1
value=8.2k
}
C 46700 43600 1 0 1 gnd-1.sym
C 42900 43800 1 180 0 capacitor-1.sym
{
T 42700 43100 5 10 0 0 180 0 1
device=CAPACITOR
T 42100 43700 5 10 1 1 0 0 1
refdes=C1
T 42700 42900 5 10 0 0 180 0 1
symversion=0.1
T 42900 43800 5 10 1 1 180 0 1
value=0.047u
}
C 46500 44800 1 270 1 resistor-variable-2.sym
{
T 47400 45600 5 10 0 1 90 2 1
device=VARIABLE_RESISTOR
T 46250 45300 5 10 1 1 180 6 1
refdes=P1
T 48400 45600 5 10 1 1 180 0 1
value=value=25k,var=Wah
}
C 44200 48100 1 0 0 9V-plus-1.sym
{
T 44200 48100 5 10 0 0 0 0 1
device=POWER
T 44500 48100 5 10 1 1 0 0 1
value=9V
T 44200 48500 5 10 1 1 0 0 1
refdes=Vcc
}
N 43900 42400 43900 43600 4
N 44400 47200 44400 44100 4
C 45600 42400 1 270 0 inductor-1.sym
{
T 46100 42200 5 10 0 0 270 0 1
device=INDUCTOR
T 45800 41700 5 10 1 1 180 8 1
refdes=L1
T 46300 42200 5 10 0 0 270 0 1
symversion=0.1
T 45600 42400 5 10 0 0 270 0 1
value=0.5H
}
N 45700 43300 45700 45700 4
N 45700 43300 46800 43300 4
N 46800 43300 46800 42900 4
{
T 46800 43300 5 10 1 1 0 0 1
netname=V6
}
N 43900 41500 46800 41500 4
N 45700 46600 44400 46600 4
C 47700 43500 1 180 0 capacitor-1.sym
{
T 47500 42800 5 10 0 0 180 0 1
device=CAPACITOR
T 46900 43400 5 10 1 1 0 0 1
refdes=C2
T 47500 42600 5 10 0 0 180 0 1
symversion=0.1
T 47600 43600 5 10 1 1 180 0 1
value=6u
}
C 47700 41700 1 180 0 capacitor-1.sym
{
T 47500 41000 5 10 0 0 180 0 1
device=CAPACITOR
T 46900 41600 5 10 1 1 0 0 1
refdes=C4
T 47500 40800 5 10 0 0 180 0 1
symversion=0.1
T 47800 41800 5 10 1 1 180 0 1
value=0.01u
}
N 48900 44200 48000 44200 4
N 48500 46700 48500 44200 4
N 44400 48100 49400 48100 4
N 49400 44700 49400 48100 4
N 46800 42000 46800 41500 4
N 49400 41500 49400 43700 4
N 47700 41500 49400 41500 4
N 47100 44200 47100 45300 4
C 46700 45700 1 90 0 resistor-2.sym
{
T 46350 46100 5 10 0 0 90 0 1
device=RESISTOR
T 46500 46400 5 10 1 1 180 0 1
refdes=R9
T 46100 46000 5 10 1 1 0 0 1
value=1.5k
}
C 46700 43900 1 90 0 resistor-2.sym
{
T 46350 44300 5 10 0 0 90 0 1
device=RESISTOR
T 46500 44600 5 10 1 1 180 0 1
refdes=R10
T 46100 44200 5 10 1 1 0 0 1
value=1.5k
}
C 48200 43000 1 0 0 gnd-1.sym
N 41800 43600 42000 43600 4
{
T 41800 43600 5 10 1 1 0 0 1
netname=V1
}
N 42900 43600 43000 43600 4
{
T 42900 43600 5 10 1 1 0 0 1
netname=V2
}
N 48300 43300 47700 43300 4