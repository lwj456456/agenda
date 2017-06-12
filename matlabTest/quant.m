function [bq, eq] = quant(signal,n)

tb = max(signal)-min(signal);
tt = round(signal*2^n/tb);
bq = tt/2^n*tb;
eq = sum(sqrt((signal-bq).^2));
end