function [channelMtx, chip, Porog, Period] = generateUWBSignal(infoTRM)
    minLen = 3000; 
    maxLen = 6000; 
    thrVal = 0.25;
    modulationType = 0;
    preambleLen = 1000;
    packetLen = 24;
    pspLen = 32;
    sigAmpl = 1e9;
    % Параметр для построения импульса
    sigAlpha = 3*10^(-22);
    % Длительность импульса
    chipDuration = 500*10^(-12);
    % Шаг по времени
    dt = chipDuration/20;
    % Отсчёты по времени
    t0 = -chipDuration/2 + dt/2 : dt : chipDuration/2 - dt/2;
    % Частота дискретизации
    Fs = 1/dt;
    sigPulse = sigAmpl*t0.*exp(-(t0.^2)/(2*sigAlpha));

    chip = sigPulse(7:13)*10^10;
    sigPulse = sigPulse*10^10;
    l_begin = length(sigPulse);
    sigPulse = [sigPulse sigPulse*0]; %1 нс
    % sigPulse = [sigPulse sigPulse*0 sigPulse*0 sigPulse*0 sigPulse*0]; % 5 нс
    % sigPulse = [sigPulse sigPulse*0];                      % 10 нс
    % sigPulse = [sigPulse sigPulse*0 sigPulse*0 sigPulse*0 sigPulse*0]; % 25 нс
    % sigPulse = [sigPulse sigPulse*0 sigPulse*0 sigPulse*0];        % 100 нс

    Period = length(sigPulse); % период между импульсами

    Eb = sum(sigPulse.^2)*dt;

    Porog = Eb*thrVal;

    figure;
    subplot(2,1,1);
    t_tmp = (0 : dt : (length(sigPulse)/l_begin)*chipDuration-dt);
    plot(Fs*t_tmp,sigPulse)
    title('Signal')
    xlabel('time (nanoseconds)')

    NFFchipDuration = 2^nextpow2(length(sigPulse)); % Next power of 2 from length of y
    Y = fft(sigPulse,NFFchipDuration)/length(sigPulse);
    f = Fs/2*linspace(0,1,NFFchipDuration/2+1);

    % Plot single-sided sigAmpllitude spectrum.
    subplot(2,1,2);
    plot(f,2*abs(Y(1:NFFchipDuration/2+1))/max(2*abs(Y(1:NFFchipDuration/2+1)))) 
    title('Single-Sided sigAmpllitude Spectrum of y(t)')
    xlabel('Frequency (Hz)')
    ylabel('|Y(f)|')
    % Теперь выполняем модуляцию
        Signal_tmp = zeros(preambleLen + packetLen*pspLen , length(sigPulse));
        ind_3 = find(infoTRM > 0);
        ind_4 = find(infoTRM < 0);
        Signal_tmp(ind_3, :) = ones(length(ind_3), 1)*sigPulse; 
        switch modulationType
            case 0
                Signal_tmp(ind_4, :) = ones(length(ind_4), 1)*sigPulse*0;
            case 1
                Signal_tmp(ind_4, :) = ones(length(ind_4), 1)*sigPulse*(-1);
        end
        % Переводим всё в строку
        Signal_tmp2 = reshape(Signal_tmp', 1, size(Signal_tmp, 1)*size(Signal_tmp, 2));

        %%
        % Повторим сигнал через случайный промежуток времени
    %     Signal_tmp3 = [Signal_tmp2 zeros(1, round(1000*rand + 10))...
    %                    Signal_tmp2 zeros(1, round(1000*rand + 10))...
    %                    Signal_tmp2 zeros(1, round(1000*rand + 10))...
    %                    Signal_tmp2];
        Signal_tmp3 = Signal_tmp2;
        Signal = Signal_tmp3;
        Signal = [zeros(1,Period*randi([1 maxLen-minLen])) Signal zeros(1,randi([minLen maxLen]))];
        channelMtx = zeros(32,length(Signal));
%         channelMtx(randi(32),:) = Signal; % есть ли сигнал
            
        SNR = -1;
        u = sqrt(0.5*Fs*Eb/(10^(SNR/10)));
        for ii = 1:32
            noise = [1,1i]*rand(2,length(Signal));
            channelMtx(ii,:) = channelMtx(ii,:) + u*noise;
        end
%         Signal = Signal + sqrt(0.5*Fs*Eb/(10^(SNR/10)))*randn(size(Signal, 1), size(Signal, 2));
    % Signal = Signal + sqrt(Fs*Eb/(10^(SNR/10)))*randn(size(Signal, 1), size(Signal, 2));
%     Signal = awgn(Signal, SNR + 3, 'measured');
    figure;
    plot(abs(Signal));
end