function y_interp = cos_interp(y1,y2,mu)
    mu2 = (1-cos(mu*pi))/2;
    y_interp = (y1*(1-mu2)+y2*mu2);
end