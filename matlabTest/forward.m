function [b_l_d,b_h_d,grp] = forward(lpt,hpt,b_l,f_delay,grp)

b_l_t=  conv(lpt,b_l);
b_l_d= b_l_t(1:2:end);
b_h_t = conv(hpt,b_l);
b_h_d= b_h_t(1:2:end);
grp = (grp+f_delay)/2;
end
%test