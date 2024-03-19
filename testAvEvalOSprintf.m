clear all
clear root
clc
pause(0.2)
s1=1;
s2=2;
s3=3;
s4=4;
s5=5;
y=[];
for i=1:5
    if eval(sprintf('s%d',i))==i
        y(end + 1)=i;
    end
end
y
d1=1;
eval(sprintf('d%d',1))
num2str(sprintf('d%d',1))=2;
d1;

