%% input mp3 file(32K)
[aud32K, fs2]=audioread('Goblin_32K.mp3');

%% sampling rate conversion part
lpt_96K = designfilt('lowpassfir','PassbandFrequency',1/3-0.05,...
    'StopbandFrequency',1/3+0.05,'PassbandRipple',0.5,...
    'StopBandAttenuation',40,'DesignMethod','equiripple');
lpt_24K = designfilt('lowpassfir','PassbandFrequency',1/4-0.05,...
    'StopbandFrequency',1/4+0.05,'PassbandRipple',0.5,...
    'StopBandAttenuation',40,'DesignMethod','equiripple');
% 32K->96K
aud96K = zeros(2,length(aud32K)*3-1);
aud96K(1,1:3:end) = aud32K(1:end,1);
aud96K(2,1:3:end) = aud32K(1:end,2);
aud96K_F = [conv(lpt_96K.Coefficients,aud96K(1,:)); conv(lpt_96K.Coefficients,aud96K(2,:))];

%96K->24K
aud96K_FF = [conv(lpt_24K.Coefficients,aud96K_F(1,:));conv(lpt_24K.Coefficients,aud96K_F(2,:))];
aud24K = aud96K_FF(:,1:4:end);
%sound(aud24K, fs2*3/4);

%% subband coding 

lpt = designfilt('lowpassfir', 'FilterOrder', 40, 'PassbandFrequency', ...
                 1/2-0.05, 'StopbandFrequency', 1/2+0.05, ...
                 'DesignMethod', 'equiripple');
             
hpt = -lpt.Coefficients;
delay = (length(hpt)-1)/2;
hpt(delay+1) = hpt(delay+1)+1;

% channel 1

[band1_l_d,band1_h_d,grp1] = forward(lpt.Coefficients,hpt,aud24K(1,:),delay,0);
[band2_l_d,band2_h_d,grp2] = forward(lpt.Coefficients,hpt,band1_l_d,delay,grp1);
[band3_l_d,band3_h_d,grp3] = forward(lpt.Coefficients,hpt,band2_l_d,delay,grp2);
[band4_l_d,band4_h_d,grp4] = forward(lpt.Coefficients,hpt,band3_l_d,delay,grp3);
[band5_l_d,band5_h_d,grp5] = forward(lpt.Coefficients,hpt,band4_l_d,delay,grp4);

% channel 2

[band1_l_d2,band1_h_d2,grp1] = forward(lpt.Coefficients,hpt,aud24K(2,:),delay,0);
[band2_l_d2,band2_h_d2,grp2] = forward(lpt.Coefficients,hpt,band1_l_d2,delay,grp1);
[band3_l_d2,band3_h_d2,grp3] = forward(lpt.Coefficients,hpt,band2_l_d2,delay,grp2);
[band4_l_d2,band4_h_d2,grp4] = forward(lpt.Coefficients,hpt,band3_l_d2,delay,grp3);
[band5_l_d2,band5_h_d2,grp5] = forward(lpt.Coefficients,hpt,band4_l_d2,delay,grp4);

%% quantization    
% bit validation
tt= 1;
best = 10000;
for n1 =8:20
    sum = n1;
    for n2=5:20
        sum =sum+ n2;
        for n3=5:20
            sum = sum+n3;
            for n4= 2:15
                sum = sum+n4;
                if sum > 52
                sum = sum-n4;
                break;
                end
                for n5 = 0:13
                    sum = sum+n5;
                    if sum > 52
                    sum = sum-n5;
                    break;
                    end
                    for n6 = 0:6
                        sum = sum+n6;
                        if sum == 52
                           [s1, eq1] = quant(band1_h_d,n6);
                            [s2, eq2] = quant(band2_h_d,n5);
                            [s3, eq3] = quant(band3_h_d,n4);
                            [s4, eq4] = quant(band4_h_d,n3);
                            [s5, eq5] = quant(band5_h_d,n2);
                            [s6, eq6] = quant(band5_l_d,n1);
                            eq = eq6+eq1+eq2+eq3+eq4+eq5;
                            if eq<best
                            best = eq;
                            b1 = n1;
                            b2 = n2;
                            b3 = n3;
                            b4 = n4;
                            b5 = n5;
                            b6 = n6;
                            end
                        else
                            sum = sum-n6;
                            break;
                         end
                        sum = sum-n6;
                    end
                    sum = sum-n5;    
                end
                sum = sum-n4;
            end
            sum = sum-n3;
        end
        sum =sum- n2;
    end
end
disp('bit validation end');
%% best bit for Error minimization
b1 = 12;
b2 = 10;
b3 = 10;
b4 = 10;
b5 =10;
b6 =0;
% channel 1
[band1_h_d_q, eq1] = quant(band1_h_d,b6);
[band2_h_d_q, eq2] = quant(band2_h_d,b5);
[band3_h_d_q, eq3] = quant(band3_h_d,b4);
[band4_h_d_q, eq4] = quant(band4_h_d,b3);
[band5_h_d_q, eq5] = quant(band5_h_d,b2);
[band5_l_d_q, eq6] = quant(band5_l_d,b1);
% channe 2 
[band1_h_d2_q, teq1] = quant(band1_h_d2,b6);
[band2_h_d2_q, teq2] = quant(band2_h_d2,b5);
[band3_h_d2_q, teq3] = quant(band3_h_d2,b4);
[band4_h_d2_q, teq4] = quant(band4_h_d2,b3);
[band5_h_d2_q, teq5] = quant(band5_h_d2,b2);
[band5_l_d2_q, teq6] = quant(band5_l_d2,b1);

%% back

% channel 1
bband5_rt = backward(lpt.Coefficients,hpt, band5_l_d_q,band5_h_d_q,delay,grp5);
bband4_rt = backward(lpt.Coefficients,hpt, bband5_rt,band4_h_d_q,delay,grp4);
bband3_rt = backward(lpt.Coefficients,hpt, bband4_rt,band3_h_d_q,delay,grp3);
bband2_rt = backward(lpt.Coefficients,hpt, bband3_rt,band2_h_d_q,delay,grp2);
bband1_rt = backward(lpt.Coefficients,hpt, bband2_rt,band1_h_d_q,delay,grp1);

% channel 2
bband5_rt2 = backward(lpt.Coefficients,hpt, band5_l_d2_q,band5_h_d2_q,delay,grp5);
bband4_rt2 = backward(lpt.Coefficients,hpt, bband5_rt2,band4_h_d2_q,delay,grp4);
bband3_rt2 = backward(lpt.Coefficients,hpt, bband4_rt2,band3_h_d2_q,delay,grp3);
bband2_rt2 = backward(lpt.Coefficients,hpt, bband3_rt2,band2_h_d2_q,delay,grp2);
bband1_rt2 = backward(lpt.Coefficients,hpt, bband2_rt2,band1_h_d2_q,delay,grp1);

result = [bband1_rt;bband1_rt2];
sound(result, fs2*3/4);

