obr = zeros(10,1);
cbr = zeros(10,1);
rbr = zeros(10,1);
[obr(1),cbr(1),rbr(1),~] = UNIQUECompression(imread('I01.bmp'));
[obr(2),cbr(2),rbr(2),~] = UNIQUECompression(imread('I02.bmp'));
[obr(3),cbr(3),rbr(3),~] = UNIQUECompression(imread('I03.bmp'));
[obr(4),cbr(4),rbr(4),~] = UNIQUECompression(imread('I04.bmp'));
[obr(5),cbr(5),rbr(5),~] = UNIQUECompression(imread('I05.bmp'));
[obr(6),cbr(6),rbr(6),~] = UNIQUECompression(imread('I06.bmp'));
[obr(7),cbr(7),rbr(7),~] = UNIQUECompression(imread('I07.bmp'));
[obr(8),cbr(8),rbr(8),~] = UNIQUECompression(imread('I08.bmp'));
[obr(9),cbr(9),rbr(9),~] = UNIQUECompression(imread('I09.bmp'));
[obr(10),cbr(10),rbr(10),~] = UNIQUECompression(imread('I10.bmp'));

fprintf('\n\n%11s%11s\n','OBR','CBR','RBR');
fprintf(' %10.3f %10.3f %10.3f\n',[obr,rbr,cbr].');
fprintf('\n\n')