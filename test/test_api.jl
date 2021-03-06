#
# This file is part of the YAActL.jl Julia package, MIT license
#
# Paul Bayer, 2020
#
using YAActL, Test

t = Ref{Task}()                # this is for debugging
lp = LinkParams(taskref=t)

arg = YAActL.Args(1, 2, c=3, d=4)
@test arg.args == (1, 2)
@test arg.kwargs == pairs((c=3, d=4))

a = b = c = d = 1
e = f = 2

incx(x, by; y=0, z=0) = x+y+z + by
subx(x, y, sub; z=0) = x+y+z - sub

A = Actor(lp, incx, a, y=b, z=c)
sleep(0.1)
@test info(A) == :runnable

# test diag and actor startup, become! (implicitly)
act = YAActL.diag!(A)
sleep(0.1)
@test act.dsp == full
@test act.sta == nothing
@test act.bhv.f == incx
@test act.bhv.args == (1,)
@test act.bhv.kwargs == pairs((y=1,z=1))

# test explicitly become!
become!(A, subx, a, b, z=c)
sleep(0.1)
@test act.bhv.f == subx
@test act.bhv.args == (1,1) 
@test act.bhv.kwargs == pairs((z=1,))

# test set!
set!(A, state)
sleep(0.1)
@test act.dsp == state

# test update!
update!(A, (1, 2, 3))
sleep(0.1)
@test act.sta == (1,2,3)
update!(A, Args(2,3, x=1, y=2), s=:arg)
sleep(0.1)
@test act.bhv.args == (2,3)
@test act.bhv.kwargs == pairs((x=1,y=2,z=1))

# test query!
@test query!(A) == (1,2,3)
@test query!(A, :res) == nothing
@test query!(A, :bhv) == subx
@test query!(A, :dsp) == state

# test call!
become!(A, incx, a, y=b, z=c)
set!(A, full)
@test call!(A, 1) == 4
@test query!(A, :res) == 4
@test query!(A) == (1,2,3)
set!(A, state)
update!(A, 1)
update!(A, Args(y=2,z=2), s=:arg)
@test call!(A, 2) == 7
@test query!(A) == 7
@test query!(A, :res) == 7

# test cast!
update!(A, 2)
update!(A, Args(y=1,z=1), s=:arg)
cast!(A, 2)
@test query!(A) == 6
@test query!(A, :res) == 6
set!(A, full)
update!(A, Args(a, y=3,z=3), s=:arg)
cast!(A, 3)
@test query!(A, :res) == 10
@test query!(A) == 6

# test exec!
@test exec!(A, Func(cos, 2pi)) == 1

# test exit!
exit!(A)
sleep(0.1)
@test info(A).state == :closed
