function [Quotient, Remainder] = Polynom_Division(Dividend, Denominator)
% Функция выполняет деление полиномов при этом
% Dividend = Quotient * Denominator + Remainder.
%
% Все переменные – массивы-строки, содержащие значения коэффициентов
% стоящих при степенях полиномов, при этом первый по порядку элемент
% соответствует коэффициенту при старшей степени полинома.
%
% Входные переменные:
% Dividend - делимый полином;
% Denominator – полином-делитель;
%
% Выходные переменные:
% Quotient - полином-частное от деления;
% Remainder - полином-остаток от деления.
%
% Пример: Dividend = x^4 + x^3 + 1 = [1, 1, 0, 0, 1]
% Denominator = x^2 + 1 = [1, 0, 1]
% Quotient = x^2 + x + 1 = [1, 1, 1]
% Remainder = x = [1, 0]
Quotient=[];
while (length(Dividend)>=length(Denominator))
    if (Dividend(1)==1)
        rzn = [Denominator zeros(1,length(Dividend)-length(Denominator))];
        Dividend = Dividend - rzn;
        Dividend(Dividend<0)=1;
        Dividend=Dividend(2:end);
        Quotient=[Quotient 1];
    else
        Dividend=Dividend(2:end);
        Quotient=[Quotient 0];
    end
end
Remainder=Dividend;
end