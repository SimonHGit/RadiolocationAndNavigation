function [ integer_scalar ] = logical2dec( logic_vec , varargin )
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
    if nargin == 2
        if varargin{1} == '2s'
            switch logic_vec(1)
                case true
                    logic_vec = logic_vec(2:end);
                    pot = 2.^(length(logic_vec)-1:-1:0);
                    integer_scalar = pot(1)*2 - sum(logic_vec .* pot) ;
                    integer_scalar = -integer_scalar;  
                    
                case false
                    logic_vec = logic_vec(2:end);
                    pot = 2.^(length(logic_vec)-1:-1:0);
                    integer_scalar = sum(logic_vec .* pot);  
                otherwise
                    error('wrong type')
            end
        end
    else
        pot = 2.^(length(logic_vec)-1:-1:0);
        integer_scalar = sum(logic_vec .* pot);  
    end



end

