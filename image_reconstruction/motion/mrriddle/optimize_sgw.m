function c2 = optimize_sgw(d,M,c1)
% Optimize min_{c2} ||SUM_r=1_R( e^(-c_2*d_r)) - Mpi ||^2 
% M = matrix size
% d = list of respiratory distances

% Exhaustive search
sgw=0:.001:5;

for n=1:numel(sgw)
    score(:,n)=exp(-sgw(n).*(abs(d)-c1));
    score(find(abs(d)<c1),n)=1;        
end
score=abs(M*pi/2-sum(score,1));

[~,minpos]=min(score);
c2=sgw(minpos);

% END

end
