function [I] = ygcr2rgb(ygcr)

T = [65.481 128.553 24.966;...
    -37.797 -74.203 112; ...
    112 -93.786 -18.214];

Tinv = T^-1;
offset = [16;128;128];

T = 255*Tinv;
offset = -Tinv*offset;

Cb = ygcr(:,:,2)/T(2,2) - (T(2,1)/T(2,2))*ygcr(:,:,1) - (T(2,3)/T(2,2))*ygcr(:,:,3) - offset(2,1)/T(2,2);

I = ycbcr2rgb(cat(3,ygcr(:,:,1),Cb,ygcr(:,:,3)));

end

