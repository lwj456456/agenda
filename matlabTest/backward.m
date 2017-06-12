function rt = backward(lpt,hpt,b_l,b_h,f_delay,grp)

bb_l = zeros(1,length(b_l)*2-1);
bb_l(1:2:end) = b_l(1:end);
bb_l_f = conv(lpt,bb_l);
grp_b_l = f_delay;

bb_h = zeros(1,length(b_h)*2-1);
bb_h(1:2:end) = b_h(1:end);
bb_h_f = conv(hpt,bb_h);
grp_b_h = grp*2+f_delay;

len = length(bb_h_f)-grp_b_h;
rt = bb_h_f(grp_b_h+1:end)+bb_l_f(grp_b_l+1:len+grp_b_l);
end