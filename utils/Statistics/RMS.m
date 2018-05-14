function res = RMS(X)

res=sqrt(sum(X(:).^2))/numel(X);

% END
end