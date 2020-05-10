clear all; clc; close all;
%% parameters
numWalsh = 5; % ����� ����-�� �����
%% transmit
[infoTRM, preamble, transmitInfo, transmitBits] = generateInfoBits(numWalsh);

%% from other code
[channelMtx, Chip, Porog, Period] = generateUWBSignal(infoTRM);

%%
% ����

% ������� ������ ���� �� ���������� ���������� � ��������� ����������
% �� ������ - ������������������ +1 � -1
% (����� 1 � 0, �� ����� �� ����� ���� ���������� � +1 � -1)
Cors = zeros(32,length(channelMtx(1,:)));
maxs = [];
for ii = 1:32
    Cors(ii,:) = abs(conv(channelMtx(ii,:),fliplr(Chip),'same'));
    maxs = [maxs max(Cors(ii,:))];
end
recSig = zeros(32,length(Cors(1,:)));
receivedSig = zeros(32,length(recSig(1,10:Period:end)));
Cors = Cors./max(maxs);
for ii = 1:32
    recSig(ii,Cors(ii,:) >= 0.3) = 1;
    recSig(ii,Cors(ii,:) < 0.3) = -1;
    receivedSig(ii,:) = recSig(ii, 10:Period:end);
end
figure;
surf(Cors);
title('Cors');

%% receive
preambleRec = 2.*preamble - 1; % ��������� ������������ ��� ��������
Walsh = Generate_Hadamard_Matrix(5);
neededWalsh = Walsh(numWalsh,:);
% ���� ������� � �����
n = 32;
cors = zeros(n, length(receivedSig(1,:)) - 1000);
for ii = 1:n
    for jj = 0:length(cors(1,:))-1
        cors(ii,jj+1) = abs(sum(preambleRec .* receivedSig(ii,(1:1000) + jj)));
        if cors(ii,jj+1) > 300
            col = ii; % ������ �������
            shift = jj; % ������ �����
            break;
        end
    end
end
figure;
surf(cors);
%%
receivedData = receivedSig(col,(1:768) + shift + 1000);
receivedBits = neededWalsh*reshape(receivedData,32,24);
receivedBits(receivedBits > 0) = 1;
receivedBits(receivedBits<=0) = 0;
receivedInfo = crc8(receivedBits);

% dif = abs(sum(infoTRM - receivedSig))
if (~isempty(receivedInfo))
    difference = abs(sum(receivedInfo - transmitInfo))
end
