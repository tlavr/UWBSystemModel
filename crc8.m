function outData = crc8(inData)
    outData = inData(1:length(inData) - 8);
%     crc = fliplr(inData(length(inData) - 8 + 1:length(inData)));
%     inData=[outData crc];
    den = [1 1 0 0 1 1 0 1 1];
    [Q, R] = Polynom_Division(inData, den);
    R=cumsum(R);
    if (R(end)~=0)
       outData=[];
    end   
end