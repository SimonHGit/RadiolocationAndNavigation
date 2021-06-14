function [ maximum, index ] = findmax( A )
%findmax find maximum in an 2D-Matrix
%   Detailed explanation goes here
    [index(1),index(2)] = find(ismember(A, max(A(:))));
    maximum = A(index(1),index(2));
end

