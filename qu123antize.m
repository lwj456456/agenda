bits=4;

step=1E-6;
x=0:step:1;

xq=round(x*2^bits);
xqn=xq/2^bits;

figure(1);
plot(x,xq);
xlabel('Analog Input');
ylabel('Digital Output');
grid
title(['ADC Test: ', num2str(bits), ' bits']); 

figure(2);
plot(x,xqn);
xlabel('Analog Input');
ylabel('Nomalized Digital Output');
grid
title(['ADC Test: ', num2str(bits), ' bits']); 
