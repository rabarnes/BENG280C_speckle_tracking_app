clear; clc;

a = [1 1; 2 2; 3 3; 4 4];
a = cat(3,a,2*a,3*a,4*a,5*a,6*a,7*a);

b = a.^2;
c = sum(b,2);
d = mean(c,1);