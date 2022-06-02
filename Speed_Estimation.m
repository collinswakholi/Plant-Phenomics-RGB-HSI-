hvel = 2000;
lvel = round(0.1*hvel);
accn = 300;
            end_pos = 0; %35000
%             end_pos = 35000;
% 
kk = 1;

Res = MyArcus.setParams(end_pos,lvel,hvel,accn);
while kk > 0
    out = MyArcus.IsBusy;
    if out == 1
        break;
    end
end
    
tic
while kk >0
    out = MyArcus.IsBusy;
    if out==0
        kk = 0;
        tt1 = toc
        break;
    end
    kk = kk +1;
end